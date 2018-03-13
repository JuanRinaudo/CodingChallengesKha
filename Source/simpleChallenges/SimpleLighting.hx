package simpleChallenges;

import kha.Assets;
import kha.Color;
import kha.Image;
import kha.Framebuffer;
import kha.Shaders;

import kha.math.FastMatrix4;
import kha.math.FastMatrix3;
import kha.math.Vector3;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.graphics4.ConstantLocation;

import kext.Application;
import kext.AppState;
import kext.g4basics.BasicMesh;
import kext.g4basics.BasicPipeline;
import kext.loaders.STLMeshLoader;
import kext.loaders.OBJMeshLoader;
import kext.debug.Debug;

import zui.Zui;
import zui.Ext;
import zui.Id;

class SimpleLighting extends AppState {
	private static inline var CANVAS_WIDTH:Int = 1600;
	private static inline var CANVAS_HEIGHT:Int = 800;
	private static inline var NAME:String = "Simple Lighting";

	private var pipeline:BasicPipeline;
	private var cubeOBJMesh:BasicMesh;
	private var sphereOBJMesh:BasicMesh;
	private var torusOBJMesh:BasicMesh;
	private var suzanneOBJMesh:BasicMesh;
	private var carFormulaOBJMesh:BasicMesh;
	private var cubeSTLMesh:BasicMesh;
	private var sphereSTLMesh:BasicMesh;
	private var torusSTLMesh:BasicMesh;
	private var suzanneSTLMesh:BasicMesh;
	private var carFormulaSTLMesh:BasicMesh;

	private var locationDirectionalLight:ConstantLocation;
	private var locationDirectionalColor:ConstantLocation;
	private var locationAmbientLight:ConstantLocation;

	private var projectionMatrix:FastMatrix4;
	private var viewMatrix:FastMatrix4;
	private var modelMatrix:FastMatrix4;
	private var projectionViewMatrix:FastMatrix4;
	private var mvpMatrix:FastMatrix4;
	private var normalMatrix:FastMatrix3;

	private var directionalLight:FastVector4;
	private var directionalColor:Color;
	private var ambientLight:Color;
	private var deltaAngle:FastVector3;
	private var meshScale:FastVector3;

	private var meshType:MeshType = MeshType.CUBE_OBJ;

	public static function initApplication() {
		return new Application(
			{title: SimpleLighting.NAME, width: SimpleLighting.CANVAS_WIDTH, height: SimpleLighting.CANVAS_HEIGHT},
			{initState: SimpleLighting}
		);
	}

	public function new() {
		super();

		pipeline = new BasicPipeline(Shaders.directionalLighting_vert, Shaders.directionalLighting_frag);
		pipeline.compile();
		locationDirectionalLight = pipeline.getConstantLocation("LIGHT_DIRECTION");
		locationDirectionalColor = pipeline.getConstantLocation("LIGHT_COLOR");
		locationAmbientLight = pipeline.getConstantLocation("AMBIENT_COLOR");

		directionalLight = new FastVector4(0, 1, 0, 0);
		directionalColor = Color.fromFloats(1, 0, 0, 1);
		ambientLight = Color.fromFloats(.2, .2, .2, 1);
		deltaAngle = new FastVector3(0, 0, 1);
		meshScale = new FastVector3(1, 1, 1);
		var size:UInt = 5;
		var ratio:Float = CANVAS_WIDTH / CANVAS_HEIGHT;
		projectionMatrix = FastMatrix4.orthogonalProjection(-size * ratio, size * ratio, size, -size, .1, 100);
		viewMatrix = FastMatrix4.lookAt(
			new FastVector3(-1, 1, -1).mult(20),
			new FastVector3(0, 0, 0),
			new FastVector3(0, 1, 0)
		);
		modelMatrix = FastMatrix4.identity();
		projectionViewMatrix = projectionMatrix.multmat(viewMatrix);
		mvpMatrix = projectionViewMatrix.multmat(modelMatrix);

		cubeOBJMesh = BasicMesh.getOBJMesh(Assets.blobs.cube_obj, pipeline.vertexStructure, Color.White);
		cubeSTLMesh = BasicMesh.getSTLMesh(Assets.blobs.cube_stl, pipeline.vertexStructure, Color.White);

		sphereOBJMesh = BasicMesh.getOBJMesh(Assets.blobs.sphere_obj, pipeline.vertexStructure, Color.White);
		sphereSTLMesh = BasicMesh.getSTLMesh(Assets.blobs.sphere_stl, pipeline.vertexStructure, Color.White);

		torusOBJMesh = BasicMesh.getOBJMesh(Assets.blobs.torus_obj, pipeline.vertexStructure, Color.White);
		torusSTLMesh = BasicMesh.getSTLMesh(Assets.blobs.torus_stl, pipeline.vertexStructure, Color.White);

		suzanneOBJMesh = BasicMesh.getOBJMesh(Assets.blobs.suzanne_obj, pipeline.vertexStructure, Color.White);
		suzanneSTLMesh = BasicMesh.getSTLMesh(Assets.blobs.suzanne_stl, pipeline.vertexStructure, Color.White);
		
		carFormulaOBJMesh = BasicMesh.getOBJMesh(Assets.blobs.carFormula_obj, pipeline.vertexStructure, Color.White);
		carFormulaSTLMesh = BasicMesh.getSTLMesh(Assets.blobs.carFormula_stl, pipeline.vertexStructure, Color.White);
	}

	override public function render(backbuffer:Image) {
		renderMesh(backbuffer);
	}

	private inline function renderMesh(backbuffer:Image) {
		backbuffer.g4.begin();
		backbuffer.g4.clear(Color.Black, Math.POSITIVE_INFINITY);

		backbuffer.g4.setPipeline(pipeline);

		drawMesh(backbuffer);

		Debug.drawDebugCube(backbuffer, projectionViewMatrix, new Vector3(directionalLight.x, directionalLight.y, directionalLight.z).mult(5), 0.1);

		backbuffer.g4.end();
	}

	private inline function drawMesh(backbuffer:Image) {
		switch(meshType) {
			case MeshType.CUBE_OBJ:
				cubeOBJMesh.setBufferMesh(backbuffer);
			case MeshType.SPHERE_OBJ:
				sphereOBJMesh.setBufferMesh(backbuffer);
			case MeshType.TORUS_OBJ:
				torusOBJMesh.setBufferMesh(backbuffer);
			case MeshType.SUZANNE_OBJ:
				suzanneOBJMesh.setBufferMesh(backbuffer);
			case MeshType.CAR_FORMULA_OBJ:
				carFormulaOBJMesh.setBufferMesh(backbuffer);
			case MeshType.CUBE_STL:
				cubeSTLMesh.setBufferMesh(backbuffer);
			case MeshType.TORUS_STL:
				torusSTLMesh.setBufferMesh(backbuffer);
			case MeshType.SPHERE_STL:
				sphereSTLMesh.setBufferMesh(backbuffer);
			case MeshType.SUZANNE_STL:
				suzanneSTLMesh.setBufferMesh(backbuffer);
			case MeshType.CAR_FORMULA_STL:
				carFormulaSTLMesh.setBufferMesh(backbuffer);
		}
		
		modelMatrix = FastMatrix4.identity()
			.multmat(FastMatrix4.scale(meshScale.x, meshScale.y, meshScale.z))
			.multmat(FastMatrix4.rotation(deltaAngle.x * Application.time, deltaAngle.y * Application.time, deltaAngle.z * Application.time));
		mvpMatrix = projectionViewMatrix.multmat(modelMatrix);
		
		normalMatrix = new FastMatrix3(modelMatrix._00, modelMatrix._10, modelMatrix._20,
			modelMatrix._01, modelMatrix._11, modelMatrix._21,
			modelMatrix._02, modelMatrix._12, modelMatrix._22).inverse().transpose();

		backbuffer.g4.setMatrix(pipeline.locationMVPMatrix, mvpMatrix);
		backbuffer.g4.setMatrix(pipeline.locationViewMatrix, viewMatrix);
		backbuffer.g4.setMatrix3(pipeline.locationNormalMatrix, normalMatrix);
		backbuffer.g4.setVector4(locationDirectionalLight, directionalLight);
		backbuffer.g4.setVector4(locationAmbientLight, new FastVector4(ambientLight.R, ambientLight.G, ambientLight.B, ambientLight.A));
		backbuffer.g4.setVector4(locationDirectionalColor, new FastVector4(directionalColor.R, directionalColor.G, directionalColor.B, directionalColor.A));

		backbuffer.g4.drawIndexedVertices();
	}

	override public function renderFramebuffer(framebuffer:Framebuffer) {
		ui.begin(framebuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
				if(ui.panel(Id.handle({selected: true}), "General")) {
					meshScale.x = ui.slider(Id.handle({value: meshScale.x}), "Mesh Scale X", 0.01, 4, true, 100, true);
					meshScale.y = ui.slider(Id.handle({value: meshScale.y}), "Mesh Scale Y", 0.01, 4, true, 100, true);
					meshScale.z = ui.slider(Id.handle({value: meshScale.z}), "Mesh Scale Z", 0.01, 4, true, 100, true);
					deltaAngle.x = ui.slider(Id.handle({value: deltaAngle.x}), "Delta Angle X", -5, 5, true, 100, true);
					deltaAngle.y = ui.slider(Id.handle({value: deltaAngle.y}), "Delta Angle Y", -5, 5, true, 100, true);
					deltaAngle.z = ui.slider(Id.handle({value: deltaAngle.z}), "Delta Angle Z", -5, 5, true, 100, true);
				}
				if(ui.panel(Id.handle({selected: true}), "Mesh Type")) {
					if(ui.button("Cube OBJ")) { meshType = MeshType.CUBE_OBJ; }
					if(ui.button("Sphere OBJ")) { meshType = MeshType.SPHERE_OBJ; }
					if(ui.button("Torus OBJ")) { meshType = MeshType.TORUS_OBJ; }
					if(ui.button("Suzanne OBJ")) { meshType = MeshType.SUZANNE_OBJ; }
					if(ui.button("Racing Car OBJ")) { meshType = MeshType.CAR_FORMULA_OBJ; }
					if(ui.button("Cube STL")) { meshType = MeshType.CUBE_STL; }
					if(ui.button("Sphere STL")) { meshType = MeshType.SPHERE_STL; }
					if(ui.button("Torus STL")) { meshType = MeshType.TORUS_STL; }
					if(ui.button("Suzanne STL")) { meshType = MeshType.SUZANNE_STL; }
					if(ui.button("Racing Car STL")) { meshType = MeshType.CAR_FORMULA_STL; }
				}
				if(ui.panel(Id.handle({selected: true}), "Lighting")) {
					directionalLight.x = ui.slider(Id.handle({value: directionalLight.x}), "Light Direction X", -1, 1, true, 100, true);
					directionalLight.y = ui.slider(Id.handle({value: directionalLight.y}), "Light Direction Y", -1, 1, true, 100, true);
					directionalLight.z = ui.slider(Id.handle({value: directionalLight.z}), "Light Direction Z", -1, 1, true, 100, true);
					directionalColor = Ext.colorPicker(ui, Id.handle({color: directionalColor}), false);
					ambientLight = Ext.colorPicker(ui, Id.handle({color: ambientLight}), false);
				}
			}
		}
		ui.end();
	}

	override public function update(delta:Float) {

	}

}