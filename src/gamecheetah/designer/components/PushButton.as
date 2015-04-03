/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components
{
	import flash.display.DisplayObjectContainer;
	
	public class PushButton extends BaseButton 
	{
		//{ ------------------- Protected/Private Info -------------------
		
		protected var	_text:String,
						_label:Label,
						_highlighted:Boolean;
						
		//{ ------------------- Public properties -------------------
		
		public var onClick:Function;
		
		public function get backgroundColor():uint 
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
			Style.drawBaseRect(this.graphics, 0, 0, _width - 1, _height - 1, _backgroundColor);
		}
		
		private var _backgroundColor:uint;
		
		//{ ------------------- Constructor -------------------
		
		public function PushButton(	parent:BaseComponent, width:int = 100, height:int = 25,
									text:String=null, handler:Function=null, labelColor:uint=0xffffff) 
		{
			_text = text;
			onClick = handler;
			
			this.setUpState(highlight);
			this.setOverState(highlight);
			this.setDownState(unhighlight);
			this.setOutState(unhighlight);
			
			if (_text) _label = new Label(this, _text, labelColor, Label.ALIGN_CENTER);
			
			super(parent, width, height);
			
			draw();
		}
		
		override public function onMouseUp():void 
		{
			super.onMouseUp();
			if (onClick != null) onClick(this);
		}
		
		//{ ------------------- Public Methods -------------------
		
		public function setSize(width:int, height:int):void 
		{
			_width = width;
			_height = height;
			draw();
		}
		
		public function highlight(...rest:Array):void 
		{
			_highlighted = true;
			draw();
		}
		
		public function unhighlight(...rest:Array):void 
		{
			_highlighted = false;
			draw();
		}
		
		public function draw():void 
		{
			this.backgroundColor = _highlighted ? Style.BUTTON_HIGHLIGHT : Style.BUTTON_BASE;
		}
	}
}
