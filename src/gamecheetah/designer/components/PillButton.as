/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.utils.Dictionary;
	
	public class PillButton extends PushButton 
	{
		private static var Groups:Dictionary = new Dictionary();
		
		private var
			_group:String;
		
		public var selected:Boolean;
		public var togglable:Boolean;
		
		public function PillButton(	parent:BaseComponent, width:int = 100, height:int = 25,
									text:String=null, handler:Function=null, group:String="", togglable:Boolean=false ) 
		{
			super(parent, width, height, text, handler, Style.FONT_HEADER);
			_group = group;
			this.togglable = togglable;
		}
		
		public function select():void 
		{
			if (Groups[_group]) Groups[_group].unselect();
			selected = true;
			Groups[_group] = this;
		}
		
		public function unselect():void 
		{
			selected = false;
		}
		
		//{ ------------------- Behavior Overrides -------------------
		
		override public function onMouseDown():void 
		{
			super.onMouseDown();
			if (togglable && selected) this.unselect()
			else this.select();
		}
		
		override public function draw():void 
		{
			this.backgroundColor = selected ? Style.BUTTON2_HIGHLIGHT : (_highlighted ? Style.BUTTON2_HIGHLIGHT : Style.BUTTON2_BASE);
		}
		
	}

}
