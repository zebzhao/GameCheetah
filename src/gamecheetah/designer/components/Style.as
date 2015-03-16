/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{

	public class Style 
	{
		[Embed(source="/../lib/OpenSans.ttf", embedAsCFF="false", fontName="Designer Font", mimeType="application/x-font")]
		public static var FONT:Class;
		public static var FONT_SIZE:uint = 12;
		public static var FONT_COLOR:uint = 0xFFffffff;
		public static var FONT_DARK:uint = 0xFF111111;
		
		public static var HEADER_BASE:uint = 0xFF535EA7;
		public static var HEADER_HIGHLIGHT:uint = 0xFF7983C2;
		
		public static var BASE:uint = 0xFFffffff;
		public static var HIGHLIGHT:uint = 0xFFd1d7fe;
		public static var SELECTED:uint = 0xFFffefa1;
		
		public static var SLIDER_HANDLE:uint = 0xFF5e74fc;
		public static var SLIDER_BG:uint = 0xFFadb8fe;
		public static var SLIDER_HIGHLIGHT:uint = 0xFF8394fe;
	}

}