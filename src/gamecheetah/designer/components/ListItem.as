/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import gamecheetah.*;
	
	public class ListItem extends PushButton 
	{
		//{ ------------------- Private Info -------------------
		private var _delete:IconButton;
		private var _editInput:TextInput;
		private var _parent:List;
		
		private var
			_selected:Boolean,
			_editable:Boolean,
			_swappable:Boolean,
			_deletable:Boolean,
			_dragging:Boolean, _dragOffset:Point = new Point(), _startPos:Point = new Point();
		
		[Embed(source = "/../lib/Icons/emblem-unreadable.png")]
		private static var DELETE_SM:Class;
		
		[Embed(source="/../lib/Icons/accessories-text-editor-sm.png")]
		public static var EDIT_SM:Class;
		
		//{ ------------------- Public Properties -------------------
		
		public function get dragging():Boolean 
		{
			return _dragging;
		}
		
		public function get editInput():TextInput 
		{
			return _editInput;
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
		
		public function get placeholder():String 
		{
			return _editable ? _editInput.placeholder : null;
		}
		
		public function set placeholder(value:String):void
		{
			if (_editable && value != null)
				_editInput.placeholder = value;
		}
		
		public function get type():String 
		{
			return _editable ? _editInput.type : null;
		}
		
		public function set type(value:String):void
		{
			if (_editable) _editInput.type = value;
		}
		
		public function get editable():Boolean 
		{
			return _editable;
		}
		
		public function set editable(value:Boolean):void 
		{
			_editable = value;
			
			if (_label) this.removeChild(_label);
			if (_editInput) this.removeChild(_label);
			
			if (_editable)
			{
				_editInput = new TextInput(this, width, 25);
				_editInput.field.addEventListener(Event.CHANGE, onEdit, false, -1);
				_editInput.background = false;
				_label = null;
			}
			else
			{
				_label = new Label(this, _text, Style.FONT_DARK, Label.ALIGN_INNER_LEFT);
				if (editInput)
				{
					_editInput.field.removeEventListener(Event.CHANGE, onEdit);
					_editInput = null;
				}
			}
		}
		
		public function get swappable():Boolean 
		{
			return _swappable;
		}
		
		public function set swappable(value:Boolean):void 
		{
			if (_swappable == value) return;
			_swappable = value;
			
			if (_swappable)
			{
				// Capture any mouse release whether on or off the entity.
				Engine.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			}
			else Engine.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}
		
		public function get deletable():Boolean 
		{
			return _deletable;
		}
		
		public function set deletable(value:Boolean):void 
		{
			_deletable = value;
			
			if (_delete) this.removeChild(_delete);
			
			if (_deletable)
			{
				_delete = new IconButton(this, DELETE_SM, onDelete);
				_delete.move(5, this.halfHeight - _delete.halfHeight);
				
				if (_label) _label.offset.setTo(25, 0);  // Make some space for delete icon.
				if (_editInput)
				{
					_editInput.move(25, 0);
					_editInput.width -= 25;
				}
			}
			else _delete = null;
		}
		
		//{ ------------------- Public Methods -------------------
		
		public function ListItem(	parent:List, width:int = 100, height:int = 25,
									text:String = "", placeholder:String = null, handler:Function = null,
									editable:Boolean=true, deletable:Boolean=true, swappable:Boolean=true ) 
		{
			super(parent, width, height, text, handler);
			
			_parent = parent;
			
			this.editable = editable;
			this.deletable = deletable;
			this.swappable = swappable;
			this.placeholder = placeholder;
		}
		
		public function select():void 
		{
			if (_selected) return;
			_selected = true;
			if (_editInput) _editInput.select();
			draw();
		}
		
		public function unselect():void 
		{
			if (!_selected) return;
			_selected = false;
			if (_editInput) _editInput.unselect();
			draw();
		}
		
		//{ ------------------- Behavior Overrides -------------------
		
		override public function onUpdate():void 
		{
			if (_dragging)
				this.y = _parent.mouseY - _dragOffset.y;
		}
		
		override public function onMouseDown():void 
		{
			if (_swappable)
			{
				_dragging = true;
				_dragOffset.y = _parent.mouseY - this.y;
				_startPos.y = this.y;
				this.bringToFront();
			}
		}
		
		override public function draw():void 
		{
			this.backgroundColor = _selected ? Style.BUTTON_SELECTED : (_highlighted ? Style.BUTTON2_HIGHLIGHT : Style.BUTTON2_BASE);
		}
		
		//{ ------------------- Private Methods -------------------
		
		private function onStageMouseUp(e:Event):void 
		{
			if (_dragging && Math.abs(this._startPos.y - this.y) > this.halfHeight)
			{
				// Successful swap event.
				_parent.findSwapItem(this);
			}
			_dragging = false;
		}
		
		private function checkListItem(target:Sprite):Boolean 
		{
			return target is ListItem;
		}
		
		private function onDelete(b:BaseButton):void
		{
			_parent.deleteItem(this);
		}
		
		private function onEdit(e:Event):void
		{
			_parent.editItem(this, _editInput.text);
		}
	}
}
