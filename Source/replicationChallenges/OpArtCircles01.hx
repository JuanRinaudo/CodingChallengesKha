package replicationChallenges;

import zui.Zui.Align;
import kext.g4basics.Camera3D;
import kext.Application;
import kext.AppState;
import kext.g4basics.BasicPipeline;
import kext.extensions.ColorExt;

import kha.graphics2.ImageScaleQuality;
import kha.graphics4.ConstantLocation;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.Usage;
import kha.Image;
import kha.Shaders;
import kha.Framebuffer;
import kha.Color;
import kha.math.Vector2;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.math.FastVector4;

import zui.Ext;
import zui.Id;
import utils.ZUIUtils;

using tweenxcore.Tools;

class OpArtCircles01 extends AppState {    
	private static inline var CANVAS_WIDTH:Int = 1080;
	private static inline var CANVAS_HEIGHT:Int = 1080;
	private static inline var NAME:String = "Op Art Circles 01";

	private var pipeline:BasicPipeline;

	private var projectionMatrix:FastMatrix4;
	private var viewMatrix:FastMatrix4;
	private var modelMatrix:FastMatrix4;
	private var projectionViewMatrix:FastMatrix4;

	private var locationMVPMatrix:ConstantLocation;
	private var locationTintColor:ConstantLocation;

	private var mainColor:Color;
	private var secondaryColor:Color;
	
	private var radius:Float = CANVAS_WIDTH;
	private var circleCount:Int = 35;
	private var circleResolution:Int = 20;
	private var colorIndexOffset:Float = 0.05;
	private var colorAnimateTime:Float = 3;
	private var rotationSpeed:Float = 0.03;
	private var rotationAnimateTime:Float = 3;

	private var rotationIndexEasing:Int = 35;
	private var colorIndexEasing:Int = 20;
	private var mainEasing:Int = 18;
	private var secondEasing:Int = 20;

	private var loop = true;
	private var running:Bool = true;
	private var time:Float = 0;
	private var timeSpeed:Float = 1;

	private var vertexBuffer:VertexBuffer;
	private var indexBufferMain:IndexBuffer;
	private var indexBufferSecond:IndexBuffer;

	public static function initApplication() {
		return new Application(
			{title: OpArtCircles01.NAME, width: OpArtCircles01.CANVAS_WIDTH, height: OpArtCircles01.CANVAS_HEIGHT},
			{initState: OpArtCircles01, defaultFontName: "KenPixel", imgScaleQuality: ImageScaleQuality.High}
		);
    }

	public function new() {
		super();

		var camera:Camera3D = new Camera3D();
		camera.orthogonal(Application.height, Application.ratio);
		camera.transform.setPositionXYZ(0, 0, 10);
		camera.lookAt(new FastVector3(0, 0, 0));
		Application.mainCamera = camera;

		radius = Application.width * 1.5 * Application.ratio;

		setupPipeline();

		generateBuffer();
		
		mainColor = Color.White;
		secondaryColor = Color.Black;
	}

	private function generateBuffer() {
		var bufferSize = circleResolution * 3 + 3;
		vertexBuffer = new VertexBuffer(bufferSize, pipeline.vertexStructure, Usage.StaticUsage);
		indexBufferMain = new IndexBuffer(bufferSize, Usage.StaticUsage);
		indexBufferSecond = new IndexBuffer(bufferSize, Usage.StaticUsage);

		var vertexes = vertexBuffer.lock();
		var vertexIndex = 0;

		vertexes.set(0, 0);
		vertexes.set(1, 0);
		vertexes.set(2, 0);
		vertexIndex += 3;

		var circleIndex = 0;
		while(circleIndex < circleResolution) {
			var angle = Math.PI * 2 * (circleIndex / circleResolution);
			vertexes.set(vertexIndex + 0, Math.cos(angle));
			vertexes.set(vertexIndex + 1, Math.sin(angle));
			vertexes.set(vertexIndex + 2, 0);
			vertexIndex += 3;
			circleIndex++;
		}
		vertexBuffer.unlock();

		var indexes = indexBufferMain.lock();
		var index = 0;
		var indexVertexIndex = 1;
		while(indexVertexIndex < circleResolution) {
			indexes.set(index + 0, 0);
			indexes.set(index + 1, indexVertexIndex + 0);
			indexes.set(index + 2, indexVertexIndex + 1);
			index += 3;
			indexVertexIndex+=2;
		}
		if(indexVertexIndex % 2 == 0) {
			indexes.set(index + 0, 0);
			indexes.set(index + 1, circleResolution);
			indexes.set(index + 2, 1);
		}
		indexBufferMain.unlock();
		
		var indexes = indexBufferSecond.lock();
		var index = 0;
		var indexVertexIndex = 2;
		while(indexVertexIndex < circleResolution) {
			indexes.set(index + 0, 0);
			indexes.set(index + 1, indexVertexIndex + 0);
			indexes.set(index + 2, indexVertexIndex + 1);
			index += 3;
			indexVertexIndex+=2;
		}
		if(indexVertexIndex % 2 == 0) {
			indexes.set(index + 0, 0);
			indexes.set(index + 1, circleResolution);
			indexes.set(index + 2, 1);
		}
		indexBufferSecond.unlock();
	}
	
	private inline function setupPipeline() {
		var vertexStructure:VertexStructure = new VertexStructure();
		vertexStructure.add(name, VertexData.Float3);
		pipeline = new BasicPipeline(Shaders.tinted_vert, Shaders.tinted_frag, null, vertexStructure);
		pipeline.compile();

		locationMVPMatrix = pipeline.getConstantLocation("MVP_MATRIX");
		locationTintColor = pipeline.getConstantLocation("TINT_COLOR");
	}

	override function update(delta:Float) {
		super.update(delta);

		if(running) {
			time += delta * timeSpeed;
		}
	}

	override public function render(backbuffer:Image) {
		beginAndClear3D(backbuffer, Color.fromBytes(85, 85, 85));
		
		var position:Vector2 = new Vector2(0, 0);
		
		for(i in 0...circleCount) {
			drawSplitedCircle(backbuffer, position, radius - i * (radius / circleCount),
				mainColor, secondaryColor, i);
		}

        end3D(backbuffer);
	}
	
	private function drawSplitedCircle(backbuffer:Image, position:Vector2, radius:Float, mainColor:Color, secondaryColor:Color, circleIndex:Int)
	{
		var rotationIndexOffset = ZUIUtils.callEasingByIndex(rotationIndexEasing, (circleIndex / circleCount)).lerp(0, circleCount);
		var colorIndexOffset = ZUIUtils.callEasingByIndex(colorIndexEasing, (circleIndex / circleCount)).lerp(0, circleCount);

		var finalTime = loop ? Math.sin(time) : time;

		var rotationOffsetTime = rotationAnimateTime > 0 ? 
			finalTime * rotationSpeed * rotationIndexOffset * rotationAnimateTime :
			1;
		var colorOffsetTime = colorAnimateTime > 0 ? 
			((finalTime + colorIndexOffset) % colorAnimateTime) / colorAnimateTime :
			1;

		backbuffer.g4.setPipeline(pipeline);
		var modelMatrix:FastMatrix4 = FastMatrix4.identity()
			.multmat(FastMatrix4.translation(position.x, position.y, 0))
			.multmat(FastMatrix4.scale(radius, radius, radius))
			.multmat(FastMatrix4.rotation(0, rotationOffsetTime, 0));
		backbuffer.g4.setMatrix(locationMVPMatrix, pipeline.getMVPMatrix(modelMatrix));

		backbuffer.g4.setVertexBuffer(vertexBuffer);

		var mainOffsetTime = ZUIUtils.callEasingByIndex(mainEasing, colorOffsetTime);

		var mainColorLerped:Color = ColorExt.lerp(mainColor, secondaryColor, mainOffsetTime);
		backbuffer.g4.setVector4(locationTintColor, new FastVector4(mainColorLerped.R, mainColorLerped.G, mainColorLerped.B, mainColorLerped.A));
		backbuffer.g4.setIndexBuffer(indexBufferMain);
		backbuffer.g4.drawIndexedVertices();

		var secondOffsetTime = ZUIUtils.callEasingByIndex(secondEasing, colorOffsetTime);

		var secondColorLerped:Color = ColorExt.lerp(secondaryColor, mainColor, secondOffsetTime);
		backbuffer.g4.setVector4(locationTintColor, new FastVector4(secondColorLerped.R, secondColorLerped.G, secondColorLerped.B, secondColorLerped.A));
		backbuffer.g4.setIndexBuffer(indexBufferSecond);
		backbuffer.g4.drawIndexedVertices();
	}

	override public function renderFramebuffer(framebuffer:Framebuffer) {
		var lastCircleResolution = circleResolution;

		ui.begin(framebuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
				if(ui.panel(Id.handle({selected: true}), "Control")) {
					if(ui.button(running ? "Pause" : "Play")) {
						running = !running;
					}
					if(ui.button("Reset")) {
						time = 0;
					}
					if(ui.button("Next Frame")) {
						running = false;
						time += Application.deltaTime;
					}
					loop = ui.check(Id.handle({selected: loop}), "Loop");
					timeSpeed = ui.slider(Id.handle({value: timeSpeed}), "Time Speed", 0, 2, true, 100);
				}
				if(ui.panel(Id.handle({selected: true}), "General")) {
					radius = ui.slider(Id.handle({value: radius}), "Radius", 1, Application.width * 1.5 * Application.ratio, true, 1);
					circleCount = Math.floor(ui.slider(Id.handle({value: circleCount}), "Circle Count", 1, 250, true, 1));
					circleResolution = Math.floor(ui.slider(Id.handle({value: circleResolution}), "Circle Resolution", 3, 250, true, .5));

					ui.separator();

					ui.text("Rotation", Align.Center);
					rotationAnimateTime = ui.slider(Id.handle({value: rotationAnimateTime}), "Rotation Animate Time", 0, 100, true, 10);
					rotationSpeed = ui.slider(Id.handle({value: rotationSpeed}), "Rotation Speed", 0, 1, true, 100);
					rotationIndexEasing = ZUIUtils.tweenEasing(ui, Id.handle({value: rotationIndexEasing}), "Index Rotation Offset Easing");

					ui.text("Color", Align.Center);
					colorAnimateTime = ui.slider(Id.handle({value: colorAnimateTime}), "Color animate Time", 0, 60, true, 10);
					// colorIndexOffset = ui.slider(Id.handle({value: colorIndexOffset}), "Color Index Offset", 0.01, 1, true, 100);
					colorIndexEasing = ZUIUtils.tweenEasing(ui, Id.handle({value: colorIndexEasing}), "Index Color Offset Easing");

					ui.separator();

					ui.text("Main Color", Align.Center);
					mainColor = Ext.colorPicker(ui, Id.handle({color: mainColor}), false);
					ui.text("Secondary Color", Align.Center);
					secondaryColor = Ext.colorPicker(ui, Id.handle({color: secondaryColor}), false);

					mainEasing = ZUIUtils.tweenEasing(ui, Id.handle({value: mainEasing}), "Main Easing");
					secondEasing = ZUIUtils.tweenEasing(ui, Id.handle({value: secondEasing}), "Second Easing");
				}
			}
		}
		ui.end();

		if(lastCircleResolution != circleResolution) {
			generateBuffer();
		}
	}
    
}