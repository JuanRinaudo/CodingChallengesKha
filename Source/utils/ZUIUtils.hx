package utils;

import kha.graphics4.TextureAddressing;
import kha.Color;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.FastVector4;
import kext.g4basics.BasicMesh;

import zui.Zui;
import zui.Ext;
import zui.Id;

using tweenxcore.Tools;

class ZUIUtils {

	private static var easingFunctions:Array<String> = [ "linear", "sineIn", "sineOut", "sineInOut", "sineOutIn", "quadIn", "quadOut", "quadInOut", "quadOutIn", "cubicIn", "cubicOut", "cubicInOut", "cubicOutIn", "quartIn", "quartOut", "quartInOut", "quartOutIn", "quintIn", "quintOut", "quintInOut", "quintOutIn", "expoIn", "expoOut", "expoInOut", "expoOutIn", "circIn", "circOut", "circInOut", "circOutIn", "bounceIn", "bounceOut", "bounceInOut", "bounceOutIn", "backIn", "backOut", "backInOut", "backOutIn", "elasticIn", "elasticOut", "elasticInOut", "elasticOutIn", "warpOut", "warpIn", "warpInOut", "warpOutIn" ];

	public static inline function vector2Sliders(ui:Zui, handle: Handle, vector:Vector2, label:String, from:Float, to:Float, precision:Int) {
		vector.x = ui.slider(handle.nest(0, {value: vector.x}), '$label X', from, to, true, precision, true);
		vector.y = ui.slider(handle.nest(1, {value: vector.y}), '$label Y', from, to, true, precision, true);
	}

	public static inline function vector3Sliders(ui:Zui, handle: Handle, vector:Vector3, label:String, from:Float, to:Float, precision:Int) {
		vector.x = ui.slider(handle.nest(0, {value: vector.x}), '$label X', from, to, true, precision, true);
		vector.y = ui.slider(handle.nest(1, {value: vector.y}), '$label Y', from, to, true, precision, true);
		vector.z = ui.slider(handle.nest(2, {value: vector.z}), '$label Z', from, to, true, precision, true);
	}

	public static inline function lightingParameters(ui:Zui, handle: Handle, lightDirection:FastVector4, lightColor:FastVector4, ambientColor:FastVector4, selected:Bool = true) {
		if(ui.panel(Id.handle({selected: selected}), "Lighting")) {
			var light:Vector3 = new Vector3(lightDirection.x, lightDirection.y, lightDirection.z);
			vector3Sliders(ui, handle.nest(0), light, "Light Direction", -1, 1, 100);
			lightDirection.x = light.x;
			lightDirection.y = light.y;
			lightDirection.z = light.z;

			var color:Color;
			ui.text("Light Color");
			color = Color.fromValue(Ext.colorPicker(ui, handle.nest(1, {color: Color.fromFloats(lightColor.x, lightColor.y, lightColor.z, lightColor.w)}), true));
			lightColor.x = color.R;
			lightColor.y = color.G;
			lightColor.z = color.B;
			lightColor.w = color.A;

			ui.text("Ambient Color");
			color = Color.fromValue(Ext.colorPicker(ui, handle.nest(2, {color: Color.fromFloats(ambientColor.x, ambientColor.y, ambientColor.z, ambientColor.w)}), true));
			ambientColor.x = color.R;
			ambientColor.y = color.G;
			ambientColor.z = color.B;
			ambientColor.w = color.A;
		}
	}

#if DEMO_MESHES
	public static function meshSelector(ui:Zui, handle: Handle, lastValue:BasicMesh, selected:Bool = true):BasicMesh {
		if(ui.panel(handle.nest(0, {selected: selected}), "Mesh Type")) {
			if(ui.button("Quad")) { return DemoMeshes.QUAD; }
			if(ui.button("Cube")) { return DemoMeshes.CUBE; }
			if(ui.button("Sphere")) { return DemoMeshes.SPHERE; }
			if(ui.button("Torus")) { return DemoMeshes.TORUS; }
			if(ui.button("Arrow")) { return DemoMeshes.ARROW; }
			if(ui.button("Suzanne")) { return DemoMeshes.SUZANNE; }
		}
		return null;
	}
#end

	public static function textureAddresing(ui:Zui, handle: Handle, value:TextureAddressing, label:String = null, selected:Bool = false):TextureAddressing {
		if(ui.panel(handle.nest(0, {selected: selected}), label == null ? "Texture Addressing" : label)) {
			if(ui.button("Repeat")) { return Repeat; }
			if(ui.button("Mirror")) { return Mirror; }
			if(ui.button("Clamp")) { return Clamp; }
		}
		return value;
	}

	public static function tweenEasing(ui:Zui, handle: Handle, label:String = null, selected:Bool = false):Int
	{
		var easingIndex:Int = Math.floor(handle.value);
		ui.text(label, Align.Center);
		easingIndex = Math.floor(ui.slider(handle, easingFunctions[easingIndex], 0, easingFunctions.length - 1, false, 1, false, Align.Right, false));
		return easingIndex;
	}

	public static function getEasingByIndex(index:Int):Float -> Float
	{
		return Reflect.field(Easing, easingFunctions[index]);
	}

	public static function callEasingByIndex(index:Int, value:Float):Float
	{
		return Reflect.callMethod(Easing, Reflect.field(Easing, easingFunctions[index]), [value]);
	}

}