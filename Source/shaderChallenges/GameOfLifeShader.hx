package shaderChallenges;

import kha.math.FastVector3;
import kha.Color;
import kha.math.Vector3;
import kext.g4basics.BasicMesh;
import kha.graphics4.Usage;
import kha.graphics4.TextureFormat;
import kext.g4basics.Camera3D;
import kha.Shaders;
import kext.g4basics.BasicPipeline;
import kha.Image;
import kext.Application;
import kext.AppState;

class GameOfLifeShader extends AppState {
    private static inline var CANVAS_WIDTH:Int = 640;
	private static inline var CANVAS_HEIGHT:Int = 640;
	private static inline var NAME:String = "Game Of Life Shader";

    private var texture:Image;
    private var camera:Camera3D;
    private var pipeline:BasicPipeline;
    private var screenQuad:BasicMesh;

	public static function initApplication():Application {
		return new Application(
			{title: NAME, width: CANVAS_WIDTH, height: CANVAS_HEIGHT},
			{initState: GameOfLifeShader, defaultFontName: "KenPixel"}
		);
	}

    public function new() {
        super();

        texture = Image.create(360, 360, TextureFormat.RGBA32, Usage.DynamicUsage);

        camera = new Camera3D();
        camera.transform.setPosition(new Vector3(0, 0, -10));
        camera.lookAt(new FastVector3(0, 0, 0));
        camera.orthogonal(1, CANVAS_WIDTH / CANVAS_HEIGHT);
        Application.mainCamera = camera;
        pipeline = new BasicPipeline(Shaders.textured_vert, Shaders.gameOfLife_frag, camera);
        pipeline.compile();

        screenQuad = BasicMesh.createQuadMesh(new Vector3(-1, -1, 0), new Vector3(1, 1, 0), pipeline, Color.White);
    }

    override function update(delta:Float) {
        super.update(delta);
    }

    override function render(backbuffer:Image) {
        super.render(backbuffer);

        beginAndClear3D(backbuffer);

        screenQuad.render(backbuffer);

        end3D(backbuffer);
    }

}