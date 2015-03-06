/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views.components 
{
	import gamecheetah.designer.bit101.components.*;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import gamecheetah.designer.views.Assets;
	import gamecheetah.Engine;

	/**
	 * 
	 * @private
	 */
	public class ItemMenu extends InterfaceGroup
	{
		protected var
			mainCombo:ComboBox,
			upButton:IconPushButton,
			downButton:IconPushButton,
			editButton:IconPushButton,
			addButton:IconPushButton,
			removeButton:IconPushButton;
		
		public function get selectedIndex():int
		{
			return mainCombo.selectedIndex;
		}
		
		public function get selectedItem():String
		{
			return mainCombo.selectedItem as String;
		}
		
		public function setItems(value:Array):void 
		{
			var selectedIndex:int = mainCombo.selectedIndex;
			if (selectedIndex >= value.length) selectedIndex = value.length - 1;
			mainCombo.items = value;
			mainCombo.numVisibleItems = Math.max(1, Math.min(Engine.stage.stageHeight/mainCombo.listItemHeight - 7, value.length));
			mainCombo.selectedIndex = Math.min(selectedIndex, value.length - 1);
		}
		
		override protected function build():void 
		{
			mainCombo = new ComboBox(this);
			upButton = new IconPushButton(this, 0, 0, "", new Assets.Up, upButton_Click);
			downButton = new IconPushButton(this, 0, 0, "", new Assets.Down, downButton_Click);
			addButton = new IconPushButton(this, 0, 0, "Add", new Assets.Add, addButton_Click);
			removeButton = new IconPushButton(this, 0, 0, "Delete", new Assets.Remove, removeButton_Click);
			editButton = new IconPushButton(this, 0, 0, "Edit", new Assets.Open, editButton_Click);
		}
		
		override protected function addListeners():void 
		{
			mainCombo.addEventListener(Event.SELECT, mainCombo_Select);
		}
		
		override protected function initialize():void 
		{
			mainCombo.autoHideScrollBar = true;
		}
		
		override protected function onResize():void 
		{
			addButton.setSize(int(_width / 2) + 1, 22);
			addButton.move(0, 0);
			removeButton.setSize(addButton.width, 22);
			removeButton.move(addButton.right, addButton.y);
			
			upButton.setSize(22, 12);
			upButton.move(0, addButton.bottom);
			downButton.setSize(22, 11);
			downButton.move(upButton.x, upButton.bottom);
			
			mainCombo.setSize(_width - upButton.width + 2, 22);
			mainCombo.move(upButton.right, addButton.bottom);
			
			editButton.setSize(_width + 1, 22);
			editButton.move(0, mainCombo.bottom);
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ UI input event listeners
		
		/**
		 * Event handler for clicking add object button.
		 */
		protected function addButton_Click(e:Event):void 
		{
		}
		
		/**
		 * Event handler for clicking remove object button.
		 */
		protected function removeButton_Click(e:Event):void 
		{
		}
		
		/**
		 * Event handler for clicking add object button.
		 */
		protected function upButton_Click(e:Event):void 
		{
		}
		
		/**
		 * Event handler for clicking remove object button.
		 */
		protected function downButton_Click(e:Event):void 
		{
		}
		
		/**
		 * Event handler for clicking remove object button.
		 */
		protected function editButton_Click(e:Event):void 
		{
		}
		
		/**
		 * Event handle for selecting item in Graphic list.
		 */
		protected function mainCombo_Select(e:Event):void
		{
		}
		
		//} UI input event listeners
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	}
}