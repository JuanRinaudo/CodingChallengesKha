package shaderChallenges;

import kha.Image;
import kha.Framebuffer;
import kha.Color;
import kha.Shaders;

import kext.AppState;
import kext.Application;

import kext.g4basics.BasicMesh;
import kext.g4basics.BasicPipeline;

import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;

import kha.math.Vector3;
import kha.math.FastVector4;

import utils.DemoMeshes;
import utils.ZUIUtils;

import zui.Id;

class TextureCutoffMeshShader extends AppState {
	private static inline var CANVAS_WIDTH:Int = 1200;
	private static inline var CANVAS_HEIGHT:Int = 800;
	private static inline var NAME:String = "Texture Cutoff Mesh Shader";

	private var pipeline:BasicPipeline;
	private var mesh:BasicMesh;
	private var fadeTexture:Image;
	private var textureSize:Int = 8;

	private var timeAnimation:Bool = true;
	private var timeMultiplier:Float = 1;
	private var cuttoffValue:Float = 0;
	private var filter:TextureFilter = TextureFilter.LinearFilter;

	private var meshRotation:Vector3;
	private var meshScale:Vector3;
	
	private var lightDirection:FastVector4;
	private var lightColor:FastVector4;
	private var ambientColor:FastVector4;

	private var locationCutoffValue:ConstantLocation;
	private var locationLightDirection:ConstantLocation;
	private var locationLightColor:ConstantLocation;
	private var locationAmbientColor:ConstantLocation;

	public static function initApplication():Application {
		return new Application(
			{title: TextureCutoffMeshShader.NAME, width: TextureCutoffMeshShader.CANVAS_WIDTH, height: TextureCutoffMeshShader.CANVAS_HEIGHT},
			{initState: TextureCutoffMeshShader, defaultFontName: "KenPixel"}
		);
	}

	public function new() {
		super();

		pipeline = new BasicPipeline(Shaders.directionalLighting_vert, Shaders.textureCutoffMesh_frag);
		pipeline.orthogonal(5, CANVAS_WIDTH / CANVAS_HEIGHT);
		pipeline.compile();

		locationCutoffValue = pipeline.getConstantLocation("CUTOFF_VALUE");
		locationLightDirection = pipeline.getConstantLocation("LIGHT_DIRECTION");
		locationLightColor = pipeline.getConstantLocation("LIGHT_COLOR");
		locationAmbientColor = pipeline.getConstantLocation("AMBIENT_COLOR");

		DemoMeshes.init(pipeline.vertexStructure, Color.White);
		mesh = DemoMeshes.CUBE_OBJ;

		meshScale = new Vector3(1, 1, 1);
		meshRotation = new Vector3(0, 0, 0);
		
		lightDirection = new FastVector4(1, 1, 0.5, 0);
		lightColor = new FastVector4(1, 1, 1, 1);
		ambientColor = new FastVector4(.2, .2, .2, 1);

		createTexture();
	}

	override public function update(delta:Float) {
		mesh.setRotation(meshRotation);
		mesh.setSize(meshScale);

		if(timeAnimation) {
			cuttoffValue = Math.abs(Math.sin(Application.time * timeMultiplier));
		}
	}

	override public function render(backbuffer:Image) {
		renderMesh(backbuffer);
	}

	private inline function renderMesh(backbuffer:Image) {
		beginAndClear(backbuffer, Color.Black);

		backbuffer.g4.setPipeline(pipeline);
		backbuffer.g4.setMatrix(pipeline.locationMVPMatrix, pipeline.getMVPMatrix(mesh.modelMatrix));
		backbuffer.g4.setMatrix3(pipeline.locationNormalMatrix, pipeline.getNormalMatrix(mesh.modelMatrix));
		backbuffer.g4.setFloat(locationCutoffValue, cuttoffValue);
		backbuffer.g4.setVector4(locationLightDirection, pipeline.camera.viewMatrix.multvec(lightDirection));
		backbuffer.g4.setVector4(locationLightColor, lightColor);
		backbuffer.g4.setVector4(locationAmbientColor, ambientColor);

		backbuffer.g4.setTexture(pipeline.textureUnit, fadeTexture);
		backbuffer.g4.setTextureParameters(pipeline.textureUnit, TextureAddressing.Repeat, TextureAddressing.Repeat,
			filter, filter, MipMapFilter.NoMipFilter);

		mesh.setBufferMesh(backbuffer);
		backbuffer.g4.drawIndexedVertices();

		backbuffer.g4.end();
	}

	var initialSeedValue:Int = 123456789;
	var seed:Int = 123456789;
	private inline static var a = 1103515245;
	private inline static var c = 12345;
	private inline static var m = 4294967296;
	private function random():Float
	{
		seed = Math.floor((a * seed + c) % m);
		return seed / m;
	}

	private function createTexture() {
		fadeTexture = Image.createRenderTarget(textureSize, textureSize, null, null, 1);
		fadeTexture.g2.begin(true, Color.Black);
		for(x in 0...textureSize) {
			for(y in 0...textureSize) {
				var value:Float = Math.min(random() + .0, 1);
				fadeTexture.g2.color = Color.fromFloats(value, 0, 0, 1);
				fadeTexture.g2.fillRect(x, y, 1, 1);
			}
		}
		fadeTexture.g2.end();
	}

	override public function renderFramebuffer(framebuffer:Framebuffer) {
		var createTextureClicked:Bool = false;
		ui.begin(framebuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
				if(ui.panel(Id.handle({selected: true}), "General")) {
					ZUIUtils.vector3Sliders(ui, Id.handle(), meshScale, "Mesh Scale", 0.1, 5, 10);
					ZUIUtils.vector3Sliders(ui, Id.handle(), meshRotation, "Mesh Rotation", 0, Math.PI * 2, 100);
				}
				if(ui.panel(Id.handle({selected: true}), "Cuttoff Parameters")) {
					textureSize = Math.floor(ui.slider(Id.handle({value: textureSize}), "Texture Size", 0, 256, true, 1, true));
					if(ui.button("Create Texture")) { createTextureClicked = true; }
					ui.text('Random seed $initialSeedValue');
					if(ui.button("Randomize Seed")) { initialSeedValue = Math.floor(Math.random() * m); createTextureClicked = true; }
					timeAnimation = ui.check(Id.handle({selected: true}), "Time / Manual");
					if(timeAnimation) {
						ui.text('Cuffout value: $cuttoffValue');
						timeMultiplier = ui.slider(Id.handle({value: timeMultiplier}), "Time Multiplier", -3, 3, true, 100, true);
					} else {
						cuttoffValue = ui.slider(Id.handle({value: cuttoffValue}), "Cuttoff Value", 0, 1, true, 100, true);
					}
					ui.text("Filters");
					if(ui.button("Point Filter")) { filter = TextureFilter.PointFilter; createTextureClicked = true; }
					if(ui.button("Linear Filter")) { filter = TextureFilter.LinearFilter; createTextureClicked = true; }
					if(ui.button("Anisotropic Filter")) { filter = TextureFilter.AnisotropicFilter; createTextureClicked = true; }
				}
				mesh = ZUIUtils.meshSelector(ui, Id.handle(), mesh);
				ZUIUtils.lightingParameters(ui, Id.handle(), lightDirection, lightColor, ambientColor, false);
			}
		}
		ui.end();

		if(createTextureClicked) {
			seed = initialSeedValue;
			createTexture();
		}
	}

}