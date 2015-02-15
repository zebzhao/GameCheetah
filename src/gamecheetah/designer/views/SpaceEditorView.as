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
	import flash.events.Event;
	import gamecheetah.Space;
	import gamecheetah.Engine;
	import gamecheetah.designer.*;
	import gamecheetah.designer.views.Assets;
	import gamecheetah.designer.views.components.*;
	import gamecheetah.namespaces.hidden;
	
	use namespace hidden;
	
	/**
	 * Manages changing, updating data for Space objects.
	 * @private
	 */
	public class SpaceEditorView extends InterfaceGroup
	{
		private var
			window:DialogWindow,
			tagLabel:Label, tagInput:InputText,
			classCombo:ComboBox,
			xLabel:Label, yLabel:Label,
			widthLabel:Label, heightLabel:Label,
			xInput:TypedInput, yInput:TypedInput,
			widthInput:TypedInput, heightInput:TypedInput,
			sxInput:TypedInput, syInput:TypedInput,
			sxLabel:Label, syLabel:Label,
			mouseEnabledButton:IconPushButton,
			openButton:IconPushButton,
			autoSizeButton:IconPushButton;
		
		
		public function get selectedSpace():Space
		{
			return _selectedSpace;
		}
		public function set selectedSpace(value:Space):void 
		{
			if (value == null) return;
			
			_selectedSpace = value;
			tagInput.text = _selectedSpace.tag;
			widthInput.text = _selectedSpace.bounds.width.toString();
			heightInput.text = _selectedSpace.bounds.height.toString();
			xInput.text = _selectedSpace.bounds.x.toString();
			yInput.text = _selectedSpace.bounds.y.toString();
			sxInput.text = _selectedSpace.startLocation.x.toString();
			syInput.text = _selectedSpace.startLocation.y.toString();
			mouseEnabledButton.selected = _selectedSpace.mouseEnabled;
			classCombo.selectedIndex = classCombo.items.indexOf(Object(_selectedSpace).constructor);
		}
		private var _selectedSpace:Space;
		
		
		public function SpaceEditorView(parent:DisplayObjectContainer) 
		{
			super(parent);
		}
		
		public function display():void 
		{
			window.display();
		}
		
		public function hide():void 
		{
			window.hide();
		}
		
		override protected function build():void 
		{
			window = new DialogWindow(this, 0, 0, "Space Editor");
			tagInput = new InputText(window.content, 0, 0, "", tagInput_Change);
			tagLabel = new Label(window.content, 0, 0, "Tag");
			classCombo = new ComboBox(window.content);
			
			mouseEnabledButton = new IconPushButton(window.content, 0, 0, "Mouse Enabled", new Assets.MouseEnabled, defaultButton_Click);
			openButton = new IconPushButton(window.content, 0, 0, "Open", new Assets.Open, openButton_Click);
			sxInput = new TypedInput(window.content, 0, 0, TypedInput.TYPE_INTEGER);
			syInput = new TypedInput(window.content, 0, 0, TypedInput.TYPE_INTEGER);
			sxLabel = new Label(window.content, 0, 0, "SX");
			syLabel = new Label(window.content, 0, 0, "SY");
			
			xInput = new TypedInput(window.content, 0, 0, TypedInput.TYPE_INTEGER, xInput_Change);
			yInput = new TypedInput(window.content, 0, 0, TypedInput.TYPE_INTEGER, yInput_Change);
			widthInput = new TypedInput(window.content, 0, 0, TypedInput.TYPE_INTEGER, widthInput_Change);
			heightInput = new TypedInput(window.content, 0, 0, TypedInput.TYPE_INTEGER, heightInput_Change);
			autoSizeButton = new IconPushButton(window.content, 0, 0, "Auto-Scale", new Assets.AutoScale);
			
			xLabel = new Label(window.content, 0, 0, "X");
			yLabel = new Label(window.content, 0, 0, "Y");
			widthLabel = new Label(window.content, 0, 0, "W");
			heightLabel = new Label(window.content, 0, 0, "H");
		}
		
		override protected function initialize():void 
		{
			classCombo.items = Engine.__spaceClasses;
			widthInput.minimum = heightInput.minimum = 1;
			mouseEnabledButton.toggle = true;
			tagInput.textField.background = true;
			tagInput.textField.backgroundColor = Style.BACKGROUND;
			Designer.model.bind("selectedSpace", this, true);
		}
		
		override protected function addListeners():void 
		{
			classCombo.addEventListener(Event.SELECT, classCombo_onSelect);
		}
		
		override protected function onResize():void 
		{
			window.setSize(180, 190);
			
			tagInput.setSize(window.width, 22);
			tagLabel.move(tagInput.right - tagLabel.width - 3, tagInput.y + 3);
			
			classCombo.setSize(tagInput.width + 1, 22);
			classCombo.move(0, tagInput.bottom);
			
			openButton.setSize(tagInput.width + 1, 22);
			openButton.move(0, classCombo.bottom);
			
			xInput.setSize(window.width / 2 + 1, 22);
			xInput.move(openButton.x, openButton.bottom);
			xLabel.move(xInput.right - xLabel.width - 3, xInput.y + 3);
			yInput.setSize(xInput.width, 22);
			yInput.move(xInput.right, xInput.y);
			yLabel.move(yInput.right - yLabel.width - 3, yInput.y + 3);
			
			widthInput.setSize(xInput.width, 22);
			widthInput.move(xInput.x, xInput.bottom);
			widthLabel.move(widthInput.right - widthLabel.width - 3, widthInput.y + 3);
			heightInput.setSize(yInput.width, 22);
			heightInput.move(yInput.x, yInput.bottom);
			heightLabel.move(heightInput.right - heightLabel.width - 3, heightInput.y + 3);
			
			autoSizeButton.setSize(openButton.width, 22);
			autoSizeButton.move(widthInput.x, widthInput.bottom);
			mouseEnabledButton.setSize(autoSizeButton.width, 22);
			mouseEnabledButton.move(autoSizeButton.x, autoSizeButton.bottom);
			
			sxInput.setSize(xInput.width, 22);
			sxInput.move(xInput.x, mouseEnabledButton.bottom);
			sxLabel.move(sxInput.right - sxLabel.width - 3, sxInput.y + 3);
			syInput.setSize(yInput.width, 22);
			syInput.move(yInput.x, sxInput.y);
			syLabel.move(syInput.right - syLabel.width - 3, syInput.y + 3);
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ UI input event listeners
		
		private function tagInput_Change(e:Event):void 
		{
			var success:Boolean = Designer.changeSpaceTag(tagInput.text);
			if (!success) tagInput.textField.backgroundColor = 0xFFCCCC;
			else tagInput.textField.backgroundColor = Style.BACKGROUND;
		}
		
		private function xInput_Change(e:Event):void 
		{
			_selectedSpace._bounds.x = xInput.value as int;
			_selectedSpace.updateSize();
			Designer.updateScrollBounds();
		}
		
		private function yInput_Change(e:Event):void 
		{
			_selectedSpace._bounds.y = xInput.value as int;
			_selectedSpace.updateSize();
			Designer.updateScrollBounds();
		}
		
		private function widthInput_Change(e:Event):void 
		{
			_selectedSpace._bounds.width = widthInput.value as int;
			_selectedSpace.updateSize();
			Designer.updateScrollBounds();
		}
		
		private function heightInput_Change(e:Event):void 
		{
			_selectedSpace._bounds.height = heightInput.value as int;
			_selectedSpace.updateSize();
			Designer.updateScrollBounds();
		}
		
		private function defaultButton_Click(e:Event):void 
		{
			_selectedSpace.mouseEnabled = mouseEnabledButton.selected;
		}
		
		private function openButton_Click(e:Event):void 
		{
			Designer.swapSpace();
		}
		
		private function classCombo_onSelect(e:Event):void 
		{
			if (classCombo.selectedItem == null || String(Object(_selectedSpace).constructor) == String(classCombo.selectedItem))
			{
				return;
			}
			else
			{
				MainView.errorWindow.displayPrompt("Are you sure? Changing the class will recreate the space.", "Change space class");
				MainView.errorWindow.addEventListener(AlertWindow.EVENT_YES, spaceClass_Change);
				MainView.errorWindow.addEventListener(AlertWindow.EVENT_NO, updateSpaceClass);
			}
		}
		
		private function spaceClass_Change(e:Event):void 
		{
			if (_selectedSpace != null && classCombo.selectedItem != null)
			{
				Designer.castSpaceAs(classCombo.selectedItem as Class);
			}
		}
		
		private function updateSpaceClass(e:Event):void 
		{
			if (_selectedSpace != null)
				classCombo.selectedIndex = classCombo.items.indexOf(Object(_selectedSpace).constructor);
		}
		
		//} UI input event listeners
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	}


}