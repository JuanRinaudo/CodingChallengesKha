package kext;

import kha.Assets;
import kha.Image;
import kha.Color;

import kext.g4basics.BasicMesh;

import zui.Zui;

class AppState extends Basic {

	public function new() {
		super();
	}

	private inline function beginAndClear(backbuffer:Image, clearColor:Color = null) {
		backbuffer.g4.begin();
		backbuffer.g4.clear(clearColor != null ? clearColor : Color.Black, Math.POSITIVE_INFINITY);
	}

	private inline function createZUI() {
		return new Zui({font: Assets.fonts.KenPixel});
	}

	private inline function setBufferMesh(backbuffer:Image, mesh:BasicMesh) {
		backbuffer.g4.setVertexBuffer(mesh.vertexBuffer);
		backbuffer.g4.setIndexBuffer(mesh.indexBuffer);
	}

}