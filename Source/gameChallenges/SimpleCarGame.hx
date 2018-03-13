package gameChallenges;

import kha.Assets;
import kha.Color;
import kha.Image;
import kha.Framebuffer;
import kha.Shaders;

import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.FastVector4;

import kha.input.KeyCode;

import kext.Application;
import kext.AppState;

import kext.g4basics.BasicPipeline;
import kext.g4basics.BasicMesh;

import kha.graphics4.ConstantLocation;

import kext.math.MathExt;
import kext.math.BoundingCube;

import kext.debug.Debug;

import zui.Id;
import utils.ZUIUtils;

typedef AICar = {
	alive:Bool,
	lane:Int,
	carSpeed:Vector2,
	carModel:Int,
	position:Vector3
}

class SimpleCarGame extends AppState {
	private static inline var CANVAS_WIDTH:Int = 768;
	private static inline var CANVAS_HEIGHT:Int = 1024;
	private static inline var NAME:String = "Simple Car Game";

	private var pipeline:BasicPipeline;
	private var meshRacingCar:BasicMesh;
	private var grassMesh:BasicMesh;
	private var roadMesh:BasicMesh;
	private var meshSedanCar:BasicMesh;

	private var gameScore:Int = 0;
	private var gameTime:Float = 0;

	private var drawBounds:Bool;
	private var boundsRacingCar:BoundingCube;
	private var boundsSedanCar:BoundingCube;

	private var aiCars:Array<AICar>;
	private var creationCounter:Float = 0;
	private var aiCreationTime:Float = 2;

	private var locationDirectionalLight:ConstantLocation;
	private var locationDirectionalColor:ConstantLocation;
	private var locationAmbientLight:ConstantLocation;

	private var worldSizeY:Float = 20;
	private var laneCount:Int = 3;
	private var laneWidth:Float = 1.6;

	private var carSpeed:Vector2 = new Vector2(5, 5);
	private var carWidth:Float = 0.7;
	private var carTargetZ:Float = 0;
	private var carMaxZ:Float = 10;
	private var carTargetLane:Int = 0;
	private var carBoundScale:Vector3 = new Vector3(0.9, 1, 0.9);

	private var cameraFrom:Vector3 = new Vector3(-9, -13, -15);
	private var cameraTo:Vector3 = new Vector3(0, 0, -6);
	private var orthogonalOrPerspective:Bool = true;
	private var cameraSize:Float = 8;
	private var cameraFov:Float = 28;

	private var lightDirection:FastVector4 = new FastVector4(0.5, 1, -1, 1);
	private var lightColor:FastVector4 = new FastVector4(1, 1, 1, 1);
	private var ambientColor:FastVector4 = new FastVector4(0.05, 0.05, 0.05, 1);

	private var fxaaOn:Bool = true;

	public static function initApplication() {
		return new Application(
			{title: SimpleCarGame.NAME, width: SimpleCarGame.CANVAS_WIDTH, height: SimpleCarGame.CANVAS_HEIGHT},
			{initState: SimpleCarGame}
		);
	}

	public function new() {
		super();

		pipeline = new BasicPipeline(Shaders.directionalLighting_vert, Shaders.directionalLighting_frag);
		pipeline.orthogonal(cameraSize, CANVAS_WIDTH / CANVAS_HEIGHT);
		pipeline.cameraLookAtXYZ(0, -2, -1, 0, 0, -3);
		pipeline.compile();

		locationDirectionalLight = pipeline.getConstantLocation("LIGHT_DIRECTION");
		locationDirectionalColor = pipeline.getConstantLocation("LIGHT_COLOR");
		locationAmbientLight = pipeline.getConstantLocation("AMBIENT_COLOR");

		meshRacingCar = BasicMesh.getOBJMesh(Assets.blobs.carFormula_obj, pipeline.vertexStructure, Color.fromFloats(0, 0, 0.8, 1));
		boundsRacingCar = BoundingCube.fromBasicMesh(meshRacingCar);

		grassMesh = BasicMesh.getOBJMesh(Assets.blobs.quad_obj, pipeline.vertexStructure, Color.fromFloats(0, 0.6, 0, 1));
		grassMesh.scale(new Vector3(15, 1, worldSizeY));
		roadMesh = BasicMesh.getOBJMesh(Assets.blobs.quad_obj, pipeline.vertexStructure, Color.fromFloats(0.4, 0.4, 0.4, 1));
		roadMesh.translate(new Vector3(0, 0.01, 0));

		meshSedanCar = BasicMesh.getOBJMesh(Assets.blobs.carSedan_obj, pipeline.vertexStructure, Color.fromFloats(0.6, 0, 0, 2));
		meshSedanCar.rotate(new Vector3(Math.PI, 0, 0));
		boundsSedanCar = BoundingCube.fromBasicMesh(meshSedanCar);

		aiCars = [];
		for(i in 0...10) {
			createAICar();
		}

		Application.setPostProcessingShader(Shaders.postFXAA_frag);
		Application.setPostProcesingConstantLocation(Shaders.postFXAA_frag, FLOAT, "FXAA_SPAN_MAX", 10);
		Application.setPostProcesingConstantLocation(Shaders.postFXAA_frag, FLOAT, "FXAA_REDUCE_MIN", 0.03);
		Application.setPostProcesingConstantLocation(Shaders.postFXAA_frag, FLOAT, "FXAA_REDUCE_MUL", 0.1);
	}

	override public function render(backbuffer:Image) {
		beginAndClear(backbuffer);

		if(orthogonalOrPerspective) { pipeline.orthogonal(cameraSize, CANVAS_WIDTH / CANVAS_HEIGHT); }
		else { pipeline.perspective(cameraFov * (Math.PI / 180), CANVAS_WIDTH / CANVAS_HEIGHT); }
		pipeline.cameraLookAtXYZ(cameraFrom.x, cameraFrom.y, cameraFrom.z, cameraTo.x, cameraTo.y, cameraTo.z);

		backbuffer.g4.setPipeline(pipeline);
		backbuffer.g4.setVector4(locationDirectionalLight, lightDirection);
		backbuffer.g4.setVector4(locationDirectionalColor, lightColor);
		backbuffer.g4.setVector4(locationAmbientLight, ambientColor);
		meshRacingCar.drawMesh(backbuffer, pipeline, false);

		grassMesh.drawMesh(backbuffer, pipeline, false);
		roadMesh.setSize(new Vector3(laneWidth * Math.floor(laneCount * .5) + carWidth, 1, 20));
		roadMesh.drawMesh(backbuffer, pipeline, false);

		if(boundsRacingCar.size.x != carBoundScale.x || boundsRacingCar.size.y != carBoundScale.y || boundsRacingCar.size.z != carBoundScale.z)
			{ boundsRacingCar.setScale(carBoundScale); }

		var collision:AICar = null;
		for(car in aiCars) {
			if(car.alive) {
				meshSedanCar.setPosition(car.position);
				boundsSedanCar.setPosition(car.position);
				meshSedanCar.drawMesh(backbuffer, pipeline, false);

				if(boundsSedanCar.size.x != boundsRacingCar.size.x || boundsSedanCar.size.y != boundsRacingCar.size.y || boundsSedanCar.size.z != boundsRacingCar.size.z)
					{ boundsSedanCar.setScale(carBoundScale); }

				if(drawBounds) { Debug.drawDebugBoundingCube(backbuffer, pipeline, boundsSedanCar); }
				if(boundsRacingCar.checkCubeOverlap(boundsSedanCar)) {
					collision = car;
				}
			}
		}

		if(collision != null) {
			restart();
		} else {
			if(drawBounds) { Debug.drawDebugBoundingCube(backbuffer, pipeline, boundsRacingCar); }
		}

		backbuffer.g4.end();

		backbuffer.g2.begin(false);
		backbuffer.g2.end();
	}

	override public function update(delta:Float) {
		getPlayerInput(delta);
		movePlayerCar(delta);

		tryCreateAICar(delta);
		moveAICars(delta);

		gameTime += delta;
	}

	private inline function restart() {
		Application.reset();
	}

	private function getPlayerInput(delta:Float) {
		if(Application.keyboard.keyPressed(KeyCode.D) && carTargetLane < Math.floor(laneCount * .5)) {
			carTargetLane++;
		} else if(Application.keyboard.keyPressed(KeyCode.A) && carTargetLane > -Math.floor(laneCount * .5)) {
			carTargetLane--;
		}

		carTargetZ += delta;
		if(Application.keyboard.keyDown(KeyCode.W)) {
			carTargetZ -= delta * carSpeed.y;
		} else if(Application.keyboard.keyDown(KeyCode.S)) {
			carTargetZ += delta * carSpeed.y;
		}
		carTargetZ = MathExt.clamp(carTargetZ, -carMaxZ, 0);
	}

	private inline function movePlayerCar(delta:Float) {
		var carDeltaX = carTargetLane * laneWidth - meshRacingCar.position.x;
		var translation:Vector3 = new Vector3(0, 0, 0);
		if(Math.abs(carDeltaX) > 0.05) {
			translation.x = delta * carSpeed.x * MathExt.clamp(carDeltaX, -1, 1);
		}
		
		if(carTargetZ != 1) {
			var carDeltaZ = carTargetZ - meshRacingCar.position.z;
			translation.z = delta * carSpeed.y * MathExt.clamp(carDeltaZ, -1, 1);
		}
		
		meshRacingCar.translate(translation);
		boundsRacingCar.translate(translation);
	}

	private inline function tryCreateAICar(delta:Float) {
		creationCounter += delta;
		if(creationCounter > aiCreationTime) {
			var car:AICar = getDeadAICar();
			if(car != null) { car.alive = true; }
			else { car = createAICar(); }
			car.lane = Math.floor(Math.random() * laneCount) - Math.floor(laneCount * .5);
			car.position.z = -worldSizeY;
			car.position.x = laneWidth * car.lane;
			
			creationCounter = 0;
		}
	}

	private inline function createAICar():AICar {
		var car:AICar = {
			alive: false,
			lane: 0,
			carSpeed: new Vector2(0, 1 + Math.random()),
			carModel: 0,
			position: new Vector3(0, 0, 0)
		};
		aiCars.push(car);
		return car;
	}

	private function getDeadAICar():AICar {
		for(car in aiCars) {
			if(!car.alive) { return car; }
		}
		return null;
	}

	private inline function moveAICars(delta:Float) {
		for(car in aiCars) {
			if(car.alive) {
				var deltaZ:Float = delta * (carSpeed.y + car.carSpeed.y);
				car.position.z += deltaZ;
				if(car.position.z > worldSizeY) {
					car.alive = false;
				}
			}
		}
	}

	override public function renderFramebuffer(framebuffer:Framebuffer) {
		var fxaaStatus:Bool = fxaaOn;

		ui.begin(framebuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: false}), "UI On/Off");
			if(uiToggle) {
				if(ui.panel(Id.handle({selected: false}), "General")) {
					worldSizeY = ui.slider(Id.handle({value: worldSizeY}), "World Wrap Y", 0, 100, true, 1);
					laneWidth = ui.slider(Id.handle({value: laneWidth}), "Lane Width", 0, 3, true, 10);
					laneCount = Math.floor(ui.slider(Id.handle({value: laneCount}), "Lane Count", 0, 10, true, 1));
				}
				if(ui.panel(Id.handle({selected: false}), "Camera")) {
					ZUIUtils.vector3Sliders(ui, Id.handle(), cameraFrom, "Camera From", -worldSizeY, worldSizeY, 10);
					ZUIUtils.vector3Sliders(ui, Id.handle(), cameraTo, "Camera To", -worldSizeY, worldSizeY, 10);
					orthogonalOrPerspective = ui.check(Id.handle({selected: orthogonalOrPerspective}), "Orthogonal / Perspective Camera");
					cameraSize = ui.slider(Id.handle({value: cameraSize}), "Camera Size", 0, 20, true, 10);
					cameraFov = ui.slider(Id.handle({value: cameraFov}), "Camera FOV", 0, 180, true, 100);
				}
				if(ui.panel(Id.handle({selected: false}), "Car Movement")) {
					ui.text('Car target Lane: $carTargetLane');
					ui.text("Racing Car Mesh Position: " + meshRacingCar.position);
					ZUIUtils.vector2Sliders(ui, Id.handle(), carSpeed, "Car Speed", 0, 30, 10);
					ui.text('Car target Z: $carTargetZ');
					carMaxZ = ui.slider(Id.handle({value: carMaxZ}), "Car Max Z", 0, worldSizeY, true, 10);
					carWidth = ui.slider(Id.handle({value: carWidth}), "Car Width", 0, 3, true, 10);
				}
				if(ui.panel(Id.handle({selected: false}), "Collisions")) {
					drawBounds = ui.check(Id.handle(), "Draw Collision Bounds");
					ZUIUtils.vector3Sliders(ui, Id.handle(), carBoundScale, "Car Bounds Scale", 0, 2, 100);
				}
				ZUIUtils.lightingParameters(ui, Id.handle(), lightDirection, lightColor, ambientColor, false);
				if(ui.panel(Id.handle({selected: false}), "AI Cars")) {
					aiCreationTime = ui.slider(Id.handle({value: aiCreationTime}), "AI Creation Time", 0, 10, true, 10);
				}
				if(ui.panel(Id.handle({selected: false}), "Post Processing")) {
					fxaaOn = ui.check(Id.handle({selected: fxaaOn}), "FXAA");
				}
			}
		}
		ui.end();

		if(fxaaStatus != fxaaOn) {
			if(fxaaOn) {
				Application.setPostProcessingShader(Shaders.postFXAA_frag);
			} else {
				Application.removePostProcessingShader(Shaders.postFXAA_frag);
			}
		}
	}

}