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
		private var _hint:Label;
		private var _frozen:Boolean;
		
		public function get frozen():Boolean 
		{
			return _frozen;
		}
		
		public function IconButton(space:Space, asset:*, handler:Function=null, hint:String=null, labelAlign:String=null) 
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
			
			this.setUpState(null, { "scaleX": 1, "scaleY": 1 }, handler);
			this.setOverState(null, { "scaleX": 1.10, "scaleY": 1.10 } );
			this.setDownState(null, { "scaleX": 0.95, "scaleY": 0.95 } );
			
			if (hint)
			{
				_hint = new Label(space, hint, this, labelAlign, Style.HEADER_BASE);
				_hint.hide();
			}
			space.add(this);
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
	}
}