package simpleChallenges;

import kha.Assets;
import kha.Color;
import kha.Image;
import kha.Framebuffer;
import kha.Shaders;

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

		pipeline = new BasicPipeline(Shaders.colored_vert, Shaders.colored_frag);
		pipeline.compile();

		mesh = BasicMesh.getOGEXMesh(Assets.blobs.ogexTest_ogex, pipeline.vertexStructure, Color.Red);
	}

	override public function update(delta:Float) {

	}

	override public function render(backbuffer:Image) {
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