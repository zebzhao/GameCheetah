/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.display.DisplayObjectContainer;
	import gamecheetah.graphics.Clip;
	import gamecheetah.utils.OrderedDict;

	public class BaseButton extends BaseComponent
	{
		//{ ------------------- Private Info -------------------
		
		public var
			mouseDown:Function, mouseUp:Function, mouseOver:Function, mouseOut:Function;
			
		
		public function BaseButton(parent:DisplayObjectContainer, width:Number=0, height:Number=0) 
		{
			super(parent, width, height);
		}
		
		//{ ------------------- Public Methods -------------------
		
		public function setDownState(handler:Function=null):void 
		{
			mouseDown = handler;
		}
		
		public function setUpState(handler:Function=null):void 
		{
			mouseUp = handler;
		}
		
		public function setOverState(handler:Function=null):void 
		{
			mouseOver = handler;
		}
		
		public function setOutState(handler:Function=null):void 
		{
			mouseOut = handler;
		}
		
		//{ ------------------- Behaviour Overrides -------------------
		
		override public function onMouseDown():void 
		{
			if (mouseDown) 		mouseDown(this);
		}
		
		override public function onMouseUp():void 
		{
			if (mouseUp) 			mouseUp(this);
		}
		
		override public function onMouseOver():void 
		{
			if (mouseOver) 		mouseOver(this);
		}
		
		override public function onMouseOut():void 
		{
			if (mouseOut)			mouseOut(this);
		}
	}
}