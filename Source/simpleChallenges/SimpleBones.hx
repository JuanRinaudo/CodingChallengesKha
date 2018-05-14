package simpleChallenges;

import kha.Assets;
import kha.Color;
import kha.Image;
import kha.Framebuffer;
import kha.Shaders;
import kha.math.FastVector3;

import kext.Application;
import kext.AppState;
import kext.g4basics.BasicMesh;
import kext.g4basics.BasicPipeline;

import zui.Zui;
import zui.Id;

class SimpleBones extends AppState {
	private static inline var CANVAS_WIDTH:Int = 800;
	private static inline var CANVAS_HEIGHT:Int = 800;
	private static inline var NAME:String = "Simple Bones";

	private var pipeline:BasicPipeline;
	private var mesh:BasicMesh;

	public static function initApplication() {
		return new Application(
			{title: SimpleBones.NAME, width: SimpleBones.CANVAS_WIDTH, height: SimpleBones.CANVAS_HEIGHT},
			{initState: SimpleBones, defaultFontName: "KenPixel"}
		);
	}

	public function new() {
		super();

		pipeline = new BasicPipeline(Shaders.normals_vert, Shaders.normals_frag);
		pipeline.upVector = new FastVector3(0, 0, 1);
		// pipeline.orthogonal(5, 1);
		pipeline.cameraLookAt(
			new FastVector3(1, 1, 1).mult(20),
			new FastVector3(0, 0, 0));
		pipeline.compile();

		mesh = BasicMesh.getOGEXMesh(Assets.blobs.boneTest_ogex, pipeline.vertexStructure, Color.Red, 0);
	}

	override public function update(delta:Float) {

	}

	override public function render(backbuffer:Image) {
		pipeline.cameraLookAt(
			new FastVector3(1, 1, Math.sin(Application.time)).mult(20),
			new FastVector3(0, 0, 0));

		backbuffer.g4.begin();
		backbuffer.g4.clear(Color.Black, Math.POSITIVE_INFINITY);

		backbuffer.g4.setPipeline(pipeline);

		mesh.drawMesh(backbuffer, pipeline);

		backbuffer.g4.end();
	}

	override public function renderFramebuffer(framebuffer:Framebuffer) {
		ui.begin(framebuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {

			}
		}
		ui.end();
	}

}