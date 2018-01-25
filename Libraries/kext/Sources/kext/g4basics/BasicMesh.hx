package kext.g4basics;

import kha.Color;

import kha.arrays.Float32Array;

import kha.math.FastMatrix4;

import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexStructure;
import kha.graphics4.Usage;

import kext.loaders.STLMeshLoader.STLMeshData;
import kext.loaders.OBJMeshLoader.OBJMeshData;

class BasicMesh {

	public var vertexBuffer:VertexBuffer;
	public var indexBuffer:IndexBuffer;

	public var modelMatrix:FastMatrix4;

	public function new(vertexCount:Int, indexCount:Int, structure:VertexStructure, vertexUsage:Usage = null, indexUsage:Usage = null) {
		if(vertexUsage == null) { vertexUsage = Usage.StaticUsage; }
		if(indexUsage == null) { indexUsage = Usage.StaticUsage; }
		vertexBuffer = new VertexBuffer(vertexCount, structure, vertexUsage);
		indexBuffer = new IndexBuffer(indexCount, indexUsage);

		modelMatrix = FastMatrix4.identity();
	}

	public static function fromSTLData(data:STLMeshData, structure:VertexStructure, vertexOffset:Int, normalsOffset:Int, vertexUsage:Usage = null, indexUsage:Usage = null):BasicMesh {
		var mesh:BasicMesh = new BasicMesh(data.vertexCount, data.triangleCount * 3, structure, vertexUsage, indexUsage);
		
		var vertexes = mesh.vertexBuffer.lock();
		var vertexStep:Int = Math.floor(structure.byteSize() / 4);
		var baseIndex:Int = 0;
		var normalIndex:Int = 0;
		for(i in 0...data.vertexCount) {
			baseIndex = i * vertexStep;

			setAllVertexDataValue(vertexes, baseIndex, vertexStep, 0);
			
			vertexes.set(baseIndex + vertexOffset + 0, data.vertexes.get(i * 3 + 0));
			vertexes.set(baseIndex + vertexOffset + 1, data.vertexes.get(i * 3 + 1));
			vertexes.set(baseIndex + vertexOffset + 2, data.vertexes.get(i * 3 + 2));
			
			normalIndex = Math.floor(i / 3);
			vertexes.set(baseIndex + normalsOffset + 0, data.normals.get(normalIndex * 3 + 0));
			vertexes.set(baseIndex + normalsOffset + 1, data.normals.get(normalIndex * 3 + 1));
			vertexes.set(baseIndex + normalsOffset + 2, data.normals.get(normalIndex * 3 + 2));
		}
		mesh.vertexBuffer.unlock();
		
		var indexes = mesh.indexBuffer.lock();
		for(i in 0...data.triangleCount * 3) {
			indexes.set(i, i);
		}
		mesh.indexBuffer.unlock();

		return mesh;
	}

	public static function fromOBJData(data:OBJMeshData, structure:VertexStructure, vertexOffset:Int, normalsOffset:Int, uvOffset:Int, vertexUsage:Usage = null, indexUsage:Usage = null) {
		var mesh:BasicMesh = new BasicMesh(data.vertexCount, data.triangleCount * 3, structure, vertexUsage, indexUsage);

		var vertexes = mesh.vertexBuffer.lock();
		var vertexStep:Int = Math.floor(structure.byteSize() / 4);
		var baseIndex:Int = 0;
		var normalIndex:Int = 0;
		for(i in 0...data.vertexCount) {
			baseIndex = i * vertexStep;
			
			setAllVertexDataValue(vertexes, baseIndex, vertexStep, 0);
			
			vertexes.set(baseIndex + vertexOffset + 0, data.vertexes.get(i * 3 + 0));
			vertexes.set(baseIndex + vertexOffset + 1, data.vertexes.get(i * 3 + 1));
			vertexes.set(baseIndex + vertexOffset + 2, data.vertexes.get(i * 3 + 2));
			
			vertexes.set(baseIndex + uvOffset + 0, data.uvs.get(i * 2 + 0));
			vertexes.set(baseIndex + uvOffset + 1, data.uvs.get(i * 2 + 1));
			
			vertexes.set(baseIndex + normalsOffset + 0, data.normals.get(i * 3 + 0));
			vertexes.set(baseIndex + normalsOffset + 1, data.normals.get(i * 3 + 1));
			vertexes.set(baseIndex + normalsOffset + 2, data.normals.get(i * 3 + 2));
		}
		mesh.vertexBuffer.unlock();
		
		var indexes = mesh.indexBuffer.lock();
		for(i in 0...data.triangleCount * 3) {
			indexes.set(i, i);
		}
		mesh.indexBuffer.unlock();

		return mesh;
	}

	private static inline function setAllVertexDataValue(vertexes:Float32Array, offset:Int, size:Int, value:Float) {
		for(i in 0...size) {
			vertexes.set(offset + i, 0);
		}
	}

	public static function setAllVertexesColor(mesh:BasicMesh, structure:VertexStructure, colorOffset:Int, color:Color) {
		var vertexes = mesh.vertexBuffer.lock();
		if(vertexes.length == 0) {
			trace("Cant color vertexes, no vertexes found");
			return;
		} 
		var vertexStep:Int = Math.floor(structure.byteSize() / 4);
		var baseIndex:Int = 0;
		for(i in 0...vertexes.length) {
			baseIndex = i * vertexStep;

			vertexes.set(baseIndex + colorOffset + 0, color.R);
			vertexes.set(baseIndex + colorOffset + 1, color.G);
			vertexes.set(baseIndex + colorOffset + 2, color.B);
			vertexes.set(baseIndex + colorOffset + 3, color.A);
		}
		mesh.vertexBuffer.unlock();
	}

}