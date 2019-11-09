package simpleChallenges;

import kha.graphics4.ConstantLocation;
import kext.g4basics.Texture;
import kext.g4basics.BasicMesh;
import kha.math.Vector3;
import kext.g4basics.Camera3D;
import kha.math.FastVector3;
import kext.g4basics.BasicPipeline;
import kha.Shaders;
import kha.Assets;
import kha.math.Vector2;
import kha.graphics4.FragmentShader;
import kha.Color;
import kha.Image;
import kext.Application;
import kext.AppState;

class SlideImage {
    public var image:Image;

    public var scale:Vector2 = new Vector2(1, 1);
    public var offset:Vector2 = new Vector2(0, 0);

    public var transitionIn:FragmentShader;
    public var transitionInTime:Float = 0;

    public var shader:FragmentShader;
    public var liveTime:Float = 1;

    public var transitionOut:FragmentShader;
    public var transitionOutTime:Float = 0;

    public function new(image:Image, inShader:FragmentShader, outShader:FragmentShader) {
        this.image = image;

        transitionIn = inShader;
        shader = Shaders.colored_frag;
        transitionOut = outShader;
    }
}

class SimpleImageSlideshow extends AppState {
	private static inline var CANVAS_WIDTH:Int = 800;
	private static inline var CANVAS_HEIGHT:Int = 800;
	private static inline var NAME:String = "Simple Image Slideshow";

	public static function initApplication() {
		return new Application(
			{title: SimpleImageSlideshow.NAME, width: SimpleImageSlideshow.CANVAS_WIDTH, height: SimpleImageSlideshow.CANVAS_HEIGHT},
			{initState: SimpleImageSlideshow, defaultFontName: "KenPixel"}
		);
	}

    private var slides:Array<SlideImage>;
    private var slideIndex:Int = -1;
    private var currentSlide:SlideImage;
    private var nextSlide:SlideImage;

    private var camera:Camera3D;
    private var pipelineIn:BasicPipeline;
    private var pipeline:BasicPipeline;
    private var pipelineOut:BasicPipeline;
    private var screenQuad:BasicMesh;

    private var counter:Float = 0;

    private var inTimeLocation:ConstantLocation;
    private var outTimeLocation:ConstantLocation;

    public function new() {
        super();

        slides = [];
        var slide1 = new SlideImage(Assets.images.TestImage001, Shaders.imageFade_frag, Shaders.imageFade_frag);
        var slide2 = new SlideImage(Assets.images.TestImage002, Shaders.imageFade_frag, Shaders.imageFade_frag);
        slides.push(slide1);
        slides.push(slide2);
        currentSlide = slide1;
        nextSlide = slide2;
        
        camera = new Camera3D();
        camera.transform.setPosition(new Vector3(0, 0, -10));
        camera.lookAt(new FastVector3(0, 0, 0));
        camera.orthogonal(1, CANVAS_WIDTH / CANVAS_HEIGHT);
        Application.mainCamera = camera;
        createPipeline(Shaders.textured_frag);
        createPipelineIn(Shaders.textured_frag);
        createPipelineOut(Shaders.textured_frag);

        screenQuad = BasicMesh.createQuadMesh(new Vector3(1, -1, 0), new Vector3(-1, 1, 0), pipelineIn, Color.White);
        screenQuad.textures = [new Texture(slide1.image, "TEXTURE"), new Texture(slide2.image, "NEXT_IMAGE")];
        screenQuad.setPipeline = false;
    }
    
    private function createPipeline(shader:FragmentShader) {
        pipeline = new BasicPipeline(Shaders.textured_vert, shader, camera);
        pipeline.basicTexture = false;
        pipeline.compile();
    }
    
    private function createPipelineIn(shader:FragmentShader) {
        pipelineIn = new BasicPipeline(Shaders.textured_vert, shader, camera);
        pipelineIn.basicTexture = false;
        pipelineIn.compile();
        
        inTimeLocation = pipelineIn.getConstantLocation("TIME");
    }
    
    private function createPipelineOut(shader:FragmentShader) {
        pipelineOut = new BasicPipeline(Shaders.textured_vert, shader, camera);
        pipelineOut.basicTexture = false;
        pipelineOut.compile();
        
        outTimeLocation = pipelineOut.getConstantLocation("TIME");
    }

    override function update(delta:Float) {
        super.update(delta);

        counter += delta;
    }

    override function render(backbuffer:Image) {
        super.render(backbuffer);

        beginAndClear3D(backbuffer, Color.Black);

        screenQuad.transform.scaleY = currentSlide.image.height / currentSlide.image.width;

        screenQuad.pipeline = pipelineIn;
        backbuffer.g4.setPipeline(pipelineIn);
        backbuffer.g4.setFloat(timeLocation, counter);
        screenQuad.render(backbuffer);

        end3D(backbuffer);
    }

}