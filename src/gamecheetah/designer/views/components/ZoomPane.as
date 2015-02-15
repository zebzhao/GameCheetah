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
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import gamecheetah.designer.DesignerError;

	/**
	 * A scroll pane that provides ability to zoom in and out.
	 * @private
	 */
	public class ZoomPane extends ScrollPane
	{
		public var scale:Number;
		public var contentOffset:Point;
		
		/**
		 * Scroll position as a percentage.
		 */
		public var relX:Number;
		public var relY:Number;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this ScrollPane.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 */
		public function ZoomPane(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			this.contentOffset = new Point();
			this.scale = 1;
			this.relX = this.relY = 0;
			super(parent, xpos, ypos);
		}
		
		override public function draw():void 
		{
			super.draw();
			content.x = -_hScrollbar.value + contentOffset.x;
			content.y = -_vScrollbar.value + contentOffset.y;
		}
		
		/**
		 * Called when either scroll bar is scrolled.
		 */
		override protected function onScroll(event:Event):void
		{
			relX = (_hScrollbar.value - _width / 2) / content.width;
			relY = (_vScrollbar.value - _height / 2) / content.height;
			content.x = -_hScrollbar.value + contentOffset.x;
			content.y = -_vScrollbar.value + contentOffset.y;
			if (isNaN(relX) || isNaN(relY)) throw new DesignerError("critical NaN error, need fix!");
		}
		
		override protected function onMouseMove(event:MouseEvent):void
		{
			_hScrollbar.value = -content.x  + contentOffset.x;
			_vScrollbar.value = -content.y  + contentOffset.y;
		}
		
		override public function update():void 
		{
			content.scaleX = content.scaleY = scale;
			relX = (_hScrollbar.value - _width / 2) / content.width;
			relY = (_vScrollbar.value - _height / 2) / content.height;
			contentOffset.x = content.width < _width ? _width / 2 - content.width / 2 : 0;
			contentOffset.y = content.height < _height ? _height / 2 - content.height / 2 : 0;
			this.draw();
		}
	}
}