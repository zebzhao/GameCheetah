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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import gamecheetah.Engine;
	import gamecheetah.gameutils.Input;
	
	/**
	 * Easy way to do game camera manipulation.
	 * @author 		Zeb Zhao
	 */
	public class Scroller extends EventDispatcher
	{
		/**
		 * Stores event identifiers.
		 */
		public static function get events():Events { return Events.instance };
		
		
		public static const ARROW_KEYS:Vector.<uint> = new Vector.<uint>;
		public static const WSAD:Vector.<uint> = new Vector.<uint>;
		
		{
			ARROW_KEYS.push(Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT);
			WSAD.push(Keyboard.W, Keyboard.S, Keyboard.A, Keyboard.D);
		}
		
		/**
		 * Coordinates of the scroller.
		 */
		public function get point():Point 
		{
			return _point;
		}
		public function set point(value:Point):void 
		{
			_point = value;
		}
		private var _point:Point;
		
		/**
		 * Maximum scrollable bounds.
		 */
		public var scrollBounds:Rectangle;
		
		/**
		 * Controls speed of acceleration.
		 */
		public var acceleration:Number;
		
		/**
		 * True if scroller works in opposite directions from normal
		 */
		public var reversed:Boolean;
		
		/**
		 * Geometric ratio controlling deceleration.
		 */
		public var friction:Number;
		
		
		// Scroller information
		private var _keys:Vector.<uint>;
		private var _xVelocity:Number, _yVelocity:Number;
		private var _enabled:Boolean;
		
		/**
		 * Constructor.
		 * @param	speed			Maximum speed of scrolling in pixels (per-frame).
		 * @param	friction		A ratio less than 1, controlling deceleration.
		 * @param	acceleration	Acceleration in pixels.
		 * @param	refPoint		Reference point object to modify by the Scroller.
		 * @param	keys			A vector of key-codes controlling scrolling up, down, left, right.
		 */
		public function Scroller(friction:Number, acceleration:Number, refPoint:Point=null, keys:Vector.<uint>=null, reversed:Boolean=false) 
		{
			if (refPoint == null ) refPoint = new Point();
			this._point = refPoint;
			this._keys = keys;
			this._xVelocity = 0;
			this._yVelocity = 0;
			this.friction = friction;
			this.acceleration = acceleration;
			this.reversed = reversed;
			
			enable();
		}
		
		/**
		 * Enable automatic key scrolling. (Default if keys were set.)
		 */
		public function enable():void 
		{
			if (_keys != null && !_enabled)
			{
				_enabled = true;
				Input.enabled = true;
				Engine.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		/**
		 * Disable automatic key scrolling.
		 */
		public function disable():void 
		{
			if (_keys != null && _enabled)
			{
				_enabled = false;
				Engine.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		/**
		 * Move to the destination while checking if in-bounds.
		 */
		public function setTo(x:Number, y:Number):void 
		{
			if (scrollBounds == null)
				_point.x = x;
			else
				_point.x = Math.min(Math.max(scrollBounds.left, x), scrollBounds.right);
			
			if (scrollBounds == null)
				_point.y = y;
			else
				_point.y = Math.min(Math.max(scrollBounds.top, y), scrollBounds.bottom);
		}
		
		/**
		 * Move the camera in the scroll direction.
		 */
		public function update(xStep:Number, yStep:Number):void 
		{
			var initialPosition:Point = _point.clone();
			
			_xVelocity += xStep * acceleration - friction * _xVelocity;
			_yVelocity += yStep * acceleration - friction * _yVelocity;
			
			if (Math.abs(_xVelocity) < 1e-1) _xVelocity = 0; 
			if (Math.abs(_yVelocity) < 1e-1) _yVelocity = 0; 
			_point.x = scrollBounds == null ? point.x + _xVelocity : Math.min(Math.max(scrollBounds.left, point.x + _xVelocity), scrollBounds.right);
			_point.y = scrollBounds == null ? point.y + _yVelocity : Math.min(Math.max(scrollBounds.top, point.y + _yVelocity), scrollBounds.bottom);
			
			if (!_point.equals(initialPosition)) this.dispatchEvent(new Event(events.E_MOVE));
		}
		
		/**
		 * Update loop.
		 */
		private function onEnterFrame(e:Event):void 
		{
			var xStep:int, yStep:int;
			
			if (Input.checkKey(_keys[0])) yStep = reversed ? 1 : -1;
			else if (Input.checkKey(_keys[1])) yStep = reversed ? -1 : 1;
			
			if (Input.checkKey(_keys[2])) xStep = reversed ? 1 : -1;
			else if (Input.checkKey(_keys[3])) xStep = reversed ? -1 : 1;
			
			update(xStep, yStep);
		}
	}

}

/**
 * Static class for event identifiers.
 */
class Events
{
	public static const instance:Events = new Events();
	
	/**
	 * Event for a change in the scroller's position.
	 */
	public const E_MOVE:String = "move";
}