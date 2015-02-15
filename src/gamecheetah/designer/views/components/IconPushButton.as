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
	
	/**
	 * Push button with an icon.
	 * @private
	 */
	public class IconPushButton extends PushButton
	{
		protected var _icon:DisplayObject;
		
		public function get backgroundVisible():Boolean 
		{
			return _back.parent != null;
		}
		public function set backgroundVisible(value:Boolean):void 
		{
			if ((_back.parent != null) != value)
			{
				if (value)
				{
					this.addChild(_back);
					this.addChild(_face);
				}
				else
				{
					this.removeChild(_back);
					this.removeChild(_face);
				}
			}
		}
		
		function IconPushButton(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number= 0, label:String="", icon:DisplayObject=null, defaultHandler:Function=null) 
		{
			this._icon = icon;
			super(parent, xpos, ypos, label, defaultHandler);
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		override protected function addChildren():void
		{
			super.addChildren();
			if (_icon != null) this.addChild(_icon);
		}
		
		override public function set label(value:String):void 
		{
			super.label = value;
			setSize(_width, _height);
		}
		
		/**
		 * Sets the size of the component.
		 * @param w The width of the component.
		 * @param h The height of the component.
		 */
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			_label.textField.x = _icon != null ? _icon.width / 2 : 0;
			
			if (_icon != null)
			{
				var leading:int = _label.text != "" ? 8 : 0;
				_icon.x = (_width - _icon.width - _label.textField.textWidth - leading) / 2;
				_icon.y = (_height - _icon.height) / 2;
			}
		}
	}

}