package beesandbombsSineCubes;

import kha.Assets;
import kha.Color;
import kha.Shaders;
import kha.Image;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.ConstantLocation;
import kha.graphics4.VertexData;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

import kext.AppState;
import kext.g4basics.BasicPipeline;
import kext.loaders.STLMeshLoader;
import kext.loaders.STLMeshLoader.STLMeshData;

import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;

import zui.Zui;
import zui.Ext;
import zui.Id;

class SineCubesState extends AppState {
	public static inline var CANVAS_WIDTH:Int = 800;
	public static inline var CANVAS_HEIGHT:Int = 800;
	public static inline var NAME:String = "Beesandbombs Sine Cubes";

	private var cubesPipeline:BasicPipeline;

	private var vertexBuffer:VertexBuffer;
	private var indexBuffer:IndexBuffer;

	private var projectionMatrix:FastMatrix4;
	private var viewMatrix:FastMatrix4;
	private var modelMatrix:FastMatrix4;
	private var projectionViewMatrix:FastMatrix4;
	private var mvpMatrix:FastMatrix4;

	private var mvpLocation:ConstantLocation;
	private var lightDirectionLocation:ConstantLocation;

	private var mesh:STLMeshData;

	private var uiToggle:Bool = true;

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
	
	public function new() {
		super();

		setupPipeline();
		setupCube();
		setupZUI();

		mvpLocation = cubesPipeline.getConstantLocation("MVP");
		lightDirectionLocation = cubesPipeline.getConstantLocation("LIGHT_POSITION");
	}

	private inline function setupPipeline() {
		cubesPipeline = new BasicPipeline(Shaders.directionalLight_vert, Shaders.directionalLight_frag);
		cubesPipeline.addVertexData("normal", VertexData.Float3);
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
		mvpMatrix = projectionViewMatrix.multmat(modelMatrix);
	}

	private inline function setupCube() {
		mesh = STLMeshLoader.load(Assets.blobs.cube_stl);

		vertexBuffer = new VertexBuffer(mesh.vertexes.length, cubesPipeline.vertexStructure, Usage.StaticUsage);
		setupCubeVertexes();

		indexBuffer = new IndexBuffer(mesh.vertexes.length, Usage.StaticUsage);
		setupCubeIndexes();

		setupCubeColor();
		setupCubeNormals();
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

		backbuffer.g4.setVertexBuffer(vertexBuffer);
		backbuffer.g4.setIndexBuffer(indexBuffer);

		if(lightRotation) {
			lightDirection = new FastVector3(Math.sin(time * lightRotationSpeed), lightDirection.y, Math.cos(time * lightRotationSpeed));
		}
		lightDirection.normalize();

		if(cubeColor != lastColor) {
			setupCubeColor();
		}

		var x:Float = 0;
		var z:Float = 0;
		var distance:Float = 0;
		for(i in 0...cubesX) {
			for(j in 0...cubesZ) {
				x = i - cubesX / 2;
				z = j - cubesZ / 2;
				distance = Math.sqrt(x * x + z * z);
				mvpMatrix = projectionViewMatrix
					.multmat(FastMatrix4.rotation(0, 0, Math.PI * .25))
					.multmat(FastMatrix4.rotation(Math.PI * .25, 0, 0))
					.multmat(FastMatrix4.translation(x, 0, z))
					.multmat(FastMatrix4.scale(1, Math.abs(Math.sin(time * timeMultiplier + distance * distanceMultiplier) * (maxValue - minValue)) + minValue, 1));
				backbuffer.g4.setMatrix(mvpLocation, mvpMatrix);
				backbuffer.g4.setVector3(lightDirectionLocation, lightDirection);

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

	private inline function setupCubeVertexes() {
		var vertexes = vertexBuffer.lock();
		var baseIndex:Int = 0;
		for(i in 0...mesh.vertexCount) {
			baseIndex = i * 12;
			vertexes.set(baseIndex + 0, mesh.vertexes.get(i * 3)); //X
			vertexes.set(baseIndex + 1, mesh.vertexes.get(i * 3 + 1)); //Y
			vertexes.set(baseIndex + 2, mesh.vertexes.get(i * 3 + 2)); //Z
			vertexes.set(baseIndex + 3, 0); //UVX
			vertexes.set(baseIndex + 4, 0); //UVY
		}
		vertexBuffer.unlock();
	}

	private inline function setupCubeColor() {
		var vertexes = vertexBuffer.lock();
		var baseIndex:Int = 0;
		var color:Color = Color.fromValue(cubeColor);
		for(i in 0...mesh.vertexCount) {
			baseIndex = i * 12;
			vertexes.set(baseIndex + 5, color.R); //R
			vertexes.set(baseIndex + 6, color.G); //G
			vertexes.set(baseIndex + 7, color.B); //B
			vertexes.set(baseIndex + 8, color.A); //A
		}
		vertexBuffer.unlock();
	}

	private inline function setupCubeNormals() {
		var vertexes = vertexBuffer.lock();
		var baseIndex:Int = 0;
		var normalIndex:Int = 0;
		for(i in 0...mesh.vertexCount) {
			baseIndex = i * 12;
			normalIndex = Math.floor(i / 3);
			vertexes.set(baseIndex + 9, mesh.normals.get(normalIndex * 3)); //NX
			vertexes.set(baseIndex + 10, mesh.normals.get(normalIndex * 3 + 1)); //NY
			vertexes.set(baseIndex + 11, mesh.normals.get(normalIndex * 3 + 2)); //NZ
		}
		vertexBuffer.unlock();
	}

	private inline function setupCubeIndexes() {
		var indices = indexBuffer.lock();
		for(i in 0...mesh.vertexCount) {
			indices.set(i, i);
		}
		indexBuffer.unlock();
	}

}