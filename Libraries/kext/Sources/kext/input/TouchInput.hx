package kext.input;

import kext.Signal;
import kext.Basic;

import kext.events.TouchStartEvent;
import kext.events.TouchEndEvent;
import kext.events.TouchMoveEvent;

import kha.input.Surface;

using kext.input.InputState;

typedef TouchPostion = {
	x:Int,
	y:Int
}

class TouchInput extends Basic
{
	private var touchData:Map<Int, InputState>;
	private var touchPosition:Map<Int, TouchPostion>;
	private var pressedQueue:Array<Int>;
	private var releasedQueue:Array<Int>;
	
	public var onTouchStart:Signal<TouchStartEvent> = new Signal();
	public var onTouchEnd:Signal<TouchEndEvent> = new Signal();
	public var onTouchMove:Signal<TouchMoveEvent> = new Signal();

	public function new() 
	{
		super();
		
		name = "Touch Input";
		
		touchData = new Map<Int, InputState>();
		touchPosition = new Map<Int, TouchPostion>();
		pressedQueue = [];
		releasedQueue = [];
		
		var surface = Surface.get(0);
		if(surface != null) {
			surface.notify(touchStartListener, touchEndListener, touchMoveListener);
		} else {
			trace("No surface of index 0 found");
		}
	}
	
	private function touchStartListener(index:Int, x:Int, y:Int) {
		touchData.set(index, PRESSED);
		pressedQueue.push(index);
		
		onTouchStart.dispatch({index: index, x: x, y: y});
	}
	
	private function touchEndListener(index:Int, x:Int, y:Int) {
		touchData.set(index, PRESSED);
		pressedQueue.push(index);
		
		onTouchEnd.dispatch({index: index, x: x, y: y});
	}
	
	private function touchMoveListener(index:Int, x:Int, y:Int) {
		var lastPosition:TouchPostion = touchPosition.get(index);
		if(lastPosition == null) {
			lastPosition = {x: x, y: y};
		}
		var deltaX:Int = x - lastPosition.x;
		var deltaY:Int = y - lastPosition.y;
		lastPosition.x = x;
		lastPosition.y = y;
		touchPosition.set(index, lastPosition);
		onTouchMove.dispatch({index: index, x: x, y: y, deltaX: deltaX, deltaY: deltaY});
	}
	
	public function touchDown(touchValue:Int):Bool {
		var state:InputState = touchData.get(touchValue);
		return state == DOWN || state == PRESSED;
	}
	
	public function touchUp(touchValue:Int):Bool {
		var state:InputState = touchData.get(touchValue);
		return state == UP || state == RELEASED;
	}
	
	public function touchPressed(touchValue:Int):Bool {
		return touchData.get(touchValue) == PRESSED;
	}
	
	public function touchReleased(touchValue:Int):Bool {
		return touchData.get(touchValue) == RELEASED;
	}
	
	override public function update(delta:Float) {
		super.update(delta);
		
		checkQueue(releasedQueue, UP);
		checkQueue(pressedQueue, DOWN);
	}
	
	private function checkQueue(queue:Array<Int>, state:InputState) {
		var key:Int;
		while (queue.length > 0) {
			var key = queue.pop();
			if (touchData.exists(key)) {
				touchData.set(key, state);
			}
		}
	}
	
	public function clearInput() {
		var touchs = touchData.keys();
		for (touch in touchs) {
			touchData.set(touch, UP);
		}
		
		while (releasedQueue.length > 0) {
			releasedQueue.pop();
		}
		while (pressedQueue.length > 0) {
			pressedQueue.pop();
		}
	}
}