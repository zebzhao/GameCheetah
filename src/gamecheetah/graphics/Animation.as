/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.graphics 
{
	import gamecheetah.utils.Restorable;
	import gamecheetah.namespaces.hidden;
	
	use namespace hidden;
	
	/**
	 * Template used by Graphic to store animation data.
	 */
	public class Animation extends Restorable
	{
		public var frames:Vector.<int>;
		public var frameRate:Number;
		public var looping:Boolean;
		
		/**
		 * Animation name.
		 */
		public function get tag():String 
		{
			return _tag;
		}
		hidden var _tag:String;
		
		/**
		 * Constructor.
		 * @param	frames		Array of frame indices to animate.
		 * @param	frameRate	Animation speed.
		 * @param	looping		If the animation should loop.
		 */
		public function Animation(tag:String=null, frames:Vector.<int>=null, frameRate:Number=1, looping:Boolean=true)
		{
			super(["_tag", "frames", "frameRate", "looping"]);
			this._tag = tag;
			this.frames = frames != null ? frames : new Vector.<int>;
			this.frameRate = frameRate;
			this.looping = looping;
		}
	}
}