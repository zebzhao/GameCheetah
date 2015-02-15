/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah 
{
	import flash.utils.describeType;
	import gamecheetah.namespaces.hidden;
	import gamecheetah.utils.Assets;
	import gamecheetah.utils.Restorable;
	
	use namespace hidden;

	/**
	 * A class responsible for managing the game state.
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}
	 * @version		1.1
	 */
	public class State extends Restorable
	{
		/**
		 * Information to reset to original state.
		 */
		private var _resetInfo:Object;
		
		/**
		 * Object managing game state.
		 */
		public function State() 
		{
			super(getProperties());
			// No need for assets to be resetted, special exception case.
			if (!(this is Assets)) _resetInfo = this.export();
		}
		
		/**
		 * Reset to original (initial) state.
		 */
		public final function reset():void 
		{
			super.restore(_resetInfo);
		}
		
		override final public function restore(obj:Object):void 
		{
			super.restore(obj);
			_resetInfo = obj;
		}
		
		/**
		 * Taken from BindMax.as
		 */
		protected final function getProperties():Array
		{
			var classDefinition:XML = describeType(this);
			var result:Array = [];
			var publiclyAccessibleData:XMLList = classDefinition.variable + classDefinition.accessor.(@access == "readwrite");
			var key:String;
			
			for each (var item:XML in publiclyAccessibleData)
			{
				key = item.@name;
				result.push(key);
			}
			return result;
		}
	}

}