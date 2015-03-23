/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import gamecheetah.graphics.TextClip;
	import gamecheetah.Space;
	
	public class Label extends BaseButton 
	{
		public static var ALIGN_CENTER:String = "center";
		public static var ALIGN_ABOVE:String = "above";
		public static var ALIGN_BELOW:String = "below";
		public static var ALIGN_LEFT:String = "left";
		public static var ALIGN_RIGHT:String = "right";
		public static var ALIGN_VCENTER_LEFT:String = "vcenter-left";
		public static var ALIGN_VABOVE_LEFT:String = "vabove-left";
		
		//{ ------------------- Private Info -------------------
		
		private var _host:BaseComponent, _hostAlign:String;
		
		//{ ------------------- Public Properties -------------------
		
		public const offset:Point = new Point();
		
		public function get text():String 
		{
			return this.textClip.text;
		}
		
		public function set text(value:String):void 
		{
			if (value == null) value = "";
			this.textClip.text = value;
		}
		
		//{ ------------------- Public Methods -------------------
		
		public function Label(space:Space=null, text:String="", host:BaseComponent=null, hostAlign:String=null, color:uint=0x000000) 
		{
			_host = host;
			_hostAlign = hostAlign;
			
			this.textClip = new TextClip(text, new TextFormat("Designer Font", Style.FONT_SIZE, color,
				null, null, null, null, null, TextFormatAlign.CENTER));
				
			this.depthOffset = 1;
			
			if (space) space.add(this);
		}
		
		/**
		 * Labels cannot be moved. Must be attached to components instead.
		 */
		override public function move(x:int, y:int):void 
		{
		}
		
		//{ ------------------- Behavior Overrides -------------------
		
		override public function onActivate():void 
		{
			this.mouseEnabled = false;
			this.renderable.setTransformAnchorToCenter();
		}
		
		override public function onUpdate():void 
		{
			super.onUpdate();
			
			if (_host)
			{
				if (_hostAlign == ALIGN_ABOVE)
				{
					this.location.setTo(_host.absoluteCenter.x-this.renderable.width / 2, _host.top-this.renderable.height * 1.05);
				}
				else if (_hostAlign == ALIGN_BELOW)
				{
					this.location.setTo(_host.absoluteCenter.x-this.renderable.width / 2, _host.bottom);
				}
				else if (_hostAlign == ALIGN_LEFT)
				{
					this.location.setTo(_host.left - this.renderable.width - 5, _host.absoluteCenter.y - this.renderable.height / 2);
				}
				else if (_hostAlign == ALIGN_RIGHT)
				{
					this.location.setTo(_host.right, _host.absoluteCenter.y - this.renderable.height / 2);
				}
				else if (_hostAlign == ALIGN_VCENTER_LEFT)
				{
					this.location.setTo(_host.left, _host.absoluteCenter.y - this.renderable.height / 2);
				}
				else if (_hostAlign == ALIGN_VABOVE_LEFT)
				{
					this.location.setTo(_host.left, _host.top-this.renderable.height * 1.05);
				}
				else
				{   // Center by default
					this.location.setTo(_host.absoluteCenter.x - this.renderable.width / 2, _host.absoluteCenter.y - this.renderable.height / 2);
				}
				this.location.offset(offset.x, offset.y);
			}
		}
	}
}