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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import gamecheetah.designer.views.Assets;
	import gamecheetah.gameutils.Input;
	
	/**
	 * For editing the collision mask.
	 * @private
	 */
	public class MaskCanvas extends ImagePane
	{
		public static var E_LOAD_MASK:String = "load mask";
		public static var E_MASK_SELECTED:String = "mask";
		public static var E_POINT_SELECTED:String = "point";
		public static var E_RECT_SELECTED:String = "rect";
		public static var E_NONE_SELECTED:String = "none";
		
		protected var
			bitmapMask:Bitmap,
			shape:Shape,
			rect:Rectangle,
			
			noneRadioButton:RadioButton,
			rectangleRadioButton:RadioButton,
			maskRadioButton:RadioButton,
			pointRadioButton:RadioButton,
			
			pencilButton:IconPushButton,
			eraserButton:IconPushButton,
			fillButton:IconPushButton,
			trashButton:IconPushButton,
			loadButton:IconPushButton;
			
		protected var
			bitmapData:BitmapData,
			mouseDown:Boolean, mousePos:Point,
			selectedButton:IconPushButton;
			
		
		public function MaskCanvas(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos);
		}
		
		/**
		 * Set canvas mask image.
		 */
		public function setMask(value:*):void 
		{
			if (value is Rectangle)
			{
				rectangleRadioButton.selected = true;
				updateIcons();
				
				// Draw rectangle in shape object.
				shape.graphics.clear();
				shape.graphics.beginFill(0xff00ffcc, 0.5);
				this.rect = value as Rectangle;
				shape.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
				shape.graphics.endFill();
				
				// Make bitmap mask invisible and shape visible.
				shape.visible = true;
				bitmapMask.bitmapData = null;
			}
			else if (value is BitmapData)
			{
				maskRadioButton.selected = true;
				updateIcons();
				// Make bitmap mask visible and shape invisible.
				shape.visible = false;
				bitmapData = value as BitmapData;
				bitmapMask.bitmapData = bitmapData;
			}
			else if (value is Point)
			{
				pointRadioButton.selected = true;
				updateIcons();
				// Make bitmap mask invisible and shape invisible.
				shape.visible = false;
				bitmapMask.bitmapData = null;
			}
			else
			{
				noneRadioButton.selected = true;
				updateIcons();
				// Make bitmap mask and shape invisible.
				shape.visible = false;
				bitmapMask.bitmapData = null; 
			}
		}
		
		override protected function build():void 
		{
			super.build();
			
			shape = new Shape();
			bitmapMask = new Bitmap();
			
			noneRadioButton = new RadioButton(this, 0, 0, "None", false, radioButton_Select);
			rectangleRadioButton = new RadioButton(this, 0, 0, "Rect", false, radioButton_Select);
			maskRadioButton = new RadioButton(this, 0, 0, "Mask", false, radioButton_Select);
			pointRadioButton = new RadioButton(this, 0, 0, "Point", false, radioButton_Select);
			
			pencilButton = new IconPushButton(this, 0, 0, "", new Assets.Pencil, pencilButton_Click);
			eraserButton = new IconPushButton(this, 0, 0, "", new Assets.Eraser, eraserButton_Click);
			fillButton = new IconPushButton(this, 0, 0, "", new Assets.BucketFill, fillButton_Click);
			trashButton = new IconPushButton(this, 0, 0, "", new Assets.Trash, trashButton_Click);
			loadButton = new IconPushButton(this, 0, 0, "", new Assets.Load, loadButton_Click);
		}
		
		override protected function initialize():void 
		{
			super.initialize();
			
			loadButton.backgroundVisible = false;
			pencilButton.backgroundVisible = false;
			eraserButton.backgroundVisible = false;
			fillButton.backgroundVisible = false;
			trashButton.backgroundVisible = false;
			updateIcons();
			
			mousePos = new Point();
			bitmapMask.alpha = 0.5;
			rectangleRadioButton.groupName = maskRadioButton.groupName = pointRadioButton.groupName = noneRadioButton.groupName = "MaskCanvas";
			
			super.pane.content.addChild(bitmapMask);
			super.pane.content.addChild(shape);
		}
		
		override protected function addListeners():void 
		{
			super.pane.content.addEventListener(MouseEvent.MOUSE_DOWN, pane_onMouseDown);
			super.pane.content.addEventListener(MouseEvent.MOUSE_MOVE, pane_onMouseMove);
		}
		
		override protected function onResize():void 
		{
			super.onResize();
			
			loadButton.setSize(22, 22);
			loadButton.x = 5;
			pencilButton.setSize(22, 22);
			pencilButton.x = _width - 125;
			eraserButton.setSize(22, 22);
			eraserButton.x = _width - 95;
			fillButton.setSize(22, 22);
			fillButton.x = _width - 65;
			trashButton.setSize(22, 22);
			trashButton.x = _width - 35;
			loadButton.y = pencilButton.y = eraserButton.y = fillButton.y = trashButton.y = _height - 26;
			
			noneRadioButton.move(10, super.pane.bottom + 8);
			pointRadioButton.move(noneRadioButton.right + 10, noneRadioButton.y);
			rectangleRadioButton.move(pointRadioButton.right + 10, pointRadioButton.y);
			maskRadioButton.move(rectangleRadioButton.right + 10, rectangleRadioButton.y);
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ UI input event listeners
		
		private function pencilButton_Click(e:Event):void 
		{
			if (selectedButton != null) selectedButton.alpha = 1;
			selectedButton = pencilButton;
			selectedButton.alpha = 0.3;
		}
		
		private function eraserButton_Click(e:Event):void 
		{
			if (selectedButton != null) selectedButton.alpha = 1;
			selectedButton = eraserButton;
			selectedButton.alpha = 0.3;
		}
		
		private function fillButton_Click(e:Event):void 
		{
			if (selectedButton != null) selectedButton.alpha = 1;
			selectedButton = fillButton;
			selectedButton.alpha = 0.3;
		}
		
		private function trashButton_Click(e:Event):void 
		{
			if (bitmapMask.bitmapData != null)
				bitmapMask.bitmapData.fillRect(bitmapMask.bitmapData.rect, 0);
		}
		
		private function loadButton_Click(e:Event):void 
		{
			this.dispatchEvent(new Event(E_LOAD_MASK));
		}
		
		private function updateIcons():void 
		{
			loadButton.alpha = pencilButton.alpha = eraserButton.alpha = fillButton.alpha = trashButton.alpha = maskRadioButton.selected ? 1 : 0;
			loadButton.enabled = pencilButton.enabled = eraserButton.enabled = fillButton.enabled = trashButton.enabled = maskRadioButton.selected;
		}
		
		private function radioButton_Select(e:Event):void 
		{
			updateIcons();
			
			if (maskRadioButton.selected) this.dispatchEvent(new Event(E_MASK_SELECTED));
			else if (pointRadioButton.selected) this.dispatchEvent(new Event(E_POINT_SELECTED));
			else if (rectangleRadioButton.selected) this.dispatchEvent(new Event(E_RECT_SELECTED));
			else if (noneRadioButton.selected) this.dispatchEvent(new Event(E_NONE_SELECTED));
		}
		
		/**
		 * Handles click events when mouse is over the image pane.
		 */
		private function pane_onMouseDown(e:MouseEvent):void 
		{
			// Start draw mode.
			mousePos.setTo(int(e.localX - bitmapMask.x), int(e.localY - bitmapMask.y));
			
			if (e.buttonDown)
			{
				mouseDown = true;
				
				if (bitmapMask.bitmapData != null)
				{
					if (selectedButton == pencilButton)
						bitmapMask.bitmapData.setPixel32(mousePos.x, mousePos.y, 0xFFFF0000);
						
					if (selectedButton == eraserButton)
						bitmapMask.bitmapData.setPixel32(mousePos.x, mousePos.y, 0);
						
					else if (selectedButton == fillButton)
						bitmapMask.bitmapData.floodFill(mousePos.x, mousePos.y, 0xFFFF0000);
				}
			}
		}
		
		/**
		 * Handles mouse move events when mouse is over the image pane.
		 */
		private function pane_onMouseMove(e:MouseEvent):void 
		{
			mouseDown = mouseDown && Input.mouseDown;
			
			if (maskRadioButton.selected)
			{
				if (mouseDown && bitmapMask.bitmapData != null)
				{
					if (selectedButton == pencilButton || selectedButton == eraserButton)
					{
						drawLine(bitmapMask.bitmapData, int(mousePos.x), int(mousePos.y), int(e.localX - bitmapMask.x), int(e.localY - bitmapMask.y),
							selectedButton == eraserButton ? 0 : 0xFFFF0000);
						mousePos.setTo(int(e.localX - bitmapMask.x), int(e.localY - bitmapMask.y));
					}
				}
			}
			else if (rectangleRadioButton.selected)
			{
				if (mouseDown && this.image != null)
				{
					var x1:Number = Math.max(0, Math.min(int(e.localX - shape.x), mousePos.x));
					var x2:Number = Math.min(this.image.width, Math.max(int(e.localX - shape.x), mousePos.x));
					var y1:Number = Math.max(0, Math.min(int(e.localY - shape.y), mousePos.y));
					var y2:Number = Math.min(this.image.height, Math.max(int(e.localY - shape.y), mousePos.y));
					
					this.rect.setTo(x1, y1, x2 - x1, y2 - y1);
					shape.graphics.clear();
					shape.graphics.beginFill(0xFF0000, 0.5);
					shape.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
					shape.graphics.endFill();
				}
			}
		}
		
		//} UI input event listeners
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Extremely Fast Line Algorithm written by Po-Han Lin
		 * Taken from: http://www.simppa.fi/blog/extremely-fast-line-algorithm-as3-optimized/
		 */
		public static function drawLine(bitmapData:BitmapData, x:int, y:int, x2:int, y2:int, color:uint):void
		{
			var shortLen:int = y2 - y;
			var longLen:int = x2 - x;
			if ((shortLen ^ (shortLen >> 31)) - (shortLen >> 31) > (longLen ^ (longLen >> 31)) - (longLen >> 31))
			{
				shortLen ^= longLen;
				longLen ^= shortLen;
				shortLen ^= longLen;
				
				var yLonger:Boolean = true;
			}
			else
			{
				yLonger = false;
			}
			
			var inc:int = longLen < 0 ? -1 : 1;
			
			var multDiff:Number = longLen == 0 ? shortLen : shortLen / longLen;
			
			if (yLonger)
			{
				for (var i:int = 0; i != longLen; i += inc)
				{
					bitmapData.setPixel32(x + i * multDiff, y + i, color);
				}
			}
			else
			{
				for (i = 0; i != longLen; i += inc)
				{
					bitmapData.setPixel32(x + i, y + i * multDiff, color);
				}
			}
		}
	}

}