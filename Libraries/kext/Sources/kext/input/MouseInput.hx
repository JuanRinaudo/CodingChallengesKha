package kext.input;

import kext.Signal;
import kext.Basic;

import kext.events.MousePressedEvent;
import kext.events.MouseReleasedEvent;
import kext.events.MouseMoveEvent;
import kext.events.MouseWheelEvent;

import kha.input.Mouse;
import kha.math.Vector2;

using kext.input.InputState;

typedef MouseButton = {
	button:Int,
	x:Int,
	y:Int
}

typedef MouseDelta = {
	x: Int,
	y: Int,
	dx: Int,
	dy: Int
}

typedef MouseWheelDelta = {
	delta: Int
}

class MouseInput extends Basic
{
	private var buttonData:Map<Int, InputState> = new Map();
	private var pressedQueue:Array<Int> = [];
	private var releasedQueue:Array<Int> = [];

	public var x(get, null):Float;
	public var y(get, null):Float;
	
	public var mousePosition(get, null):Vector2;
	public var mousePosDelta(get, null):Vector2;
	private var _mousePosition:Vector2 = new Vector2();
	private var _mousePosDelta:Vector2 = new Vector2();
	
	public var onMousePressed:Signal<MousePressedEvent> = new Signal();
	public var onMouseReleased:Signal<MouseReleasedEvent> = new Signal();
	public var onMouseMove:Signal<MouseMoveEvent> = new Signal();
	public var onMouseWheel:Signal<MouseWheelEvent> = new Signal();
	
	public var mouseWheel(get, null):Int;

	public function new() 
	{
		super();
		
		name = "Mouse Input";
		
		Mouse.get().notify(mouseDownListener, mouseUpListener, mouseMoveListener, mouseWheelListener);
	}
	
	private function mouseDownListener(index:Int, x:Int, y:Int) {
		_mousePosition.x = x;
		_mousePosition.y = y;
		_mousePosDelta.x = 0;
		_mousePosDelta.y = 0;
		buttonData.set(index, PRESSED);
		pressedQueue.push(index);
		onMousePressed.dispatch({index: index, x: x, y: y});
	}
	
	private function mouseUpListener(index:Int, x:Int, y:Int) {
		_mousePosition.x = x;
		_mousePosition.y = y;
		_mousePosDelta.x = 0;
		_mousePosDelta.y = 0;
		buttonData.set(index, RELEASED);
		releasedQueue.push(index);
		onMouseReleased.dispatch({index: index, x: x, y: y});
	}
	
	private function mouseMoveListener(x:Int, y:Int, deltaX:Int, deltaY:Int) {
		_mousePosition.x = x;
		_mousePosition.y = y;
		_mousePosDelta.x = deltaX;
		_mousePosDelta.y = deltaY;
		onMouseMove.dispatch({x: x, y: y, deltaX: deltaX, deltaY: deltaY});
	}
	
	private function mouseWheelListener(delta:Int) {
		mouseWheel = delta;
		onMouseWheel.dispatch({delta: delta});
	}
	
	public function buttonDown(buttonValue:Int):Bool {
		var state:InputState = buttonData.get(buttonValue);
		return state == DOWN || state == PRESSED;
	}
	
	public function buttonUp(buttonValue:Int):Bool {
		var state:InputState = buttonData.get(buttonValue);
		return state == UP || state == RELEASED;
	}
	
	public function buttonPressed(buttonValue:Int):Bool {
		return buttonData.get(buttonValue) == PRESSED;
	}
	
	public function buttonReleased(buttonValue:Int):Bool {
		return buttonData.get(buttonValue) == RELEASED;
	}
	
	override public function update(delta:Float) {
		super.update(delta);
		
		checkQueue(releasedQueue, UP);
		checkQueue(pressedQueue, DOWN);
		
		mouseWheel = 0;
	}
	
	private function checkQueue(queue:Array<Int>, state:InputState) {
		var key:String;
		while (queue.length > 0) {
			var key = queue.pop();
			if (buttonData.exists(key)) {
				buttonData.set(key, state);
			}
		}
	}
	
	public function get_x():Float {
		return _mousePosition.x;
	}

	public function get_y():Float {
		return _mousePosition.y;
	}

	public function get_mousePosition():Vector2 {
		return new Vector2(_mousePosition.x, _mousePosition.y);
	}

	public function get_mousePosDelta():Vector2 {
		return new Vector2(_mousePosDelta.x, _mousePosDelta.y);
	}
	
	public function get_mouseWheel():Int {
		return this.mouseWheel;
	}
	
	public function clearInput() {
		var buttons = buttonData.keys();
		for (button in buttons) {
			buttonData.set(button, UP);
		}
		
		while (releasedQueue.length > 0) {
			releasedQueue.pop();
		}
		while (pressedQueue.length > 0) {
			pressedQueue.pop();
		}
	}
}