/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class IconButton extends BaseButton 
	{
		protected var
			_hintLabel:Label, _hintLabelAlign:String;
			
		protected var _icon:Bitmap;
		protected var _frozen:Boolean;
		
		public function get frozen():Boolean 
		{
			return _frozen;
		}
		
		public function get hint():String 
		{
			return _hintLabel ? _hintLabel.text : null;
		}
		
		public function set hint(value:String):void 
		{
			if (value)
			{
				if (!_hintLabel) _hintLabel = new Label(this, value, Style.FONT_HEADER, _hintLabelAlign);
				_hintLabel.alpha = 0;
				_hintLabel.text = value;
			}
			else if (_hintLabel) this.removeChild(_hintLabel);
		}
		
		public function IconButton(parent:BaseComponent, asset:*, handler:Function=null, hint:String=null, labelAlign:String=null) 
		{
			setIcon(asset);
			
			_hintLabelAlign = labelAlign;
			this.setDownState(handler);
			this.hint = hint;
			
			super(parent, _icon.width, _icon.height);
		}
		
		public function setIcon(asset:Class):void 
		{
			if (_icon) this.removeChild(_icon);
			_icon = new asset() as Bitmap;
			this.addChild(_icon);
		}
		
		public function setBitmapData(asset:BitmapData, width:Number=NaN, height:Number=NaN):void 
		{
			if (_icon) this.removeChild(_icon);
			_icon = new Bitmap(asset, "auto", false);
			if (width) _icon.width = width;
			if (height) _icon.height = height;
			this.addChild(_icon);
		}
		
		public function freeze():void 
		{
			_frozen = true;
			if (_hintLabel) _hintLabel.alpha = 1;
		}
		
		public function unfreeze():void 
		{
			_frozen = false;
			if (_hintLabel) _hintLabel.alpha = 0;
		}
		
		override public function hide(...rest:Array):void 
		{
			super.hide();
			if (_hintLabel) _hintLabel.visible = false;
		}
		
		override public function show(...rest:Array):void 
		{
			super.show();
			if (_hintLabel) _hintLabel.visible = true;
		}
		
		override public function onMouseOver():void 
		{
			if (!_frozen)
			{
				super.onMouseOver();
				if (_hintLabel) _hintLabel.tweenClip(null, { "alpha":1 } );
			}
		}
		
		override public function onMouseOut():void 
		{
			if (!_frozen)
			{
				super.onMouseOut();
				if (_hintLabel) _hintLabel.tweenClip(null, { "alpha":0 } );
			}
		}
	}
}