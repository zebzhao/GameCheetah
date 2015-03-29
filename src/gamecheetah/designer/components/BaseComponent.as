package gamecheetah.designer.components 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import gamecheetah.Engine;

	public class BaseComponent extends Sprite
	{
		protected var
			_width:Number,
			_height:Number;
		
		//{ ------------------- Constructor -------------------
		
		public function BaseComponent(parent:DisplayObjectContainer, width:Number=0, height:Number=0):void 
		{
			_width = width;
			_height = height;
			this.addEventListener(Event.ADDED_TO_STAGE, _onStageEnter);
			this.addEventListener(Event.REMOVED_FROM_STAGE, _onStageExit);
			if (parent) parent.addChild(this);
		}
			
		//{ ------------------- Public Properties -------------------
		
		public function bringToFront():void 
		{
			this.parent.setChildIndex(this, this.parent.numChildren - 1);
		}
		
		public function hide(...rest:Array):void 
		{
			this.visible = false;
		}
		
		public function show(...rest:Array):void 
		{
			this.visible = true;
		}
		
		public function move(x:int, y:int):void 
		{
			this.x = x;
			this.y = y;
		}
		
		override public function get width():Number 
		{
			return _width;
		}
		
		override public function set width(value:Number):void 
		{
			_width = value;
		}
		
		override public function get height():Number 
		{
			return _height;
		}
		
		override public function set height(value:Number):void 
		{
			_height = value;
		}
		
		public function get left():int
		{
			return this.x;
		}
		
		public function get right():int
		{
			return this.width + this.x;
		}
		
		public function get top():int
		{
			return this.y;
		}
		
		public function get bottom():int
		{
			return this.height + this.y;
		}
		
		public function get centerX():int
		{
			return this.x + this.width / 2;
		}
		
		public function get centerY():int
		{
			return this.y + this.height / 2;
		}
		
		public function get halfWidth():int
		{
			return this.width / 2;
		}
		
		public function get halfHeight():int
		{
			return this.height / 2;
		}
		
		public function tweenClip(from:Object=null, to:Object=null, duration:Number=0.5, ease:Function=null, delayStart:Number=0, transformAnchor:Point=null, onComplete:Function=null, onCompleteParams:Array=null):void 
		{
			Engine.cancelTweens(this);
			Engine.startTween(this, delayStart, duration, from, to, ease, onComplete, onCompleteParams, true);
		}
		
		//{ ------------------- Behaviour Overrides -------------------
		
		public function onActivate():void {}
		public function onDeactivate():void {}
		public function onUpdate():void {}
		public function onMouseUp():void {}
		public function onMouseDown():void {}
		public function onMouseOver():void {}
		public function onMouseOut():void {}
		public function onRender():void {}
		
		private function _onStageEnter(e:Event):void 
		{
			onActivate();
			this.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			this.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
		}
		
		private function _onStageExit(e:Event):void 
		{
			onDeactivate();
			this.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			this.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
		}
		
		private function _onEnterFrame(e:Event):void 
		{
			onUpdate();
		}
		
		private function _onMouseUp(e:MouseEvent):void 
		{
			onMouseUp();
		}
		
		private function _onMouseDown(e:MouseEvent):void 
		{
			onMouseDown();
		}
		
		private function _onMouseOver(e:MouseEvent):void 
		{
			onMouseOver();
		}
		
		private function _onMouseOut(e:MouseEvent):void 
		{
			onMouseOut();
		}
	}

}