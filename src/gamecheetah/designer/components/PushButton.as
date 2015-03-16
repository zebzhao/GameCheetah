/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components
{
	import gamecheetah.Entity;
	import gamecheetah.Space;
	
	public class PushButton extends BaseButton 
	{
		//{ ------------------- Protected/Private Info -------------------
		
		protected var	_text:String,
						_handler:Function,
						_label:Label;
						
		private var	_stamp:ButtonStamp;
		
		//{ ------------------- Public Methods -------------------
		
		public function PushButton(	space:Space = null, width:int = 100, height:int = 25,
									text:String="", handler:Function=null) 
		{
			_text = text;
			_handler = handler;
			_stamp = new ButtonStamp(width, height);
			
			this.renderable = _stamp;
			this.setUpState(null, null, _stamp.highlight);
			this.setOverState(null, null, _stamp.highlight );
			this.setDownState(null, null, _stamp.unhighlight );
			this.setOutState(null, _stamp.unhighlight );
			
			if (space)
			{
				_label = new Label(space, _text, this, Label.ALIGN_CENTER, Style.FONT_COLOR);
				space.add(this);
				
				this.registerChildren(_label)
				this.setDepth(0);
			}
		}
		
		override public function onMouseUp():void 
		{
			super.onMouseUp();
			if (_handler) _handler(this);
			this.setDepth(0);
		}
		
		//{ ------------------- Private Methods -------------------
	}
}
import flash.display.BitmapData;
import flash.geom.Rectangle;
import gamecheetah.graphics.Renderable;
import gamecheetah.designer.components.*;

class ButtonStamp extends Renderable
{
	public function ButtonStamp(width:int, height:int):void 
	{
		this.setBuffer(new BitmapData(width, height, true, Style.SLIDER_HANDLE));
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