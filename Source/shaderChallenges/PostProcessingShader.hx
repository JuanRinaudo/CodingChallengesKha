package shaderChallenges;

import kha.Assets;
import kha.Color;
import kha.Image;
import kha.Shaders;

import kha.math.Vector2;
import kha.math.FastVector3;

import kha.graphics4.FragmentShader;

import kext.Application;
import kext.AppState;

import kext.g4basics.BasicMesh;
import kext.g4basics.BasicPipeline;

import utils.DemoMeshes;
import utils.ZUIUtils;

import zui.Zui;
import zui.Id;

using kext.UniformType;

enum PostProcessingEfect {
	BLUR;
	GAUSSIANBLUR;
	COLORQUANTIZATION;
	BLACKANDWHITE;
	PIXELATE;
	COLORCORRECTION;
	FXAA;
}

class PostProcessingShader extends AppState {
	private static inline var CANVAS_WIDTH:Int = 1200;
	private static inline var CANVAS_HEIGHT:Int = 800;
	private static inline var NAME:String = "Post Processing Shader";

	private var pipelineCube:BasicPipeline;
	private var pipelineLenna:BasicPipeline;
	private var mesh:BasicMesh;
	private var texture:Image;
	private var effectList:Array<PostProcessingEfect> = [];

	//Blur
	private var blurValue:Int = 1;
	//Gaussian Blur
	private var blursize:Int = 1;
	private var sigma:Float = 5;
	private var direction:Vector2 = new Vector2(1, 0);
	//Color Quantization
	private var colorQuantization:Int = 1;
	//Pixelate
	private var cellSize:Vector2 = new Vector2(2, 2);
	//Color correction
	private var red:Float = 1;
	private var green:Float = 1;
	private var blue:Float = 1;
	private var contrast:Float = 1;
	private var brightness:Float = 0;
	private var temperature:Float = 0;
	private var tint:Float = 0;
	private var gamma:Float = 1;
	private var hue:Float = 0;
	private var saturation:Float = 0;
	private var lumination:Float = 0;
	//FXAA
	private var fxaaSpanMax:Float = 10;
	private var fxaaReduceMin:Float = 0.03;
	private var fxaaReduceMul:Float = 0.1;
	
	public static function initApplication():Application {
		return new Application(
			{title: PostProcessingShader.NAME, width: PostProcessingShader.CANVAS_WIDTH, height: PostProcessingShader.CANVAS_HEIGHT},
			{initState: PostProcessingShader}
		);
	}

	public function new() {
		super();

		pipelineCube = new BasicPipeline(Shaders.testColored_vert, Shaders.colored_frag);
		pipelineCube.orthogonal(5, CANVAS_WIDTH / CANVAS_HEIGHT);
		pipelineCube.compile();
		
		pipelineLenna = new BasicPipeline(Shaders.textured_vert, Shaders.textured_frag);
		pipelineLenna.orthogonal(5, CANVAS_WIDTH / CANVAS_HEIGHT);
		pipelineLenna.cameraLookAt(new FastVector3(0, -10, 0.1), new FastVector3(0, 0, 0));
		pipelineLenna.compile();

		DemoMeshes.init(pipelineCube.vertexStructure, Color.White);
		DemoMeshes.CUBE_OBJ.scale(3, 3, 3);
		DemoMeshes.QUAD_OBJ.scale(4, 4, 4);

		mesh = DemoMeshes.CUBE_OBJ;
		texture = Assets.images.Lenna;
	}

	override public function render(backbuffer:Image) {
		DemoMeshes.CUBE_OBJ.rotate(Application.deltaTime, 0, 0);

		beginAndClear(backbuffer);
		mesh.setBufferMesh(backbuffer);
		if(mesh == DemoMeshes.CUBE_OBJ) {
			backbuffer.g4.setPipeline(pipelineCube);
			backbuffer.g4.setMatrix(pipelineCube.locationMVPMatrix, pipelineCube.getMVPMatrix(mesh.modelMatrix));
		} else {
			backbuffer.g4.setPipeline(pipelineLenna);
			backbuffer.g4.setTexture(pipelineLenna.textureUnit, texture);
			pipelineLenna.setDefaultTextureUnitParameters(backbuffer, pipelineLenna.textureUnit);
			backbuffer.g4.setMatrix(pipelineLenna.locationMVPMatrix, pipelineLenna.getMVPMatrix(mesh.modelMatrix));
		}
		backbuffer.g4.drawIndexedVertices();
		backbuffer.g4.end();
	}

	override public function renderUI(backbuffer:Image) {
		ui.begin(backbuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
				if(ui.panel(Id.handle({selected: true}), "General")) {
					if(ui.button("Test Cube")) { mesh = DemoMeshes.CUBE_OBJ; }
					if(ui.button("Lena Image")) { mesh = DemoMeshes.QUAD_OBJ; texture = Assets.images.Lenna; }
					if(ui.button("Test Image")) { mesh = DemoMeshes.QUAD_OBJ; texture = Assets.images.Test; }
				}
				for(effect in effectList) {
					switch(effect) {
						case BLUR:
							if(ui.panel(Id.handle({selected: true}), "Post Processing Parameters Blur")) {
								blurValue = Math.floor(ui.slider(Id.handle({value: blurValue}), "Blur Value", 1, 16, true, 1));
							}
						case GAUSSIANBLUR:
							if(ui.panel(Id.handle({selected: true}), "Post Processing Parameters Gaussian Blur")) {
								blursize = Math.floor(ui.slider(Id.handle({value: blursize}), "Blur Size", 1, 32, true, 1));
								sigma = ui.slider(Id.handle({value: sigma}), "Sigma", 0.01, 100, true, 100);
								ZUIUtils.vector2Sliders(ui, Id.handle(), direction, "Direction", -1, 1, 100);
							}
						case COLORQUANTIZATION:
							if(ui.panel(Id.handle({selected: true}), "Post Processing Parameters Color Quantization")) {
								colorQuantization = Math.floor(ui.slider(Id.handle({value: colorQuantization}), "Color quantization", 1, 255, true, 1));
							}
						case PIXELATE:
							if(ui.panel(Id.handle({selected: true}), "Post Processing Parameters Pixelate")) {
								ZUIUtils.vector2Sliders(ui, Id.handle(), cellSize, "Pixel Size", 2, 64, 1);
							}
						case COLORCORRECTION:
							if(ui.panel(Id.handle({selected: true}), "Post Processing Parameters Color Correction")) {
								red = ui.slider(Id.handle({value: red}), "Red", -2, 2, true, 100);
								green = ui.slider(Id.handle({value: green}), "Green", -2, 2, true, 100);
								blue = ui.slider(Id.handle({value: blue}), "Blue", -2, 2, true, 100);
								contrast = ui.slider(Id.handle({value: contrast}), "Contrast", -5, 5, true, 100);
								brightness = ui.slider(Id.handle({value: brightness}), "Brightness", -5, 5, true, 100);
								temperature = ui.slider(Id.handle({value: brightness}), "Temperature", -3, 3, true, 100);
								tint = ui.slider(Id.handle({value: brightness}), "Tint", -5, 5, true, 100);
								gamma = ui.slider(Id.handle({value: gamma}), "Gamma", 0, 10, true, 100);
								hue = ui.slider(Id.handle({value: hue}), "Hue", 0, 1, true, 100);
								saturation = ui.slider(Id.handle({value: saturation}), "Saturation", -1, 1, true, 100);
								lumination = ui.slider(Id.handle({value: lumination}), "Lumination", -1, 1, true, 100);
							}
						case FXAA:
							if(ui.panel(Id.handle({selected: true}), "Post Processing Parameters FXAA")) {
								fxaaSpanMax = ui.slider(Id.handle({value: fxaaSpanMax}), "FXAA Span Max", 0, 20, true, 100);
								fxaaReduceMin = ui.slider(Id.handle({value: fxaaReduceMin}), "FXAA Reduce Min", 0, 1, true, 100);
								fxaaReduceMul = ui.slider(Id.handle({value: fxaaReduceMul}), "FXAA Reduce Mul", 0, 1, true, 100);
							}
						default:
					}
				}
				if(ui.panel(Id.handle({selected: true}), "Post Processing Effect")) {
					postProcessingCheck(ui.check(Id.handle(), "Blur"), PostProcessingEfect.BLUR, Shaders.postBlur_frag);
					postProcessingCheck(ui.check(Id.handle(), "Gaussian Blur"), PostProcessingEfect.GAUSSIANBLUR, Shaders.postGaussianBlur_frag);
					postProcessingCheck(ui.check(Id.handle(), "Color Quantization"), PostProcessingEfect.COLORQUANTIZATION, Shaders.postColorQuantization_frag);
					postProcessingCheck(ui.check(Id.handle(), "Black And White"), PostProcessingEfect.BLACKANDWHITE, Shaders.postBlackAndWhite_frag);
					postProcessingCheck(ui.check(Id.handle(), "Pixelate"), PostProcessingEfect.PIXELATE, Shaders.postPixelate_frag);
					postProcessingCheck(ui.check(Id.handle(), "Color Correction"), PostProcessingEfect.COLORCORRECTION, Shaders.postColorCorrection_frag);
					postProcessingCheck(ui.check(Id.handle(), "FXAA"), PostProcessingEfect.FXAA, Shaders.postFXAA_frag);
				}
			}
		}
		ui.end();

		for(effect in effectList) {
			switch(effect) {
				case BLUR:
					Application.setPostProcesingConstantLocation(Shaders.postBlur_frag, INT, "BLUR_VALUE", blurValue);
				case GAUSSIANBLUR:
					Application.setPostProcesingConstantLocation(Shaders.postGaussianBlur_frag, INT, "BLUR_SIZE", blursize);
					Application.setPostProcesingConstantLocation(Shaders.postGaussianBlur_frag, FLOAT, "SIGMA", sigma);
					Application.setPostProcesingConstantLocation(Shaders.postGaussianBlur_frag, VECTOR2, "DIRECTION", direction);
				case COLORQUANTIZATION:
					Application.setPostProcesingConstantLocation(Shaders.postColorQuantization_frag, INT, "COLOR_QUANTIZATION", colorQuantization);
				case PIXELATE:
					Application.setPostProcesingConstantLocation(Shaders.postPixelate_frag, VECTOR2, "CELL_SIZE", cellSize);
				case COLORCORRECTION:
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "RED", red);
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "GREEN", green);
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "BLUE", blue);
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "CONTRAST", contrast);
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "BRIGHTNESS", brightness);
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "TEMPERATURE", temperature);
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "TINT", tint);
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "GAMMA", gamma);
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "HUE", hue);
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "SATURATION", saturation);
					Application.setPostProcesingConstantLocation(Shaders.postColorCorrection_frag, FLOAT, "LUMINATION", lumination);
				case FXAA:
					Application.setPostProcesingConstantLocation(Shaders.postFXAA_frag, FLOAT, "FXAA_SPAN_MAX", fxaaSpanMax);
					Application.setPostProcesingConstantLocation(Shaders.postFXAA_frag, FLOAT, "FXAA_REDUCE_MIN", fxaaReduceMin);
					Application.setPostProcesingConstantLocation(Shaders.postFXAA_frag, FLOAT, "FXAA_REDUCE_MUL", fxaaReduceMul);
				default:
			}
		}
	}

	private inline function postProcessingCheck(check:Bool, effect:PostProcessingEfect, shader:FragmentShader) {
		if(check && effectList.indexOf(effect) == -1) {
			effectList.push(effect); Application.setPostProcessingShader(shader);
		} else if(!check && effectList.indexOf(effect) != -1) {
			effectList.remove(effect); Application.removePostProcessingShader(shader);
		}
	}

}