/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.utils.Dictionary;
	import gamecheetah.Space;
	
	public class PillButton extends PushButton 
	{
		private static var Groups:Dictionary = new Dictionary();
		
		private var _stamp:PillButtonStamp;
		
		private var
			_group:String,
			_selected:Boolean;
		
		public function PillButton(	space:Space = null, width:int = 100, height:int = 25,
									text:String="", handler:Function=null, group:String="" ) 
		{
			super(space, width, height, text, handler, new PillButtonStamp(width, height));
			_group = group;
		}
		
		public function select():void 
		{
			if (Groups[_group]) Groups[_group].unselect();
			_stamp.select();
			_selected = true;
			Groups[_group] = this;
		}
		
		public function unselect():void 
		{
			_stamp.unhighlight();
			_selected = false;
		}
		
		//{ ------------------- Behavior Overrides -------------------
		
		override public function onMouseDown():void 
		{
			super.onMouseDown();
			this.select();
		}
		
		override public function onMouseOver():void 
		{
			// Do not do highlighting if selected.
			if (!_selected) super.onMouseOver();
		}
		
		override public function onMouseOut():void 
		{
			// Do not do highlighting if selected.
			if (!_selected) super.onMouseOut();
		}
		
	}

}

import flash.display.BitmapData;
import flash.geom.Rectangle;
import gamecheetah.graphics.Renderable;
import gamecheetah.designer.components.Style;

class PillButtonStamp extends Renderable
{
	
	public function PillButtonStamp(width:int, height:int) 
	{
		this.setBuffer(new BitmapData(width, height, true, Style.BASE));
		this.setTransformAnchorToCenter();
	}
	
	public function select(b:*=null):void 
	{
		this.buffer.fillRect(new Rectangle(0, 0, this.width, this.height), Style.SELECTED);
	}
	
	public function highlight(b:*=null):void 
	{
		this.buffer.fillRect(new Rectangle(0, 0, this.width, this.height), Style.HIGHLIGHT);
	}
	
	public function unhighlight(b:*=null):void 
	{
		this.buffer.fillRect(new Rectangle(0, 0, this.width, this.height), Style.BASE);
	}
}