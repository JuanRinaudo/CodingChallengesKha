package replicationChallenges;

import kha.math.FastMatrix2;
import kha.math.Vector3;
import kext.g4basics.Camera3D;
import kha.graphics5.Usage;
import kext.Application;
import kext.AppState;
import kext.g4basics.BasicMesh;
import kext.g4basics.BasicPipeline;

import kha.graphics2.GraphicsExtension;
import kha.graphics2.ImageScaleQuality;
import kha.graphics4.ConstantLocation;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.Usage;
import kha.Assets;
import kha.Image;
import kha.Shaders;
import kha.Framebuffer;
import kha.Color;
import kha.math.Vector2i;
import kha.math.Vector2;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.math.FastVector4;

import zui.Ext;
import zui.Id;

class LeParcNoodles extends AppState {    
	private static inline var CANVAS_WIDTH:Int = 1080;
	private static inline var CANVAS_HEIGHT:Int = 1080;
	private static inline var NAME:String = "Beesandbombs Sine Cubes";

	private var pipeline:BasicPipeline;
	private var cubeMesh:BasicMesh;

	private var projectionMatrix:FastMatrix4;
	private var viewMatrix:FastMatrix4;
	private var modelMatrix:FastMatrix4;
	private var projectionViewMatrix:FastMatrix4;

	private var locationMVPMatrix:ConstantLocation;
	private var locationTintColor:ConstantLocation;

	private var mainColors:Array<Color>;
	private var secondaryColors:Array<Color>;

	private var noodles:Vector2i = new Vector2i(6, 6);
	private var padding:Vector2 = new Vector2(0.22, 0.22);

	private var noodleSize:Float = 55;
	private var movementDelta:Vector2 = new Vector2(80, 0.005);

	private var minColor:Float = 0.15;
	private var maxColor:Float = 1.0;

	private var offsetDelta:Float = 3.14;
	private var rowOffsetX:Float = 10;
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

		var camera:Camera3D = new Camera3D();
		camera.orthogonal(Application.height, Application.width / Application.height);
		camera.transform.setPositionXYZ(Application.width, Application.height, 10);
		camera.lookAt(new FastVector3(Application.width, Application.height, 0));
		Application.mainCamera = camera;

		setupPipeline();
		setupCube();
		
		mainColors = [];
		secondaryColors = [];
	}
	
	private inline function setupPipeline() {
		var vertexStructure:VertexStructure = new VertexStructure();
		vertexStructure.add(name, VertexData.Float3);
		pipeline = new BasicPipeline(Shaders.tinted_vert, Shaders.tinted_frag, null, vertexStructure);
		pipeline.compile();

		locationMVPMatrix = pipeline.getConstantLocation("MVP_MATRIX");
		locationTintColor = pipeline.getConstantLocation("TINT_COLOR");
	}

	private inline function setupCube() {
		cubeMesh = BasicMesh.getOBJMesh(Assets.blobs.cube_obj, pipeline);
	}

	override public function render(backbuffer:Image) {
		beginAndClear3D(backbuffer, Color.White);
		
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

				drawNoodle(backbuffer, position.x - rowOffsetX * (rowCount % 2 == 0 ? -1 : 1), position.y, noodleSize, movementDelta, mainColors[noodleCount], secondaryColors[noodleCount], Application.time + (offsetByRow ? rowCount : noodleCount) * offsetDelta);
				position.x += delta.x;

				noodleCount++;
			}
			rowCount++;
			position.y += delta.y;
		}

        end3D(backbuffer);
	}
	
	private function drawNoodle(backbuffer:Image, startX:Float, startY:Float, radius:Float, moveDelta:Vector2, topColor:Color, bottomColor:Color, offsetY:Float)
	{
		backbuffer.g4.setPipeline(pipeline);
		var modelMatrix:FastMatrix4 = FastMatrix4.identity().multmat(FastMatrix4.translation(startX, startY, 0));
		backbuffer.g4.setMatrix(locationMVPMatrix, pipeline.getMVPMatrix(modelMatrix));

		var stepIndex = 0;
		var steps = Math.ceil(Application.height / trailYDelta * 2);
		var vertexIndex = 0;

		var vertexBuffer:VertexBuffer = new VertexBuffer(steps * 6, pipeline.vertexStructure, Usage.DynamicUsage);
		var vertexes = vertexBuffer.lock();
		while(stepIndex < steps) {
			vertexes.set(vertexIndex + 0, startX + Math.sin(stepIndex * trailYDelta * moveDelta.y + offsetY) * moveDelta.x - radius * 0.5);
			vertexes.set(vertexIndex + 1, startY + stepIndex * trailYDelta - radius * 0.5);
			vertexes.set(vertexIndex + 2, 0);
			vertexes.set(vertexIndex + 3, startX + Math.sin(stepIndex * trailYDelta * moveDelta.y + offsetY) * moveDelta.x - radius * 0.5 + noodleSize * 2);
			vertexes.set(vertexIndex + 4, startY + stepIndex * trailYDelta - radius * 0.5);
			vertexes.set(vertexIndex + 5, 0);

			vertexIndex += 6;
			stepIndex++;
		}
		vertexBuffer.unlock();

		var indexBuffer:IndexBuffer = new IndexBuffer(vertexIndex - 6, Usage.DynamicUsage);
		var indexes = indexBuffer.lock();
		var index = 0;
		var indexVertexIndex = 0;
		while(indexVertexIndex < vertexIndex) {
			indexes.set(index + 0, indexVertexIndex + 0);
			indexes.set(index + 1, indexVertexIndex + 1);
			indexes.set(index + 2, indexVertexIndex + 2);
			indexes.set(index + 3, indexVertexIndex + 2);
			indexes.set(index + 4, indexVertexIndex + 1);
			indexes.set(index + 5, indexVertexIndex + 3);
			index += 6;
			indexVertexIndex += 2;
		}
		indexBuffer.unlock();

		backbuffer.g4.setVector4(locationTintColor, new FastVector4(bottomColor.R, bottomColor.G, bottomColor.B, bottomColor.A));
		backbuffer.g4.setVertexBuffer(vertexBuffer);
		backbuffer.g4.setIndexBuffer(indexBuffer);
		backbuffer.g4.drawIndexedVertices();

		var topCircleResolution = 20;
		var circleIndex = 0;
		vertexIndex = 0;

		vertexBuffer = new VertexBuffer(topCircleResolution * 3 + 3, pipeline.vertexStructure, Usage.DynamicUsage);
		vertexes = vertexBuffer.lock();

		vertexes.set(0, startX + Math.sin(offsetY) * moveDelta.x - radius * 0.5 + noodleSize);
		vertexes.set(1, startY + trailYDelta - noodleSize);
		vertexes.set(2, 0);
		vertexIndex += 3;

		while(circleIndex < topCircleResolution) {
			var angle = Math.PI * 2 * (circleIndex / topCircleResolution);
			vertexes.set(vertexIndex + 0, startX + Math.sin(offsetY) * moveDelta.x - radius * 0.5 + noodleSize + Math.cos(angle) * noodleSize);
			vertexes.set(vertexIndex + 1, startY + radius * 0.5 - noodleSize + Math.sin(angle) * noodleSize);
			vertexes.set(vertexIndex + 2, 0);
			vertexIndex += 3;
			circleIndex++;
		}
		vertexBuffer.unlock();

		indexBuffer = new IndexBuffer(vertexIndex, Usage.DynamicUsage);
		indexes = indexBuffer.lock();
		index = 0;
		indexVertexIndex = 1;
		while(indexVertexIndex < topCircleResolution) {
			indexes.set(index + 0, 0);
			indexes.set(index + 1, indexVertexIndex + 0);
			indexes.set(index + 2, indexVertexIndex + 1);
			index += 3;
			indexVertexIndex++;
		}
		indexes.set(index + 0, 0);
		indexes.set(index + 1, topCircleResolution);
		indexes.set(index + 2, 1);
		indexBuffer.unlock();

		backbuffer.g4.setVector4(locationTintColor, new FastVector4(topColor.R, topColor.G, topColor.B, topColor.A));
		backbuffer.g4.setVertexBuffer(vertexBuffer);
		backbuffer.g4.setIndexBuffer(indexBuffer);
		backbuffer.g4.drawIndexedVertices();
	}

	override public function renderFramebuffer(framebuffer:Framebuffer) {
		ui.begin(framebuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
				if(ui.panel(Id.handle({selected: true}), "General")) {
					noodleSize = Math.floor(ui.slider(Id.handle({value: noodleSize}), "Noodle Size", 1, 100, true, 1));

					noodles.x = Math.floor(ui.slider(Id.handle({value: noodles.x}), "Noodles X", 1, 30, true, 1));
					noodles.y = Math.floor(ui.slider(Id.handle({value: noodles.y}), "Noodles Y", 1, 30, true, 1));

					padding.x = ui.slider(Id.handle({value: padding.x}), "Padding X", 0, .45, true, 100);
					padding.y = ui.slider(Id.handle({value: padding.y}), "Padding Y", 0, .45, true, 100);

					trailYDelta = Math.floor(ui.slider(Id.handle({value: trailYDelta}), "Trail Y Delta", 1, 100, true, 1));
					movementDelta.x = ui.slider(Id.handle({value: movementDelta.x}), "Movement Delta X", 0, 100, true, 1);
					movementDelta.y = ui.slider(Id.handle({value: movementDelta.y}), "Movement Delta Y", 0, 0.2, true, 1000);

					minColor = ui.slider(Id.handle({value: minColor}), "Min Color", 0, 1, true, 100);
					maxColor = ui.slider(Id.handle({value: maxColor}), "Max Color", 0, 1, true, 100);

					offsetDelta = ui.slider(Id.handle({value: offsetDelta}), "Offset Delta", 0, 3.14*2, true, 100);
					rowOffsetX = ui.slider(Id.handle({value: rowOffsetX}), "Row offset X", 0, 100, true, 1);
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