/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.display.Bitmap;
	import gamecheetah.graphics.Clip;
	import gamecheetah.Space;
	import gamecheetah.utils.OrderedDict;
	
	public class IconToggleButton extends IconButton 
	{
		private var
			_selected:Boolean,
			_labelAlign:String,
			_offHint:String, _onHint:String;
		
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void 
		{
			_selected = value;
			this.clip.frame = _selected ? 1 : 0;
			
			if (!_hint)
			{
				_hint = new Label(space, _selected ? _onHint : _offHint, this, _labelAlign, Style.HEADER_BASE);
				_hint.hide();
			}
			else _hint.text = _selected ? _onHint : _offHint;
		}
		
		public function IconToggleButton(	space:Space, offState:Class, onState:Class,
											handler:Function = null,
											offHint:String=null, onHint:String=null, labelAlign:String=null ) 
		{
			_offHint = offHint;
			_onHint = onHint;
			_labelAlign = labelAlign;
			
			var frameBmds:Array = [(new offState() as Bitmap).bitmapData, (new onState() as Bitmap).bitmapData];
			super(space, new Clip(frameBmds, new OrderedDict()), handler, _offHint, labelAlign);
			
			// TODO: Graphical glitch with label alignment. Temporary solution.
			this.setUpState(null, null, handler);
			this.setOverState();
			this.setDownState();
		}
		
		override public function onMouseDown():void 
		{
			this.selected = !this.selected;
		}
	}

}