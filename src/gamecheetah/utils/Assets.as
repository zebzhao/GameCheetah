/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.utils 
{
	import flash.utils.Dictionary;
	import gamecheetah.namespaces.hidden;
	
	use namespace hidden;
	
	/**
	 * @author 		Zeb Zhao
	 * @private
	 */
	public class Assets extends Restorable 
	{
		
		public function get graphics():OrderedDict
		{
			return _graphics;
		}
		hidden var _graphics:OrderedDict = new OrderedDict();

		
		/**
		 * Dictionary of all object spaces for the game.
		 */
		public function get spaces():OrderedDict
		{
			return _spaces;
		}
		hidden var _spaces:OrderedDict = new OrderedDict();
		
		
		/**
		 * Dictionary of all TextStyles for the game.
		 */
		public function get textStyles():OrderedDict
		{
			return _textStyles;
		}
		hidden var _textStyles:OrderedDict = new OrderedDict();
		
		/**
		 * Dictory of designer settings.
		 */
		hidden var _designerContext:Dictionary = new Dictionary();
		
		/**
		 * Object managing game state.
		 */
		public function Assets() 
		{
			super(["_graphics", "_spaces", "_textStyles", "_designerContext"]);
		}
		
		/*override public function restore(obj:Object):void 
		{
			super.restore(obj);
		}*/
	}
}