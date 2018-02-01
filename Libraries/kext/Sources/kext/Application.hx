package kext;

import kha.Image;
import kha.Assets;
import kha.System;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System.SystemOptions;
import kha.Scaler;

import kext.input.GamepadInput;
import kext.input.KeyboardInput;
import kext.input.MouseInput;
import kext.input.TouchInput;

import kext.events.ApplicationStartEvent;
import kext.events.ApplicationEndEvent;
import kext.events.LoadCompleteEvent;

import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;

#if debug
import kext.debug.Debug;
#end

typedef ApplicationOptions = {
	?updateStart:Float,
	?updatePeriod:Float,
	initState:Class<AppState>,
	?stateArguments:Array<Dynamic>
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

	public static var onApplicationStart:Signal<ApplicationStartEvent> = new Signal();
	public static var onApplicationEnd:Signal<ApplicationEndEvent> = new Signal();
	public static var onLoadComplete:Signal<LoadCompleteEvent> = new Signal();

	public static var time:Float = 0;
	public static var deltaTime(default, null):Float = 0;

	private static var nextID:UInt = 0;

	#if debug
	private var debug:Debug;
	#end

	public function new(systemOptions:SystemOptions, applicationOptions:ApplicationOptions) {
		sysOptions = systemOptions;
		options = defaultApplicationOptions(applicationOptions);
		
		deltaTime = options.updatePeriod;

		System.init(systemOptions, onInit);
	}

	private function defaultApplicationOptions(applicationOptions:ApplicationOptions) {
		if(applicationOptions.updateStart == null) { applicationOptions.updateStart = 0; }
		if(applicationOptions.updatePeriod == null) { applicationOptions.updatePeriod = 1 / 60; }
		if(applicationOptions.stateArguments == null) { applicationOptions.stateArguments = []; }
		return applicationOptions;
	}

	private function onInit() {
		#if debug
		debug = new Debug();
		#end

		gamepad = new GamepadInput();
		keyboard = new KeyboardInput();
		mouse = new MouseInput();
		touch = new TouchInput();

		backbuffer = Image.createRenderTarget(sysOptions.width, sysOptions.height, TextureFormat.RGBA32, DepthStencilFormat.DepthOnly);

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
		
		#if debug
		debug.render(backbuffer);
		#end

		framebuffer.g2.begin();
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	private function updatePass() {
		if(currentState != null) {
			time += options.updatePeriod;
			currentState.update(options.updatePeriod);
		}

		#if debug
		debug.update(options.updatePeriod);
		#end
	}

	public static function getNextID():UInt {
		return nextID++;
	}

}