/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import gamecheetah.graphics.Clip;
	import gamecheetah.Space;
	import gamecheetah.utils.OrderedDict;
	
	public class IconToggleButton extends IconButton 
	{
		private var _selected:Boolean;
		
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void 
		{
			_selected = value;
			this.clip.frame = _selected ? 1 : 0;
		}
		
		public function IconToggleButton(space:Space, offState:Class, onState:Class, handler:Function=null, hint:String=null, labelAlign:String=null) 
		{
			var frameBmds = [(new offState() as Bitmap).bitmapData, (new onState() as Bitmap).bitmapData;
			super(space, new Clip(frameBmds, new OrderedDict()), handler, hint, labelAlign);
		}
		
		override public function onMouseDown():void 
		{
			super.onMouseDown();
			this.selected = !this.selected;
		}
	}

}