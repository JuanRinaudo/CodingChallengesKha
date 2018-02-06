package kext.loaders;

import kha.Blob;

import kha.math.Vector2;
import kha.math.Vector3;

import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;

typedef OBJMeshData = {
	vertexes:Float32Array,
	uvs:Float32Array,
	normals:Float32Array,
	indices:Uint32Array,
	triangleCount:UInt,
	vertexCount:UInt
}

typedef TriangleData = {
	v:UInt,
	vt:UInt,
	vn:UInt
}

class OBJMeshLoader {

	public static function parse(blob:Blob):OBJMeshData {
		var dataString:String = blob.readUtf8String();
		var lines:Array<String> = dataString.split("\n");

		var vertexes:Array<Vector3> = [];
		var uvs:Array<Vector2> = [];
		var normals:Array<Vector3> = [];
		var triangleVertexes:Array<TriangleData> = [];

		var splitted:Array<String>;
		var triangleSplit:Array<String>;
		for(line in lines) {
			splitted = line.split(" ");
			switch(splitted[0]) {
				case "v":
					vertexes.push(new Vector3(Std.parseFloat(splitted[1]), Std.parseFloat(splitted[2]), Std.parseFloat(splitted[3])));
				case "vt":
					uvs.push(new Vector2(Std.parseFloat(splitted[1]), Std.parseFloat(splitted[2])));
				case "vn":
					normals.push(new Vector3(Std.parseFloat(splitted[1]), Std.parseFloat(splitted[2]), Std.parseFloat(splitted[3])));
				case "f":
					for(i in 1...4) {
						triangleSplit = splitted[i].split("/");
						triangleVertexes.push({
							v: Std.parseInt(triangleSplit[0]) - 1,
							vt: Std.parseInt(triangleSplit[1]) - 1,
							vn: Std.parseInt(triangleSplit[2]) - 1
						});
					}
			}
		}

		var triangleCount:UInt = Math.floor(triangleVertexes.length / 3);
		var vertexCount:UInt = triangleVertexes.length;
		
		var mesh:OBJMeshData = {
			#if js
			vertexes: new Float32Array(vertexCount * 3),
			uvs: new Float32Array(vertexCount * 2),
			normals: new Float32Array(vertexCount * 3),
			indices: new Uint32Array(triangleCount * 3),
			#else
			vertexes: new Float32Array(),
			uvs: new Float32Array(),
			normals: new Float32Array(),
			indices: new Uint32Array(),
			#end
			triangleCount: triangleCount,
			vertexCount: vertexCount
		}

		var index:Int = 0;
		var vertex:Vector3;
		var uv:Vector2;
		var normal:Vector3;
		for(vertexIndices in triangleVertexes) {
			vertex = vertexes[vertexIndices.v];
			mesh.vertexes.set(index * 3 + 0, vertex.x);
			mesh.vertexes.set(index * 3 + 1, vertex.y);
			mesh.vertexes.set(index * 3 + 2, vertex.z);

			if(vertexIndices.vt >= 0 && uvs.length > 0) {
				uv = uvs[vertexIndices.vt];
				mesh.uvs.set(index * 2 + 0, uv.x);
				mesh.uvs.set(index * 2 + 1, uv.y);
			} else {
				mesh.uvs.set(index * 2 + 0, 0);
				mesh.uvs.set(index * 2 + 1, 0);
			}

			normal = normals[vertexIndices.vn];
			mesh.normals.set(index * 3 + 0, normal.x);
			mesh.normals.set(index * 3 + 1, normal.y);
			mesh.normals.set(index * 3 + 2, normal.z);

			mesh.indices.set(index * 3 + 0, index * 3 + 0);
			mesh.indices.set(index * 3 + 1, index * 3 + 1);
			mesh.indices.set(index * 3 + 2, index * 3 + 2);

			index++;
		}
		
		return mesh;
	}

}