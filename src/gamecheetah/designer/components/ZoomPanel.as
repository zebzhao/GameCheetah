/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import gamecheetah.Entity;

	public class ZoomPanel extends BaseComponent 
	{
		private var
			_hSlider:Slider, _vSlider:Slider,
			_width:int, _height:int,
			_stamp:BackgroundStamp,
			_content:Entity,
			_contentScale:Number = 1;
			
		public var drawMask:Boolean;
			
		public function ZoomPanel(parent:DisplayObjectContainer, entity:Entity, width:uint, height:uint) 
		{
			_width = width;
			_height = height;
			_hSlider = new Slider(this, width, 10, Slider.HORIZONTAL, 0, 1, 1, slider_Slide);
			_vSlider = new Slider(this, 10, height, Slider.VERTICAL, 0, 1, 1, slider_Slide);
			_stamp = new BackgroundStamp(_width, _height);
			
			this._content = entity;
			this.addChild(new Bitmap(_stamp.buffer));
			
			super(parent, width, height);
		}
		
		public function get content():Entity 
		{
			return _content;
		}
		public function set content(value:Entity):void 
		{
			_content = value;
			updateContent();
		}
		
		public function get contentScale():Number 
		{
			return _contentScale;
		}
		public function set contentScale(value:Number):void 
		{
			_contentScale = value;
			updateContent();
		}
		
		public function centerContent():void 
		{
			_hSlider.centerValue();
			_vSlider.centerValue();
		}
		
		override public function onUpdate():void 
		{
			if (_content)
			{
				_content.clip.update();
				_stamp.draw(_content, drawMask);
			}
			_hSlider.move(0, _height + 1);
			_vSlider.move(_width + 1, 0);
		}
		
		private function updateContent():void 
		{
			if (_content)
			{
				_content.clip.scaleX = _content.clip.scaleY = _contentScale;
				_hSlider.setBounds(0, Math.max(_width, _content.clip.width), _width);
				_vSlider.setBounds(0, Math.max(_height, _content.clip.height), _height);
				_stamp.offsetX = _width > _content.clip.width ? _width / 2 - _content.clip.width / 2 : 0;
				_stamp.offsetY = _height > _content.clip.height ? _height / 2 - _content.clip.height / 2 : 0;
			}
		}
		
		private function slider_Slide(s:Slider):void 
		{
			_stamp.scrollX = _hSlider.value;
			_stamp.scrollY = _vSlider.value;
		}
	}
}

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import gamecheetah.Entity;
import gamecheetah.graphics.Renderable;
import gamecheetah.namespaces.hidden;

use namespace hidden;

class BackgroundStamp extends Renderable
{
	public var scrollX:int, scrollY:int;
	public var offsetX:int, offsetY:int;
	
	public function BackgroundStamp(width:int, height:int):void 
	{
		if (width == 0 || height == 0) this.setBuffer(Renderable.EMPTY);
		else this.setBuffer(new BitmapData(width, height, true, 0));
	}
	
	public function draw(entity:Entity, drawMask:Boolean=false):void 
	{
		// Clear buffer
		this.buffer.fillRect(this.buffer.rect, 0);
		// Draw clip
		entity.clip.render(_buffer, -scrollX + offsetX, -scrollY + offsetY);
		
		if (drawMask)
		{
			// Get collision masks for the entity
			var mask:* = entity._getMask();
			var bmd:BitmapData = mask as BitmapData;
			
			// Tricky: Transformed rectangle masks are returned as bitmaps.
			if (mask is Rectangle)
			{
				var rect:Rectangle = new Rectangle();
				rect.copyFrom(mask);
				rect.offset(-scrollX + offsetX, -scrollY + offsetY);
				this.buffer.fillRect(rect, 0x90ff0000);
			}
			else if (bmd != null) this.buffer.copyPixels(bmd, bmd.rect, new Point( -scrollX + offsetX, -scrollY + offsetY), null, null, true);
		}
	}
}