/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import gamecheetah.graphics.Clip;
	import gamecheetah.Space;
	import gamecheetah.utils.OrderedDict;
	
	public class IconToggleButton extends IconButton 
	{
		private var
			_selected:Boolean,
			_labelAlign:String,
			_offHint:String, _onHint:String,
			_offState:Class, _onState:Class;
		
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void 
		{
			if (_selected == value) return;
			_selected = value;
			this.setIcon(_selected ? _onState : _offState);
			
			if (!_hintLabel)
			{
				_hintLabel = new Label(this, _selected ? _onHint : _offHint, Style.FONT_HEADER, _labelAlign);
				_hintLabel.hide();
			}
			else _hintLabel.text = _selected ? _onHint : _offHint;
		}
		
		public function IconToggleButton(	parent:DisplayObjectContainer, offState:Class, onState:Class,
											handler:Function = null,
											offHint:String=null, onHint:String=null, labelAlign:String=null ) 
		{
			_offHint = offHint;
			_onHint = onHint;
			_labelAlign = labelAlign;
			_offState = offState;
			_onState = onState;
			
			this.setUpState(handler);
			
			super(parent, _offState, handler, _offHint, labelAlign);
		}
		
		override public function onMouseDown():void 
		{
			this.selected = !this.selected;
		}
	}

}