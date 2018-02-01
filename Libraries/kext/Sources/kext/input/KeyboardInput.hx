package kext.input;

import kext.Signal;
import kext.Basic;

import kext.events.KeyPressedEvent;
import kext.events.KeyReleasedEvent;

import kha.input.KeyCode;
import kha.input.Keyboard;

using kext.input.InputState;

typedef KeyboardKey = {
	key: KeyCode,
	value: String
}

class KeyboardInput extends Basic
{
	private var keyData:Map<KeyCode, InputState> = new Map();
	private var pressedQueue:Array<KeyCode> = [];
	private var releasedQueue:Array<KeyCode> = [];
	
	public var onKeyPressed:Signal<KeyPressedEvent> = new Signal();
	public var onKeyReleased:Signal<KeyReleasedEvent> = new Signal();
	
	public function new() 
	{
		super();
		
		name = "Keyboard Input";
		
		Keyboard.get().notify(keyDownListener, keyUpListener);
	}
	
	private function keyDownListener(key:KeyCode) {		
		keyData.set(key, PRESSED);
		pressedQueue.push(key);
		onKeyPressed.dispatch({key: key});
	}
	
	private function keyUpListener(key:KeyCode) {		
		keyData.set(key, RELEASED);
		releasedQueue.push(key);
		onKeyReleased.dispatch({key: key});
	}
	
	public function keyDown(keyValue:KeyCode):Bool {		
		var state:InputState = keyData.get(keyValue);
		return state == DOWN || state == PRESSED;
	}
	
	public function keyUp(keyValue:KeyCode):Bool {
		var state:InputState = keyData.get(keyValue);
		return state == UP || state == RELEASED;
	}
	
	public function keyPressed(keyValue:KeyCode):Bool {
		return keyData.get(keyValue) == PRESSED;
	}
	
	public function keyReleased(keyValue:KeyCode):Bool {
		return keyData.get(keyValue) == RELEASED;
	}
	
	override public function update(delta:Float) {
		super.update(delta);
		
		checkQueue(releasedQueue, UP);
		checkQueue(pressedQueue, DOWN);
	}
	
	private function checkQueue(queue:Array<KeyCode>, state:InputState) {
		var key:String;
		while (queue.length > 0) {
			var key = queue.pop();
			if (keyData.exists(key)) {
				keyData.set(key, state);
			}
		}
	}
	
	public function clearInput() {
		var keys = keyData.keys();
		for (key in keys) {
			keyData.set(key, UP);
		}
		
		while (releasedQueue.length > 0) {
			releasedQueue.pop();
		}
		while (pressedQueue.length > 0) {
			pressedQueue.pop();
		}
	}
	
}