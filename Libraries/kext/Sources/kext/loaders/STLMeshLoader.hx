package kext.loaders;

import kha.Blob;
import kha.arrays.Float32Array;
import kha.math.Vector3;

typedef STLMeshData = {
	normals:Float32Array,
	vertexes:Float32Array,
	triangleCount:Int,
	vertexCount:Int
}

class STLMeshLoader {

	private static inline var HEADER_SIZE:Int = 80;

	public static function load(blob:Blob):STLMeshData {
		var index:Int = 0;

		var header:String;
		var charArray:Array<String> = [];
		while(index < HEADER_SIZE) {
			charArray[index] = String.fromCharCode(blob.readU8(index));
			index++;
		}
		header = charArray.join('');

		var triangles:UInt = blob.readS32LE(index);
		index+=4;

		var mesh:STLMeshData = {
			#if js
			normals: new Float32Array(triangles * 3), //One V3 per normal
			vertexes: new Float32Array(triangles * 9), //V3, one for each vertex in the triangle
			#else
			normals: new Float32Array(), //One V3 per normal
			vertexes: new Float32Array(), //V3, one for each vertex in the triangle
			#end
			triangleCount: triangles,
			vertexCount: triangles * 3
		};

		for(i in 0...triangles) {
			mesh.normals.set(i * 3 + 0, blob.readF32LE(index));
			mesh.normals.set(i * 3 + 1, blob.readF32LE(index + 4));
			mesh.normals.set(i * 3 + 2, blob.readF32LE(index + 8));
			// trace(new Vector3(blob.readF32LE(index + 0), blob.readF32LE(index + 4), blob.readF32LE(index + 8))); // Normal
			
			mesh.vertexes.set(i * 9 + 0, blob.readF32LE(index + 12));
			mesh.vertexes.set(i * 9 + 1, blob.readF32LE(index + 16));
			mesh.vertexes.set(i * 9 + 2, blob.readF32LE(index + 20));
			mesh.vertexes.set(i * 9 + 3, blob.readF32LE(index + 24));
			mesh.vertexes.set(i * 9 + 4, blob.readF32LE(index + 28));
			mesh.vertexes.set(i * 9 + 5, blob.readF32LE(index + 32));
			mesh.vertexes.set(i * 9 + 6, blob.readF32LE(index + 36));
			mesh.vertexes.set(i * 9 + 7, blob.readF32LE(index + 40));
			mesh.vertexes.set(i * 9 + 8, blob.readF32LE(index + 44));
			// trace(new Vector3(blob.readF32LE(index + 12), blob.readF32LE(index + 16), blob.readF32LE(index + 20))); //Vector1
			// trace(new Vector3(blob.readF32LE(index + 24), blob.readF32LE(index + 28), blob.readF32LE(index + 32))); //Vector2
			// trace(new Vector3(blob.readF32LE(index + 36), blob.readF32LE(index + 40), blob.readF32LE(index + 44))); //Vector3
			// trace(blob.readU16LE(i + 48)); //Attributes - IGNORED FOR NOW
			index += 50;
		}

		return mesh;
	}

}