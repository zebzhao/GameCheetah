/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import gamecheetah.*;
	import gamecheetah.gameutils.Input;
	
	public class ListItem extends PushButton 
	{
		//{ ------------------- Private Info -------------------
		private var _delete:IconButton;
		private var _parent:List;
		private var _stamp:ListItemStamp;
		
		private var _selected:Boolean;
		
		private var
			_dragging:Boolean, _dragOffset:Point = new Point();
		
		[Embed(source = "/../lib/Icons/emblem-unreadable.png")]
		private static var ICON1:Class;
		
		//{ ------------------- Public Properties -------------------
		
		public function get dragging():Boolean 
		{
			return _dragging;
		}
		
		public function get text():String 
		{
			return _label.text;
		}
		
		public function set text(value:String):void
		{
			_label.text = value;
		}
		
		//{ ------------------- Public Methods -------------------
		
		public function ListItem(parent:List, space:Space = null, width:int=100, height:int=25, text:String="", handler:Function=null) 
		{
			_parent = parent;
			_text = text;
			_handler = handler;
			
			_stamp = new ListItemStamp(width, height);
			
			_delete = new IconButton(space, ICON1, onDelete);
			_delete.location.setTo(10, height / 2 - _delete.renderable.height / 2);
			_delete.depthOffset = 1;
			
			this.renderable = _stamp;
			this.setUpState(null, null, handler);
			this.setOverState(null, null, _stamp.highlight );
			this.setDownState(null, null, _stamp.unhighlight );
			this.setOutState(null, _stamp.unhighlight );
			
			if (space)
			{
				_label = new Label(space, _text, this, Label.ALIGN_VCENTER_LEFT, Style.FONT_DARK);
				_label.offset.setTo(30, 0);  // Make some space for delete icon.
				space.add(this);
				
				this.registerChildren(_label, _delete);
			}
			
			// Capture any mouse release whether on or off the entity.
			Engine.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			
			this.setDepth(0);
		}
		
		override public function hide(...rest:Array):void 
		{
			super.hide();
			_delete.visible = false;
		}
		
		public function select():void 
		{
			_stamp.select();
			_selected = true;
		}
		
		public function unselect():void 
		{
			_stamp.unhighlight();
			_selected = false;
		}
		
		//{ ------------------- Behavior Overrides -------------------
		
		override public function onUpdate():void 
		{
			// Copy tweenable properties
			_label.renderable.alpha = _delete.renderable.alpha = this.renderable.alpha;
			
			if (_dragging)
				this.location.setTo(Input.mouseX - _dragOffset.x, Input.mouseY - _dragOffset.y);
		}
		
		override public function onMouseDown():void 
		{
			this.setDepth(2);
			_dragging = true;
			_dragOffset.setTo(Input.mouseX - this.location.x, Input.mouseY - this.location.y);
		}
		
		override public function onMouseOver():void 
		{
			// Do not do highlighting if selected.
			if (!_selected) super.onMouseOver();
		}
		
		override public function onMouseOut():void 
		{
			// Do not do highlighting if selected.
			if (!_selected) super.onMouseOut();
		}
		
		//{ ------------------- Private Methods -------------------
		
		private function onStageMouseUp(e:Event):void 
		{
			if (_dragging)
			{
				// Successful swap event.
				_parent.findSwapItem(this);
			}
			this.setDepth(0);
			_dragging = false;
		}
		
		private function checkListItem(target:Entity):Boolean 
		{
			return target is ListItem;
		}
		
		private function onDelete(b:BaseButton):void
		{
			_parent.deleteItem(this);
		}
	}
}
import flash.display.BitmapData;
import flash.geom.Rectangle;
import gamecheetah.graphics.Renderable;
import gamecheetah.designer.components.Style;

class ListItemStamp extends Renderable
{
	
	public function ListItemStamp(width:int, height:int):void 
	{
		this.setBuffer(new BitmapData(width, height, true, Style.BASE));
		this.setTransformAnchorToCenter();
	}
	
	public function select(b:*=null):void 
	{
		this.buffer.fillRect(new Rectangle(0, 0, this.width, this.height), Style.SELECTED);
	}
	
	public function highlight(b:*=null):void 
	{
		this.buffer.fillRect(new Rectangle(0, 0, this.width, this.height), Style.HIGHLIGHT);
	}
	
	public function unhighlight(b:*=null):void 
	{
		this.buffer.fillRect(new Rectangle(0, 0, this.width, this.height), Style.BASE);
	}
}