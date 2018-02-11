package kext;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Image;
import kha.System;
import kha.Scheduler;
import kha.System.SystemOptions;
import kha.Scaler;
import kha.Shaders;

import kha.math.FastVector2;

import kext.g4basics.BasicPipeline;

import kext.input.GamepadInput;
import kext.input.KeyboardInput;
import kext.input.MouseInput;
import kext.input.TouchInput;

import kext.events.ApplicationStartEvent;
import kext.events.ApplicationEndEvent;
import kext.events.LoadCompleteEvent;

import kha.graphics4.PipelineState;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.FragmentShader;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;

import kext.debug.Debug;

using kext.UniformType;

typedef ApplicationOptions = {
	?updateStart:Float,
	?updatePeriod:Float,
	initState:Class<AppState>,
	?stateArguments:Array<Dynamic>
}

typedef PostProcessingUniform = {
	type:UniformType,
	?location:ConstantLocation,
	?textureUnit:TextureUnit,
	value:Dynamic
}

class Application {

	private var sysOptions:SystemOptions;
	private var options:ApplicationOptions;

	private var currentState:AppState;

	public static var gamepad:GamepadInput;
	public static var keyboard:KeyboardInput;
	public static var mouse:MouseInput;
	public static var touch:TouchInput;

	public static var backbuffer:Image;
	public static var postbackbuffer:Image;

	public static var onApplicationStart:Signal<ApplicationStartEvent> = new Signal();
	public static var onApplicationEnd:Signal<ApplicationEndEvent> = new Signal();
	public static var onLoadComplete:Signal<LoadCompleteEvent> = new Signal();

	public static var time:Float = 0;
	public static var deltaTime(default, null):Float = 0;

	private static var nextID:UInt = 0;

	private static var postProcessingPipelines:Map<FragmentShader, BasicPipeline>;
	private static var postProcessingUniforms:Map<FragmentShader, Map<String, PostProcessingUniform>>;

	private var debug:Debug;

	public function new(systemOptions:SystemOptions, applicationOptions:ApplicationOptions) {
		sysOptions = systemOptions;
		options = defaultApplicationOptions(applicationOptions);
		
		deltaTime = options.updatePeriod;

		#if js
		var game = js.Browser.document.getElementById("game");
		game.style.width = systemOptions.width + "px";
		game.style.height = systemOptions.height + "px";
		#end

		System.init(systemOptions, onInit);
	}

	private function defaultApplicationOptions(applicationOptions:ApplicationOptions) {
		if(applicationOptions.updateStart == null) { applicationOptions.updateStart = 0; }
		if(applicationOptions.updatePeriod == null) { applicationOptions.updatePeriod = 1 / 60; }
		if(applicationOptions.stateArguments == null) { applicationOptions.stateArguments = []; }
		return applicationOptions;
	}

	private function onInit() {
		debug = new Debug();

		gamepad = new GamepadInput();
		keyboard = new KeyboardInput();
		mouse = new MouseInput();
		touch = new TouchInput();

		backbuffer = Image.createRenderTarget(sysOptions.width, sysOptions.height, TextureFormat.RGBA32, DepthStencilFormat.DepthOnly);
		postbackbuffer = Image.createRenderTarget(sysOptions.width, sysOptions.height, TextureFormat.RGBA32, DepthStencilFormat.DepthOnly);

		postProcessingPipelines = new Map();
		postProcessingUniforms = new Map();
		setPostProcessingShader(Shaders.painter_image_frag);

		System.notifyOnRender(renderPass);

		Assets.loadEverything(loadCompleteHandler);

		onApplicationStart.dispatch();
	}

	private function loadCompleteHandler() {
		Scheduler.addTimeTask(updatePass, options.updateStart, options.updatePeriod);
		
		currentState = Type.createInstance(options.initState, options.stateArguments);
	
		onLoadComplete.dispatch();
	}

	private function renderPass(framebuffer:Framebuffer) {
		if(currentState != null) {
			currentState.render(backbuffer);
		}
		
		var buffer1:Image = postbackbuffer;
		var buffer2:Image = backbuffer;
	
		for(pipeline in postProcessingPipelines) {
			buffer1.g2.pipeline = pipeline;
			buffer1.g2.begin(false);
			setUniformParameters(pipeline, buffer1);
			Scaler.scale(buffer2, buffer1, System.screenRotation);
			buffer1.g2.end();
			if(buffer1 == backbuffer) { buffer1 = postbackbuffer; buffer2 = backbuffer; }
			else { buffer1 = backbuffer; buffer2 = postbackbuffer; }
		}
		backbuffer.g2.pipeline = null;
		backbuffer.g2.begin(false);
		Scaler.scale(buffer2, backbuffer, System.screenRotation);
		backbuffer.g2.end();

		if(currentState != null) {
			currentState.renderUI(backbuffer);
		}
		debug.render(backbuffer);

		framebuffer.g2.begin(true);
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	private inline function setUniformParameters(pipeline:PipelineState, buffer:Image) {
		var uniforms:Map<String, PostProcessingUniform> = postProcessingUniforms.get(pipeline.fragmentShader);
		buffer.g4.setVector2(pipeline.getConstantLocation("RENDER_SIZE"), new FastVector2(sysOptions.width, sysOptions.height));
		for(uniform in uniforms) {
			switch(uniform.type) {
				case BOOL:
					buffer.g4.setBool(uniform.location, uniform.value);
				case FLOAT:
					buffer.g4.setFloat(uniform.location, uniform.value);
				// case FLOAT2:
				// 	buffer.g4.setFloat(uniform.location, uniform.value); TODO		
				// case FLOAT3:
				// 	buffer.g4.setFloat(uniform.location, uniform.value); TODO
				// case FLOAT4:
				// 	buffer.g4.setFloat(uniform.location, uniform.value); TODO
				case INT:
					buffer.g4.setInt(uniform.location, uniform.value);
				case MATRIX3:
					buffer.g4.setMatrix3(uniform.location, uniform.value);
				case MATRIX:
					buffer.g4.setMatrix(uniform.location, uniform.value);
				case VECTOR2:
					buffer.g4.setVector2(uniform.location, uniform.value);
				case VECTOR3:
					buffer.g4.setVector3(uniform.location, uniform.value);
				case VECTOR4:
					buffer.g4.setVector4(uniform.location, uniform.value);
				case CUBEMAP:
					buffer.g4.setCubeMap(uniform.textureUnit, uniform.value);
				case TEXTURE:
					buffer.g4.setTexture(uniform.textureUnit, uniform.value);
				case IMAGETEXTURE:
					buffer.g4.setImageTexture(uniform.textureUnit, uniform.value);
				case VIDEOTEXTURE:
					buffer.g4.setVideoTexture(uniform.textureUnit, uniform.value);
			}
		}
	}

	private function updatePass() {
		if(currentState != null) {
			time += options.updatePeriod;
			currentState.update(options.updatePeriod);
		}

		debug.update(options.updatePeriod);
	}

	public static function getNextID():UInt {
		return nextID++;
	}

	public static function setPostProcessingShader(shader:FragmentShader) {
		var pipeline:BasicPipeline = new BasicPipeline(Shaders.painter_image_vert, shader);
		pipeline.compile();
		postProcessingPipelines.set(shader, pipeline);
		postProcessingUniforms.set(shader, new Map());
	}

	public static function removePostProcessingShader(shader:FragmentShader) {
		postProcessingPipelines.remove(shader);
		postProcessingUniforms.remove(shader);
	}

	public static inline function setPostProcesingConstantLocation(shader:FragmentShader, type:UniformType, name:String, value:Dynamic) {
		var pipeline:BasicPipeline = postProcessingPipelines.get(shader);
		if(pipeline == null) { trace('No pipeline found for the current post processing uniform: $name'); return; }
		
		var uniforms:Map<String, PostProcessingUniform> = postProcessingUniforms.get(shader);
		uniforms.set(name, {type: type, location: pipeline.getConstantLocation(name), value: value});
	}
	
	public static inline function setPostProcesingTextureUnit(shader:FragmentShader, type:UniformType, name:String, value:Dynamic) {
		var pipeline:BasicPipeline = postProcessingPipelines.get(shader);
		if(pipeline == null) { trace('No pipeline found for the current post processing uniform: $name'); return; }
		var uniforms:Map<String, PostProcessingUniform> = postProcessingUniforms.get(shader);
		uniforms.set(name, {type: type, textureUnit: pipeline.getTextureUnit(name), value: value});
	}

}