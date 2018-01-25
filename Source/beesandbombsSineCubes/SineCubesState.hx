package beesandbombsSineCubes;

import kha.Assets;
import kha.Color;
import kha.Shaders;
import kha.Image;
import kha.graphics4.ConstantLocation;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.math.FastVector4;

import kext.Application;
import kext.AppState;
import kext.g4basics.BasicMesh;
import kext.g4basics.BasicPipeline;
import kext.loaders.STLMeshLoader;

import zui.Zui;
import zui.Ext;
import zui.Id;

class SineCubesState extends AppState {
	private static inline var CANVAS_WIDTH:Int = 800;
	private static inline var CANVAS_HEIGHT:Int = 800;
	private static inline var NAME:String = "Beesandbombs Sine Cubes";

	private var cubesPipeline:BasicPipeline;

	private var projectionMatrix:FastMatrix4;
	private var viewMatrix:FastMatrix4;
	private var modelMatrix:FastMatrix4;
	private var projectionViewMatrix:FastMatrix4;
	private var normalMatrix:FastMatrix3;

	private var locationMVPMatrix:ConstantLocation;
	private var locationNormalMatrix:ConstantLocation;
	private var locationDirectionalLight:ConstantLocation;
	private var locationDirectionalColor:ConstantLocation;
	private var locationAmbientLight:ConstantLocation;

	private var cubeMesh:BasicMesh;

	private var time:Float = 0;
	private var cubesX:Int = 20;
	private var cubesZ:Int = 20;
	private var timeMultiplier:Float = 1.8;
	private var distanceMultiplier:Float = -0.35;
	private var minValue:Float = 5;
	private var maxValue:Float = 15;
	private var lastColor:Int = Color.White.value;
	private var cubeColor:Int = Color.White.value;

	private var lightRotation:Bool = false;
	private var lightRotationSpeed:Float = 1;
	private var lightDirection:FastVector3 = new FastVector3(0, -.3, -.5);
	private var ambientLight:Color = Color.Black;
	
	private var cameraSize:Float = 18;

	private var ui:Zui;
	private var uiToggle:Bool = true;

	public static function initApplication() {
		return new Application(
			{title: SineCubesState.NAME, width: SineCubesState.CANVAS_WIDTH, height: SineCubesState.CANVAS_HEIGHT},
			{initState: SineCubesState}
		);
	}
	
	public function new() {
		super();

		setupPipeline();
		setupCube();
		setupZUI();

		locationMVPMatrix = cubesPipeline.getConstantLocation("MVP_MATRIX");
		locationNormalMatrix = cubesPipeline.getConstantLocation("NORMAL_MATRIX");
		locationDirectionalLight = cubesPipeline.getConstantLocation("LIGHT_DIRECTION");
		locationDirectionalColor = cubesPipeline.getConstantLocation("LIGHT_COLOR");
		locationAmbientLight = cubesPipeline.getConstantLocation("AMBIENT_COLOR");
	}

	private inline function setupPipeline() {
		cubesPipeline = new BasicPipeline(Shaders.directionalLighting_vert, Shaders.directionalLighting_frag);
		cubesPipeline.compile();
	}

	private inline function setupMVP() {
		var size:Float = cameraSize;
		projectionMatrix = FastMatrix4.orthogonalProjection(-size, size, -size, size, .1, 300);
		viewMatrix = FastMatrix4.lookAt(
			new FastVector3(0, 0, -100),
			new FastVector3(0, 0, 0),
			new FastVector3(0, 1, 0)
		);
		modelMatrix = FastMatrix4.identity();
		projectionViewMatrix = projectionMatrix.multmat(viewMatrix);
	}

	private inline function setupCube() {
		cubeMesh = STLMeshLoader.getBasicMesh(Assets.blobs.cube_stl, cubesPipeline.vertexStructure, 0, 3, 8, Color.White);
	}

	private inline function setupZUI() {
		ui = new Zui({font: Assets.fonts.KenPixel});
	}

	override public function render(backbuffer:Image) {
		setupMVP();

		backbuffer.g4.begin();
		backbuffer.g4.clear(Color.Black, Math.POSITIVE_INFINITY);

		renderCubes(backbuffer);

		renderUI(backbuffer);
	}

	private inline function renderCubes(backbuffer:Image) {
		backbuffer.g4.setPipeline(cubesPipeline);

		backbuffer.g4.setVertexBuffer(cubeMesh.vertexBuffer);
		backbuffer.g4.setIndexBuffer(cubeMesh.indexBuffer);

		if(lightRotation) {
			lightDirection = new FastVector3(Math.sin(time * lightRotationSpeed), lightDirection.y, Math.cos(time * lightRotationSpeed));
		}
		lightDirection.normalize();
		backbuffer.g4.setVector3(locationDirectionalLight, lightDirection);
		backbuffer.g4.setVector4(locationDirectionalColor, new FastVector4(1, 1, 1, 1));
		backbuffer.g4.setVector4(locationAmbientLight, new FastVector4(0, 0, 0, 0));

		if(cubeColor != lastColor) {
			BasicMesh.setAllVertexesColor(cubeMesh, cubesPipeline.vertexStructure, 8, cubeColor);
		}

		var modelViewMatrix:FastMatrix4;
		var mvpMatrix:FastMatrix4;
		var baseMatrix:FastMatrix4 = FastMatrix4.identity()
			.multmat(FastMatrix4.rotation(0, 0, Math.PI * .25))
			.multmat(FastMatrix4.rotation(Math.PI * .25, 0, 0));

		var x:Float = 0;
		var z:Float = 0;
		var distance:Float = 0;
		for(i in 0...cubesX) {
			for(j in 0...cubesZ) {
				x = i - cubesX / 2;
				z = j - cubesZ / 2;
				distance = Math.sqrt(x * x + z * z);
				modelViewMatrix = baseMatrix
					.multmat(FastMatrix4.translation(x, 0, z))
					.multmat(FastMatrix4.scale(.5, (Math.abs(Math.sin(time * timeMultiplier + distance * distanceMultiplier) * (maxValue - minValue)) + minValue) * .5, .5));
				mvpMatrix = projectionViewMatrix.multmat(modelViewMatrix);
				backbuffer.g4.setMatrix(locationMVPMatrix, mvpMatrix);
				normalMatrix = new FastMatrix3(modelViewMatrix._00, modelViewMatrix._10, modelViewMatrix._20,
					modelViewMatrix._01, modelViewMatrix._11, modelViewMatrix._21,
					modelViewMatrix._02, modelViewMatrix._12, modelViewMatrix._22).inverse().transpose();
				backbuffer.g4.setMatrix3(locationNormalMatrix, normalMatrix);

				backbuffer.g4.drawIndexedVertices();
			}
		}
		backbuffer.g4.end();
	}

	private inline function renderUI(backbuffer:Image) {
		ui.begin(backbuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
				if(ui.panel(Id.handle({selected: true}), "General")) {
					cubesX = Math.floor(ui.slider(Id.handle({value: cubesX}), "Cubes X", 1, 100, true, 1));
					cubesZ = Math.floor(ui.slider(Id.handle({value: cubesZ}), "Cubes Z", 1, 100, true, 1));
					timeMultiplier = ui.slider(Id.handle({value: timeMultiplier}), "Time Multiplier", -5, 5, true, 10);
					distanceMultiplier = ui.slider(Id.handle({value: distanceMultiplier}), "Distance Multiplier", -5, 5, true, 100);
					minValue = ui.slider(Id.handle({value: minValue}), "Min Value", 0, 100, true, 10);
					maxValue = ui.slider(Id.handle({value: maxValue}), "Max Value", 0, 100, true, 10);
					if(ui.panel(Id.handle({selected: true}), "Cube Color")) {
						cubeColor = Ext.colorPicker(ui, Id.handle({color: cubeColor}), false);
					}
					// timeMultiplier = ui.floatInput(Id.handle({text: '' + timeMultiplier}), "Time Multiplier");
					// distanceMultiplier = ui.floatInput(Id.handle({text: '' + distanceMultiplier}), "Distance Multiplier");
					// minValue = ui.floatInput(Id.handle({text: '' + minValue}), "Min Value");
					// maxValue = ui.floatInput(Id.handle({text: '' + maxValue}), "Max Value");
				}
				if(ui.panel(Id.handle({selected: true}), "Lighting")) {
					lightRotation = ui.check(Id.handle(), "Rotate Light");
					if(!lightRotation) {
						lightDirection.x = ui.slider(Id.handle({value: lightDirection.x}), "Light Direction X", -1, 1, true, 100, true);
						lightDirection.y = ui.slider(Id.handle({value: lightDirection.y}), "Light Direction Y", -1, 1, true, 100, true);
						lightDirection.z = ui.slider(Id.handle({value: lightDirection.z}), "Light Direction Z", -1, 1, true, 100, true);
					} else {
						lightRotationSpeed = ui.slider(Id.handle({value: lightRotationSpeed}), "Light Rotation Speed", -10, 10, true, 10, true);
						lightDirection.y = ui.slider(Id.handle({value: lightDirection.y}), "Light Direction Y", -1, 1, true, 100, true);
					}
				}
				if(ui.panel(Id.handle({selected: true}), "Camera")) {
					cameraSize = ui.slider(Id.handle({value: cameraSize}), "Camera Size", 0, 50, true, 10, true);
				}
			}
		}
		ui.end();
	}

	override public function update(delta:Float) {
		time += delta;
	}

}