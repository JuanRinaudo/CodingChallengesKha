package kext;

import kha.Image;
import kha.Color;

import kext.g4basics.BasicMesh;

class AppState {

	public function new() {

	}

	public function render(backbuffer:Image) {

	}

	private inline function beginAndClear(backbuffer:Image, clearColor:Color = null) {
		backbuffer.g4.begin();
		backbuffer.g4.clear(clearColor != null ? clearColor : Color.Black, Math.POSITIVE_INFINITY);
	}

	private inline function setBufferMesh(backbuffer:Image, mesh:BasicMesh) {
		backbuffer.g4.setVertexBuffer(mesh.vertexBuffer);
		backbuffer.g4.setIndexBuffer(mesh.indexBuffer);
	}

	public function update(delta:Float) {

	}

}