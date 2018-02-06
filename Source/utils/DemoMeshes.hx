package utils;

import kha.Assets;
import kha.Color;
import kha.graphics4.VertexStructure;

import kext.g4basics.BasicMesh;

class DemoMeshes {

	public static var CUBE_OBJ:BasicMesh;
	public static var SPHERE_OBJ:BasicMesh;
	public static var TORUS_OBJ:BasicMesh;
	public static var ARROW_OBJ:BasicMesh;
	public static var SUZANNE_OBJ:BasicMesh;
	public static var CAR_FORMULA_OBJ:BasicMesh;
	public static var CUBE_STL:BasicMesh;
	public static var SPHERE_STL:BasicMesh;
	public static var TORUS_STL:BasicMesh;
	public static var ARROW_STL:BasicMesh;
	public static var SUZANNE_STL:BasicMesh;
	public static var CAR_FORMULA_STL:BasicMesh;

	public static function init(structure:VertexStructure, vertexOffset:UInt, normalOffset:UInt, uvOffset:UInt, colorOffset:UInt = 0, color:Color = null) {
		CUBE_OBJ = BasicMesh.getOBJMesh(Assets.blobs.cube_obj, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		SPHERE_OBJ = BasicMesh.getOBJMesh(Assets.blobs.sphere_obj, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		TORUS_OBJ = BasicMesh.getOBJMesh(Assets.blobs.torus_obj, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		ARROW_OBJ = BasicMesh.getOBJMesh(Assets.blobs.arrow_obj, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		SUZANNE_OBJ = BasicMesh.getOBJMesh(Assets.blobs.suzanne_obj, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		CAR_FORMULA_OBJ = BasicMesh.getOBJMesh(Assets.blobs.carFormula_obj, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		
		CUBE_STL = BasicMesh.getOBJMesh(Assets.blobs.cube_stl, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		SPHERE_STL = BasicMesh.getOBJMesh(Assets.blobs.sphere_stl, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		TORUS_STL = BasicMesh.getOBJMesh(Assets.blobs.torus_stl, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		ARROW_STL = BasicMesh.getOBJMesh(Assets.blobs.arrow_stl, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		SUZANNE_STL = BasicMesh.getOBJMesh(Assets.blobs.suzanne_stl, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
		CAR_FORMULA_STL = BasicMesh.getOBJMesh(Assets.blobs.carFormula_stl, structure, vertexOffset, normalOffset, uvOffset, colorOffset, color);
	}

}