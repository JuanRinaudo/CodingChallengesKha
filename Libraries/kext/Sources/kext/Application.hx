package kext;

import kha.Color;
import kha.Image;
import kha.Assets;
import kha.System;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System.SystemOptions;
import kha.Scaler;

import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;

typedef ApplicationOptions = {
	?updateStart:Float,
	?updatePeriod:Float,
	initState:Class<AppState>,
	?stateArguments:Array<Dynamic>
}

class Application {

	private var sysOptions:SystemOptions;
	private var options:ApplicationOptions;

	private var currentState:AppState;

	public static var backbuffer:Image;

	public function new(systemOptions:SystemOptions, applicationOptions:ApplicationOptions) {
		sysOptions = systemOptions;
		options = defaultApplicationOptions(applicationOptions);
		System.init(systemOptions, onInit);
	}

	private function defaultApplicationOptions(applicationOptions:ApplicationOptions) {
		if(applicationOptions.updateStart == null) { applicationOptions.updateStart = 0; }
		if(applicationOptions.updatePeriod == null) { applicationOptions.updatePeriod = 1 / 60; }
		if(applicationOptions.stateArguments == null) { applicationOptions.stateArguments = []; }
		return applicationOptions;
	}

	private function onInit() {
		backbuffer = Image.createRenderTarget(sysOptions.width, sysOptions.height, TextureFormat.RGBA32, DepthStencilFormat.DepthOnly);

		System.notifyOnRender(renderPass);

		Assets.loadEverything(onLoadComplete);
	}

	private function onLoadComplete() {
		Scheduler.addTimeTask(updatePass, options.updateStart, options.updatePeriod);
		
		currentState = Type.createInstance(options.initState, options.stateArguments);
	}

	private function renderPass(framebuffer:Framebuffer) {
		if(currentState != null) {
			currentState.render(backbuffer);
		}

		framebuffer.g2.begin();
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	private function updatePass() {
		if(currentState != null) {
			currentState.update(options.updatePeriod);
		}
	}

}