/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import gamecheetah.Entity;
	import gamecheetah.graphics.Clip;
	import gamecheetah.utils.OrderedDict;

	public class BaseButton extends BaseComponent
	{
		//{ ------------------- Private Info -------------------
		
		private var
			_downTweenTo:Object, _upTweenTo:Object, _overTweenTo:Object,
			_mouseDown:Function, _mouseUp:Function, _mouseOver:Function, _mouseOut:Function,
			_downAnimation:String, _upAnimation:String, _overAnimation:String;
		
		//{ ------------------- Public Methods -------------------
		
		public function BaseButton(frameImages:Array=null, animations:OrderedDict=null) 
		{
			if (frameImages && animations) this.renderable = new Clip(frameImages, animations);
		}
		
		public function setDownState(animation:String=null, tweenTo:Object=null, handler:Function=null):void 
		{
			_downAnimation = animation;
			_downTweenTo = tweenTo;
			_mouseDown = handler;
		}
		
		public function setUpState(animation:String=null, tweenTo:Object=null, handler:Function=null):void 
		{
			_upAnimation = animation;
			_upTweenTo = tweenTo;
			_mouseUp = handler;
		}
		
		public function setOverState(animation:String=null, tweenTo:Object=null, handler:Function=null):void 
		{
			_overAnimation = animation;
			_overTweenTo = tweenTo;
			_mouseOver = handler;
		}
		
		public function setOutState(animation:String=null, handler:Function=null):void 
		{
			_mouseOut = handler;
		}
		
		//{ ------------------- Behaviour Overrides -------------------
		
		override public function onMouseDown():void 
		{
			if (_downAnimation)		this.clip.play(_downAnimation);
			if (_downTweenTo) 		this.tweenClip(null, _downTweenTo);
			if (_mouseDown) 		_mouseDown(this);
		}
		
		override public function onMouseUp():void 
		{
			if (_upAnimation)		this.clip.play(_upAnimation);
			if (_upTweenTo) 		this.tweenClip(null, _upTweenTo);
			if (_mouseUp) 			_mouseUp(this);
		}
		
		override public function onMouseOver():void 
		{
			if (_overAnimation)		this.clip.play(_overAnimation);
			if (_overTweenTo) 		this.tweenClip(null, _overTweenTo);
			if (_mouseOver) 		_mouseOver(this);
		}
		
		override public function onMouseOut():void 
		{
			if (_upAnimation)		this.clip.play(_upAnimation);
			if (_upTweenTo) 		this.tweenClip(null, _upTweenTo);
			if (_mouseOut)			_mouseOut(this);
		}	
	}
}