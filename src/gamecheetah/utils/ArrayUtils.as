/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.utils 
{
	/**
	 * @private
	 */
	public final class ArrayUtils 
	{
		
		public static function moveDown(itemIndex:uint, array:Array):void 
		{
			if (itemIndex < array.length - 1)
			{
				var first:* = array[itemIndex];
				array[itemIndex] = array[itemIndex + 1];
				array[itemIndex + 1] = first;
			}
		}
		
		public static function moveUp(itemIndex:uint, array:Array):void 
		{
			if (itemIndex > 0)
			{
				var last:* = array[itemIndex];
				array[itemIndex] = array[itemIndex - 1];
				array[itemIndex - 1] = last;
			}
		}
		
		public static function removeItem(item:*, array:Array):void 
		{
			if (array.indexOf(item) == -1) throw new GCError("missing item cannot be removed from array");
			array.splice(array.indexOf(item), 1);
		}
	}

}