package kext.math;

class MathExt {

	public static inline function clamp(value:Float, min:Float, max:Float):Float {
		return Math.max(Math.min(value, max), min);
	}

}