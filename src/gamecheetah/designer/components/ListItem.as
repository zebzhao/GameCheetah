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
		private var _editInput:TextInput;
		private var _parent:List;
		
		private var
			_selected:Boolean,
			_editable:Boolean,
			_dragging:Boolean, _dragOffset:Point = new Point();
		
		[Embed(source = "/../lib/Icons/emblem-unreadable.png")]
		private static var DELETE_SM:Class;
		
		[Embed(source="/../lib/Icons/accessories-text-editor-sm.png")]
		public static var EDIT_SM:Class;
		
		//{ ------------------- Public Properties -------------------
		
		public function get dragging():Boolean 
		{
			return _dragging;
		}
		
		public function get text():String 
		{
			return _editable ? _editInput.text : _label.text;
		}
		
		public function set text(value:String):void
		{
			if (_editable) _editInput.text = value;
			else _label.text = value;
		}
		
		//{ ------------------- Public Methods -------------------
		
		public function ListItem(	parent:List, space:Space = null, width:int = 100, height:int = 25,
									text:String="", handler:Function=null, editable:Boolean=true, deletable:Boolean=true ) 
		{
			super(null, width, height, text, handler, new ListItemStamp(width, height));
			
			_parent = parent;
			_editable = editable;
			
			if (deletable)
			{
				_delete = new IconButton(space, DELETE_SM, onDelete);
				_delete.location.setTo(5, height / 2 - _delete.renderable.height / 2);
				_delete.depthOffset = 1;
				
				this.registerChildren(_delete);
			}
			
			if (editable)
			{
				_editInput = new TextInput(space, width - 25, 25, onEdit);
				_editInput.location.setTo(25, 0);
				_editInput.depthOffset = 2;
				this.registerChildren(_editInput);
			}
			else
			{
				_label = new Label(space, _text, this, Label.ALIGN_VCENTER_LEFT, Style.FONT_DARK);
				_label.offset.setTo(25, 0);  // Make some space for delete icon.
				this.registerChildren(_label);
			}
			
			if (space) space.add(this);
			
			// Capture any mouse release whether on or off the entity.
			Engine.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			
			this.setDepth(0);
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
			super.onUpdate();
			
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
		
		private function onEdit(b:TextInput):void
		{
			_parent.editItem(this, b.text);
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