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

typedef OrthogonalCameraData = {
	size:Float,
	aspectRatio:Float
}

typedef PerspectiveCameraData = {
	fovY:Float,
	aspectRatio:Float
}

class BasicPipeline extends PipelineState {

	public var vertexStructure:VertexStructure;

	public var projectionMatrix:FastMatrix4;
	public var viewMatrix:FastMatrix4;

	public var locationMVPMatrix:ConstantLocation;
	public var locationModelMatrix:ConstantLocation;
	public var locationProjectionMatrix:ConstantLocation;
	public var locationViewMatrix:ConstantLocation;
	public var locationProjectionViewMatrix:ConstantLocation;
	public var locationNormalMatrix:ConstantLocation;

	public var textureUnit:TextureUnit;

	public var orthogonalCamera(default, null):OrthogonalCameraData;
	public var perspectiveCamera(default, null):PerspectiveCameraData;
	public var nearPlane(default, set):Float;
	public var farPlane(default, set):Float;

	public var upVector:FastVector3 = new FastVector3(0, 1, 0);

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

		nearPlane = 0.1;
		farPlane = 100;
		orthogonal(5, 1);
		cameraLookAt(new FastVector3(-1, -1, -1).mult(50), new FastVector3(0, 0, 0));
	}

	public function cameraLookAt(from:FastVector3, to:FastVector3) {
		viewMatrix = FastMatrix4.lookAt(from, to, upVector);
	}

	public function orthogonal(size:Float, aspectRatio:Float) {
		perspectiveCamera = null;
		orthogonalCamera = {size: size, aspectRatio: aspectRatio};
		projectionMatrix = FastMatrix4.orthogonalProjection(-size * aspectRatio, size * aspectRatio, size, -size, farPlane, nearPlane);
	}

	public function perspective(fovY:Float, aspectRatio:Float) {
		orthogonalCamera = null;
		perspectiveCamera = {fovY: fovY, aspectRatio: aspectRatio};
		projectionMatrix = FastMatrix4.perspectiveProjection(fovY, aspectRatio, farPlane, nearPlane);
	}

	public inline function getMVPMatrix(modelMatrix:FastMatrix4):FastMatrix4 {
		return projectionMatrix.multmat(viewMatrix).multmat(modelMatrix);
	}

	public inline function getNormalMatrix(modelMatrix:FastMatrix4):FastMatrix3 {
		var modelViewMatrix:FastMatrix4 = viewMatrix.multmat(modelMatrix);
		return new FastMatrix3(modelViewMatrix._00, modelViewMatrix._10, modelViewMatrix._20,
			modelViewMatrix._01, modelViewMatrix._11, modelViewMatrix._21,
			modelViewMatrix._02, modelViewMatrix._12, modelViewMatrix._22).inverse().transpose();
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
		if(orthogonalCamera != null) {
			orthogonal(orthogonalCamera.size, orthogonalCamera.aspectRatio);
		} else if(perspectiveCamera != null) {
			perspective(perspectiveCamera.fovY, perspectiveCamera.aspectRatio);
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

}