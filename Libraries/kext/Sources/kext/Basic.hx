package kext;

import kha.Image;

class Basic {

	public var ID:UInt = 0;
	public var name(get, set):String;
	private var _name:String;

	public function new() {
		ID = Application.getNextID();
		name = "Basic";
	}

	public function update(delta:Float) {
		#if debug
		#end
	}

	public function render(backbuffer:Image) {
		#if debug
		#end
	}

	public function get_name():String {
		return _name;
	}
	public function set_name(value:String):String {
		_name = value + ' ($ID)';
		return _name;
	}
	
}