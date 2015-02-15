/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views.components 
{
	import gamecheetah.designer.bit101.components.*;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	/**
	 * Text input that only allows for one specific input type.
	 * @private
	 */
	public class TypedInput extends InputText
	{
		public static const TYPE_STRING:uint = 0;
		public static const TYPE_NUMERIC:uint = 1;
		public static const TYPE_INTEGER:uint = 2;
		public static const TYPE_INT_VECTOR:uint = 4;
		public static const TYPE_PINT_VECTOR:uint = 5;
		
		public var type:uint;
		public var value:*;
		public var precision:uint = 1;
		public var maximum:Number = 999999999;
		public var minimum:Number = -999999999;
		
		/**
		 * True if the text field is focus of input.
		 */
		public function get focused():Boolean 
		{
			if (this.stage) return stage.focus == _tf;
			else return false;
		}
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this InputText.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param type Specifies the type of input.
		 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
		 */
		public function TypedInput(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, type:uint=TYPE_STRING, defaultHandler:Function=null)
		{
			super(parent, xpos, ypos, text, defaultHandler);
			
			switch (type) 
			{
				case TYPE_NUMERIC:
					super.restrict = "0-9.\\-";
				break;
				
				case TYPE_INTEGER:
					super.restrict = "0-9\\-";
				break;
				
				case TYPE_INT_VECTOR:
					super.restrict = "0-9,\\-";
				break;
				
				case TYPE_PINT_VECTOR:
					super.restrict = "0-9,";
				break;
			}
			
			this.type = type;
		}
		
		override protected function onChange(event:Event):void 
		{
			var parsedValue:* = parseText(_tf.text);
			if (parsedValue != null) this.value = parsedValue;
			else _tf.text = _text;
				
			super.onChange(event);
		}
		
		/**
		 * @return	True if the input is a valid format, false otherwise.
		 */
		private function parseText(input:String):* 
		{
			var value:*;
			
			switch (type) 
			{
				case TYPE_STRING:
					value = input;
				break;
				
				case TYPE_NUMERIC:
					if (!isNaN(Number(input)))
					{
						// Tricky: Blank value evaluates to minimum.
						value = input.length == 0 ? int(minimum) : int(input);
						
						if (value < minimum)
						{
							// Special case, alter value before exiting function.
							this.value = minimum;
							super.text = minimum.toPrecision(precision);
							return;
						}
						else if (value > maximum)
						{
							// Special case, alter value before exiting function.
							this.value = minimum;
							super.text = minimum.toPrecision(precision);
							return;
						}
					}
				break;
				
				case TYPE_INTEGER:
					if (!isNaN(Number(input)) || input.length == 0)
					{
						// Tricky: Blank value evaluates to minimum.
						value = input.length == 0 ? int(minimum) : int(input);
						
						if (value < int(minimum))
						{
							// Special case, alter value before exiting function.
							this.value = int(minimum);
							super.text = int(minimum).toString();
							return;
						}
						else if (value > int(maximum))
						{
							// Special case, alter value before exiting function.
							this.value = int(minimum);
							super.text = int(minimum).toString();
							return;
						}
					}
				break;
				
				case TYPE_INT_VECTOR:
				case TYPE_PINT_VECTOR:
					
					var i:uint, elem:String;
					var vector:Vector.<int> = new Vector.<int>;
					var array:Array = input.split(",");
					
					for (i = 0; i < array.length; i++)
					{
						elem = array[i];
						if (isNaN(Number(elem)))
						{
							vector = null;
							break;
						}
						else vector[i] = int(elem);
					}
					value = vector;
				break;
			}
			return value;
		}
		
		override public function set text(value:String):void 
		{
			if (value == super.text || value == null) return;
			
			// Do necessary checks before setting text property.
			var parsedValue:* = parseText(value);
			
			if (parsedValue != null && String(parsedValue) != String(this.value))
			{
				this.value = parsedValue;
				super.text = value;
			}
		}
	}


}