/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import gamecheetah.designer.bit101.components.*;
	import flash.display.DisplayObjectContainer;
	import flash.events.*;
	import flash.geom.Point;
	import gamecheetah.*;
	import gamecheetah.designer.Designer;
	import gamecheetah.designer.views.Assets;
	import gamecheetah.designer.views.components.*;
	
	/**
	 * Manages changing, updating data for Entity objects.
	 * @private
	 */
	public class EntityEditorView extends InterfaceGroup
	{
		protected var
			window:DialogWindow,
			tagLabel:Label, tagInput:InputText,
			propertyCombo:ComboBox, editPropertyButton:IconPushButton,
			depthLabel:Label, depthInput:TypedInput,
			deleteEntityButton:IconPushButton;
		
		
		public function get selectedEntity():Entity 
		{
			return _selectedEntity;
		}
		public function set selectedEntity(value:Entity):void 
		{
			if (value == null)
			{
				// No entity selected.
				this.hide();
				return;
			}
			_selectedEntity = value;
			tagInput.text = _selectedEntity.tag;
			depthInput.text = _selectedEntity.depth.toString();
			//propertyCombo.items = _selectedEntity.properties;
			
			// Display edit entity window.
			var screenPosition:Point = value.location.subtract(value.space.camera);
			this.display(screenPosition);
		}
		private var _selectedEntity:Entity;
		
		
		public function EntityEditorView(parent:DisplayObjectContainer) 
		{
			super(parent);
		}
		
		public function display(pos:Point):void 
		{
			window.x = pos.x - window.width / 2;;
			window.y = pos.y - window.height;
			window.display();
		}
		
		public function hide():void 
		{
			window.hide();
		}
		
		override protected function build():void 
		{
			window = new DialogWindow(this, 0, 0, "Entity Editor");
			tagInput = new InputText(window.content, 0, 0, "", tagInput_Change);
			tagLabel = new Label(window.content, 0, 0, "Tag");
			depthInput = new TypedInput(window.content, 0, 0, TypedInput.TYPE_INTEGER, depthInput_Change);
			depthLabel = new Label(window.content, 0, 0, "Depth");
			//propertyCombo = new ComboBox(window.content);
			//editPropertyButton = new IconPushButton(window.content, 0, 0, "Edit Property", new Assets.Open, editPropertyButton_Click);
			deleteEntityButton = new IconPushButton(window.content, 0, 0, "Delete Entity", new Assets.Remove, deleteButton_Click);
		}
		
		override protected function initialize():void 
		{
			Designer.model.bind("selectedEntity", this, true);
		}
		
		/*override protected function addListeners():void 
		{
			propertyCombo.addEventListener(Event.SELECT, propertyCombo_onSelect);
		}*/
		
		override protected function onResize():void 
		{
			window.setSize(180, 60);
			
			deleteEntityButton.setSize(window.width, 22);
			deleteEntityButton.move(0, 0);
			
			tagInput.move(deleteEntityButton.x, deleteEntityButton.bottom);
			tagInput.setSize(window.width / 2 + 1, 22);
			tagLabel.move(tagInput.right - tagLabel.width - 3, tagInput.y + 3);
			
			depthInput.setSize(tagInput.width-1, 22);
			depthInput.move(tagInput.right, tagInput.y);
			depthLabel.move(depthInput.right - depthLabel.width - 3, depthInput.y + 3);
			
			/*propertyCombo.setSize(window.width + 1, 22);
			propertyCombo.move(tagInput.x, tagInput.bottom);
			editPropertyButton.setSize(propertyCombo.width, 22);
			editPropertyButton.move(propertyCombo.x, propertyCombo.bottom);*/
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ UI input event listeners
		
		/**
		 * Handles when an item is selected in propertyCombo.
		 */
		/*private function propertyCombo_onSelect(e:Event):void 
		{
			MainView.propertyPrompt.hide();
		}*/
		
		/**
		 * Handles when the set property button is clicked. TODO: Not implemented.
		 */
		/*private function editPropertyButton_Click(e:Event):void 
		{
			if (propertyCombo.selectedIndex != -1)
			{
				MainView.propertyPrompt.display();
				MainView.propertyPrompt.bind(propertyCombo.selectedItem as String, _selectedEntity);
			}
		}*/
		
		/**
		 * Handles when the delete entity button is clicked.
		 */
		private function deleteButton_Click(e:Event):void 
		{
			Designer.removeEntity();
			//MainView.propertyPrompt.hide();
		}
		
		private function tagInput_Change(e:Event):void 
		{
			Designer.changeEntityTag(tagInput.text);
		}
		
		private function depthInput_Change(e:Event):void 
		{
			if (Designer.model.selectedEntity != null)
				Designer.model.selectedEntity.depth = depthInput.value;
		}
		
		//} UI input event listeners
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	}


}