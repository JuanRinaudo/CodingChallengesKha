package utils;

import kha.Color;
import kha.math.Vector3;
import kha.math.FastVector4;
import kext.g4basics.BasicMesh;

import zui.Zui;
import zui.Ext;
import zui.Id;

class ZUIUtils {

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
			color = Color.fromValue(Ext.colorPicker(ui, handle.nest(1, {color: Color.fromFloats(lightColor.x, lightColor.y, lightColor.z, lightColor.w)})));
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

	public static function meshSelector(ui:Zui, handle: Handle, lastValue:BasicMesh, selected:Bool = true, uiOBJ:Bool = true, uiSTL:Bool = false):BasicMesh {
		if(ui.panel(handle.nest(0, {selected: selected}), "Mesh Type")) {
			if(uiOBJ) {
				if(ui.button("Cube OBJ")) { return DemoMeshes.CUBE_OBJ; }
				if(ui.button("Sphere OBJ")) { return DemoMeshes.SPHERE_OBJ; }
				if(ui.button("Torus OBJ")) { return DemoMeshes.TORUS_OBJ; }
				if(ui.button("Arrow OBJ")) { return DemoMeshes.ARROW_OBJ; }
				if(ui.button("Suzanne OBJ")) { return DemoMeshes.SUZANNE_OBJ; }
				if(ui.button("Racing Car OBJ")) { return DemoMeshes.CAR_FORMULA_OBJ; }
			}
			if(uiSTL) {
				if(ui.button("Cube STL")) { return DemoMeshes.CUBE_STL; }
				if(ui.button("Sphere STL")) { return DemoMeshes.SPHERE_STL; }
				if(ui.button("Torus STL")) { return DemoMeshes.TORUS_STL; }
				if(ui.button("Arrow STL")) { return DemoMeshes.ARROW_STL; }
				if(ui.button("Suzanne STL")) { return DemoMeshes.SUZANNE_STL; }
				if(ui.button("Racing Car STL")) { return DemoMeshes.CAR_FORMULA_STL; }
			}
		}
		return lastValue;
	}

}