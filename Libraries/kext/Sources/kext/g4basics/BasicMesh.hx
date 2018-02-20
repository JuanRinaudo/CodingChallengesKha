package kext.g4basics;

import kha.Color;
import kha.Image;
import kha.Blob;

import kha.arrays.Float32Array;

import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.FastMatrix4;

import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexStructure;
import kha.graphics4.Usage;

import kext.loaders.STLMeshLoader;
import kext.loaders.STLMeshLoader.STLMeshData;
import kext.loaders.OBJMeshLoader;
import kext.loaders.OBJMeshLoader.OBJMeshData;

class BasicMesh {

	public var vertexBuffer:VertexBuffer;
	public var indexBuffer:IndexBuffer;

	public var triangleCount:UInt = 0;
	public var indexCount:UInt = 0;
	public var vertexCount:UInt = 0;
	public var vertexStructure:VertexStructure;

	public var modelMatrix:FastMatrix4;

	public var position(default, null):Vector3;
	public var rotation(default, null):Vector3;
	public var size(default, null):Vector3;

	public static var VERTEX_OFFSET:Int = 0;
	public static var NORMAL_OFFSET:Int = 3;
	public static var UV_OFFSET:Int = 6;
	public static var COLOR_OFFSET:Int = 8;

	public function new(vertexCount:Int, indexCount:Int, structure:VertexStructure, vertexUsage:Usage = null, indexUsage:Usage = null) {
		if(vertexUsage == null) { vertexUsage = Usage.StaticUsage; }
		if(indexUsage == null) { indexUsage = Usage.StaticUsage; }
		vertexBuffer = new VertexBuffer(vertexCount, structure, vertexUsage);
		indexBuffer = new IndexBuffer(indexCount, indexUsage);

		vertexStructure = structure;

		position = new Vector3(0, 0, 0);
		rotation = new Vector3(0, 0, 0);
		size = new Vector3(1, 1, 1);
		recalculateModelMatrix();
	}

	public inline function setBufferMesh(backbuffer:Image) {
		backbuffer.g4.setVertexBuffer(vertexBuffer);
		backbuffer.g4.setIndexBuffer(indexBuffer);
	}
	
	public inline function drawMesh(backbuffer:Image, pipeline:BasicPipeline, setPipeline:Bool = true) {
		if(setPipeline) { backbuffer.g4.setPipeline(pipeline); }
		backbuffer.g4.setVertexBuffer(vertexBuffer);
		backbuffer.g4.setIndexBuffer(indexBuffer);
		backbuffer.g4.setMatrix(pipeline.locationMVPMatrix, pipeline.getMVPMatrix(modelMatrix));
		backbuffer.g4.setMatrix(pipeline.locationModelMatrix, modelMatrix);
		backbuffer.g4.setMatrix3(pipeline.locationNormalMatrix, pipeline.getNormalMatrix(modelMatrix));
		backbuffer.g4.drawIndexedVertices();
	}

	public inline function translate(deltaPosition:Vector3) {
		position = position.add(deltaPosition);
		modelMatrix = modelMatrix.multmat(FastMatrix4.translation(deltaPosition.x, deltaPosition.y, deltaPosition.z));
	}

	public inline function rotate(deltaRotation:Vector3) {
		rotation = rotation.add(deltaRotation);
		modelMatrix = modelMatrix.multmat(FastMatrix4.rotation(deltaRotation.x, deltaRotation.y, deltaRotation.z));
	}

	public inline function scale(deltaScale:Vector3) {
		size.x *= deltaScale.x;
		size.y *= deltaScale.y;
		size.z *= deltaScale.z;
		modelMatrix = modelMatrix.multmat(FastMatrix4.scale(deltaScale.x, deltaScale.y, deltaScale.z));
	}

	public inline function recalculateModelMatrix() {
		modelMatrix = FastMatrix4.identity()
			.multmat(FastMatrix4.translation(position.x, position.y, position.z))
			.multmat(FastMatrix4.scale(size.x, size.y, size.z))
			.multmat(FastMatrix4.rotation(rotation.x, rotation.y, rotation.z));
	}

	public function setPosition(newPosition:Vector3) {
		position.setFrom(newPosition);
		recalculateModelMatrix();
	}

	public function setRotation(newRotation:Vector3) {
		rotation.setFrom(newRotation);
		recalculateModelMatrix();
	}

	public function setSize(newSize:Vector3) {
		size.setFrom(newSize);
		recalculateModelMatrix();
	}

	public inline function addTriangle(v1:Vector3, v2:Vector3, v3:Vector3, n1:Vector3, n2:Vector3, n3:Vector3,
		uv1:Vector2, uv2:Vector2, uv3:Vector2, color1:Color, color2:Color = null, color3:Color = null) {
		if(color2 == null) { color2 = color1; }
		if(color3 == null) { color3 = color1; }

		var structSize = Math.floor(vertexStructure.byteSize() / 4);
		var baseIndex:Int = vertexCount * structSize;
		var vertexes:Float32Array = vertexBuffer.lock();
		setVertex(vertexes, baseIndex, v1, n1, uv1, color1);
		setVertex(vertexes, baseIndex + structSize, v2, n2, uv2, color2);
		setVertex(vertexes, baseIndex + structSize * 2, v3, n3, uv3, color3);
		vertexBuffer.unlock();

		var baseIndex:Int = indexCount;
		var indexes = indexBuffer.lock();
		indexes.set(baseIndex + 0, baseIndex + 0);
		indexes.set(baseIndex + 1, baseIndex + 1);
		indexes.set(baseIndex + 2, baseIndex + 2);
		indexBuffer.unlock();

		triangleCount += 1;
		indexCount += 3;
		vertexCount += 3;
	}

	public inline function addVertexes(vectors:Array<Vector3>, normals:Array<Vector3>, uvs:Array<Vector2>, colors:Array<Color>) {
		if(vectors.length != normals.length || normals.length != uvs.length || uvs.length != colors.length) {
			trace("addVertexes: Arrays dont have the same length " + vectors.length + " | " + normals.length + " | " + uvs.length + " | " + colors.length);
		}

		var structSize = Math.floor(vertexStructure.byteSize() / 4);
		var baseIndex:Int = vertexCount * structSize;
		var vertexes:Float32Array = vertexBuffer.lock();
		for(i in 0...vectors.length) {
			setVertex(vertexes, baseIndex, vectors[i], normals[i], uvs[i], colors[i]);
			baseIndex += structSize;
		}
		vertexBuffer.unlock();
		vertexCount += vectors.length;
	}

	public inline function addIndexes(indexes:Array<Int>) {
		var baseIndex = indexCount;
		var indexes = indexBuffer.lock();
		for(index in indexes) {
			indexes.set(baseIndex, index);
			baseIndex++;
		}
		indexBuffer.unlock();
		indexCount += indexes.length;
		triangleCount = Math.floor(indexCount / 3);
	}

	private inline function setVertex(vertexes:Float32Array, baseIndex:Int, vector:Vector3, normal:Vector3, uv:Vector2, color:Color) {
		vertexes.set(baseIndex + VERTEX_OFFSET + 0, vector.x);
		vertexes.set(baseIndex + VERTEX_OFFSET + 1, vector.y);
		vertexes.set(baseIndex + VERTEX_OFFSET + 2, vector.z);
		vertexes.set(baseIndex + NORMAL_OFFSET + 0, normal.x);
		vertexes.set(baseIndex + NORMAL_OFFSET + 1, normal.y);
		vertexes.set(baseIndex + NORMAL_OFFSET + 2, normal.z);
		vertexes.set(baseIndex + UV_OFFSET + 0, uv.x);
		vertexes.set(baseIndex + UV_OFFSET + 1, uv.y);
		vertexes.set(baseIndex + COLOR_OFFSET + 0, color.R);
		vertexes.set(baseIndex + COLOR_OFFSET + 1, color.G);
		vertexes.set(baseIndex + COLOR_OFFSET + 2, color.B);
		vertexes.set(baseIndex + COLOR_OFFSET + 3, color.A);
	}
	
	public static inline function getSTLMesh(blob:Blob, structure:VertexStructure, color:Color = null):BasicMesh {
		var objMeshData = STLMeshLoader.parse(blob);
		var mesh:BasicMesh = BasicMesh.fromSTLData(objMeshData, structure);
		if(color != null) {
			BasicMesh.setAllVertexesColor(mesh, structure, color);
		}
		return mesh;
	}

	public static function fromSTLData(data:STLMeshData, structure:VertexStructure, vertexUsage:Usage = null, indexUsage:Usage = null):BasicMesh {
		var mesh:BasicMesh = new BasicMesh(data.vertexCount, data.triangleCount * 3, structure, vertexUsage, indexUsage);
		
		var vertexes = mesh.vertexBuffer.lock();
		var vertexStep:Int = Math.floor(structure.byteSize() / 4);
		var baseIndex:Int = 0;
		var normalIndex:Int = 0;
		for(i in 0...data.vertexCount) {
			baseIndex = i * vertexStep;

			setAllVertexDataValue(vertexes, baseIndex, vertexStep, 0);
			
			vertexes.set(baseIndex + VERTEX_OFFSET + 0, data.vertexes.get(i * 3 + 0));
			vertexes.set(baseIndex + VERTEX_OFFSET + 1, data.vertexes.get(i * 3 + 1));
			vertexes.set(baseIndex + VERTEX_OFFSET + 2, data.vertexes.get(i * 3 + 2));
			
			normalIndex = Math.floor(i / 3);
			vertexes.set(baseIndex + NORMAL_OFFSET + 0, data.normals.get(normalIndex * 3 + 0));
			vertexes.set(baseIndex + NORMAL_OFFSET + 1, data.normals.get(normalIndex * 3 + 1));
			vertexes.set(baseIndex + NORMAL_OFFSET + 2, data.normals.get(normalIndex * 3 + 2));
		}
		mesh.vertexBuffer.unlock();
		
		var indexes = mesh.indexBuffer.lock();
		for(i in 0...data.triangleCount * 3) {
			indexes.set(i, i);
		}
		mesh.indexBuffer.unlock();
		
		mesh.vertexCount = data.vertexCount;
		mesh.indexCount = data.triangleCount * 3;
		mesh.triangleCount = data.triangleCount;

		return mesh;
	}

	public static inline function getOBJMesh(blob:Blob, structure:VertexStructure, color:Color = null):BasicMesh {
		var objMeshData = OBJMeshLoader.parse(blob);
		var mesh:BasicMesh = BasicMesh.fromOBJData(objMeshData, structure);
		if(color != null) {
			BasicMesh.setAllVertexesColor(mesh, structure, color);
		}
		return mesh;
	}

	public static function fromOBJData(data:OBJMeshData, structure:VertexStructure, vertexUsage:Usage = null, indexUsage:Usage = null) {
		var mesh:BasicMesh = new BasicMesh(data.vertexCount, data.triangleCount * 3, structure, vertexUsage, indexUsage);

		var vertexes = mesh.vertexBuffer.lock();
		var vertexStep:Int = Math.floor(structure.byteSize() / 4);
		var baseIndex:Int = 0;
		var normalIndex:Int = 0;
		for(i in 0...data.vertexCount) {
			baseIndex = i * vertexStep;
			
			setAllVertexDataValue(vertexes, baseIndex, vertexStep, 0);
			
			vertexes.set(baseIndex + VERTEX_OFFSET + 0, data.vertexes.get(i * 3 + 0));
			vertexes.set(baseIndex + VERTEX_OFFSET + 1, data.vertexes.get(i * 3 + 1));
			vertexes.set(baseIndex + VERTEX_OFFSET + 2, data.vertexes.get(i * 3 + 2));
			
			vertexes.set(baseIndex + UV_OFFSET + 0, data.uvs.get(i * 2 + 0));
			vertexes.set(baseIndex + UV_OFFSET + 1, data.uvs.get(i * 2 + 1));
			
			vertexes.set(baseIndex + NORMAL_OFFSET + 0, data.normals.get(i * 3 + 0));
			vertexes.set(baseIndex + NORMAL_OFFSET + 1, data.normals.get(i * 3 + 1));
			vertexes.set(baseIndex + NORMAL_OFFSET + 2, data.normals.get(i * 3 + 2));
		}
		mesh.vertexBuffer.unlock();
		
		var indexes = mesh.indexBuffer.lock();
		for(i in 0...data.triangleCount * 3) {
			indexes.set(i, i);
		}
		mesh.indexBuffer.unlock();

		mesh.vertexCount = data.vertexCount;
		mesh.indexCount = data.triangleCount * 3;
		mesh.triangleCount = data.triangleCount;

		return mesh;
	}

	private static inline function setAllVertexDataValue(vertexes:Float32Array, offset:Int, size:Int, value:Float) {
		for(i in 0...size) {
			vertexes.set(offset + i, 0);
		}
	}

	public static function setAllVertexesColor(mesh:BasicMesh, structure:VertexStructure, color:Color) {
		var vertexes = mesh.vertexBuffer.lock();
		if(vertexes.length == 0) {
			trace("Cant color vertexes, no vertexes found");
			return;
		} 
		var vertexStep:Int = Math.floor(structure.byteSize() / 4);
		var baseIndex:Int = 0;
		for(i in 0...vertexes.length) {
			baseIndex = i * vertexStep;

			vertexes.set(baseIndex + COLOR_OFFSET + 0, color.R);
			vertexes.set(baseIndex + COLOR_OFFSET + 1, color.G);
			vertexes.set(baseIndex + COLOR_OFFSET + 2, color.B);
			vertexes.set(baseIndex + COLOR_OFFSET + 3, color.A);
		}
		mesh.vertexBuffer.unlock();
	}

}