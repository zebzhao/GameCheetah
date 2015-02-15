/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.gameutils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import gamecheetah.Engine;
	import gamecheetah.namespaces.hidden;

	use namespace hidden;
	
	/**
	 * Easy way to check for keyboard/mouse input.
	 * Adapted from Flashpunk 1.7 source code by Zeb Zhao.
	 */
	public class Input
	{
		/**
		 * Stores event identifiers.
		 */
		public static function get events():Events { return Events.instance };
		
		/**
		 * Dispatches input events (e.g. Enter key).
		 */
		public static var dispatcher:EventDispatcher = new EventDispatcher();
		
		/**
		 * Max amount of characters stored by the keystring.
		 */
		public static var KEYSTRING_MAX:uint = 0;
		
		/**
		 * Max amount of key presses to store in history.
		 */
		public static var KEYDOWN_HISTORY_MAX:uint = 0;
		
		/**
		 * Max amount of key releases to store in history.
		 */
		public static var KEYUP_HISTORY_MAX:uint = 0;
		
		/**
		 * An updated string containing the last 100 characters pressed on the keyboard.
		 * Useful for creating text input fields, such as highscore entries, etc.
		 */
		public static var keyString:String = "";
		
		/**
		 * The last key pressed.
		 */
		public static var lastKey:int;
		
		/**
		 * If the mouse button is down.
		 */
		public static var mouseDown:Boolean = false;
		
		/**
		 * If the mouse button is up.
		 */
		public static var mouseUp:Boolean = true;
		
		/**
		 * If the mouse button was pressed this frame.
		 */
		public static var mousePressed:Boolean = false;
		
		/**
		 * If the mouse button was released this frame.
		 */
		public static var mouseReleased:Boolean = false;
		
		/**
		 * If the mouse wheel was moved this frame.
		 */
		public static var mouseWheel:Boolean = false; 
		
		/**
		 * If the mouse wheel was moved this frame, this was the delta.
		 */
		public static function get mouseWheelDelta():int
		{
			if (mouseWheel)
			{
				mouseWheel = false;
				return _mouseWheelDelta;
			}
			return 0;
		}
		
		/**
		 * The absolute mouse x position on the screen (unscaled).
		 */
		public static function get mouseX():int
		{
			return Engine.stage.mouseX;
		}
		
		/**
		 * The absolute mouse y position on the screen (unscaled).
		 */
		public static function get mouseY():int
		{
			return Engine.stage.mouseY;
		}
		
		/**
		 * Internally used by Designer class to avoid firing key events while in design mode.
		 */
		hidden static var _eventsEnabled:Boolean = true;
		
		/**
		 * If the key is held down.
		 * @param	input		An input key to check for.
		 * @return	True or false.
		 */
		public static function checkKey(input:uint):Boolean
		{
			return _key[input];
		}
		
		/**
		 * If the keys were pressed in order within the last number of frames.
		 * @param	input		An ordered list of input keys to check for.
		 * @param	limit		The number of recent frames to look in.
		 * @param	onKeyUp		True to check released keys instead of pressed keys.
		 * @return	True or false.
		 */
		public static function checkKeySequence(input:Array, limit:uint, onKeyUp:Boolean=true):Boolean
		{
			// Choose to check key presses or key releases.
			var history:Vector.<int> = onKeyUp ? _release : _press;
			
			var frameBegin:uint = Engine.frameElapsed;
			frameBegin -= limit <= frameBegin ? limit : frameBegin;
			
			// Start with the last element, and match in backwards order.
			var lastIndex:int = input.length - 1;
			var matchIndex:int = lastIndex;
			var currentMatch:int = input[matchIndex];
			
			var index:int = history.length;
			while (index >= 2)
			{
				index -= 2;
				if (history[index + 1] < frameBegin)
				{
					break;
				}
				else if (history[index] == currentMatch)
				{
					matchIndex--;
					if (matchIndex >= 0) currentMatch = input[matchIndex];
					else return true;
				}
				else
				{
					matchIndex = lastIndex;
					currentMatch = input[matchIndex];
				}
			}
			return false;
		}
		
		/** @private Called by Engine to enable keyboard input on the stage. */
		public static function get enabled():Boolean 
		{
			return _enabled;
		}
		public static function set enabled(value:Boolean):void
		{
			if (_enabled == value) return;
			_enabled = value;
			if (_enabled)
			{
				Engine.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				Engine.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				Engine.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				Engine.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				Engine.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
			else
			{
				Engine.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				Engine.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				Engine.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				Engine.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				Engine.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
		}
		
		/** @private Event handler for key press. */
		private static function onKeyDown(e:KeyboardEvent):void
		{
			// get the keycode
			var code:int = lastKey = e.keyCode;
			
			if (_eventsEnabled)
				if (code == Keyboard.ENTER || code == Keyboard.NUMPAD_ENTER)
					dispatcher.dispatchEvent(new Event(events.E_ENTER_PRESSED));
			
			// update the keystring
			if (KEYSTRING_MAX > 0)
			{
				if (code == Keyboard.BACKSPACE)
				{
					keyString = keyString.substring(0, keyString.length - 1);
				}
				else if (e.charCode > 31 && e.charCode != 127) // 127 is delete
				{
					if (keyString.length > KEYSTRING_MAX) keyString = keyString.substring(1);
					keyString += String.fromCharCode(e.charCode);
				}
			}
			
			// update the keystate
			if (!_key[code])
			{
				_key[code] = true;
				_keyNum ++;
				_pressNum ++
				
				if (_press.length == 2*KEYDOWN_HISTORY_MAX)
				{
					_press.shift();
					_press.shift();
				}
				_press.push(code, Engine.frameElapsed);
			}
		}
		
		/** @private Event handler for key release. */
		private static function onKeyUp(e:KeyboardEvent):void
		{
			// get the keycode and update the keystate
			var code:int = e.keyCode;
			
			if (_key[code])
			{
				_key[code] = false;
				_keyNum --;
				_releaseNum ++;
				
				if (_release.length == 2*KEYUP_HISTORY_MAX)
				{
					_release.shift();
					_release.shift();
				}
				_release.push(code, Engine.frameElapsed);
			}
			if (_eventsEnabled)
				dispatcher.dispatchEvent(new Event(events.E_KEY_RELEASE));
		}
		
		/** @private Event handler for mouse press. */
		private static function onMouseDown(e:MouseEvent):void
		{
			if (!mouseDown)
			{
				mouseDown = true;
				mouseUp = false;
				mousePressed = true;
			}
		}
		
		/** @private Event handler for mouse release. */
		private static function onMouseUp(e:MouseEvent):void
		{
			mouseDown = false;
			mouseUp = true;
			mouseReleased = true;
		}
		
		/** @private Event handler for mouse wheel events */
		private static function onMouseWheel(e:MouseEvent):void
		{
		    mouseWheel = true;
		    _mouseWheelDelta = e.delta;
		}
		
		// Input information.
		/** @private */ private static var _enabled:Boolean = false; // Got to enable to register key presses
		/** @private */ private static var _key:Vector.<Boolean> = new Vector.<Boolean>(256);
		/** @private */ private static var _keyNum:int = 0;
		/** @private */ private static var _press:Vector.<int> = new Vector.<int>(256);
		/** @private */ private static var _release:Vector.<int> = new Vector.<int>(256);
		/** @private */ private static var _pressNum:int = 0;
		/** @private */ private static var _releaseNum:int = 0;
		/** @private */ private static var _mouseWheelDelta:int = 0;
	}
}

/**
 * Static class for event identifiers.
 */
class Events
{
	public static const instance:Events = new Events();
	
	public const E_ENTER_PRESSED:String = "enter";
	public const E_KEY_RELEASE:String = "pressed";
}
