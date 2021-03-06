package shaderChallenges;

import kha.graphics4.TextureFormat;
import zui.Zui;
import zui.Zui.Handle;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import utils.ZUIUtils;
import kha.graphics4.TextureAddressing;
import zui.Ext;
import kext.g4basics.Texture;
import kext.g4basics.G4Constants;
import zui.Id;
import kha.Framebuffer;
import kha.graphics2.GraphicsExtension;
import kha.math.Vector2;
import kha.math.FastVector3;
import kha.Color;
import kha.math.Vector3;
import kext.g4basics.BasicMesh;
import kext.g4basics.Camera3D;
import kha.Shaders;
import kext.g4basics.BasicPipeline;
import kha.Image;
import kext.Application;
import kext.AppState;
import kha.graphics4.ConstantLocation;

enum Pattern {
    Blinker;
    Grin;
    Pole4;
    Beacon;
    Glider;
    GliderGun;
}

class GameOfLifeShader extends AppState {
    private static inline var CANVAS_WIDTH:Int = 640;
	private static inline var CANVAS_HEIGHT:Int = 640;
	private static inline var NAME:String = "Game Of Life Shader";

    private var texture:Texture;
    private var textureBuffer:Image;
    private var camera:Camera3D;
    private var pipeline:BasicPipeline;
    private var pausedPipeline:BasicPipeline;
    private var screenQuad:BasicMesh;

    private var deltaWidthLocation:ConstantLocation;
    private var deltaHeightLocation:ConstantLocation;
    private var solitudeLocation:ConstantLocation;
    private var overpopulationLocation:ConstantLocation;
    private var populateLocation:ConstantLocation;

    private var addOrRemove:Bool = true;
    private var running:Bool = false;
    private var checkHandle:Handle;
    private var addOrRemoveHandle:Handle;

    private var pattern:Pattern;

    private var updateCounter:Float = 0;
    private var updateTime:Float = 0.01;
    private var stepsPerUpdate:Int = 1;

    private var solitude:Int = 1;
    private var overpopulation:Int = 4;
    private var populate:Int = 3;

    private var samplingDelta:Int = 1;
    private var brushSize:Float = 3;

    private static var width:Int = 128;
    private static var height:Int = 128;

	public static function initApplication():Application {
		return new Application(
			{title: NAME, width: CANVAS_WIDTH, height: CANVAS_HEIGHT},
			{initState: GameOfLifeShader, defaultFontName: "KenPixel", bufferWidth: width, bufferHeight: height}
		);
	}

    public function new() {
        super();

        ui.alwaysRedraw = true;
        checkHandle = Id.handle({selected: running});
        addOrRemoveHandle = Id.handle({selected: addOrRemove});

        pattern = Glider;

        camera = new Camera3D();
        camera.transform.setPosition(new Vector3(0, 0, -10));
        camera.lookAt(new FastVector3(0, 0, 0));
        camera.orthogonal(1, CANVAS_WIDTH / CANVAS_HEIGHT);
        Application.mainCamera = camera;
        createPipeline(Shaders.gameOfLifeMathOnly_frag);

        pausedPipeline = new BasicPipeline(Shaders.textured_vert, Shaders.textured_frag, camera);
        pausedPipeline.compile();

        screenQuad = BasicMesh.createQuadMesh(new Vector3(1, -1, 0), new Vector3(-1, 1, 0), pipeline, Color.White);
        screenQuad.setPipeline = false;

        setupBuffers();
    }

    private function createPipeline(shader:FragmentShader) {
        pipeline = new BasicPipeline(Shaders.textured_vert, shader, camera);
        pipeline.compile();
        
        deltaWidthLocation = pipeline.getConstantLocation("DELTA_WIDTH");
        deltaHeightLocation = pipeline.getConstantLocation("DELTA_HEIGHT");
        solitudeLocation = pipeline.getConstantLocation("SOLITUDE");
        overpopulationLocation = pipeline.getConstantLocation("OVERPOPULATION");
        populateLocation = pipeline.getConstantLocation("POPULATE");
    }

    private function setupBuffers() {
        Application.instance.resizeBuffers(width, height);
        textureBuffer = Image.createRenderTarget(width, height, L8, NoDepthAndStencil, 0);
        texture = new Texture(textureBuffer, G4Constants.TEXTURE);
        screenQuad.textures = [texture];
    }

    private function clearBuffers() {
        textureBuffer.g2.begin(true);
        textureBuffer.g2.end();
    }

    override function update(delta:Float) {
        super.update(delta);

        updateCounter += delta;

        if(Application.keyboard.keyPressed(Space)) {
            running = !running;
            checkHandle.selected = running;
        }

        if(Application.keyboard.keyPressed(C)) {
            clearBuffers();
        }
        
        if(Application.keyboard.keyPressed(One)) {
            pattern = Blinker;
        } else if(Application.keyboard.keyPressed(Two)) {
            pattern = Grin;
        } else if(Application.keyboard.keyPressed(Three)) {
            pattern = Pole4;
        } else if(Application.keyboard.keyPressed(Four)) {
            pattern = Beacon;
        } else if(Application.keyboard.keyPressed(Five)) {
            pattern = Glider;
        } else if(Application.keyboard.keyPressed(Six)) {
            pattern = GliderGun;
        }

        if(Application.mouse.buttonPressed(0)) {
            var mousePosition:Vector2 = Application.mouse.position;
            textureBuffer.g2.begin(false);
            textureBuffer.g2.color = addOrRemove ? Color.White : Color.Black;
            switch(pattern) {
                case Blinker:
                    textureBuffer.g2.fillRect(mousePosition.x, mousePosition.y, 1, 3);
                case Grin:
                    textureBuffer.g2.fillRect(mousePosition.x + 1, mousePosition.y, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x, mousePosition.y + 1, 1, 2);
                    textureBuffer.g2.fillRect(mousePosition.x + 1, mousePosition.y + 3, 1, 1);
                case Pole4:
                    textureBuffer.g2.fillRect(mousePosition.x, mousePosition.y, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 2, mousePosition.y, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 2, mousePosition.y + 2, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 4, mousePosition.y + 2, 1, 1);
                case Beacon:
                    textureBuffer.g2.fillRect(mousePosition.x, mousePosition.y, 1, 2);
                    textureBuffer.g2.fillRect(mousePosition.x + 1, mousePosition.y, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 3, mousePosition.y + 2, 1, 2);
                    textureBuffer.g2.fillRect(mousePosition.x + 2, mousePosition.y + 3, 1, 1);
                case Glider:
                    textureBuffer.g2.fillRect(mousePosition.x, mousePosition.y, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 1, mousePosition.y + 1, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x - 1, mousePosition.y + 2, 3, 1);
                case GliderGun:
                    textureBuffer.g2.fillRect(mousePosition.x     , mousePosition.y + 4, 2, 2);
                    textureBuffer.g2.fillRect(mousePosition.x + 34, mousePosition.y + 2, 2, 2);

                    textureBuffer.g2.fillRect(mousePosition.x + 12, mousePosition.y + 2, 2, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 11, mousePosition.y + 3, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 10, mousePosition.y + 4, 1, 3);
                    textureBuffer.g2.fillRect(mousePosition.x + 14, mousePosition.y + 5, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 11, mousePosition.y + 7, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 12, mousePosition.y + 8, 2, 1);

                    textureBuffer.g2.fillRect(mousePosition.x + 15, mousePosition.y + 3, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 16, mousePosition.y + 4, 1, 3);
                    textureBuffer.g2.fillRect(mousePosition.x + 17, mousePosition.y + 5, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 15, mousePosition.y + 7, 1, 1);

                    textureBuffer.g2.fillRect(mousePosition.x + 24, mousePosition.y    , 1, 2);
                    textureBuffer.g2.fillRect(mousePosition.x + 22, mousePosition.y + 1, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 20, mousePosition.y + 2, 2, 3);
                    textureBuffer.g2.fillRect(mousePosition.x + 22, mousePosition.y + 5, 1, 1);
                    textureBuffer.g2.fillRect(mousePosition.x + 24, mousePosition.y + 5, 1, 2);
            }
            textureBuffer.g2.end();
        }
        if(Application.mouse.buttonDown(1)) {
            var mousePosition:Vector2 = Application.mouse.position;
            textureBuffer.g2.begin(false);
            textureBuffer.g2.color = addOrRemove ? Color.White : Color.Black;
            GraphicsExtension.fillCircle(textureBuffer.g2, mousePosition.x, mousePosition.y, brushSize);
            textureBuffer.g2.end();
        }
    }

    override function render(backbuffer:Image) {
        super.render(backbuffer);

        if(running && updateCounter > updateTime) {
            screenQuad.pipeline = pipeline;

            textureBuffer.g2.color = Color.White;
            for(i in 0...stepsPerUpdate) {
                beginAndClear3D(backbuffer);
                backbuffer.g4.setPipeline(pipeline);
                backbuffer.g4.setFloat(deltaWidthLocation, samplingDelta / textureBuffer.width);
                backbuffer.g4.setFloat(deltaHeightLocation, samplingDelta / textureBuffer.height);
                backbuffer.g4.setInt(solitudeLocation, solitude);
                backbuffer.g4.setInt(overpopulationLocation, overpopulation);
                backbuffer.g4.setInt(populateLocation, populate);
                screenQuad.render(backbuffer);
                end3D(backbuffer);

                textureBuffer.g2.begin(true);
                textureBuffer.g2.drawImage(backbuffer, 0, 0);
                textureBuffer.g2.end();
            }

            updateCounter = 0;
        } else {
            beginAndClear3D(backbuffer);
            backbuffer.g4.setPipeline(pausedPipeline);
            screenQuad.pipeline = pausedPipeline;
            screenQuad.render(backbuffer);
            end3D(backbuffer);
        }
    }
    
	override public function renderFramebuffer(framebuffer:Framebuffer) {
		ui.begin(framebuffer.g2);
		if(ui.window(Id.handle(), 0, 0, 400, 800)) {
			uiToggle = ui.check(Id.handle({selected: true}), "UI On/Off");
			if(uiToggle) {
                updateTime = ui.slider(Id.handle({value: updateTime}), "Step Time", 0.001, 1, true, 1000);
                stepsPerUpdate = Math.floor(ui.slider(Id.handle({value: stepsPerUpdate}), "Steps Per Update", 1, 50, true, 1));
                solitude = Math.floor(ui.slider(Id.handle({value: solitude}), "Solitude Threshold", 0, 8, true, 1));
                overpopulation = Math.floor(ui.slider(Id.handle({value: overpopulation}), "Overpopulation Threshold", 0, 8, true, 1));
                populate = Math.floor(ui.slider(Id.handle({value: populate}), "Populate Threshold", 0, 8, true, 1));
                if(ui.button("Clear")) {
                    clearBuffers();
                }
                brushSize = ui.slider(Id.handle({value: brushSize}), "Brush Size", 0, 100, true, 10);
                samplingDelta = Math.floor(ui.slider(Id.handle({value: samplingDelta}), "Sampling Delta", 0, 100, true, 1));
                width = Math.floor(ui.slider(Id.handle({value: width}), "World Width", 0, 4096, true, 1));
                height = Math.floor(ui.slider(Id.handle({value: height}), "World Height", 0, 4096, true, 1));
                texture.verticalAddresing = ZUIUtils.textureAddresing(ui, Id.handle(), texture.verticalAddresing, "Vertical Addresing");
                texture.horizontalAddresing = ZUIUtils.textureAddresing(ui, Id.handle(), texture.horizontalAddresing, "Horizontal Addresing");
                if(ui.button("Resize")) {
                    setupBuffers();
                }
                running = ui.check(checkHandle, "Running");
                addOrRemove = ui.check(addOrRemoveHandle, "Add/Remove cells");
                if(ui.panel(Id.handle(), "Spawn Pattern")) {
                    if(ui.button("Blinker")) {
                        pattern = Blinker;
                    }
                    if(ui.button("Grin")) {
                        pattern = Grin;
                    }
                    if(ui.button("Pole4")) {
                        pattern = Pole4;
                    }
                    if(ui.button("Beacon")) {
                        pattern = Beacon;
                    }
                    if(ui.button("Glider")) {
                        pattern = Glider;
                    }
                    if(ui.button("GliderGun")) {
                        pattern = GliderGun;
                    }
                }
                if(ui.panel(Id.handle(), "Shader")) {
                    if(ui.button("Game Of Life Normal")) {
                        createPipeline(Shaders.gameOfLife_frag);
                    }
                    if(ui.button("Game Of Life No Branches")) {
                        createPipeline(Shaders.gameOfLifeNoBranches_frag);
                    }
                    if(ui.button("Game Of Life Math Only")) {
                        createPipeline(Shaders.gameOfLifeMathOnly_frag);
                    }
                }
			}
		}
		ui.end();
	}

}