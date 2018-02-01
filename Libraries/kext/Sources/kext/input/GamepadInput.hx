package kext.input;

import kext.Basic;
import kext.Signal;
import kha.input.Gamepad;

import kext.events.PadAxisChangeEvent;
import kext.events.PadButtonChangeEvent;

typedef GamepadListenerType = Int -> Float -> Void;

typedef GamepadListeners = {
	axis:GamepadListenerType,
	button:GamepadListenerType
}

class GamepadInput extends Basic
{
	private var gamepadsSetted:Int = 0;
	private var gamepadListeners:Array<GamepadListeners> = [];
	private var axisData:Map<String, Float> = new Map();
	private var buttonData:Map<String, Float> = new Map();
	
	public var onAxisChange:Signal<PadAxisChangeEvent> = new Signal();
	public var onButtonChange:Signal<PadButtonChangeEvent> = new Signal();
	
	public function new() 
	{
		super();
		
		name = "Gamepad Input";
	}
	
	public function setGamepadCount(number:Int) {
		while (number != gamepadsSetted) {
			if (number > gamepadsSetted) {
				addGamepad(gamepadsSetted);
			} else {
				removeGamepad(gamepadsSetted);
			}
		}
	}
	
	private function addGamepad(index:Int) {
		var axisListener:GamepadListenerType = axisChangeListener.bind(index, _, _);
		var buttonListener:GamepadListenerType = buttonChangeListener.bind(index, _, _);
		gamepadListeners[index] = {axis: axisListener, button: buttonListener};
		Gamepad.get(index).notify(axisListener, buttonListener);
		gamepadsSetted++;
	}
	
	private function removeGamepad(index:Int) {
		var listeners:GamepadListeners = gamepadListeners[index];
		Gamepad.get(index).remove(listeners.axis, listeners.button);
		gamepadsSetted--;
	}
	
	private inline function getKey(index:Int, id:Int) {
		return index + "_" + id;
	}
	
	private function axisChangeListener(index:Int, id:Int, value:Float) {
		axisData.set(getKey(index, id), value);
		onAxisChange.dispatch({index: index, id: id, value: value});
	}
	
	private function buttonChangeListener(index:Int, id:Int, value:Float) {
		buttonData.set(getKey(index, id), value);
		onButtonChange.dispatch({index: index, id: id, value: value});
	}
	
	public function getAxis(index:Int, id:Int):Float {
		return axisData.get(getKey(index, id));
	}
	
	public function getButton(index:Int, id:Int):Float {
		return buttonData.get(getKey(index, id));
	}
	
	public function clearInput() {
		var keys = axisData.keys();
		for (key in keys) {
			axisData.set(key, 0);
		}
		
		var keys = buttonData.keys();
		for (key in keys) {
			buttonData.set(key, 0);
		}
	}
}