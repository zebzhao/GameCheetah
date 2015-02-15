/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.utils 
{
	/**
	 * Data class for delayed callbacks.
	 * @private
	 */
	public final class CallbackData
	{
		// Delayed callback information
		public var invoker:Object;
		public var callback:Function;
		public var params:Array;
		public var delayCountdown:uint;
		
		// Tween information
		public var ease:Function;
		public var duration:uint; 
		public var durationCounter:uint;
		public var from:Object;
		public var to:Object;
		public var change:Object;
		public var isTween:Boolean;
		
		public function CallbackData(delay:uint, callback:Function, params:Array, invoker:Object = null) 
		{
			this.delayCountdown = delay;
			this.callback = callback;
			this.params = params;
			this.invoker = invoker;
		}
	}

}