/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;

	public class Style 
	{
		[Embed(source="/../lib/OpenSans.ttf", embedAsCFF="false", fontName="Designer Font", mimeType="application/x-font")]
		public static var FONT:Class;
		public static var FONT_SIZE:uint = 14;
		public static var FONT_BASE:uint = 0xffffff;
		public static var FONT_HEADER:uint = 0x535EA7;
		public static var FONT_DARK:uint = 0x323232;
		public static var FONT_LIGHT:uint = 0xbbbbbb;
		
		public static var ROUND_RADIUS:uint = 6;
		public static var LINE_LIGHT:uint = 0xababab;
		
		public static var BUTTON_HIGHLIGHT:uint = 0x8394fe;
		public static var BUTTON_BASE:uint = 0x5e74fc;
		public static var BUTTON_SELECTED:uint = 0xffefa1;
		public static var BUTTON_INVALID:uint = 0xff5555;
		
		public static var BUTTON2_HIGHLIGHT:uint = 0xd1d7fe;
		public static var BUTTON2_BASE:uint = 0xffffff;
		public static var BUTTON2_SELECTED:uint = 0xffefa1;
		public static var BUTTON2_INVALID:uint = 0xff5555;
		
		public static var SLIDER_BASE:uint = 0x5e74fc;
		public static var SLIDER_DARK:uint = 0xadb8fe;
		public static var SLIDER_HIGHLIGHT:uint = 0x8394fe;
		
		public static var HINT_BASE:uint = 0x000000;
		public static var HINT_ALPHA:Number = 0.5;
		
		public static function drawBaseRect(graphics:Graphics, x:Number, y:Number, width:Number, height:Number, color:uint, alpha:Number=1, line:Boolean=true, clear:Boolean=true):void 
		{
			if (clear) graphics.clear();
			if (line) graphics.lineStyle(1, LINE_LIGHT, 1, true);
			graphics.beginFill(color, alpha);
			if (ROUND_RADIUS > 0) graphics.drawRoundRect(x, y, width, height, ROUND_RADIUS, ROUND_RADIUS);
			else graphics.drawRect(x, y, width, height);
			graphics.endFill();
		}
	}

}