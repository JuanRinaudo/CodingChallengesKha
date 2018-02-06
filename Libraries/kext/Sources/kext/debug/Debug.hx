package kext.debug;

import kext.g4basics.BasicMesh;
import kext.g4basics.BasicPipeline;
import kext.loaders.OBJMeshLoader;

import kha.Assets;
import kha.Color;
import kha.Image;
import kha.Shaders;
import kha.math.Vector3;
import kha.math.FastMatrix4;
import kha.input.KeyCode;

class Debug extends Basic {

	public static var debugOn:Bool = false;
	
	private static var pipeline:BasicPipeline;
	private static var cube:BasicMesh;

	public function new() {
		super();

		pipeline = new BasicPipeline(Shaders.colored_vert, Shaders.colored_frag);
		pipeline.compile();
		Application.onLoadComplete.add(loadCompleteHandler);
	}

	override public function update(delta:Float) {
		var keyboard = Application.keyboard;
		if(keyboard.keyPressed(KeyCode.Shift) && keyboard.keyPressed(KeyCode.D)) {
			debugOn = !debugOn;
		}
	}

	override public function render(backbuffer:Image) {

	}

	private function loadCompleteHandler() {
		cube = BasicMesh.getOBJMesh(Assets.blobs.cube_obj, pipeline.vertexStructure, 0, 3, 6, 8, Color.White);
	}

	public static function drawDebugCube(backbuffer:Image, projectionViewMatrix:FastMatrix4, position:Vector3, size:Float) {
		backbuffer.g4.setPipeline(pipeline);

		backbuffer.g4.setVertexBuffer(cube.vertexBuffer);
		backbuffer.g4.setIndexBuffer(cube.indexBuffer);

		var modelMatrix:FastMatrix4 = FastMatrix4.identity()
			.multmat(FastMatrix4.translation(position.x, position.y, position.z))
			.multmat(FastMatrix4.scale(size, size, size));
		var mvpMatrix:FastMatrix4 = projectionViewMatrix.multmat(modelMatrix);
		backbuffer.g4.setMatrix(pipeline.locationMVPMatrix, mvpMatrix);
		backbuffer.g4.drawIndexedVertices();
	}

}