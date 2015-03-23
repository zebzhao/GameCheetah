/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import gamecheetah.graphics.Clip;
	import gamecheetah.Space;

	public class ZoomPanel extends BaseComponent 
	{
		private var
			_hSlider:Slider, _vSlider:Slider,
			_width:int, _height:int,
			_stamp:BackgroundStamp,
			_content:Clip,
			_contentScale:Number = 1;
			
		public function ZoomPanel(space:Space, clip:Clip, width:uint, height:uint) 
		{
			_width = width;
			_height = height;
			_hSlider = new Slider(space, width, 10, Slider.HORIZONTAL, 0, 1, 1, slider_Slide);
			_vSlider = new Slider(space, 10, height, Slider.VERTICAL, 0, 1, 1, slider_Slide);
			_stamp = new BackgroundStamp(_width, _height);
			
			this._content = clip;
			this.renderable = _stamp;
			
			this.registerChildren(_hSlider, _vSlider);
			if (space) space.add(this);
		}
		
		public function get content():Clip 
		{
			return _content;
		}
		public function set content(value:Clip):void 
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
				_content.update();
				_stamp.draw(_content);
			}
			_hSlider.location.setTo(0, _height + 1);
			_vSlider.location.setTo(_width + 1, 0);
		}
		
		private function updateContent():void 
		{
			if (_content)
			{
				_content.scaleX = _content.scaleY = _contentScale;
				_hSlider.setBounds(0, Math.max(_width, _content.width), _width);
				_vSlider.setBounds(0, Math.max(_height, _content.height), _height);
				_stamp.offsetX = _width > _content.width ? _width / 2 - _content.width / 2 : 0;
				_stamp.offsetY = _height > _content.height ? _height / 2 - _content.height / 2 : 0;
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
import gamecheetah.graphics.Renderable;
import gamecheetah.designer.components.Style;

class BackgroundStamp extends Renderable
{
	public var scrollX:int, scrollY:int;
	public var offsetX:int, offsetY:int;
	
	public function BackgroundStamp(width:int, height:int):void 
	{
		if (width == 0 || height == 0) this.setBuffer(Renderable.EMPTY);
		else this.setBuffer(new BitmapData(width, height, true, Style.BASE));
	}
	
	public function draw(clip:Renderable):void 
	{
		this._buffer.fillRect(this._buffer.rect, Style.BASE);
		clip.render(_buffer, -scrollX + offsetX, -scrollY + offsetY);
	}
}