package replicationChallenges;

import kext.Application;
import kext.AppState;

import kha.graphics2.GraphicsExtension;
import kha.graphics2.ImageScaleQuality;
import kha.graphics4.Graphics2.ColoredShaderPainter;
import kha.Image;
import kha.Framebuffer;
import kha.Color;
import kha.math.Vector2i;
import kha.math.Vector2;

import zui.Ext;
import zui.Id;

class LeParcNoodles extends AppState {    
	private static inline var CANVAS_WIDTH:Int = 1080;
	private static inline var CANVAS_HEIGHT:Int = 1080;
	private static inline var NAME:String = "Beesandbombs Sine Cubes";

	private var mainColors:Array<Color>;
	private var secondaryColors:Array<Color>;

	private var noodles:Vector2i = new Vector2i(8, 8);
	private var padding:Vector2 = new Vector2(0.1, 0.1);

	private var noodleSize:Float = 30;
	private var movementDelta:Float = 45;

	private var minColor:Float = 0.25;
	private var maxColor:Float = 1.0;

	private var offsetDelta:Float = 3.14;
	private var offsetByRow:Bool = true;
	
	private var trailYDelta:Int = 20;

	public static function initApplication() {
		return new Application(
			{title: LeParcNoodles.NAME, width: LeParcNoodles.CANVAS_WIDTH, height: LeParcNoodles.CANVAS_HEIGHT},
			{initState: LeParcNoodles, defaultFontName: "KenPixel", imgScaleQuality: ImageScaleQuality.High}
		);
    }

	public function new() {
		super();
		
		mainColors = [];
		secondaryColors = [];
    }

	override public function render(backbuffer:Image) {
		beginAndClear3D(backbuffer, Color.Black);

		trace(Application.width + " " + Application.height);
		
		var containerSize:Vector2 = new Vector2(Application.width * (1 - padding.x * 2), Application.height * (1 - padding.y * 2));
		var delta:Vector2 = new Vector2(containerSize.x / (noodles.x - 1), containerSize.y / (noodles.y - 1));
		var position:Vector2 = new Vector2(0, Application.height * padding.x);

		if(noodles.y == 1) { position.y = Application.height * 0.5; }

		var noodleCount:Int = 0;
		var rowCount:Int = 0;
		for(y in 0...noodles.y) {
			if(noodles.x == 1) { position.x = Application.width * 0.5; }
			else { position.x = Application.width * padding.x; }
			
			for(x in 0...noodles.x) {
				if(mainColors.length < noodleCount) {
					var mainColor:Color = Color.fromFloats(Math.random() * (maxColor - minColor) + minColor,
						Math.random() * (maxColor - minColor) + minColor,
						Math.random() * (maxColor - minColor) + minColor);
					mainColors.push(mainColor);
					secondaryColors.push(Color.fromFloats(mainColor.R * 0.75, mainColor.G * 0.75, mainColor.B * 0.75));
				}

				drawNoodle(backbuffer, position.x, position.y, noodleSize, movementDelta, mainColors[noodleCount], secondaryColors[noodleCount], Application.time + (offsetByRow ? rowCount : noodleCount) * offsetDelta);
				position.x += delta.x;

				noodleCount++;
			}
			rowCount++;
			position.y += delta.y;
		}

        end3D(backbuffer);
	}
	
	private function drawNoodle(backbuffer:Image, startX:Float, startY:Float, radius:Float, moveDelta:Float, topColor:Color, bottomColor:Color, offsetY:Float)
	{
		backbuffer.g2.color = bottomColor;
		var yMovement:Float = 0;
		while(yMovement < Math.floor(Application.height)) {
			GraphicsExtension.fillCircle(backbuffer.g2, startX + Math.sin(yMovement * 0.01 + offsetY) * moveDelta, startY + yMovement, radius);
			yMovement += trailYDelta;
		}
		backbuffer.g2.color = topColor;
		GraphicsExtension.fillCircle(backbuffer.g2, startX + Math.sin(offsetY) * moveDelta, startY, radius);
	}

	override public function renderFramebuffer(framebuffer:Framebuffer) {
		ui.begin(framebuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
				if(ui.panel(Id.handle({selected: true}), "General")) {
					noodleSize = Math.floor(ui.slider(Id.handle({value: noodleSize}), "Noodle Size", 1, 50, true, 1));

					noodles.x = Math.floor(ui.slider(Id.handle({value: noodles.x}), "Noodles X", 1, 100, true, 1));
					noodles.y = Math.floor(ui.slider(Id.handle({value: noodles.y}), "Noodles Y", 1, 100, true, 1));

					padding.x = ui.slider(Id.handle({value: padding.x}), "Padding X", 0, 1, true, 100);
					padding.y = ui.slider(Id.handle({value: padding.y}), "Padding Y", 0, 1, true, 100);

					trailYDelta = Math.floor(ui.slider(Id.handle({value: trailYDelta}), "Trail Y Delta", 1, 100, true, 1));
					movementDelta = Math.floor(ui.slider(Id.handle({value: movementDelta}), "Movement Delta", 0, 100, true, 1));

					minColor = ui.slider(Id.handle({value: minColor}), "Min Color", 0, 1, true, 100);
					maxColor = ui.slider(Id.handle({value: maxColor}), "Max Color", 0, 1, true, 100);

					offsetDelta = ui.slider(Id.handle({value: offsetDelta}), "Offset Delta", 0, 3.14*2, true, 100);
					offsetByRow = ui.check(Id.handle({selected: offsetByRow}), "Offset By Row");

					if(ui.button("Reset Colors")) {
						mainColors = [];
						secondaryColors = [];
					}
				}
			}
		}
		ui.end();
	}
    
}