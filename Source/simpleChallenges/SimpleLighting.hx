package simpleChallenges;

import kha.Assets;
import kha.Color;
import kha.Image;
import kha.Shaders;

import kha.math.FastMatrix4;
import kha.math.FastMatrix3;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.graphics4.ConstantLocation;

import kext.Application;
import kext.AppState;
import kext.g4basics.BasicMesh;
import kext.g4basics.BasicPipeline;
import kext.loaders.STLMeshLoader;
import kext.loaders.OBJMeshLoader;

import zui.Zui;
import zui.Ext;
import zui.Id;

class SimpleLighting extends AppState {
	private static inline var CANVAS_WIDTH:Int = 800;
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

	private var locationMVPMatrix:ConstantLocation;
	private var locationNormalMatrix:ConstantLocation;
	private var locationDirectionalLight:ConstantLocation;
	private var locationDirectionalColor:ConstantLocation;
	private var locationAmbientLight:ConstantLocation;

	private var projectionMatrix:FastMatrix4;
	private var viewMatrix:FastMatrix4;
	private var modelMatrix:FastMatrix4;
	private var projectionViewMatrix:FastMatrix4;
	private var mvpMatrix:FastMatrix4;
	private var normalMatrix:FastMatrix3;

	private var directionalLight:FastVector3;
	private var directionalColor:Color;
	private var ambientLight:Color;
	private var deltaAngle:FastVector3;
	private var meshScale:FastVector3;

	private var meshType:MeshType = MeshType.CUBE_OBJ;

	private var ui:Zui;
	private var uiToggle:Bool = true;

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
		locationMVPMatrix = pipeline.getConstantLocation("MVP_MATRIX");
		locationNormalMatrix = pipeline.getConstantLocation("NORMAL_MATRIX");
		locationDirectionalLight = pipeline.getConstantLocation("LIGHT_DIRECTION");
		locationDirectionalColor = pipeline.getConstantLocation("LIGHT_COLOR");
		locationAmbientLight = pipeline.getConstantLocation("AMBIENT_COLOR");

		directionalLight = new FastVector3(0, 1, 0);
		directionalColor = Color.fromFloats(1, 0, 0, 1);
		ambientLight = Color.fromFloats(.2, .2, .2, 1);
		deltaAngle = new FastVector3(0, 0, 1);
		meshScale = new FastVector3(1, 1, 1);
		var size:UInt = 5;
		projectionMatrix = FastMatrix4.orthogonalProjection(-size, size, size, -size, .1, 100);
		viewMatrix = FastMatrix4.lookAt(
			new FastVector3(-5, 5, -5),
			new FastVector3(0, 0, 0),
			new FastVector3(0, 1, 0)
		);
		modelMatrix = FastMatrix4.identity();
		projectionViewMatrix = projectionMatrix.multmat(viewMatrix);
		mvpMatrix = projectionViewMatrix.multmat(modelMatrix);

		cubeOBJMesh = OBJMeshLoader.getBasicMesh(Assets.blobs.cube_obj, pipeline.vertexStructure, 0, 3, 6, 8, Color.White);
		cubeSTLMesh = STLMeshLoader.getBasicMesh(Assets.blobs.cube_stl, pipeline.vertexStructure, 0, 3, 8, Color.White);

		sphereOBJMesh = OBJMeshLoader.getBasicMesh(Assets.blobs.sphere_obj, pipeline.vertexStructure, 0, 3, 6, 8, Color.White);
		sphereSTLMesh = STLMeshLoader.getBasicMesh(Assets.blobs.sphere_stl, pipeline.vertexStructure, 0, 3, 8, Color.White);

		torusOBJMesh = OBJMeshLoader.getBasicMesh(Assets.blobs.torus_obj, pipeline.vertexStructure, 0, 3, 6, 8, Color.White);
		torusSTLMesh = STLMeshLoader.getBasicMesh(Assets.blobs.torus_stl, pipeline.vertexStructure, 0, 3, 8, Color.White);

		suzanneOBJMesh = OBJMeshLoader.getBasicMesh(Assets.blobs.suzanne_obj, pipeline.vertexStructure, 0, 3, 6, 8, Color.White);
		suzanneSTLMesh = STLMeshLoader.getBasicMesh(Assets.blobs.suzanne_stl, pipeline.vertexStructure, 0, 3, 8, Color.White);
		
		carFormulaOBJMesh = OBJMeshLoader.getBasicMesh(Assets.blobs.carFormula_obj, pipeline.vertexStructure, 0, 3, 6, 8, Color.White);
		carFormulaSTLMesh = STLMeshLoader.getBasicMesh(Assets.blobs.carFormula_stl, pipeline.vertexStructure, 0, 3, 8, Color.White);

		setupZUI();
	}

	private inline function setupZUI() {
		ui = new Zui({font: Assets.fonts.KenPixel});
	}

	override public function render(backbuffer:Image) {
		renderMesh(backbuffer);
		renderUI(backbuffer);
	}

	private inline function renderMesh(backbuffer:Image) {
		backbuffer.g4.begin();
		backbuffer.g4.clear(Color.Black, Math.POSITIVE_INFINITY);

		backbuffer.g4.setPipeline(pipeline);

		switch(meshType) {
			case MeshType.CUBE_OBJ:
				setBufferMesh(backbuffer, cubeOBJMesh);
			case MeshType.SPHERE_OBJ:
				setBufferMesh(backbuffer, sphereOBJMesh);
			case MeshType.TORUS_OBJ:
				setBufferMesh(backbuffer, torusOBJMesh);
			case MeshType.SUZANNE_OBJ:
				setBufferMesh(backbuffer, suzanneOBJMesh);
			case MeshType.CAR_FORMULA_OBJ:
				setBufferMesh(backbuffer, carFormulaOBJMesh);
			case MeshType.CUBE_STL:
				setBufferMesh(backbuffer, cubeSTLMesh);
			case MeshType.TORUS_STL:
				setBufferMesh(backbuffer, torusSTLMesh);
			case MeshType.SPHERE_STL:
				setBufferMesh(backbuffer, sphereSTLMesh);
			case MeshType.SUZANNE_STL:
				setBufferMesh(backbuffer, suzanneSTLMesh);
			case MeshType.CAR_FORMULA_STL:
				setBufferMesh(backbuffer, carFormulaSTLMesh);
		}

		// directionalLight = new FastVector3(Math.sin(Application.time), directionalLight.y, Math.cos(Application.time));
		
		modelMatrix = FastMatrix4.identity()
			.multmat(FastMatrix4.scale(meshScale.x, meshScale.y, meshScale.z))
			.multmat(FastMatrix4.rotation(deltaAngle.x * Application.time, deltaAngle.y * Application.time, deltaAngle.z * Application.time));
		mvpMatrix = projectionViewMatrix.multmat(modelMatrix);
		
		var modelViewMatrix = viewMatrix.multmat(modelMatrix);
		normalMatrix = new FastMatrix3(modelViewMatrix._00, modelViewMatrix._10, modelViewMatrix._20,
			modelViewMatrix._01, modelViewMatrix._11, modelViewMatrix._21,
			modelViewMatrix._02, modelViewMatrix._12, modelViewMatrix._22).inverse().transpose();

		backbuffer.g4.setMatrix(locationMVPMatrix, mvpMatrix);
		backbuffer.g4.setMatrix3(locationNormalMatrix, normalMatrix);
		backbuffer.g4.setVector3(locationDirectionalLight, directionalLight);
		backbuffer.g4.setVector4(locationAmbientLight, new FastVector4(ambientLight.R, ambientLight.G, ambientLight.B, ambientLight.A));
		backbuffer.g4.setVector4(locationDirectionalColor, new FastVector4(directionalColor.R, directionalColor.G, directionalColor.B, directionalColor.A));

		backbuffer.g4.drawIndexedVertices();

		backbuffer.g4.end();
	}

	private inline function renderUI(backbuffer:Image) {
		ui.begin(backbuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
				if(ui.panel(Id.handle({selected: true}), "General")) {
					meshScale.x = ui.slider(Id.handle({value: meshScale.x}), "Mesh Scale X", 0.01, 4, true, 100, true);
					meshScale.y = ui.slider(Id.handle({value: meshScale.y}), "Mesh Scale Y", 0.01, 4, true, 100, true);
					meshScale.z = ui.slider(Id.handle({value: meshScale.z}), "Mesh Scale Z", 0.01, 4, true, 100, true);
					deltaAngle.x = ui.slider(Id.handle({value: deltaAngle.x}), "Delta Angle X", -1, 1, true, 100, true);
					deltaAngle.y = ui.slider(Id.handle({value: deltaAngle.y}), "Delta Angle Y", -1, 1, true, 100, true);
					deltaAngle.z = ui.slider(Id.handle({value: deltaAngle.z}), "Delta Angle Z", -1, 1, true, 100, true);
				}
				if(ui.panel(Id.handle({selected: true}), "Mesh Type")) {
					if(ui.button("Cube Smooth")) { meshType = MeshType.CUBE_OBJ; }
					if(ui.button("Sphere Smooth")) { meshType = MeshType.SPHERE_OBJ; }
					if(ui.button("Torus Smooth")) { meshType = MeshType.TORUS_OBJ; }
					if(ui.button("Suzanne Smooth")) { meshType = MeshType.SUZANNE_OBJ; }
					if(ui.button("Racing Car Smooth")) { meshType = MeshType.CAR_FORMULA_OBJ; }
					if(ui.button("Cube Vertex")) { meshType = MeshType.CUBE_STL; }
					if(ui.button("Sphere Vertex")) { meshType = MeshType.SPHERE_STL; }
					if(ui.button("Torus Vertex")) { meshType = MeshType.TORUS_STL; }
					if(ui.button("Suzanne Vertex")) { meshType = MeshType.SUZANNE_STL; }
					if(ui.button("Racing Car Vertex")) { meshType = MeshType.CAR_FORMULA_STL; }
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