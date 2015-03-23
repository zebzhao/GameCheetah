/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import gamecheetah.graphics.Clip;
	import gamecheetah.Space;
	import gamecheetah.utils.OrderedDict;
	
	public class IconButton extends BaseButton 
	{
		protected var _hint:Label;
		protected var _frozen:Boolean;
		
		
		public function get frozen():Boolean 
		{
			return _frozen;
		}
		
		public function IconButton(space:Space, asset:*, handler:Function=null, hint:String=null, labelAlign:String=null) 
		{
			setIcon(asset);
			
			this.setUpState(null, { "scaleX": 1, "scaleY": 1 }, handler);
			this.setOverState(null, { "scaleX": 1.10, "scaleY": 1.10 } );
			this.setDownState(null, { "scaleX": 0.95, "scaleY": 0.95 } );
			
			if (hint)
			{
				// Tricky: Hint does not belong directly to IconButton, as it's visible property shouldn't be linked.
				_hint = new Label(space, hint, this, labelAlign, Style.HEADER_BASE);
				_hint.renderable.alpha = 0;
			}
			space.add(this);
		}
		
		public function setIcon(asset:*):void 
		{
			if (asset is Class)
			{
				var iconBmd:BitmapData = (new asset() as Bitmap).bitmapData;
				this.renderable = new Clip([iconBmd], new OrderedDict());
			}
			else if (asset is BitmapData)
			{
				this.renderable = new Clip([asset], new OrderedDict());
			}
			else if (asset is Clip)
			{
				this.renderable = asset;
			}
		}
		
		public function freeze():void 
		{
			_frozen = true;
			if (_hint)
			{
				_hint.stopTween(true);
				_hint.renderable.alpha = 1;
			}
		}
		
		public function unfreeze():void 
		{
			_frozen = false;
			if (_hint) _hint.renderable.alpha = 0;
		}
		
		override public function hide(...rest:Array):void 
		{
			super.hide();
			if (_hint.visible) _hint.visible = false;
		}
		
		override public function show(...rest:Array):void 
		{
			super.show();
			if (!_hint.visible) _hint.visible = true;
		}
		
		override public function onMouseDown():void 
		{
			super.onMouseDown();
			if (_hint) this.move(this.origin.x, this.origin.y);
		}
		
		override public function onMouseOver():void 
		{
			if (!_frozen)
			{
				super.onMouseOver();
				if (_hint) _hint.tweenClip(null, { "alpha": 1 } );
			}
		}
		
		override public function onMouseOut():void 
		{
			if (!_frozen)
			{
				super.onMouseOut();
				if (_hint) _hint.tweenClip(null, { "alpha": 0 } );
			}
		}
		
		override public function setDepth(value:int):void 
		{
			super.setDepth(value);
			if (_hint) _hint.depth = this.depth + 1;
		}
		
		override public function onUpdate():void 
		{
			if (!_frozen) super.onUpdate();
		}
	}
}