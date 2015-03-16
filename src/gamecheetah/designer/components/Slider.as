/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import gamecheetah.Space;
	
	public class Slider extends BaseButton 
	{
		public static const VERTICAL:String = "vertical";
		public static const HORIZONTAL:String = "horizontal";
		
		//{ ------------------- Private Info -------------------
		
		private var _handle:SliderHandle;
		
		private var
			_width:int, _height:int;
			
		//{ ------------------- Public Properties -------------------
		
		public function get value():int 
		{
			return _handle.value;
		}
		
		public function get width():int 
		{
			return _width;
		}
		
		public function set width(value:int):void 
		{
			if (value == _width) return;
			_width = value;
			this.renderable = new BackgroundStamp(_width, _height);
			_handle.updateSize();
		}
		
		public function get height():int 
		{
			return _height;
		}
		
		public function set height(value:int):void 
		{
			if (value == _height) return;
			_height = value;
			this.renderable = new BackgroundStamp(_width, _height);
			_handle.updateSize();
		}
		
		//{ ------------------- Public Methods -------------------
		
		public function Slider(	space:Space = null, width:int = 100, height:int = 8,
								orientation:String = HORIZONTAL,
								min:int = 0, max:int = 100, handleSpan:uint = 1,
								handler:Function = null) 
		{
			_width = width;
			_height = height;
			
			this.renderable = new BackgroundStamp(_width, _height);
			
			_handle = new SliderHandle(this, 0, 0, orientation, handler);
			this.setBounds(min, max, handleSpan);
			
			space.add(this);
			space.add(_handle);
			
			this.registerChildren(_handle);
			this.setDepth(0);
		}
		
		public function setBounds(min:int, max:int, handleSpan:uint):void 
		{
			_handle.setBounds(min, max, handleSpan);
		}
		
		override public function onUpdate():void 
		{
			// Copy tweenable properties
			_handle.renderable.alpha = this.renderable.alpha;
		}
	}
}

import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import gamecheetah.designer.components.*;
import gamecheetah.Engine;
import gamecheetah.gameutils.Input;
import gamecheetah.graphics.Renderable;

class SliderHandle extends BaseButton
{
	private var	_stamp:ButtonStamp;
	private var	_parent:Slider;
	private var _onSlide:Function;
	private var _orientation:String;
	
	private var
		_dragging:Boolean, _dragOffset:Point = new Point();
	
	private var
		_max:int, _min:int,
		_span:uint;
		
	public var 
		value:int = 0;
		
	public function SliderHandle(parent:Slider, width:int, height:int, orientation:String=null, onSlide:Function=null) 
	{
		_parent = parent;
		_orientation = orientation;
		_onSlide = onSlide;
		setSize(width, height);
		this.depthOffset = 2;
		
		// Capture any mouse release whether on or off the entity.
		Engine.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
	}
	
	public function setSize(width:int, height:int):void 
	{
		_stamp = new ButtonStamp(width, height);
		this.renderable = _stamp;
		this.setUpState(null, null, _stamp.highlight);
		this.setOverState(null, null, _stamp.highlight);
		this.setDownState(null, null, _stamp.unhighlight);
		this.setOutState(null, _stamp.unhighlight );
	}
	
	public function setBounds(min:int, max:int, handleSpan:uint):void 
	{
		if (_min == min && _max == max && _span == handleSpan)
			return;		// Nothing has changed
			
		_min = min;
		_max = max;
		_span = handleSpan;
		
		updateSize();
	}
	
	public function updateSize():void 
	{
		// Create slider handle
		if (_orientation == Slider.VERTICAL) setSize(_parent.width, calculateSize());
		else setSize(calculateSize(), _parent.height);
		
		updatePosition();
	}
	
	private function updatePosition():void 
	{
		if (_orientation == Slider.VERTICAL)
		{
			// Bound slider bar position
			this.location.y = Math.max(0, Math.min(this.location.y, _parent.height - calculateSize()));
			value = this.location.y / (_parent.height / (_max - _min));
		}
		else
		{
			// Bound slider bar position
			this.location.x = Math.max(0, Math.min(this.location.x, _parent.width - calculateSize()));
			value = this.location.x / (_parent.width / (_max - _min));
		}
	}
	
	//{ ------------------- Behavior Overrides -------------------
	
	override public function onUpdate():void 
	{
		if (_dragging)
		{
			if (_orientation == Slider.VERTICAL)
				this.location.setTo(0, Input.mouseY - _dragOffset.y);
			else
				this.location.setTo(Input.mouseX - _dragOffset.x, 0);
			
			updatePosition();
			if (_onSlide) _onSlide(this);
		}
	}
	
	override public function onMouseDown():void 
	{
		super.onMouseDown();
		_dragging = true;
		_dragOffset.setTo(Input.mouseX - this.location.x, Input.mouseY - this.location.y);
	}
	
	//{ ------------------- Private Methods -------------------
	
	private function calculateSize():int 
	{
		var length:int = _orientation == Slider.VERTICAL ? _parent.height : _parent.width;
		if (_max - _min > 0) return _span / (_max - _min) * length;
		else return length;
	}
	
	private function onStageMouseUp(e:Event):void 
	{
		_dragging = false;
	}
}

class BackgroundStamp extends Renderable
{
	public function BackgroundStamp(width:int, height:int):void 
	{
		if (width == 0 || height == 0) this.setBuffer(Renderable.EMPTY);
		else this.setBuffer(new BitmapData(width, height, true, Style.SLIDER_BG));
	}
}

class ButtonStamp extends Renderable
{
	public function ButtonStamp(width:int, height:int):void 
	{
		if (width == 0 || height == 0) this.setBuffer(Renderable.EMPTY);
		else this.setBuffer(new BitmapData(width, height, true, Style.SLIDER_HANDLE));
	}
	
	public function highlight(b:*):void 
	{
		this.buffer.fillRect(new Rectangle(0, 0, this.width, this.height), Style.SLIDER_HIGHLIGHT);
	}
	
	public function unhighlight(b:*):void 
	{
		this.buffer.fillRect(new Rectangle(0, 0, this.width, this.height), Style.SLIDER_HANDLE);
	}
}