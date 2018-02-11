package utils;

import kha.Assets;
import kha.Color;
import kha.graphics4.VertexStructure;

import kext.g4basics.BasicMesh;

class DemoMeshes {

	public static var QUAD_OBJ:BasicMesh;
	public static var CUBE_OBJ:BasicMesh;
	public static var SPHERE_OBJ:BasicMesh;
	public static var TORUS_OBJ:BasicMesh;
	public static var ARROW_OBJ:BasicMesh;
	public static var SUZANNE_OBJ:BasicMesh;
	public static var CAR_FORMULA_OBJ:BasicMesh;
	public static var QUAD_STL:BasicMesh;
	public static var CUBE_STL:BasicMesh;
	public static var SPHERE_STL:BasicMesh;
	public static var TORUS_STL:BasicMesh;
	public static var ARROW_STL:BasicMesh;
	public static var SUZANNE_STL:BasicMesh;
	public static var CAR_FORMULA_STL:BasicMesh;

	public static function init(structure:VertexStructure, color:Color = null) {
		QUAD_OBJ = BasicMesh.getOBJMesh(Assets.blobs.quad_obj, structure, color);
		CUBE_OBJ = BasicMesh.getOBJMesh(Assets.blobs.cube_obj, structure, color);
		SPHERE_OBJ = BasicMesh.getOBJMesh(Assets.blobs.sphere_obj, structure, color);
		TORUS_OBJ = BasicMesh.getOBJMesh(Assets.blobs.torus_obj, structure, color);
		ARROW_OBJ = BasicMesh.getOBJMesh(Assets.blobs.arrow_obj, structure, color);
		SUZANNE_OBJ = BasicMesh.getOBJMesh(Assets.blobs.suzanne_obj, structure, color);
		CAR_FORMULA_OBJ = BasicMesh.getOBJMesh(Assets.blobs.carFormula_obj, structure, color);
		
		QUAD_STL = BasicMesh.getSTLMesh(Assets.blobs.quad_stl, structure);
		CUBE_STL = BasicMesh.getSTLMesh(Assets.blobs.cube_stl, structure);
		SPHERE_STL = BasicMesh.getSTLMesh(Assets.blobs.sphere_stl, structure);
		TORUS_STL = BasicMesh.getSTLMesh(Assets.blobs.torus_stl, structure);
		ARROW_STL = BasicMesh.getSTLMesh(Assets.blobs.arrow_stl, structure);
		SUZANNE_STL = BasicMesh.getSTLMesh(Assets.blobs.suzanne_stl, structure);
		CAR_FORMULA_STL = BasicMesh.getSTLMesh(Assets.blobs.carFormula_stl, structure);
	}

}