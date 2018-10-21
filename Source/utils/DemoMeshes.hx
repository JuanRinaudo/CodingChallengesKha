package utils;

import kha.math.Vector3;
import kext.g4basics.BasicPipeline;
import kha.Assets;
import kha.Color;
import kha.graphics4.VertexStructure;

import kext.g4basics.BasicMesh;

class DemoMeshes {

	public static var QUAD:BasicMesh;
	public static var CUBE:BasicMesh;
	public static var SPHERE:BasicMesh;
	public static var TORUS:BasicMesh;
	public static var ARROW:BasicMesh;
	public static var SUZANNE:BasicMesh;

	public static function init(pipeline:BasicPipeline, color:Color = null) {
		QUAD = BasicMesh.createQuadMesh(new Vector3(-1, -1, 0), new Vector3(1, 1, 0), pipeline, color);
		CUBE = BasicMesh.getOBJMesh(Assets.blobs.cube_obj, pipeline, color);
		SPHERE = BasicMesh.getOBJMesh(Assets.blobs.sphere_obj, pipeline, color);
		TORUS = BasicMesh.getOBJMesh(Assets.blobs.torus_obj, pipeline, color);
		ARROW = BasicMesh.getOBJMesh(Assets.blobs.arrow_obj, pipeline, color);
		SUZANNE = BasicMesh.getOBJMesh(Assets.blobs.suzanne_obj, pipeline, color);
	}

}