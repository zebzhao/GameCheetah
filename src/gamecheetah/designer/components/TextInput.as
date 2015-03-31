/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.*;
	import flash.display.BlendMode;
	import gamecheetah.designer.Designer;
	import gamecheetah.*
	import gamecheetah.utils.GCError;
	
	public class TextInput extends Label 
	{
		public var
			onChange:Function;
			
		protected var
			_hintLabel:Label;
			
		private var
			_type:String,
			_placeholder:String;
		
		private var
			_background:Boolean = true,
			_highlighted:Boolean,
			_selected:Boolean,
			_focused:Boolean,
			_invalid:Boolean;
		
		public static const TYPE_STRING:String = "string";
		public static const TYPE_INT:String = "int";
		public static const TYPE_UINT:String = "uint";
		public static const TYPE_UINT_VECTOR:String = "vector<+int>";
		public static const TYPE_INT_VECTOR:String = "vector<int>";
	
		public var value:*;
		public var maximum:Number = 999999999;
		public var minimum:Number = -999999999;
		
		
		override public function set text(value:String):void 
		{
			if (value == _text) return;
			super.text = value;
			onTextChange();
			checkEmpty();
		}
		
		public function get background():Boolean 
		{
			return _background;
		}
		
		public function set background(value:Boolean):void 
		{
			_background = value;
			draw();
		}
		
		public function get type():String 
		{
			return _type;
		}
		
		public function set type(value:String):void 
		{
			_type = value;
			
			if (_type == TYPE_INT) _field.restrict = "0-9\\-";
			else if (_type == TYPE_UINT) _field.restrict = "0-9";
			else if (_type == TYPE_UINT_VECTOR) _field.restrict = "0-9,";
			else if (_type == TYPE_INT_VECTOR) _field.restrict = "0-9,\\-";
			else if (_type != TYPE_STRING) throw new GCError("unrecognized input type option");
		}
		
		public function setHint(hint:String, align:String=null):void 
		{
			if (hint)
			{
				if (!_hintLabel) _hintLabel = new Label(this, hint, Style.FONT_BASE, align);
				_hintLabel.text = hint;
				_hintLabel.padding = 15;
				Style.drawBaseRect(_hintLabel.graphics, -5, 0, _hintLabel.width + 10, this.height, Style.HINT_BASE, Style.HINT_ALPHA, false); 
			}
			else if (_hintLabel) this.removeChild(_hintLabel);
			
			draw();
		}
		
		public function get placeholder():String 
		{
			return _placeholder;
		}
		
		public function set placeholder(value:String):void 
		{
			_placeholder = value;
			checkEmpty();
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
			_field.width = value - 5;
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
			_field.height = value;
		}
		
		public function TextInput(parent:DisplayObjectContainer, width:int=100, height:int=25, onChange:Function=null, placeholder:String=null, type:String=TYPE_STRING) 
		{
			super(parent, "", Style.FONT_DARK);
			
			_field.autoSize = TextFieldAutoSize.NONE;
			_field.type = TextFieldType.INPUT;
			_field.selectable = true;
			_field.multiline = false;
			_field.defaultTextFormat = new TextFormat("Designer Font", Style.FONT_SIZE, Style.FONT_DARK,
				null, null, null, null, null, TextFormatAlign.LEFT, 5);
			_field.setTextFormat(_field.defaultTextFormat);
			
			this.placeholder = placeholder;
			this.type = type;
			this.text = "";
			this.width = width;
			this.height = height;
			
			checkEmpty();
			
			this.onChange = onChange;
		}
		
		override public function onActivate():void 
		{
			_field.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_field.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_field.addEventListener(Event.CHANGE, onTextChange);
		}
		
		override public function onDeactivate():void 
		{
			// Remove text field display object.
			_field.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_field.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_field.removeEventListener(Event.CHANGE, onTextChange);
		}
		
		override public function onMouseOver():void 
		{
			highlight();
		}
		
		override public function onMouseOut():void 
		{
			unhighlight();
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
			if (_background) 
			{
				var bgColor:uint = _focused ? (_invalid ? Style.BUTTON2_INVALID : Style.BUTTON2_SELECTED) :
												(_selected ? Style.BUTTON2_SELECTED : (_highlighted ?
													Style.BUTTON2_HIGHLIGHT :
													Style.BUTTON2_BASE));
				Style.drawBaseRect(this.graphics, 0, 0, _width - 1, _height - 1, bgColor);
			}
			else this.graphics.clear();
			
			if (_hintLabel)
			{
				_hintLabel.visible = _focused;
			}
			
			_field.textColor = _focused ? Style.FONT_DARK : Style.FONT_LIGHT;
		}
		
		public function select():void 
		{
			if (_selected) return;
			_selected = true;
			draw();
		}
		
		public function unselect():void 
		{
			if (!_selected) return;
			_selected = false;
			draw();
		}
		
		private function onFocusIn(e:Event):void 
		{
			_focused = true;
			_field.text = text;
			draw();
		}
		
		private function onFocusOut(e:Event):void 
		{
			checkEmpty();
			_field.text = text;
			_focused = false;
			draw();
		}
		
		private function onTextChange(e:Event=null):void 
		{
			this.value = parseText(_field.text);
			
			_invalid = this.value == null;
			_focused = Engine.stage.focus == _field;
			
			if (!_invalid)
			{
				super.text = value;
				if (onChange) onChange(this);
			}
			
			draw();
		}
		
		private function checkEmpty():void 
		{
			if (this.text == "" && placeholder)
			{
				_field.text = placeholder;
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
			else if (_type == TYPE_UINT_VECTOR || _type == TYPE_INT_VECTOR)
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