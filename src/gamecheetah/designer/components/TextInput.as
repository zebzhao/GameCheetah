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
		private var _placeholder:Label;
		private var _type:String;
		
		public static const TYPE_STRING:String = "string";
		public static const TYPE_INT:String = "int";
		public static const TYPE_UINT:String = "uint";
		public static const TYPE_UINT_VECTOR:String = "vector<uint>";
	
		public var value:*;
		public var maximum:Number = 999999999;
		public var minimum:Number = -999999999;
		
		
		public function get text():String 
		{
			return _tf.text;
		}
		
		public function set text(value:String):void 
		{
			_tf.text = value;
			onTextChange(null);
		}
		
		public function TextInput(space:Space, width:int=100, height:int=25, onChange:Function=null, placeholder:String=null, type:String=TYPE_STRING) 
		{
			_onChange = onChange;
			_type = type;
			
			_tf = new TextField();
			_tf.width = width - 5;
			_tf.height = height - 5;
			_tf.embedFonts = true;
			_tf.type = TextFieldType.INPUT;
			_tf.defaultTextFormat = new TextFormat("Designer Font", Style.FONT_SIZE, 0x000000);
			
			if (_type == TYPE_INT) _tf.restrict = "0-9\\-";
			else if (_type == TYPE_UINT) _tf.restrict = "0-9";
			else if (_type == TYPE_UINT_VECTOR) _tf.restrict = "0-9,";
			
			_stamp = new BackgroundStamp(width, height);
			this.renderable = _stamp;
			
			if (placeholder)
			{
				_placeholder = new Label(space, placeholder, this, Label.ALIGN_CENTER, 0xCDCDCD);
				_placeholder.depth = this.depth + 1;
			}
			
			if (space)
			{
				space.add(this);
			}
		}
		
		override public function hide(...rest:Array):void 
		{
			super.hide();
			if (_placeholder && _placeholder.visible) _placeholder.hide();
		}
		
		override public function show(...rest:Array):void 
		{
			super.show();
			if (_placeholder && !_placeholder.visible) _placeholder.show();
		}
		
		override public function onActivate():void 
		{
			Engine.stage.addChild(_tf);
			_tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_tf.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_tf.addEventListener(Event.CHANGE, onTextChange);
		}
		
		override public function onDeactivate():void 
		{
			super.onDeactivate();
			// Remove text field display object.
			_tf.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_tf.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
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
		
		private function onFocusIn(e:Event):void 
		{
			this.value = parseText(text);
			if (this.value == null) _stamp.invalid();
			else _stamp.highlight();
		}
		
		private function onFocusOut(e:Event):void 
		{
			if (this.value == null)
			{
				_stamp.invalid();
				this.text = "";
			}
			else _stamp.unhighlight();
		}
		
		private function onTextChange(e:Event):void 
		{
			this.value = parseText(text);
			
			if (this.value == null) _stamp.invalid();
			else
			{
				if (Engine.stage.focus == _tf) _stamp.highlight();
				else _stamp.unhighlight();
				if (_onChange) _onChange(this);
			}
			
			if (_placeholder)
			{
				if (text && text.length > 0) _placeholder.depth = this.depth - 1;
				else _placeholder.depth = this.depth + 1;
			}
		}
		
		/**
		 * @return	The parsed text value depending on the type, null otherwise.
		 */
		private function parseText(input:String):* 
		{
			var value:*;
			
			if (_type == TYPE_INT || _type == TYPE_UINT)
			{
				return validateNumber(input) ? int(input) : null;
			}
			else if (_type == TYPE_UINT_VECTOR)
			{
				var i:uint, elem:String;
				var vector:Vector.<int> = new Vector.<int>;
				var array:Array = input.split(",");
				
				for (i = 0; i < array.length; i++)
				{
					elem = array[i];
					if (validateNumber(elem)) vector[i] = int(elem);
				}
				value = vector;
			}
			else value = input;
			
			return value;
		}
		
		private function validateNumber(input:String):Boolean 
		{
			var parsed:Number = Number(input);
			return !isNaN(parsed) && maximum >= parsed && parsed >= minimum;
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