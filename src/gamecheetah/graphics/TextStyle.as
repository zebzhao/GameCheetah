/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.graphics 
{
	import flash.geom.Point;
	import flash.text.TextFormat;
	import gamecheetah.Graphic;
	import gamecheetah.Space;
	import gamecheetah.Entity;
	import gamecheetah.utils.GCError;
	
	/**
	 * Sharable text styling used by the TextClip class.
	 * @author Zeb Zhao
	 */
	public class TextStyle extends Graphic
	{
		public static const ALIGN_LEFT:String = "left";
		public static const ALIGN_RIGHT:String = "right";
		public static const ALIGN_CENTER:String = "center";
		public static const ALIGN_JUSTIFY:String = "justify";
		
		/**
		 * [Read-only] The text format object for this text Graphic.
		 */
		public function get format():TextFormat 
		{
			return _format;
		}
		private var _format:TextFormat;
		
		/**
		 * Creates a TextStyle object with the specified properties.
		 * 
		 *   Any parameter may be set to null to indicate that it is not defined. All of the
		 * parameters are optional; any omitted parameters are treated as null.
		 * @param	font	The name of a font for text as a string.
		 * @param	size	An integer that indicates the size in pixels.
		 * @param	color	The color of text using this text format. A number containing three 8-bit RGB
		 *   components; for example, 0xFF0000 is red, and 0x00FF00 is green.
		 * @param	bold	A Boolean value that indicates whether the text is boldface.
		 * @param	italic	A Boolean value that indicates whether the text is italicized.
		 * @param	underline	A Boolean value that indicates whether the text is underlined.
		 * @param	align	The alignment of the paragraph, as a TextFormatAlign value.
		 * @param	leftMargin	Indicates the left margin of the paragraph, in pixels.
		 * @param	rightMargin	Indicates the right margin of the paragraph, in pixels.
		 * @param	indent	An integer that indicates the indentation from the left margin to the first character
		 *   in the paragraph.
		 * @param	leading	A number that indicates the amount of leading vertical space between lines.
		 */
		public function TextStyle(font:String = null, size:Object = null, color:Object = null, bold:Object = null, italic:Object = null, underline:Object=null, 
			url:String=null, target:String=null, align:String=null, leftMargin:Object=null, rightMargin:Object=null, indent:Object=null, leading:Object=null) 
		{
			_format = new TextFormat(font, size, color, bold, italic, underline, url, target, align, leftMargin, rightMargin, indent, leading);
		}
		
		/**
		 * Create a new text entity with this text style.
		 * @param	space	If left null, the entity will not be added to any space.
		 */
		public function newText(text:String, space:Space=null, dest:Point=null):Entity 
		{
			var result:Entity = new Entity();
			result.graphic = this;
			result.textClip = new TextClip(text, _format);
			entities.push(result);
			
			if (dest != null) result.location = dest;
			if (space != null) space.add(result);
			
			return result;
		}
		
		public function newTextClip(text:String):TextClip 
		{
			CONFIG::developer
			{
				trace("for general use: please use newText() to avoid errors when swapping spaces!");
			}
			return new TextClip(text, _format);
		}
		
		override public function newEntity():Entity 
		{
			var result:Entity = new Entity();
			result.textClip = new TextClip("", _format);
			result.graphic = this;
			entities.push(result);
			return result;
		}
		
		override public function newRenderable():Renderable 
		{
			return new TextClip("", _format);
		}
	}

}