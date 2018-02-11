package shaderChallenges;

import kha.Assets;
import kha.Shaders;
import kha.Image;
import kha.Color;

import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;

import kext.Application;
import kext.AppState;

import kext.g4basics.BasicMesh;
import kext.g4basics.BasicPipeline;
import kext.loaders.OBJMeshLoader;

import kha.math.FastMatrix4;

import zui.Zui;
import zui.Zui.Handle;
import zui.Id;

class TransitionShaders extends AppState {
	private static inline var CANVAS_WIDTH:Int = 800;
	private static inline var CANVAS_HEIGHT:Int = 800;
	private static inline var NAME:String = "Transition Shaders";

	private var pipeline:BasicPipeline;
	private var quad:BasicMesh;

	private var locationTransition:ConstantLocation;
	private var locationTilesX:ConstantLocation;
	private var locationTilesY:ConstantLocation;

	private var fadeTexture:Image;

	private var screenMatrix:FastMatrix4;

	private var time:Float = 0;
	private var transition:Float = 0;
	private var tilesX:Int = 1;
	private var tilesY:Int = 1;
	private var transitionDelta:Float = 0.5;

    public static function initApplication():Application {
		return new Application(
			{title: TransitionShaders.NAME, width: TransitionShaders.CANVAS_WIDTH, height: TransitionShaders.CANVAS_HEIGHT},
			{initState: TransitionShaders}
		);
	}

	public function new() {
		super();

		pipeline = new BasicPipeline(Shaders.textured_vert, Shaders.transition_frag);
		pipeline.compile();

		locationTransition = pipeline.getConstantLocation("TRANSITION");
		locationTilesX = pipeline.getConstantLocation("TILES_X");
		locationTilesY = pipeline.getConstantLocation("TILES_Y");

		quad = BasicMesh.getOBJMesh(Assets.blobs.quad_obj, pipeline.vertexStructure, Color.Black);
		quad.modelMatrix = FastMatrix4.identity().multmat(FastMatrix4.rotation(0, 0, Math.PI * 0.5));

		fadeTexture = Assets.images.FadeTextureBottomTop;

		screenMatrix = FastMatrix4.orthogonalProjection(-1, 1, -1, 1, 0, 1000);
	}

	override public function render(backbuffer:Image) {
		beginAndClear(backbuffer, Color.White);

		backbuffer.g4.setTexture(pipeline.textureUnit, fadeTexture);
		backbuffer.g4.setTextureParameters(pipeline.textureUnit, TextureAddressing.Repeat, TextureAddressing.Repeat,
			TextureFilter.PointFilter, TextureFilter.PointFilter, MipMapFilter.NoMipFilter);

		backbuffer.g4.setPipeline(pipeline);

		backbuffer.g4.setFloat(locationTransition, transition);
		backbuffer.g4.setInt(locationTilesX, tilesX);
		backbuffer.g4.setInt(locationTilesY, tilesY);
		backbuffer.g4.setMatrix(pipeline.locationMVPMatrix, screenMatrix.multmat(quad.modelMatrix));

		quad.setBufferMesh(backbuffer);

		backbuffer.g4.drawIndexedVertices();

		backbuffer.g4.end();
	}
	
	override public function update(delta:Float) {
		time += Application.deltaTime * transitionDelta;
		transition = Math.abs(time % 2 - 1);
	}

	override public function renderUI(backbuffer:Image) {
		ui.begin(backbuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
				if(ui.panel(Id.handle({selected: true}), "General")) {
					ui.text('Transition: $transition');
					if(ui.button("Reset")) { transition = 0; }
					transitionDelta = ui.slider(Id.handle({value: transitionDelta}), "Transition Delta", -1, 1, true, 100);
					tilesX = Math.floor(ui.slider(Id.handle({value: tilesX}), "Tiles X", 0, 100, true, 1));
					tilesY = Math.floor(ui.slider(Id.handle({value: tilesY}), "Tiles Y", 0, 100, true, 1));
				}
				if(ui.panel(Id.handle({selected: true}), "Fade Effect")) {
					ui.text("Texture");
					ui.image(fadeTexture);
					if(ui.button("BottomTop")) { fadeTexture = Assets.images.FadeTextureBottomTop; }
					if(ui.button("Counterclockwise")) { fadeTexture = Assets.images.FadeTextureCounterClockwise; }
					if(ui.button("Center Circular")) { fadeTexture = Assets.images.FadeTextureCenterCircular; }
					if(ui.button("Middle Horizontal")) { fadeTexture = Assets.images.FadeTextureMiddleHorizontal; }
					if(ui.button("Middle Vertical")) { fadeTexture = Assets.images.FadeTextureMiddleVertical; }
				}
				if(ui.panel(Id.handle({selected: true}), "Camera")) {

				}
			}
		}
		ui.end();
	}

}