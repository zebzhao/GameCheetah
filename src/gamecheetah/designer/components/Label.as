/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import gamecheetah.graphics.TextClip;
	import gamecheetah.Space;
	
	public class Label extends BaseComponent 
	{
		public static var ALIGN_CENTER:String = "center";
		public static var ALIGN_ABOVE:String = "above";
		public static var ALIGN_BELOW:String = "below";
		public static var ALIGN_LEFT:String = "left";
		public static var ALIGN_RIGHT:String = "right";
		public static var ALIGN_INNER_LEFT:String = "inner-left";
		public static var ALIGN_ABOVE_LEFT:String = "above-left";
		public static var ALIGN_INNER_TOP_LEFT:String = "inner-bottom-left";
		public static var ALIGN_FREE:String = "free";
		
		//{ ------------------- Private Info -------------------
		
		private var
			_host:BaseComponent, _align:String;
			
		protected var _field:TextField;
		
		//{ ------------------- Public Properties -------------------
		
		public const offset:Point = new Point();
		public var padding:int = 5;
		public var innerPadding:int = 5;
		
		public function get text():String 
		{
			return _text;
		}
		
		public function set text(value:String):void 
		{
			_text = _field.text = value;
			if (_field.autoSize != TextFieldAutoSize.NONE)
			{
				_width = _field.width;
				_height = _field.height;
			}
		}
		
		public function get field():TextField 
		{
			return _field;
		}
		
		protected var _text:String;
		
		//{ ------------------- Public Methods -------------------
		
		public function Label(host:BaseComponent=null, text:String="", color:uint=0x000000, align:String=null, textAlign:String=null) 
		{
			_host = host;
			_align = align;
			
			_field = new TextField();
			_field.wordWrap = false;
			_field.multiline = true;
			_field.selectable = false;
			_field.textColor = 0xffffffff;
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.embedFonts = true;
			_field.text = text;
			_field.defaultTextFormat = new TextFormat("Designer Font", Style.FONT_SIZE, color,
				null, null, null, null, null, textAlign || TextFormatAlign.CENTER);
			_field.setTextFormat(_field.defaultTextFormat);
			
			this.addChild(_field);
			super(host, _field.width, _field.height);
		}
		
		//{ ------------------- Behavior Overrides -------------------
		
		override public function onUpdate():void 
		{
			if (_host)
			{
				if (_align == ALIGN_ABOVE)
				{
					this.move(_host.halfWidth - this.halfWidth, -this.height - padding);
				}
				else if (_align == ALIGN_BELOW)
				{
					this.move(_host.halfWidth - this.halfWidth, _host.height + padding);
				}
				else if (_align == ALIGN_LEFT)
				{
					this.move(-this.width - padding, _host.halfHeight - this.halfHeight);
				}
				else if (_align == ALIGN_RIGHT)
				{
					this.move(_host.width + padding, _host.halfHeight - this.halfHeight);
				}
				else if (_align == ALIGN_INNER_LEFT)
				{
					this.move(innerPadding, _host.halfHeight - this.halfHeight);
				}
				else if (_align == ALIGN_ABOVE_LEFT)
				{
					this.move(innerPadding, -this.height - padding);
				}
				else if (_align == ALIGN_INNER_TOP_LEFT)
				{
					this.move(innerPadding, innerPadding);
				}
				else if (_align == ALIGN_CENTER)
				{   // Center by default
					this.move(_host.halfWidth - this.halfWidth, _host.halfHeight - this.halfHeight);
				}
				_field.x = offset.x;
				_field.y = offset.y;
			}
		}
	}
}