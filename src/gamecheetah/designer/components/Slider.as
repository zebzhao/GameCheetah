/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.display.DisplayObjectContainer;
	
	public class Slider extends PushButton 
	{
		public static const VERTICAL:String = "vertical";
		public static const HORIZONTAL:String = "horizontal";
		
		//{ ------------------- Private Info -------------------
		
		private var _handle:SliderHandle;
			
		//{ ------------------- Public Properties -------------------
		
		public function get value():int 
		{
			return _handle.value;
		}
		
		override public function set width(value:Number):void 
		{
			super.width = value;
			_handle.updateSize();
			draw();
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value;
			_handle.updateSize();
			draw();
		}
		
		//{ ------------------- Public Methods -------------------
		
		public function Slider(	parent:DisplayObjectContainer, width:int = 100, height:int = 8,
								orientation:String = HORIZONTAL,
								min:int = 0, max:int = 100, handleSpan:uint = 1,
								handler:Function = null) 
		{
			_handle = new SliderHandle(this, 0, 0, orientation, handler);
			this.setBounds(min, max, handleSpan);
			super(parent, width, height);
		}
		
		override public function onMouseDown():void 
		{
			_handle.dragging = true;
		}
		
		public function setValue(value:int):void 
		{
			_handle.setValue(value);
		}
		
		public function centerValue():void 
		{
			_handle.centerValue();
		}
		
		public function setBounds(min:int, max:int, handleSpan:uint):void 
		{
			_handle.setBounds(min, max, handleSpan);
			draw();
		}
		
		override public function draw():void 
		{
			this.backgroundColor = Style.SLIDER_DARK;
		}
	}
}

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import gamecheetah.designer.components.*;
import gamecheetah.Engine;

class SliderHandle extends PushButton
{
	private var	_parent:Slider;
	private var _onSlide:Function;
	private var _orientation:String;
	
	public var
		dragging:Boolean, _dragOffset:Point = new Point();
	
	private var
		_max:int, _min:int,
		_span:uint;
		
	public var 
		value:int = 0;
		
	public function SliderHandle(parent:Slider, width:int, height:int, orientation:String=null, onSlide:Function=null) 
	{
		super(parent, width, height);
		
		_parent = parent;
		_orientation = orientation;
		_onSlide = onSlide;
		
		// Capture any mouse release whether on or off the entity.
		Engine.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
	}
	
	public function setBounds(min:int, max:int, handleSpan:uint):void 
	{
		if (_min == min && _max == max && _span == handleSpan)
			return;		// Nothing has changed
			
		_min = min;
		_max = max;
		_span = handleSpan;
		
		updateSize();
		updatePosition();
	}
	
	public function updateSize():void 
	{
		// Create slider handle
		if (_orientation == Slider.VERTICAL) setSize(_parent.width, calculateSize());
		else setSize(calculateSize(), _parent.height);
		updatePosition();
	}
	
	public function setValue(value:int):void 
	{
		if (_orientation == Slider.VERTICAL) this.y = value * (_parent.height / (_max - _min));
		else this.x = value * (_parent.width / (_max - _min));
		updatePosition();
	}
	
	public function centerValue():void 
	{
		setValue((_max + _min) / 2 - _span / 2);
	}
	
	//{ ------------------- Behavior Overrides -------------------
	
	override public function onUpdate():void 
	{
		if (dragging)
		{
			if (_orientation == Slider.VERTICAL)
				this.move(0, _parent.mouseY - _dragOffset.y);
			else
				this.move(_parent.mouseX - _dragOffset.x, 0);
			
			updatePosition();
			if (_onSlide) _onSlide(_parent);
		}
	}
	
	override public function onMouseDown():void 
	{
		super.onMouseDown();
		dragging = true;
		_dragOffset.setTo(_parent.mouseX - this.x, _parent.mouseY - this.y);
	}
	
	override public function draw():void 
	{
		this.backgroundColor = _highlighted ? Style.SLIDER_HIGHLIGHT : Style.SLIDER_BASE;
	}
	
	//{ ------------------- Private Methods -------------------
	
	private function updatePosition():void 
	{
		if (_orientation == Slider.VERTICAL)
		{
			// Bound slider bar position
			this.y = Math.max(0, Math.min(this.y, _parent.height - calculateSize()));
			value = this.y / (_parent.height / (_max - _min));
		}
		else
		{
			// Bound slider bar position
			this.x = Math.max(0, Math.min(this.x, _parent.width - calculateSize()));
			value = this.x / (_parent.width / (_max - _min));
		}
	}
	
	private function calculateSize():int 
	{
		var length:int = _orientation == Slider.VERTICAL ? _parent.height : _parent.width;
		if (_max - _min > 0) return _span / (_max - _min) * length;
		else return length;
	}
	
	private function onStageMouseUp(e:Event):void 
	{
		dragging = false;
	}
}
