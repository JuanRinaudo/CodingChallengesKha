package kext.g4basics;

import kha.Image;

import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.FragmentShader;
import kha.graphics4.CompareMode;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.BlendingFactor;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;

typedef CameraParameters = {
	orthogonalPerspective:Bool,
	size:Float,
	fovY:Float,
	aspectRatio:Float,
	projectionMatrix:FastMatrix4,
	viewMatrix:FastMatrix4
}

class BasicPipeline extends PipelineState {

	public var vertexStructure:VertexStructure;

	public var locationMVPMatrix:ConstantLocation;
	public var locationModelMatrix:ConstantLocation;
	public var locationProjectionMatrix:ConstantLocation;
	public var locationViewMatrix:ConstantLocation;
	public var locationProjectionViewMatrix:ConstantLocation;
	public var locationNormalMatrix:ConstantLocation;

	public var textureUnit:TextureUnit;

	public var camera(default, set):CameraParameters;
	public var nearPlane(default, set):Float;
	public var farPlane(default, set):Float;

	public var upVector:FastVector3 = new FastVector3(0, -1, 0);

	public function new(vertexShader:VertexShader, fragmentShader:FragmentShader) {
		super();

		vertexStructure = new VertexStructure();
		vertexStructure.add("position", VertexData.Float3);
		vertexStructure.add("normal", VertexData.Float3);
		vertexStructure.add("texuv", VertexData.Float2);
		vertexStructure.add("color", VertexData.Float4);

		this.vertexShader = vertexShader;
		this.fragmentShader = fragmentShader;

		blendSource = BlendingFactor.BlendOne;
		blendDestination = BlendingFactor.InverseSourceAlpha;
		alphaBlendSource = BlendingFactor.SourceAlpha;
		alphaBlendDestination = BlendingFactor.InverseSourceAlpha;

		depthWrite = true;
		depthMode = CompareMode.LessEqual;

		camera = {
			orthogonalPerspective: false,
			size: 0,
			fovY: 0,
			aspectRatio: 0,
			viewMatrix: null,
			projectionMatrix: null
		}

		nearPlane = 0.1;
		farPlane = 100;
		orthogonal(5, 1);
		cameraLookAt(new FastVector3(-1, -1, -1).mult(50), new FastVector3(0, 0, 0));
	}

	public function cameraLookAt(from:FastVector3, to:FastVector3) {
		camera.viewMatrix = FastMatrix4.lookAt(from, to, upVector);
	}

	public function cameraLookAtXYZ(fromX:Float, fromY:Float, fromZ:Float, toX:Float, toY:Float, toZ:Float) {
		camera.viewMatrix = FastMatrix4.lookAt(new FastVector3(fromX, fromY, fromZ), new FastVector3(toX, toY, toZ), upVector);
	}

	public function orthogonal(size:Float, aspectRatio:Float) {
		camera.orthogonalPerspective = true;
		camera.size = size;
		camera.aspectRatio = aspectRatio;
		camera.projectionMatrix = FastMatrix4.orthogonalProjection(-size * aspectRatio, size * aspectRatio, -size, size, farPlane, nearPlane);
	}

	public function perspective(fovY:Float, aspectRatio:Float) {
		camera.orthogonalPerspective = false;
		camera.fovY = fovY;
		camera.aspectRatio = aspectRatio;
		camera.projectionMatrix = FastMatrix4.perspectiveProjection(fovY, aspectRatio, farPlane, nearPlane);
	}

	public inline function getMVPMatrix(modelMatrix:FastMatrix4):FastMatrix4 {
		var projectionViewMatrix:FastMatrix4 = camera.projectionMatrix.multmat(camera.viewMatrix);
		return projectionViewMatrix.multmat(modelMatrix);
	}

	public inline function getNormalMatrix(modelMatrix:FastMatrix4):FastMatrix3 {
		return new FastMatrix3(modelMatrix._00, modelMatrix._10, modelMatrix._20,
			modelMatrix._01, modelMatrix._11, modelMatrix._21,
			modelMatrix._02, modelMatrix._12, modelMatrix._22).inverse().transpose();
	}

	public function addVertexData(name:String, dataType:VertexData) {
		vertexStructure.add(name, dataType);
	}

	override public function compile() {
		inputLayout = [vertexStructure];
		super.compile();

		locationMVPMatrix = getConstantLocation("MVP_MATRIX");
		locationModelMatrix = getConstantLocation("MODEL_MATRIX");
		locationViewMatrix = getConstantLocation("VIEW_MATRIX");
		locationProjectionMatrix = getConstantLocation("PROJECTION_MATRIX");
		locationProjectionViewMatrix = getConstantLocation("VP_MATRIX");
		locationNormalMatrix = getConstantLocation("NORMAL_MATRIX");

		textureUnit = getTextureUnit("TEXTURE");
	}

	public inline function setDefaultTextureUnitParameters(backbuffer:Image, unit:TextureUnit) {
		backbuffer.g4.setTextureParameters(unit, TextureAddressing.Repeat, TextureAddressing.Repeat,
			TextureFilter.PointFilter, TextureFilter.PointFilter, MipMapFilter.NoMipFilter);
	}

	private inline function refreshCamera() {
		if(camera.orthogonalPerspective) {
			orthogonal(camera.size, camera.aspectRatio);
		} else {
			perspective(camera.fovY, camera.aspectRatio);
		}
	}

	public function set_nearPlane(value:Float):Float {
		nearPlane = value;
		refreshCamera();
		return nearPlane;
	}

	public function set_farPlane(value:Float):Float {
		farPlane = value;
		refreshCamera();
		return farPlane;
	}

	public function set_camera(value:CameraParameters):CameraParameters {
		camera = value;
		refreshCamera();
		return value;
	}

}