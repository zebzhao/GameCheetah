/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views.components
{
	import gamecheetah.designer.bit101.components.*;
	import flash.display.*;
	import flash.events.*;
	
	/**
	 * @private
	 */
	public class DialogWindow extends Window
	{
		protected var _parent:DisplayObjectContainer;
		
		public function DialogWindow(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, title:String = "Window")
		{
			super(parent, xpos, ypos, title);
			_parent = parent;
			this.hasCloseButton = true;
		}
		
		override protected function init():void 
		{
			super.init();
			build();
			initialize();
			addListeners();
			onResize(null);
			this.addEventListener(Event.RESIZE, onResize);
		}		
		
		protected function build():void 
		{
		}
		
		protected function initialize():void 
		{
		}
		
		protected function addListeners():void 
		{
		}
		
		protected function onResize(e:Event):void 
		{
		}
		
		public function center():void 
		{
			this.move(_parent.width / 2 - this.width / 2, _parent.height / 2 - this.height / 2);
		}
		
		public function display():void
		{
			_parent.addChild(this);
		}
		
		public function hide():void
		{
			if (this.parent != null) this.parent.removeChild(this);
		}
		
		override protected function onClose(event:MouseEvent):void
		{
			super.onClose(event);
			hide();
		}
	}

}