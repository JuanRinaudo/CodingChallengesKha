package kext.math;

import kha.math.Vector3;
import kha.math.FastVector4;

import kext.g4basics.BasicMesh;

class BoundingCube {
	public var position:Vector3;
	public var size(default, null):Vector3;
	private var originalV1:Vector3;
	private var originalV2:Vector3;
	public var v1:Vector3;
	public var v2:Vector3;

	public inline function new(centerPosition:Vector3, vector1:Vector3, vector2:Vector3) {
		if(vector1.x == vector2.x) { trace("Bounding cube has no width"); }
		if(vector1.y == vector2.y) { trace("Bounding cube has no height"); }
		if(vector1.z == vector2.z) { trace("Bounding cube has no depth"); }

		position = centerPosition;
		size = new Vector3(1, 1, 1);
		originalV1 = vector1.mult(1);
		originalV2 = vector2.mult(1);

		v1 = vector1;
		v2 = vector2;
	}

	public inline function getCubeSize():Vector3 {
		return v2.sub(v1);
	}

	public inline function getCubeCenter():Vector3 {
		return v1.add(position).add(getCubeSize().mult(0.5));
	}

	public inline function setPosition(vector:Vector3) {
		position.setFrom(vector);
	}

	public inline function setScale(vector:Vector3) {
		v1.x = originalV1.x * vector.x;
		v1.y = originalV1.y * vector.y;
		v1.z = originalV1.z * vector.z;
		v2.x = originalV2.x * vector.x;
		v2.y = originalV2.y * vector.y;
		v2.z = originalV2.z * vector.z;
		size.setFrom(vector);
	}

	public inline function translate(vector:Vector3) {
		position.x += vector.x;
		position.y += vector.y;
		position.z += vector.z;
	}

	public inline function scale(vector:Vector3) {
		v1.x *= vector.x;
		v1.y *= vector.y;
		v1.z *= vector.z;
		v2.x *= vector.x;
		v2.y *= vector.y;
		v2.z *= vector.z;
		size.x *= vector.x;
		size.y *= vector.y;
		size.z *= vector.z;
	}

	public inline function checkVectorOverlap(vector:Vector3) {
		var tv1:Vector3 = v1.add(position);
		var tv2:Vector3 = v2.add(position);
		if(vector.x < tv1.x || vector.x > tv2.x) { return false; }
		if(vector.y < tv1.y || vector.y > tv2.y) { return false; }
		if(vector.z < tv1.z || vector.z > tv2.z) { return false; }

		return true;
	}

	public inline function checkCubeOverlap(cube:BoundingCube) {
		var tv1:Vector3 = v1.add(position);
		var tv2:Vector3 = v2.add(position);
		var cubetv1:Vector3 = cube.v1.add(cube.position);
		var cubetv2:Vector3 = cube.v2.add(cube.position);
		if(tv1.x > cubetv2.x) return false;
		if(tv1.y > cubetv2.y) return false;
		if(tv1.z > cubetv2.z) return false;
		if(tv2.x < cubetv1.x) return false;
		if(tv2.y < cubetv1.y) return false;
		if(tv2.z < cubetv1.z) return false;

		return true;
	}

	public inline static function fromBasicMesh(mesh:BasicMesh):BoundingCube {
		var vertexes = mesh.vertexBuffer.lock();
		var x:Float = vertexes.get(0);
		var y:Float = vertexes.get(1);
		var z:Float = vertexes.get(2);
		var vector1:Vector3 = new Vector3(x, y, z);
		var vector2:Vector3 = new Vector3(x, y, z);
		var transformedVector:FastVector4;

		var structSize:Int = Math.floor(mesh.vertexStructure.byteSize() / 4);
		var baseIndex:Int = 0;
		for(i in 0...mesh.vertexCount) {
			x = vertexes.get(baseIndex + 0);
			y = vertexes.get(baseIndex + 1);
			z = vertexes.get(baseIndex + 2);
			transformedVector = mesh.modelMatrix.multvec(new FastVector4(x, y, z, 0));
			if(transformedVector.x < vector1.x) { vector1.x = transformedVector.x; }
			if(transformedVector.y < vector1.y) { vector1.y = transformedVector.y; }
			if(transformedVector.z < vector1.z) { vector1.z = transformedVector.z; }
			if(transformedVector.x > vector2.x) { vector2.x = transformedVector.x; }
			if(transformedVector.y > vector2.y) { vector2.y = transformedVector.y; }
			if(transformedVector.z > vector2.z) { vector2.z = transformedVector.z; }
			baseIndex += structSize;
		}

		return new BoundingCube(mesh.position, vector1, vector2);
	}

	public function toString() {
		return 'Bounding Cube (Position: $position, v1: $v1, v2: $v2)';
	}

}