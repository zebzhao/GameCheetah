/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.components 
{
	import gamecheetah.graphics.Renderable;
	import gamecheetah.Space;

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
		private var _hidden:Boolean;
		
		private var
			_onDelete:Function, _onSwap:Function, _onSelect:Function, _onDeselect:Function, _onEdit:Function;
		
		//{ ------------------- Public Properties -------------------
		
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
			return _hidden ? [] : _items;
		}
		
		public function set items(value:Array):void
		{
			_items = value;
			_selected.length = _items.length;
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
		
		//{ ------------------- Public Methods -------------------
		
		public function List(	space:Space, items:Array = null, visibleItems:uint = 8,
								itemWidth:uint = 125, itemHeight:uint = 25,
								onSelect:Function = null, onDeselect:Function = null, onDelete:Function = null, onSwap:Function = null, onEdit:Function = null,
								editable:Boolean = true, deletable:Boolean = true, swappable:Boolean = true ) 
		{
			_onSelect = onSelect;
			_onDeselect = onDeselect;
			_onDelete = onDelete;
			_onSwap = onSwap;
			_onEdit = onEdit;
			
			this.items = items;
			_itemWidth = itemWidth;
			_itemHeight = itemHeight;
			
			_editable = editable;
			_deletable = deletable;
			_swappable = swappable;
			
			_listItems = [];
			_visibleItems = visibleItems;
			
			this.renderable = new Renderable();
			
			_slider = new Slider(space, 10, calculateSliderHeight(), Slider.VERTICAL);
			_slider.setBounds(0, items.length, _visibleItems);
			
			if (space)
			{
				space.add(this);
				this.registerChildren(_slider);
				this.setDepth(0);
			}
			
			makeItems();
		}
		
		override public function get bottom():int 
		{
			return this.absoluteLocation.y + calculateSliderHeight();
		}
		
		override public function get right():int 
		{
			return this.absoluteLocation.x + _itemWidth + 10;
		}
		
		public function selectItem(index:int):void 
		{
			if (!multiselect)
			{
				for (var i:int = 0; i < _selected.length; i ++)
					if (i != index) deselectItem(i);
			}
			_selected.length = _items.length;
			
			if (_selected[index]) return;  // Skip callback if already selected.
			
			_selected[index] = true;
			if (_onSelect) _onSelect(this, index);
		}
		
		public function deselectItem(index:int):void 
		{
			if (!_selected[index]) return;
			_selected[index] = false;
			if (_onDeselect) _onDeselect(this, index);
		}
		
		override public function hide(...rest:Array):void 
		{
			_hidden = true;
		}
		
		override public function show(...rest:Array):void 
		{
			if (!_hidden) return;
			_hidden = false;
		}
		
		//}
		//{ ------------------- Internal methods -------------------
		
		internal function deleteItem(item:ListItem):void 
		{
			if (_onDelete) _onDelete(_listItems.indexOf(item) + _slider.value);
		}
		
		internal function editItem(item:ListItem, text:String):void 
		{
			if (_onEdit) _onEdit(_listItems.indexOf(item) + _slider.value, text);
		}
		
		internal function findSwapItem(item:ListItem):void 
		{
			// Find closest item
			for each (var item2:ListItem in _listItems)
			{
				if (Math.abs(item2.left - item.left) < _itemWidth &&
					Math.abs(item2.top - item.top) < _itemHeight &&
					item2 != item)
				{
					if (_onSwap)
						_onSwap(_listItems.indexOf(item2) + _slider.value, _listItems.indexOf(item) + _slider.value);
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
					listItem.location.setTo(0, i * (_itemHeight + 1));
					
				// Reposition slider
				_slider.location.setTo(_itemWidth + 1, 0);
				
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
			_slider.height = calculateSliderHeight();
			_slider.setBounds(0, items.length, Math.min(items.length, _visibleItems));
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
				this.unregisterChildren(listItem);
				listItem.space.destroyEntity(listItem);
			}
			
			_listItems.length = 0;
			
			for (var i:uint = 0; i < _visibleItems; i++)
			{
				listItem = new ListItem(this, this.space, _itemWidth, _itemHeight, "", placeholder, onSelectItem, _editable, _deletable, _swappable);
				_listItems.push(listItem); 
				this.registerChildren(listItem);
			}
			onUpdate();
		}
		
		private function calculateSliderHeight():int 
		{
			return Math.min(items.length, _visibleItems) * (_itemHeight + 1);
		}
	}

}