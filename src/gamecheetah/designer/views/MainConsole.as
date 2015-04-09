/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import gamecheetah.designer.components.*;
	import gamecheetah.*;
	import gamecheetah.designer.Designer;
	import gamecheetah.namespaces.hidden;
	
	use namespace hidden;
	
	public class MainConsole extends BaseComponent 
	{
		private var
			_graphicConsole:GraphicConsole,
			_spaceConsole:SpaceConsole,
			_playConsole:PlayConsole,
			_spaceCanvas:SpaceCanvas;
			
		private var
			_loadBtn:IconButton, _saveBtn:IconButton,
			_graphicsBtn:IconButton, _spacesBtn:IconButton, _settingsBtn:IconButton, _newEntityBtn:IconButton,
			_graphicsList:List, _spacesList:List,
			_addGraphicBtn:IconButton, _addSpaceBtn:IconButton,
			_editGraphicBtn:IconButton, _editSpaceBtn:IconButton,
			_openSpaceBtn:IconButton,
			_errorLbl:Label,
			_gridWidthInput:TextInput, _gridHeightInput:TextInput, _snapToGridBtn:IconToggleButton;
		
		//{ ------------------------------------ Property bindings ------------------------------------
		
		public function get spacesList():Array { return null; }
		public function set spacesList(value:Array):void 
		{
			_spacesList.items = value;
		}
		
		public function get graphicsList():Array { return null; }
		public function set graphicsList(value:Array):void 
		{
			_graphicsList.items = value;
		}
		
		public function get activeSpace():Space { return null; }
		public function set activeSpace(value:Space):void 
		{
			var spaceContext:Object = Designer.getDesignerContextSetting("SPACE::" + Engine.space.tag);
			if (spaceContext)
			{
				_gridWidthInput.text = spaceContext["gridW"];
				_gridHeightInput.text = spaceContext["gridH"];
				_snapToGridBtn.selected = _spaceCanvas.gridSnapping = spaceContext["gridSnapping"];
			}
			else
			{
				// Defaults
				_gridWidthInput.text = "1";
				_gridHeightInput.text = "1";
				_snapToGridBtn.selected = false;
			}
		}
		
		public function get selectedGraphic():Graphic { return null; }
		public function set selectedGraphic(value:Graphic):void 
		{
			if (value && value._frameImages.length > 0)
			{
				_newEntityBtn.setIcon(Assets.ADD);
				_newEntityBtn.hint = "New Entity";
			}
			else
			{
				_newEntityBtn.setIcon(Assets.MISSING);
				_newEntityBtn.hint = "Disabled";
			}
		}
		
		public function get errorMessage():String { return null; }
		public function set errorMessage(value:String):void 
		{
			if (value)
			{
				_errorLbl.tweenClip(null, { "alpha": 1 }, 0.5, null, 0, null, _errorLbl.tweenClip, [null, {"alpha": 0}, 0.5, null, 2.5]);
				_errorLbl.text = value;
				_errorLbl.padding = 15;
				Style.drawBaseRect(_errorLbl.graphics, -5, 0, _errorLbl.width + 10, _errorLbl.height, Style.HINT_BASE, Style.HINT_ALPHA, false);
			}
			else _errorLbl.alpha = 0;
		}
		
		//}
		//{ ------------------------------------ Constructor ------------------------------------
			
		public function MainConsole(parent:DisplayObjectContainer) 
		{
			_graphicConsole = new GraphicConsole(null, this);
			_spaceConsole = new SpaceConsole(null, this);
			_playConsole = new PlayConsole(parent, this);
			_spaceCanvas = new SpaceCanvas(this);
			
			_gridWidthInput = new TextInput(this, 100, 25, gridWidthInput_Change, "Grid Width", TextInput.TYPE_UINT);
			_gridWidthInput.minimum = 1;
			_gridWidthInput.setHint("Grid Width", Label.ALIGN_LEFT);
			_gridHeightInput = new TextInput(this, 100, 25, gridHeightInput_Change, "Grid Height", TextInput.TYPE_UINT);
			_gridHeightInput.minimum = 1;
			_gridHeightInput.setHint("Grid Height", Label.ALIGN_LEFT);
			_snapToGridBtn = new IconToggleButton(this, Assets.UNSNAPPING, Assets.SNAPPING, snapToGridBtn_Click, "Snap", "Un-Snap", Label.ALIGN_RIGHT);
			
			_errorLbl = new Label(this, "", Style.FONT_BASE, Label.ALIGN_FREE);
			_errorLbl.alpha = 0;
			
			_loadBtn = new IconButton(this, Assets.LOAD, loadBtn_Click, "Load Data", Label.ALIGN_ABOVE);
			_saveBtn = new IconButton(this, Assets.SAVE, saveBtn_Click, "Save Data", Label.ALIGN_ABOVE);
			
			_graphicsBtn = new IconButton(this, Assets.GRAPHICS, graphicsBtn_Click, "Graphics", Label.ALIGN_BELOW);
			_spacesBtn = new IconButton(this, Assets.SPACES, spacesBtn_Click, "Spaces", Label.ALIGN_BELOW);
			_settingsBtn = new IconButton(this, Assets.SETTINGS, settingsBtn_Click, "Settings", Label.ALIGN_BELOW);
			_newEntityBtn = new IconButton(this, Assets.MISSING, newEntityBtn_Click, "Disabled", Label.ALIGN_BELOW);
			
			_graphicsList = new List(this, [], 8, 150, 25, graphicsList_Select, null, graphicsList_Delete, graphicsList_Swap, graphicsList_Edit);
			_spacesList = new List(this, [], 8, 150, 25, spacesList_Select, null, spacesList_Delete, spacesList_Swap, spacesList_Edit);
			
			_addGraphicBtn = new IconButton(this, Assets.ADD, addGraphicBtn_Click, "Add", Label.ALIGN_BELOW);
			_addSpaceBtn = new IconButton(this, Assets.ADD, addSpaceBtn_Click, "Add", Label.ALIGN_BELOW);
			_openSpaceBtn = new IconButton(this, Assets.OPEN, openSpaceBtn_Click, "Open", Label.ALIGN_BELOW);
			_editGraphicBtn = new IconButton(this, Assets.EDIT, editGraphicBtn_Click, "Edit", Label.ALIGN_BELOW);
			_editSpaceBtn = new IconButton(this, Assets.EDIT, editSpaceBtn_Click, "Edit", Label.ALIGN_BELOW);
			
			// Bind to properties
			Designer.model.bind("spacesList", this, true);
			Designer.model.bind("graphicsList", this, true);
			Designer.model.bind("activeSpace", this, true);
			Designer.model.bind("selectedGraphic", this, true);
			Designer.model.bind("errorMessage", this, true);
			
			super(parent);
		}
		
		public function removeConsoles():void 
		{
			if (this.parent) this.parent.removeChild(this);
			if (_spaceConsole.parent) _spaceConsole.parent.removeChild(_spaceConsole);
			if (_graphicConsole.parent) _graphicConsole.parent.removeChild(_graphicConsole);
		}
		
		//}
		//{ ------------------------------------ Behaviour Overrides ------------------------------------
		
		override public function onActivate():void 
		{
			this.parent.addChild(_playConsole);
			hideGraphicList();
			hideSpaceList();
			hideSettings();
			onUpdate();
		}
		
		override public function onUpdate():void 
		{
			var stageWidth:int = Engine.buffer.width;
			var stageHeight:int = Engine.buffer.height;
			
			_saveBtn.move(stageWidth * 0.367 - 16, stageHeight - 42);
			_loadBtn.move(stageWidth * 0.633 - 16, stageHeight - 42);
			
			_errorLbl.move(stageWidth * 0.5 - _errorLbl.halfWidth, stageHeight * 0.5 - _errorLbl.halfHeight);
			
			_spacesBtn.move(stageWidth * 0.1 - 16, 10);
			_spacesList.move(_spacesBtn.left, _spacesBtn.bottom + 30);
			_addSpaceBtn.move(_spacesList.left, _spacesList.bottom + 5);
			_openSpaceBtn.move(_spacesList.left + 42, _spacesList.bottom + 5);
			_editSpaceBtn.move(_spacesList.left + 84, _spacesList.bottom + 5);
			
			_graphicsBtn.move(stageWidth * 0.367 - 16, 10);
			_graphicsList.move(_graphicsBtn.left, _graphicsBtn.bottom + 30);
			_addGraphicBtn.move(_graphicsList.left, _graphicsList.bottom + 5);
			_editGraphicBtn.move(_graphicsList.left + 42, _graphicsList.bottom + 5);
			
			_settingsBtn.move(stageWidth * 0.633 - 16, 10);
			_gridWidthInput.move(_settingsBtn.left, _settingsBtn.bottom + 30);
			_gridHeightInput.move(_gridWidthInput.left, _gridWidthInput.bottom + 5);
			_snapToGridBtn.move(_gridHeightInput.left, _gridHeightInput.bottom + 5);
			
			_newEntityBtn.move(stageWidth * 0.9 - 16, 10);
		}
		
		//}
		//{ ------------------------------------ Component event handlers ------------------------------------
		
		private function graphicsList_Select(list:List, index:int):void 
		{
			Designer.selectGraphic(index);
		}
		
		private function spacesList_Select(list:List, index:int):void 
		{
			Designer.model.update("selectedSpace", Engine.assets.spaces.getAt(index), true);
		}
		
		private function spacesList_Swap(indexA:int, indexB:int):void 
		{
			var success:Boolean = Engine.assets.spaces.swap(indexA, indexB);
			if (success) Designer.model.update("spacesList", null, true);
		}
		
		private function spacesList_Edit(index:int, text:String):void 
		{
			var valid:Boolean = Designer.changeSpaceTag(index, text);
			
			if (valid) _spacesList.getListItem(index).editInput.setHint(null);
			else _spacesList.getListItem(index).editInput.setHint("Tag duplicated!", Label.ALIGN_RIGHT);
		}
		
		private function spacesList_Delete(index:int):void 
		{
			Designer.removeSpace(index);
		}
		
		private function graphicsList_Edit(index:int, text:String):void 
		{
			var valid:Boolean = Designer.changeGraphicTag(index, text);
			
			if (valid) _graphicsList.getListItem(index).editInput.setHint(null);
			else _graphicsList.getListItem(index).editInput.setHint("Tag duplicated!", Label.ALIGN_RIGHT);
		}
		
		private function graphicsList_Swap(indexA:int, indexB:int):void 
		{
			var success:Boolean = Engine.assets.graphics.swap(indexA, indexB);
			if (success) Designer.model.update("graphicsList", null, true);
		}
		
		private function graphicsList_Delete(index:int):void 
		{
			Designer.removeGraphic(index);
		}
		
		private function addSpaceBtn_Click(b:BaseButton):void 
		{
			Designer.addSpace();
		}
		
		private function addGraphicBtn_Click(b:BaseButton):void 
		{
			Designer.addGraphic();
		}
		
		private function openSpaceBtn_Click(b:BaseButton):void 
		{
			Designer.swapSpace();
		}
		
		private function editSpaceBtn_Click(b:BaseButton):void 
		{
			if (Designer.model.selectedSpace)
			{
				this.parent.addChild(_spaceConsole);
				this.parent.removeChild(this);
				_playConsole.bringToFront();
			}
		}
		
		private function editGraphicBtn_Click(b:BaseButton):void 
		{
			if (Designer.model.selectedGraphic)
			{
				this.parent.addChild(_graphicConsole);
				this.parent.removeChild(this);
				_playConsole.bringToFront();
			}
		}
		
		private function gridHeightInput_Change(b:BaseComponent, userTrigger:Boolean):void 
		{
			_spaceCanvas.gridH = _gridHeightInput.value;
			Designer.updateDesignerContext(getDesignerContext());
		}
		
		private function gridWidthInput_Change(b:BaseComponent, userTrigger:Boolean):void 
		{
			_spaceCanvas.gridW = _gridWidthInput.value;
			Designer.updateDesignerContext(getDesignerContext());
		}
		
		private function snapToGridBtn_Click(b:IconToggleButton):void 
		{
			_spaceCanvas.gridSnapping = _snapToGridBtn.selected;
			Designer.updateDesignerContext(getDesignerContext());
		}
		
		private function loadBtn_Click(b:BaseButton):void 
		{
			Designer.loadContext();
		}
		
		private function saveBtn_Click(b:BaseButton):void 
		{
			Designer.saveContext();
		}
		
		private function spacesBtn_Click(b:BaseButton):void 
		{
			if (!_spacesBtn.frozen)
			{
				_spacesBtn.freeze();
				_spacesList.show();
				_addSpaceBtn.show();
				_openSpaceBtn.show();
				_editSpaceBtn.show();
				hideGraphicList();
				hideSettings();
			}
			else hideSpaceList();
		}
		
		private function graphicsBtn_Click(b:BaseButton):void 
		{
			if (!_graphicsBtn.frozen)
			{
				_graphicsBtn.freeze();
				_graphicsList.show();
				_addGraphicBtn.show();
				_editGraphicBtn.show();
				hideSpaceList();
				hideSettings();
			}
			else hideGraphicList();
		}
		
		private function newEntityBtn_Click(b:BaseButton):void 
		{
			// Create new entity at the center of screen.
			Designer.addEntity(Engine.space.camera.x + Engine.buffer.width / 2, Engine.space.camera.y + Engine.buffer.height / 2);
		}
		
		private function settingsBtn_Click(b:BaseButton):void 
		{
			if (!_settingsBtn.frozen)
			{
				_settingsBtn.freeze();
				
				_gridHeightInput.show();
				_gridWidthInput.show();
				_snapToGridBtn.show();
				
				hideSpaceList();
				hideGraphicList()
			}
			else hideSettings();
		}
		
		private function hideSpaceList():void 
		{
			_spacesBtn.unfreeze();
			_spacesList.hide();
			_addSpaceBtn.hide();
			_openSpaceBtn.hide();
			_editSpaceBtn.hide();
		}
		
		private function hideGraphicList():void 
		{
			_graphicsBtn.unfreeze();
			_graphicsList.hide();
			_addGraphicBtn.hide();
			_editGraphicBtn.hide();
		}
		
		private function hideSettings():void 
		{
			_settingsBtn.unfreeze();
			_gridHeightInput.hide();
			_gridWidthInput.hide();
			_snapToGridBtn.hide();
		}
		//}
		
		private function getDesignerContext():Object 
		{
			var result:Object = {};
			result["SPACE::" + Engine.space.tag] = { "gridW": _spaceCanvas.gridW, "gridH": _spaceCanvas.gridH, "gridSnapping": _spaceCanvas.gridSnapping };
			return result;
		}
	}
}