/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views.components 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import gamecheetah.designer.views.Assets;
	
	/**
	 * @private
	 */
	public class ImagePane extends InterfaceGroup
	{
		protected var
			pane:ZoomPane,
			bitmap:Bitmap,
			zoomInButton:IconPushButton,
			zoomOutButton:IconPushButton;
		
		public function get image():BitmapData 
		{
			return bitmap.bitmapData;
		}
		public function set image(value:BitmapData):void 
		{
			bitmap.bitmapData = value;
			pane.update();
		}
		
		public function ImagePane(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos);
		}
		
		override protected function build():void 
		{
			bitmap = new Bitmap();
			pane = new ZoomPane(this);
			pane.content.addChild(bitmap);
			zoomInButton = new IconPushButton(this, 0, 0, "", new Assets.ZoomIn, zoomIn_Click);
			zoomOutButton = new IconPushButton(this, 0, 0, "", new Assets.ZoomOut, zoomOut_Click);
		}
		
		override protected function initialize():void 
		{
			pane.autoHideScrollBar = true;
			pane.dragContent = false;
			zoomInButton.backgroundVisible = false;
			zoomOutButton.backgroundVisible = false;
		}
		
		override protected function onResize():void 
		{
			zoomInButton.setSize(22, 22);
			zoomInButton.move(5, 3);
			zoomOutButton.setSize(22, 22);
			zoomOutButton.move(25, 3);
			pane.setSize(_width - 1, _height);
		}
		
		private function zoomIn_Click(e:Event):void 
		{
			if (pane.content.scaleX < 16)
			{
				pane.scale *= 2;
				pane.update();
			}
		}
		
		private function zoomOut_Click(e:Event):void 
		{
			if (pane.content.scaleX > 0.5)
			{
				pane.scale /= 2;
				pane.update();
			}
		}
	}
}