/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.graphics 
{
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;

	/**
	 * Used for drawing text using embedded fonts.
	 */
	public class TextClip extends Renderable
	{
		/**
		 * Constructor.
		 * @param	text		Text to display.
		 * @param	style		An object containing formatting information.
		 */
		public function TextClip(text:String, format:TextFormat = null)
		{
			super();
			_field.wordWrap = _wordWrap;
			_field.multiline = true;
			_field.textColor = 0xffffffff;
			_field.autoSize = TextFieldAutoSize.LEFT;
			this.format = format;
			this.text = text;
			this.transformAnchor.setTo(_buffer.width / 2, _buffer.height / 2);
		}
		
		public function autoSize():void 
		{
			_field.autoSize = TextFieldAutoSize.LEFT;
			_fixedWidth = NaN;
			_fixedHeight = NaN;
		}
		
		public function setSize(width:Number, height:Number):void 
		{
			_field.autoSize = TextFieldAutoSize.NONE;
			_fixedWidth = _field.width = width;
			_fixedHeight = _field.height = height;
		}
		
		/**
		 * Disposes the text clip.
		 */
		override public function dispose():void 
		{
			_buffer.dispose();
		}
		
		override public function render(target:BitmapData, x:Number, y:Number):void 
		{
			super.render(target, x, y);
		}
		
		/** Updates the text buffer, which is the source for the image buffer. */
		public function updateTextBuffer():void
		{
			var width:int = Math.ceil(isNaN(_fixedWidth) ? _field.textWidth + 4 : _fixedWidth);
			var height:int = Math.ceil(isNaN(_fixedHeight) ? _field.textHeight + 4 : _fixedHeight);
			
			if (_buffer == null)
			{
				setBuffer(new BitmapData(width, height, true, 0));
			}
			else if (width != _buffer.width || height != _buffer.height)
			{
				_buffer.dispose();
				setBuffer(new BitmapData(width, height, true, 0));
			}
			
			_buffer.fillRect(_buffer.rect, 0);
			_buffer.draw(_field);
		}
		
		/**
		 * Text string.
		 */
		public function get text():String { return _field.text; }
		public function set text(value:String):void
		{
			if (_text == value) return;
			_field.text = value;
			updateTextBuffer();
		}
		private var _text:String;
		
		/**
		 * Format of the text.
		 * Known bug: TextField.draw() does not work when antiAliasType is ADVANCED,
		 * consequently, embed fonts MUST be used for text formatting.
		 */
		public function get format():TextFormat { return _format; }
		public function set format(value:TextFormat):void 
		{
			if (value != null)
			{
				if (_format == value) return;
				_field.embedFonts = true;
				_field.defaultTextFormat = _format = value;
				_field.setTextFormat(_format);
				updateTextBuffer();
			}
			else _field.embedFonts = false;
		}
		protected var _format:TextFormat;
		
		/**
		 * Width of the text within the image.
		 */
		public function get textWidth():uint { return _field.textWidth; }
		
		/**
		 * Height of the text within the image.
		 */
		public function get textHeight():uint { return _field.textHeight; }
		
		/**
		 * Internal field object.
		 */
		public function get textField():TextField 
		{
			return _field;
		}
		
		
		/**
		 * The text buffer size, if NaN then buffer will auto-size.
		 */
		private var _fixedWidth:Number;
		
		/**
		 * The text buffer size, if NaN then buffer will auto-size.
		 */
		private var _fixedHeight:Number;
		
		
		// Text information.
		protected var _field:TextField = new TextField;
		protected var _wordWrap:Boolean = false;
	}
}
