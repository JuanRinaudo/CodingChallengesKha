package kext.g4basics;

import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.FragmentShader;
import kha.graphics4.CompareMode;

class BasicPipeline extends PipelineState {

	public var vertexStructure:VertexStructure;

	public function new(vertexShader:VertexShader, fragmentShader:FragmentShader) {
		super();

		vertexStructure = new VertexStructure();
		vertexStructure.add("position", VertexData.Float3);
		vertexStructure.add("texuv", VertexData.Float2);
		vertexStructure.add("color", VertexData.Float4);

		this.vertexShader = vertexShader;
		this.fragmentShader = fragmentShader;

		depthWrite = true;
		depthMode = CompareMode.LessEqual;
	}

	public function addVertexData(name:String, dataType:VertexData) {
		vertexStructure.add(name, dataType);
	}

	override public function compile() {
		inputLayout = [vertexStructure];
		super.compile();
	}

}