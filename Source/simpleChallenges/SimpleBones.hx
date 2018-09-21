package simpleChallenges;

import kha.Assets;
import kha.Color;
import kha.Image;
import kha.Framebuffer;
import kha.Shaders;
import kha.graphics4.VertexData;
import kha.math.Vector3;
import kha.math.FastVector3;

import kext.Application;
import kext.AppState;
import kext.g4basics.BasicMesh;
import kext.g4basics.SkeletalMesh;
import kext.g4basics.BasicPipeline;
import kext.g4basics.G4Constants;

import zui.Zui;
import zui.Id;

class SimpleBones extends AppState {
	private static inline var CANVAS_WIDTH:Int = 800;
	private static inline var CANVAS_HEIGHT:Int = 800;
	private static inline var NAME:String = "Simple Bones";
	
	private var basicPipeline:BasicPipeline;
	private var animatedPipeline:BasicPipeline;
	private var animatedMesh:SkeletalMesh;
	private var basicMesh:BasicMesh;

	private var cameraSpeed:Float = 10;
	private var cameraPosition:FastVector3;

	public static function initApplication() {
		return new Application(
			{title: SimpleBones.NAME, width: SimpleBones.CANVAS_WIDTH, height: SimpleBones.CANVAS_HEIGHT},
			{initState: SimpleBones, defaultFontName: "KenPixel"}
		);
	}

	public function new() {
		super();

		cameraPosition = new FastVector3(5, 5, 5);

		basicPipeline = new BasicPipeline(Shaders.textured_vert, Shaders.textured_frag);
		basicPipeline.compile();
		// basicMesh = BasicMesh.getOGEXMesh(Assets.blobs.ogexTest_ogex, basicPipeline.vertexStructure, Color.Red);
		basicMesh = BasicMesh.getOGEXMesh(Assets.blobs.CharacterRunning_ogex, basicPipeline.vertexStructure, Color.White);
		basicMesh.transform.setPosition(new kha.math.Vector3(5, 0, 0));
		basicMesh.transform.scaleTransform(new Vector3(.4, .4, .4));
		basicMesh.texture = Assets.images.CharacterTexture;

		animatedPipeline = new BasicPipeline(Shaders.texturedBones_vert, Shaders.textured_frag);
		animatedPipeline.addVertexData(G4Constants.VERTEX_DATA_JOINT_INDEX, VertexData.Float4);
		animatedPipeline.addVertexData(G4Constants.VERTEX_DATA_JOINT_WEIGHT, VertexData.Float4);
		animatedPipeline.compile();
		animatedMesh = SkeletalMesh.getOGEXAnimatedMesh(Assets.blobs.CharacterRunning_ogex, animatedPipeline.vertexStructure, Color.White);
		animatedMesh.texture = Assets.images.CharacterTexture;
		animatedMesh.transform.scaleTransform(new Vector3(.4, .4, .4));
	}

	override public function update(delta:Float) {
		if(Application.keyboard.keyDown(kha.input.KeyCode.A)) {
			cameraPosition.x += Application.deltaTime * cameraSpeed;
		} else if(Application.keyboard.keyDown(kha.input.KeyCode.D)) {
			cameraPosition.x -= Application.deltaTime * cameraSpeed;
		}
		if(Application.keyboard.keyDown(kha.input.KeyCode.W)) {
			cameraPosition.y += Application.deltaTime * cameraSpeed;
		} else if(Application.keyboard.keyDown(kha.input.KeyCode.S)) {
			cameraPosition.y -= Application.deltaTime * cameraSpeed;
		}
		if(Application.keyboard.keyDown(kha.input.KeyCode.Q)) {
			cameraPosition.z += Application.deltaTime * cameraSpeed;
		} else if(Application.keyboard.keyDown(kha.input.KeyCode.E)) {
			cameraPosition.z -= Application.deltaTime * cameraSpeed;
		}
		basicPipeline.cameraLookAt(cameraPosition, new FastVector3(0, 0, 0));
		animatedPipeline.cameraLookAt(cameraPosition, new FastVector3(0, 0, 0));
	}

	override public function render(backbuffer:Image) {
		backbuffer.g4.begin();
		backbuffer.g4.clear(Color.Black, Math.POSITIVE_INFINITY);

		basicMesh.drawMesh(backbuffer, basicPipeline);
		animatedMesh.drawMesh(backbuffer, animatedPipeline);

		backbuffer.g4.end();
	}

	override public function renderFramebuffer(framebuffer:Framebuffer) {
		ui.begin(framebuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
				cameraSpeed = ui.slider(Id.handle({value: cameraSpeed}), "Camera Speed", 0, 100, true, 10, true);
				animatedMesh.fps = ui.slider(Id.handle({value: animatedMesh.fps}), "Animation FPS", 0, 300, true, 1, true);
			}
		}
		ui.end();
	}

}