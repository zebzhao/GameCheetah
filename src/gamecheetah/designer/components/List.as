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
					_itemWidth:uint, _itemHeight:uint,
					_editable:Boolean, _deletable:Boolean;
		
		private var _visibleItems:uint,
					_listItems:Array,
					_selectedItem:ListItem;
		
		private var _slider:Slider;
		private var _hidden:Boolean;
		
		private var
			_onDelete:Function, _onSwap:Function, _onSelect:Function, _onEdit:Function;
		
		//{ ------------------- Public Properties -------------------
		
		public function get selectedIndex():int 
		{
			return _listItems.indexOf(_selectedItem) + _slider.value;
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
								onSelect:Function = null, onDelete:Function = null, onSwap:Function = null, onEdit:Function = null,
								editable:Boolean = true, deletable:Boolean = true ) 
		{
			_onSelect = onSelect;
			_onDelete = onDelete;
			_onSwap = onSwap;
			_onEdit = onEdit;
			
			_items = items;
			_itemWidth = itemWidth;
			_itemHeight = itemHeight;
			
			_editable = editable;
			_deletable = deletable;
			
			_listItems = [];
			_visibleItems = visibleItems;
			
			_slider = new Slider(space, 10, calculateSliderHeight(), Slider.VERTICAL);
			_slider.setBounds(0, items.length, _visibleItems);
			
			this.renderable = new Renderable();
			
			if (space)
			{
				space.add(this);
				this.registerChildren(_slider);
				this.setDepth(0);
			}
		}
		
		override public function get bottom():int 
		{
			return this.absoluteLocation.y + calculateSliderHeight();
		}
		
		override public function get right():int 
		{
			return this.absoluteLocation.x + _itemWidth + 10;
		}
		
		public function deleteItem(item:ListItem):void 
		{
			if (_onDelete) _onDelete(_listItems.indexOf(item) + _slider.value);
		}
		
		public function editItem(item:ListItem, text:String):void 
		{
			if (_onEdit) _onEdit(_listItems.indexOf(item) + _slider.value, text);
		}
		
		public function findSwapItem(item:ListItem):void 
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
		
		override public function hide(...rest:Array):void 
		{
			_hidden = true;
			
			for each (var listItem:ListItem in _listItems)
			{
				listItem.stopTween();
			}
			_slider.stopTween();
		}
		
		override public function show(...rest:Array):void 
		{
			if (!_hidden) return;
			_hidden = false;
			openAnimation();
		}
		
		//{ ------------------- Behavior Overrides -------------------
		
		override public function onActivate():void 
		{
			makeItems();
			openAnimation();
		}
		
		override public function onUpdate():void 
		{
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
			if (_selectedItem) _selectedItem.unselect();
			_selectedItem = item;
			_selectedItem.select();
			if (_onSelect) _onSelect(_listItems.indexOf(_selectedItem) + _slider.value);
		}
		
		//{ ------------------- Private Methods -------------------
		
		private function openAnimation():void 
		{
			var listItem:ListItem;
			for (var i:uint = 0; i < _visibleItems; i++)
			{
				if (i < items.length)
				{
					listItem = _listItems[i];
					listItem.tweenClip( { "alpha": 0 }, { "alpha": 1 }, 0.3, null, i * 0.1);
				}
			}
		}
		
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
				listItem = new ListItem(this, this.space, _itemWidth, _itemHeight, "{Empty}", onSelectItem, _editable, _deletable);
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