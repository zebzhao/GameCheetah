/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.graphics 
{
	import gamecheetah.Engine;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import gamecheetah.strix.collision.Agent;
	import gamecheetah.utils.OrderedDict;
	
	/**
	 * Adapted from Flashpunk's Spritesheet class to save memory.
	 */
	public class Clip extends Renderable
	{	
		/**
		 * If the animation has stopped.
		 */
		public var complete:Boolean = false;
		
		/**
		 * The current playing animation.
		 */
		public function get animationName():String { return _animName; }
		
		/**
		* Current animation frame index.
		*/
		public function get frame():uint { return _frame; }
		public function set frame(value:uint):void 
		{
			value %= _frameImages.length;
			_frame = value;
		}
		
		// Graphic information.
		private var _index:uint;
		private var _timer:Number;
		private var _frame:int;
		private var _animData:Animation;
		private var _animName:String;
		private var _frameImages:Array;
		private var _animations:OrderedDict;
		
		/**
		 * Constructor.
		 * @param	frameImages		Array of frame images.
		 * @param	animations		Dictionary of animation data.
		 */
		public function Clip(frameImages:Array, animations:OrderedDict) 
		{
			super();
			// References data objects of parent Graphic.
			_frameImages = frameImages;
			_animations = animations;
			
			_frame = 0;
			_timer = 0;
			setBuffer(_frameImages[_frame]);
			transformAnchor.setTo(_buffer.width / 2, _buffer.height / 2);;
		}
		
		/**
		 * Destructor.
		 */
		override public function dispose():void 
		{
				//
		}
		
		/**
		 * Updates the animation.
		 */
		public function update():void 
		{
			if (_animData != null)
			{
				var timeAdd:Number = _animData.frameRate;
				_timer += timeAdd;
				if (_timer >= 1)
				{
					if (_animData.frames.length == 0) return;  // Avoid modulo by 0 case.
					
					while (_timer >= 1)
					{
						_timer --;
						_index ++;
						if (_index >= _animData.frames.length)
						{
							
							if (!_animData.looping)
							{
								_index = _animData.frames.length - 1;
								complete = true;
								break;
							}
							else
							{
								_index = 0;
								complete = false;
							}
						}
					}
					_frame = _animData.frames[_index];
				}
			}
			setBuffer(_frameImages[_frame]);;
		}
		
		/**
		 * Plays an animation.
		 * @param	name		Name of the animation to play.
		 * @param	reset		If the animation should force-restart if it is already playing.
		 * @param	index		Frame of the animation to start from.
		 * @return	Returns false if animation doesn't exist or is already playing.
		 */
		public function play(name:String = "", reset:Boolean = false, index:int = 0):Boolean
		{
			if (!reset && _animData != null && _animName == name || !_animations.contains(name))
			{
				return false;
			}
			_animData = _animations.get(name);
			_animName = name;
			
			_index = index;
			_timer = 0;
			complete = false;
			
			return true;
		}
	}
}
