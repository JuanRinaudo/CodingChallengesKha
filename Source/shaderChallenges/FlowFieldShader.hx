package shaderChallenges;

import js.html.FileReader;
import zui.Ext;
import kha.graphics4.ConstantLocation;
import zui.Zui.Handle;
import kha.graphics2.GraphicsExtension;
import kha.math.Vector2;
import kha.Color;
import kha.Shaders;
import kha.math.FastVector3;
import kha.math.Vector3;
import kext.g4basics.Camera3D;
import kext.g4basics.BasicMesh;
import kext.g4basics.G4Constants;
import kext.g4basics.Texture;
import kext.g4basics.BasicPipeline;
import kha.graphics4.FragmentShader;
import kha.Framebuffer;
import zui.Id;
import kha.Image;
import kext.Application;
import kext.AppState;

typedef Creature = {
    var position:Vector2;
    var velocity:Vector2;
}

class FlowFieldShader extends AppState {
    private static inline var CANVAS_WIDTH:Int = 640;
	private static inline var CANVAS_HEIGHT:Int = 640;
	private static inline var NAME:String = "Flow Field Shader";

    private var texture:Texture;
    private var flowTexture:Texture;
    private var buffer:Image;
    private var textureBuffer:Image;
    private var flowBuffer:Image;
    private var camera:Camera3D;
    private var pipeline:BasicPipeline;
    private var noisePipeline:BasicPipeline;
    private var pausedPipeline:BasicPipeline;
    private var screenQuad:BasicMesh;

    private var deltaWidthLocation:ConstantLocation;
    private var deltaHeightLocation:ConstantLocation;
    private var colorMultiplyLocation:ConstantLocation;
    private var speedLocation:ConstantLocation;

    private var colorMultiply:Float = 0.995;
    private var speed:Float = 0.9;

    private var spawnSize:Float = 2;
    private var spawnColor:Color = Color.Red;

    private var drawNoiseField:Bool = false;
    private var drawNoiseFieldHandle:Handle;
    private var drawFlowField:Bool = false;
    private var drawFlowFieldHandle:Handle;

    private var noiseResolution:Float = 1;
    private var noiseCounter:Float = 0;
    private var noiseRefreshTime:Float = -0.01;

    private var creatures:Array<Creature>;
    private var creatureCount:Int = 100;
    private var flowField:Array<Array<Vector2>>;
    private var flowFieldWidth:Int = 32;
    private var flowFieldHeight:Int = 32;

    private var renderTargetWidth:Int = 256;
    private var renderTargetHeight:Int = 256;

    private static var width:Int = 256;
    private static var height:Int = 256;

	public static function initApplication():Application {
		return new Application(
			{title: NAME, width: CANVAS_WIDTH, height: CANVAS_HEIGHT},
			{initState: FlowFieldShader, defaultFontName: "KenPixel", bufferWidth: width, bufferHeight: height}
		);
	}

    public function new() {
        super();

        ui.alwaysRedraw = true;
        drawNoiseFieldHandle = Id.handle({selected: drawNoiseField});
        drawFlowFieldHandle = Id.handle({selected: drawFlowField});

        camera = new Camera3D();
        camera.transform.setPosition(new Vector3(0, 0, -10));
        camera.lookAt(new FastVector3(0, 0, 0));
        camera.orthogonal(1, CANVAS_WIDTH / CANVAS_HEIGHT);
        Application.mainCamera = camera;
        createPipeline(Shaders.flowField_frag);

        pausedPipeline = new BasicPipeline(Shaders.textured_vert, Shaders.textured_frag, camera);
        pausedPipeline.compile();

        screenQuad = BasicMesh.createQuadMesh(new Vector3(1, -1, 0), new Vector3(-1, 1, 0), pipeline, Color.White);
        screenQuad.setPipeline = false;

        flowField = [];
        for(i in 0...flowFieldWidth) {
            var temp = [];
            for(j in 0...flowFieldHeight) {
                temp.push(new Vector2(Math.random() * 2 - 1, Math.random() * 2 - 1));
            }
            flowField[i] = temp;
        }

        creatures = [];
        initBuffers();
    }

    private function createPipeline(shader:FragmentShader) {
        pipeline = new BasicPipeline(Shaders.textured_vert, shader, camera);
        pipeline.compile();

        noisePipeline = new BasicPipeline(Shaders.textured_vert, Shaders.noise_frag, camera);
        noisePipeline.compile();

        deltaWidthLocation = pipeline.getConstantLocation("DELTA_WIDTH");
        deltaHeightLocation = pipeline.getConstantLocation("DELTA_HEIGHT");
        colorMultiplyLocation = pipeline.getConstantLocation("COLOR_MULTIPLY");
        speedLocation = pipeline.getConstantLocation("SPEED");
    }

    private function initBuffers() {
        initCreatures();

        width = renderTargetWidth;
        height = renderTargetHeight;

        Application.instance.resizeBuffers(width, height);
        buffer = Image.createRenderTarget(width, height, RGBA32, NoDepthAndStencil, 1);
        textureBuffer = Image.createRenderTarget(width, height, RGBA32, NoDepthAndStencil, 1);
        flowBuffer = Image.createRenderTarget(width, height, RGBA32, NoDepthAndStencil, 1);

        texture = new Texture(textureBuffer, "FLOW_TEXTURE");
        texture.minificationFilter = AnisotropicFilter;
        texture.magnificationFilter = AnisotropicFilter;
        flowTexture = new Texture(flowBuffer, G4Constants.TEXTURE);
        flowTexture.minificationFilter = AnisotropicFilter;
        flowTexture.magnificationFilter = AnisotropicFilter;
        screenQuad.textures = [texture, flowTexture];

        clearBuffers();
        drawNoise();
    }

    private function initCreatures() {
        var initialSize = creatures.length;
        creatures.resize(creatureCount);
        if(creatureCount > initialSize) {
            for(i in initialSize...creatureCount) {
                creatures[i] = {
                    position: new Vector2(Math.random() * width, Math.random() * height),
                    velocity: new Vector2(Math.random() * width, Math.random() * height)
                };
            }
        }

        for(i in 0...creatures.length) {
            creatures[i].position.x = (creatures[i].position.x / width) * renderTargetWidth;
            creatures[i].position.y = (creatures[i].position.y / height) * renderTargetHeight;
        }
    }

    private function clearBuffers() {
        buffer.g4.begin();
        buffer.g4.clear(Color.Black);
        buffer.g4.end();
        textureBuffer.g4.begin();
        textureBuffer.g4.clear(Color.Black);
        textureBuffer.g4.end();
        flowBuffer.g4.begin();
        flowBuffer.g4.clear(Color.fromFloats(.5, .5, 0, 1));
        flowBuffer.g4.end();
    }
    
    override function update(delta:Float) {
        super.update(delta);
        
        if(Application.keyboard.keyPressed(Escape)) {
            uiToggle = !uiToggle;
        }

        if(Application.mouse.buttonDown(0)) {
            
        }

        textureBuffer.g2.begin(false);
        textureBuffer.g2.color = spawnColor;
        for(i in 0...creatures.length) {
            var flowFieldX:Int = Math.floor((creatures[i].position.x / width) * flowFieldWidth);
            var flowFieldY:Int = Math.floor((creatures[i].position.y / height) * flowFieldHeight);

            creatures[i].velocity.x = Math.min(Math.max(creatures[i].velocity.x + flowField[flowFieldX][flowFieldY].x * delta * 10, -10), 10);
            creatures[i].velocity.y = Math.min(Math.max(creatures[i].velocity.y + flowField[flowFieldX][flowFieldY].y * delta * 10, -10), 10);

            creatures[i].position.x = (creatures[i].position.x + creatures[i].velocity.x * delta + width) % width;
            creatures[i].position.y = (creatures[i].position.y + creatures[i].velocity.y * delta + height) % height;
            GraphicsExtension.fillCircle(textureBuffer.g2, creatures[i].position.x, creatures[i].position.y, spawnSize);
        }
        textureBuffer.g2.end();

        if(Application.mouse.buttonDown(1)) {
            var mousePosition:Vector2 = Application.mouse.position;
            textureBuffer.g2.begin(false);
            textureBuffer.g2.color = spawnColor;
            GraphicsExtension.fillCircle(textureBuffer.g2, mousePosition.x, mousePosition.y, spawnSize);
            textureBuffer.g2.end();
        }

        noiseCounter += delta;
        if(Application.keyboard.keyPressed(N) || (noiseRefreshTime > 0 && noiseCounter > noiseRefreshTime)) {
            noiseCounter = 0;
            drawNoise();
        }

        if(Application.keyboard.keyPressed(C)) {
            clearBuffers();
        }
    }

    private function drawNoise() {
        beginAndClear3D(flowBuffer, Color.Black);
        flowBuffer.g4.setPipeline(noisePipeline);
        trace(1.0 / flowBuffer.width);
        flowBuffer.g4.setFloat(noisePipeline.getConstantLocation("DELTA_WIDTH"), 1 / (flowBuffer.width * noiseResolution));
        flowBuffer.g4.setFloat(noisePipeline.getConstantLocation("DELTA_HEIGHT"), 1 / (flowBuffer.height * noiseResolution));
        flowBuffer.g4.setFloat(noisePipeline.getConstantLocation("TIME"), Math.random() + 1);
        screenQuad.pipeline = noisePipeline;
        screenQuad.render(flowBuffer);
        end3D(flowBuffer);
    }

    override function render(backbuffer:Image) {
        super.render(backbuffer);

        beginAndClear3D(buffer, Color.Black);
        buffer.g4.setPipeline(pipeline);
        screenQuad.pipeline = pipeline;
        buffer.g4.setFloat(deltaWidthLocation, 1 / buffer.width);
        buffer.g4.setFloat(deltaHeightLocation, 1 / buffer.height);
        buffer.g4.setFloat(colorMultiplyLocation, colorMultiply);
        buffer.g4.setFloat(speedLocation, speed);
        screenQuad.render(buffer);
        end3D(buffer);

        textureBuffer.g2.begin(true, Color.Black);
        textureBuffer.g2.color = Color.fromFloats(1, 1, 1, 1);
        textureBuffer.g2.drawImage(buffer, 0, 0);
        textureBuffer.g2.end();

        backbuffer.g2.begin(true, Color.Black);
        backbuffer.g2.color = Color.fromFloats(1, 1, 1, 1);
        backbuffer.g2.drawImage(drawNoiseField ? buffer : flowBuffer, 0, 0);
        backbuffer.g2.end();
    }

	override public function renderFramebuffer(framebuffer:Framebuffer) {
        var reinitBuffers:Bool = false;
        var reinitCreatures:Bool = false;

        if(uiToggle) {
            ui.begin(framebuffer.g2);
            if(ui.window(Id.handle(), 0, 0, 400, 800)) {
                uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");

                ui.separator();
                ui.text("Flow Field");
                drawNoiseField = ui.check(drawNoiseFieldHandle, "Draw Noise Field");
                drawFlowField = ui.check(drawFlowFieldHandle, "Draw Flow Field");

                ui.separator();
                ui.text("Color");
                colorMultiply = ui.slider(Id.handle({value: colorMultiply}), "Color Multiply", 0, 1, true, 1000, true, Right, true);
                speed = ui.slider(Id.handle({value: speed}), "Speed", 0, 10, true, 10, true, Right, true);

                spawnSize = ui.slider(Id.handle({value: spawnSize}), "Spawn Size", 0, 32, true, 10, true, Right, true);
                spawnColor = Ext.colorPicker(ui, Id.handle({color: spawnColor}), true);
                
                noiseResolution = ui.slider(Id.handle({value: noiseResolution}), "Noise Resolution", 0, 1, true, 100, true, Right, true);
                noiseRefreshTime = ui.slider(Id.handle({value: noiseRefreshTime}), "Noise Refresh Time", -0.01, 1, true, 100, true, Right, true);

                renderTargetWidth = Math.floor(ui.slider(Id.handle({value: renderTargetWidth}), "World Width", 0, 4096, true, 1));
                renderTargetHeight = Math.floor(ui.slider(Id.handle({value: renderTargetHeight}), "World Height", 0, 4096, true, 1));
                if(ui.button("Reinitialize")) {
                    reinitBuffers = true;
                }

                ui.separator();
                ui.text("Paint Creatures");
                creatureCount = Math.floor(ui.slider(Id.handle({value: creatureCount}), "Creature Count", 0, 1000, true, 1, true, Right, true));
                if(ui.button("Reinitialize")) {
                    reinitCreatures = true;
                }
            }
            ui.end();
        }

        if(reinitBuffers) {
            initBuffers();
        }
        if(reinitCreatures) {
            initCreatures();
        }
    }

}