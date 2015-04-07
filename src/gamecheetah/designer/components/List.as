/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import gamecheetah.utils.GCError;

	public class List extends BaseButton
	{
		//{ ------------------- Private Info -------------------
		
		private var	_items:Array,
					_selected:Vector.<Boolean> = new Vector.<Boolean>(),
					_itemWidth:uint, _itemHeight:uint,
					_editable:Boolean, _deletable:Boolean, _swappable:Boolean;
		
		private var _visibleItems:uint,
					_listItems:Array;
		
		private var _slider:Slider;
		
		//{ ------------------- Public Properties -------------------
		
		public var
			onDelete:Function, onSwap:Function, onSelect:Function, onDeselect:Function, onEdit:Function;
			
		/**
		 * If true, hides the scroll bar if not needed.
		 */
		public var autoHideScrollbar:Boolean = true;
		
		/**
		 * The placeholder value for TextInput if list items are editable.
		 */
		public var placeholder:String;
		
		/**
		 * True if multiple items can be selected.
		 */
		public var multiselect:Boolean;
		
		/**
		 * The index of the first selected item.
		 */
		public function get selectedIndex():int 
		{
			return _selected.indexOf(true);
		}
		
		/**
		 * Sets / gets the list of items to be shown.
		 */
		public function get items():Array
		{
			return _items;
		}
		
		public function set items(value:Array):void
		{
			if (shallowEquals(value, _items)) return;
			_items = value;
			_selected.length = _items.length;
			for (var i:int = 0; i < _selected.length; i++) _selected[i] = false;
		}
		
		/**
		 * Sets / gets the number of items to be shown.
		 */
		public function get visibleItems():uint
		{
			return _visibleItems;
		}
		
		public function set visibleItems(value:uint):void
		{
			_visibleItems = value;
			_slider.setBounds(0, items.length, _visibleItems);
			makeItems();
		}
		
		/**
		 * Gets array of selected/unselected statuses.
		 */
		public function get selected():Vector.<Boolean> 
		{
			return _selected;
		}
		
		/**
		 * The height of the list.
		 */
		override public function get height():Number 
		{
			return Math.min(_items.length, _visibleItems) * (_itemHeight + 1);
		}
		
		//{ ------------------- Constructor -------------------
		
		public function List(	parent:BaseComponent, items:Array = null, visibleItems:uint = 8,
								itemWidth:uint = 125, itemHeight:uint = 25,
								onSelect:Function = null, onDeselect:Function = null, onDelete:Function = null, onSwap:Function = null, onEdit:Function = null,
								editable:Boolean = true, deletable:Boolean = true, swappable:Boolean = true ) 
		{
			this.onSelect = onSelect;
			this.onDeselect = onDeselect;
			this.onDelete = onDelete;
			this.onSwap = onSwap;
			this.onEdit = onEdit;
			
			this.items = items;
			_itemWidth = itemWidth;
			_itemHeight = itemHeight;
			
			_editable = editable;
			_deletable = deletable;
			_swappable = swappable;
			
			_listItems = [];
			_visibleItems = visibleItems;
			
			_slider = new Slider(this, 10, this.height, Slider.VERTICAL);
			_slider.setBounds(0, items.length, _visibleItems);
			// Reposition slider
			_slider.move(_itemWidth + 1, 0);
			
			makeItems();
			super(parent);
		}
		
		//{ ------------------- Public Methods -------------------
		
		public function getListItem(index:int, throwError:Boolean=true):ListItem 
		{
			if (index >= 0 && index < _listItems.length)
				return _listItems[index] as ListItem;
			else if (throwError)
				throw new GCError("list item index out of range");
			else
				return null;
		}
		
		public function selectItem(index:int, invokeCallback:Boolean=true):void 
		{
			if (!multiselect)
			{
				for (var i:int = 0; i < _selected.length; i ++)
					if (i != index) deselectItem(i);
			}
			_selected.length = _items.length;
			
			if (index < selected.length)
			{
				if (_selected[index])
				{
					if (multiselect)
					{
						// Deselect selected
						_selected[index] = false;
						if (onDeselect != null && invokeCallback) onDeselect(this, index);
					}
					return;  // Skip callback if already selected.
				}
				
				_selected[index] = true;
				if (onSelect != null && invokeCallback) onSelect(this, index);
			}
		}
		
		public function deselectAll(invokeCallback:Boolean=true):void 
		{
			_selected.length = _items.length;
			for (var i:int = 0; i < _selected.length; i ++)
				deselectItem(i, invokeCallback);
		}
		
		public function deselectItem(index:int, invokeCallback:Boolean=true):void 
		{
			_selected.length = _items.length;
			if (!_selected[index]) return;
			_selected[index] = false;
			if (onDeselect != null && invokeCallback) onDeselect(this, index);
		}
		
		//}
		//{ ------------------- Internal methods -------------------
		
		internal function deleteItem(item:ListItem):void 
		{
			if (onDelete != null) onDelete(_listItems.indexOf(item) + _slider.value);
		}
		
		internal function editItem(item:ListItem, text:String):void 
		{
			var index:int = _listItems.indexOf(item) + _slider.value;
			items[index] = text;
			if (onEdit != null) onEdit(index, text);
		}
		
		internal function findSwapItem(item:ListItem):void 
		{
			// Find closest item
			for each (var item2:ListItem in _listItems)
			{
				if (Math.abs(item2.top - item.top) < _itemHeight/2 &&
					item2 != item)
				{
					if (onSwap != null)
						onSwap(_listItems.indexOf(item2) + _slider.value, _listItems.indexOf(item) + _slider.value);
					break;
				}
			}
		}
		
		//}
		//{ ------------------- Behavior Overrides -------------------
		
		override public function onUpdate():void 
		{
			_selected.length = _items.length;
			
			var listItem:ListItem;
			for (var i:uint = 0; i < _visibleItems; i++)
			{
				listItem = _listItems[i];
				
				// Reposition list item if not being dragged.
				if (!listItem.dragging)
					listItem.move(0, i * (_itemHeight + 1));
				
				if (i < items.length)
				{
					listItem.mouseEnabled = true;
					listItem.text = items[_slider.value + i];
					listItem.visible = true;
					
					if (_selected[i + _slider.value]) listItem.select();
					else listItem.unselect();
				}
				else
				{
					listItem.mouseEnabled = false;
					listItem.hide();
				}
			}
			
			if (autoHideScrollbar && items.length <= _visibleItems)
			{
				_slider.visible = false;
			}
			else
			{
				_slider.visible = true;
				_slider.height = this.height;
				_slider.setBounds(0, items.length, Math.min(items.length, _visibleItems));
			}
		}
		
		private function onSelectItem(item:ListItem):void 
		{
			selectItem(_listItems.indexOf(item) + _slider.value);
		}
		
		//{ ------------------- Private Methods -------------------
		
		private function makeItems():void 
		{
			var listItem:ListItem;
			for each (listItem in _listItems)
			{
				this.removeChild(listItem);
			}
			
			_listItems.length = 0;
			
			for (var i:uint = 0; i < _visibleItems; i++)
			{
				listItem = new ListItem(this, _itemWidth, _itemHeight, "", placeholder, onSelectItem, _editable, _deletable, _swappable);
				_listItems.push(listItem); 
			}
			onUpdate();
		}
		
		public static function shallowEquals(array1:Array, array2:Array):Boolean 
		{
			// compare lengths - can save a lot of time 
			if (array1 == null || array2 == null || array1.length != array2.length)
				return false;

			for (var i:int = 0; i < array1.length; i++)
				if (array1[i] != array2[i]) return false;
			
			return true;
		}
	}
}