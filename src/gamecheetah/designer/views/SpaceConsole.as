/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import flash.display.DisplayObjectContainer;
	import gamecheetah.designer.components.*;
	import gamecheetah.*;
	import gamecheetah.namespaces.hidden;
	import gamecheetah.designer.*;
	
	use namespace hidden;
	
	public class SpaceConsole extends BaseComponent 
	{
		private var
			_main:MainConsole;
			
		private var
			_backBtn:IconButton, _classesBtn:IconButton, _startLocationBtn:IconButton, _boundsBtn:IconButton,
			_classesList:List, _startLocationList:List,
			_xInput:TextInput, _yInput:TextInput,
			_widthInput:TextInput, _heightInput:TextInput,
			_sxInput:TextInput, _syInput:TextInput,
			_mouseEnabledBtn:IconButton, _autoSizeBtn:IconButton;
			
			
		public function get selectedSpace():Space { return null };
		public function set selectedSpace(value:Space):void 
		{
			if (!value) return;
			
			// Select class
			_classesList.selectItem(Engine.__spaceClasses.indexOf(Object(value).constructor || Space));
			
			_widthInput.text = value.bounds.width.toString();
			_heightInput.text = value.bounds.height.toString();
			_xInput.text = value.bounds.x.toString();
			_yInput.text = value.bounds.y.toString();
			_sxInput.text = int(value.startLocation.x).toString();
			_syInput.text = int(value.startLocation.y).toString();
			if (value.mouseEnabled) _mouseEnabledBtn.freeze();
			
			else _mouseEnabledBtn.unfreeze();
		}
		
		public function SpaceConsole(parent:DisplayObjectContainer, main:MainConsole) 
		{
			_main = main;
			
			_backBtn = new IconButton(this, Assets.EXIT, backBtn_Click, "Back", Label.ALIGN_BELOW);
			_classesBtn = new IconButton(this, Assets.CLASSES, classesBtn_Click, "Classes", Label.ALIGN_BELOW);
			_startLocationBtn = new IconButton(this, Assets.START_LOCATION, startLocationBtn_Click, "Start Location", Label.ALIGN_BELOW);
			_boundsBtn = new IconButton(this, Assets.SPACE_DIM, boundsBtn_Click, "Bounds", Label.ALIGN_BELOW);
			_autoSizeBtn = new IconButton(this, Assets.AUTOSIZE, autoSizeBtn_Click, "AutoSize", Label.ALIGN_ABOVE);
			_mouseEnabledBtn = new IconButton(this, Assets.MOUSE, mouseEnabledBtn_Click, "Mouse\nEnabled", Label.ALIGN_ABOVE);
			
			_classesList = new List(this, Engine.__spaceClasses, 8, 150, 25, classesList_Select, null, null, null, null, false, false, false);
			_startLocationList = new List(this, ["", ""], 2, 100, 25, startLocationList_Select, null, null, null, null, false, false, false);
			
			_startLocationList.getListItem(0).editable = true;
			_startLocationList.getListItem(1).editable = true;
			_sxInput = _startLocationList.getListItem(0).editInput;
			_syInput = _startLocationList.getListItem(1).editInput;
			_sxInput.type = TextInput.TYPE_INT;
			_syInput.type = TextInput.TYPE_INT;
			_sxInput.placeholder = "Start-X";
			_syInput.placeholder = "Start-Y";
			_sxInput.onChange = sxInput_Change;
			_syInput.onChange = syInput_Change;
			_sxInput.setHint("Start-Location X", Label.ALIGN_LEFT);
			_syInput.setHint("Start-Location Y", Label.ALIGN_LEFT);
			
			_xInput = new TextInput(this, 100, 25, xInput_Change, "Left", TextInput.TYPE_INT);
			_xInput.setHint("Bound-Left", Label.ALIGN_LEFT);
			_yInput = new TextInput(this, 100, 25, yInput_Change, "Top", TextInput.TYPE_INT);
			_yInput.setHint("Bound-Top", Label.ALIGN_LEFT);
			_widthInput = new TextInput(this, 100, 25, widthInput_Change, "Width", TextInput.TYPE_UINT);
			_widthInput.setHint("Bound-Width", Label.ALIGN_RIGHT);
			_heightInput = new TextInput(this, 100, 25, heightInput_Change, "Height", TextInput.TYPE_UINT);
			_heightInput.setHint("Bound-Height", Label.ALIGN_RIGHT);
			
			super(parent);
			
			Designer.model.bind("selectedSpace", this, true);
		}
		
		override public function onActivate():void 
		{
			hideBounds();
			hideClassesList();
			hideStartLocationList();
		}
		
		override public function onUpdate():void 
		{
			var stageWidth:int = Engine.buffer.width;
			var stageHeight:int = Engine.buffer.height;
			
			_classesBtn.move(stageWidth * 0.1 - 16, 10);
			_boundsBtn.move(stageWidth * 0.367 - 16, 10);
			_startLocationBtn.move(stageWidth * 0.633 - 16, 10);
			_backBtn.move(stageWidth * 0.9 - 16, 10);
			_autoSizeBtn.move(stageWidth * 0.367 - 16, stageHeight - 42);
			_mouseEnabledBtn.move(stageWidth * 0.633 - 16, stageHeight - 42);
			
			_classesList.move(_classesBtn.left, _classesBtn.bottom + 30);
			_startLocationList.move(_startLocationBtn.left, _startLocationBtn.bottom + 30);
			
			_xInput.move(_boundsBtn.left, _boundsBtn.bottom + 30);
			_yInput.move(_xInput.left, _xInput.bottom + 1);
			_widthInput.move(_yInput.left, _yInput.bottom + 5);
			_heightInput.move(_widthInput.left, _widthInput.bottom + 1);
		}
		
		private function classesBtn_Click(b:BaseButton):void 
		{
			if (!_classesBtn.frozen)
			{
				_classesBtn.freeze();
				_classesList.show();
				hideBounds();
				hideStartLocationList();
			}
			else hideClassesList();
		}
		
		private function startLocationBtn_Click(b:BaseButton):void 
		{
			if (!_startLocationBtn.frozen)
			{
				_startLocationBtn.freeze();
				_startLocationList.show();
				hideBounds();
				hideClassesList();
			}
			else hideStartLocationList();
		}
		
		private function boundsBtn_Click(b:BaseButton):void 
		{
			if (!_boundsBtn.frozen)
			{
				_boundsBtn.freeze();
				_xInput.show();
				_yInput.show();
				_widthInput.show();
				_heightInput.show();
				hideStartLocationList();
				hideClassesList();
			}
			else hideBounds();
		}
		
		private function syInput_Change(t:TextInput):void 
		{
			_startLocationList.items[1] = t.text;
			Designer.model.selectedSpace.startLocation.y = _syInput.value as int;
		}
		
		private function sxInput_Change(t:TextInput):void 
		{
			_startLocationList.items[0] = t.text;
			Designer.model.selectedSpace.startLocation.x = _sxInput.value as int;
		}
		
		private function heightInput_Change(t:TextInput):void 
		{
			Designer.model.selectedSpace.bounds.height = _heightInput.value as int;
			Designer.model.selectedSpace.reindexQuadtree();
			Designer.updateScrollBounds();
		}
		
		private function widthInput_Change(t:TextInput):void 
		{
			Designer.model.selectedSpace.bounds.width = _widthInput.value as int;
			Designer.model.selectedSpace.reindexQuadtree();
			Designer.updateScrollBounds();
		}
		
		private function yInput_Change(t:TextInput):void 
		{
			Designer.model.selectedSpace.bounds.y = _yInput.value as int;
			Designer.model.selectedSpace.reindexQuadtree();
			Designer.updateScrollBounds();
		}
		
		private function xInput_Change(t:TextInput):void 
		{
			Designer.model.selectedSpace.bounds.x = _xInput.value as int;
			Designer.model.selectedSpace.reindexQuadtree();
			Designer.updateScrollBounds();
		}
		
		private function mouseEnabledBtn_Click(b:IconButton):void 
		{
			if (_mouseEnabledBtn.frozen) _mouseEnabledBtn.unfreeze();
			else _mouseEnabledBtn.freeze();
			Designer.model.selectedSpace.mouseEnabled = _mouseEnabledBtn.frozen;
		}
		
		private function autoSizeBtn_Click(b:IconButton):void 
		{
			Designer.model.selectedSpace.autoSize();
			Designer.model.update("selectedSpace", Designer.model.selectedSpace, true);
		}
		
		private function backBtn_Click(b:BaseButton):void 
		{
			this.parent.addChild(_main);
			this.parent.removeChild(this);
		}
		
		private function classesList_Select(list:List, index:int):void 
		{
			Designer.castSpaceAs(Engine.__spaceClasses[index] as Class);
		}
		
		private function startLocationList_Select(list:List, index:int):void 
		{
			list.deselectItem(index);
		}
		
		private function hideClassesList():void 
		{
			_classesBtn.unfreeze();
			_classesList.hide();
		}
		
		private function hideStartLocationList():void 
		{
			_startLocationBtn.unfreeze();
			_startLocationList.hide();
		}
		
		private function hideBounds():void 
		{
			_boundsBtn.unfreeze();
			_xInput.hide();
			_yInput.hide();
			_widthInput.hide();
			_heightInput.hide();
		}
	}

}