package kext.g4basics;

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
	public var locationAmbientColor:ConstantLocation;

	public var locationTexture:TextureUnit;

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

		projectionMatrix = FastMatrix4.perspectiveProjection(45, 1, 0.1, 100);
		viewMatrix = FastMatrix4.lookAt(
			new FastVector3(0, 0, -5),
			new FastVector3(0, 0, 0),
			new FastVector3(0, 1, 0)
		);
	}

	public function getMVPMatrix(modelMatrix:FastMatrix4):FastMatrix4 {
		return projectionMatrix.multmat(viewMatrix.multmat(modelMatrix));
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
		locationAmbientColor = getConstantLocation("AMBIENT_COLOR");

		locationTexture = getTextureUnit("TEXTURE");
	}

}