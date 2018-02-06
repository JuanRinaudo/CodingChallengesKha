package kext;

import kha.Assets;
import kha.Image;
import kha.Color;

import kext.g4basics.BasicMesh;

import zui.Zui;

class AppState extends Basic {

	private var ui:Zui;
	private var uiToggle:Bool = true;

	public function new() {
		super();

		createZUI();
	}

	private inline function beginAndClear(backbuffer:Image, clearColor:Color = null) {
		backbuffer.g4.begin();
		backbuffer.g4.clear(clearColor != null ? clearColor : Color.Black, Math.POSITIVE_INFINITY);
	}

	private inline function createZUI() {
		ui = new Zui({font: Assets.fonts.KenPixel});
	}

}