/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import gamecheetah.designer.Designer;
	import gamecheetah.Engine;
	import gamecheetah.Space;
	
	public class TextInput extends BaseComponent 
	{
		private var
			_onChange:Function;
			
		private var _tf:TextField;
		private var _stamp:BackgroundStamp;
		
		public function get text():String 
		{
			return _tf.text;
		}
		
		public function set text(value:String):void 
		{
			_tf.text = value;
		}
		
		public function TextInput(space:Space, width:int=100, height:int=25, onChange:Function=null) 
		{
			_onChange = onChange;
			
			_tf = new TextField();
			_tf.width = width - 5;
			_tf.height = height - 5;
			_tf.embedFonts = true;
			_tf.type = TextFieldType.INPUT;
			_tf.defaultTextFormat = new TextFormat("Designer Font", Style.FONT_SIZE, 0x000000);
			
			_stamp = new BackgroundStamp(width, height);
			this.renderable = _stamp;
			space.add(this);
		}
		
		override public function onActivate():void 
		{
			Engine.stage.addChild(_tf);
			_tf.addEventListener(FocusEvent.FOCUS_IN, _stamp.highlight);
			_tf.addEventListener(FocusEvent.FOCUS_OUT, _stamp.unhighlight);
			_tf.addEventListener(Event.CHANGE, onTextChange);
		}
		
		override public function onDeactivate():void 
		{
			super.onDeactivate();
			_tf.removeEventListener(FocusEvent.FOCUS_IN, _stamp.highlight);
			_tf.removeEventListener(FocusEvent.FOCUS_OUT, _stamp.unhighlight);
			_tf.removeEventListener(Event.CHANGE, onTextChange);
			Engine.stage.removeChild(_tf);
		}
		
		override public function onUpdate():void 
		{
			super.onUpdate();
			_tf.x = this.absoluteLocation.x + 3;
			_tf.y = this.absoluteCenter.y -_tf.textHeight / 2 - 3;
			_tf.alpha = this.renderable.alpha;
			_tf.visible = this.visible;
		}
		
		private function onTextChange(e:Event):void 
		{
			if (_onChange) _onChange(this);
		}
	}
}
import flash.display.BitmapData;
import gamecheetah.graphics.Renderable;
import gamecheetah.designer.components.Style;
import flash.geom.Rectangle;

class BackgroundStamp extends Renderable
{
	private var _rect:Rectangle;
	
	public function BackgroundStamp(width:int, height:int):void 
	{
		_rect = new Rectangle(1, 1, width - 2, height - 2);
		this.setBuffer(new BitmapData(width, height, true, Style.HIGHLIGHT));
		this.buffer.fillRect(_rect, Style.BASE);
	}
	
	public function invalid(b:*=null):void 
	{
		this.buffer.fillRect(_rect, Style.INVALID);
	}
	
	public function highlight(b:*=null):void 
	{
		this.buffer.fillRect(_rect, Style.SELECTED);
	}
	
	public function unhighlight(b:*=null):void 
	{
		this.buffer.fillRect(_rect, Style.BASE);
	}
}