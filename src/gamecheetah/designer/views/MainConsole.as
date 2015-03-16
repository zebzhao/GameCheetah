/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import flash.geom.Point;
	import gamecheetah.designer.components.*;
	import gamecheetah.*;
	import gamecheetah.designer.Designer;
	
	public class MainConsole extends Space 
	{
		private var
			_loadBtn:IconButton, _saveBtn:IconButton,
			_graphicsBtn:IconButton, _spacesBtn:IconButton,
			_graphicsList:List, _spacesList:List,
			_addGraphicBtn:IconButton, _addSpaceBtn:IconButton,
			_editGraphicBtn:IconButton, _editSpaceBtn:IconButton;
		
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
		
		//}
		//{ ------------------------------------ Constructor ------------------------------------
			
		public function MainConsole():void 
		{
			_loadBtn = new IconButton(this, Assets.LOAD, loadBtn_Click, "Load Data", Label.ALIGN_LEFT);
			_saveBtn = new IconButton(this, Assets.SAVE, saveBtn_Click, "Save Data", Label.ALIGN_LEFT);
			_graphicsBtn = new IconButton(this, Assets.GRAPHICS, graphicsBtn_Click, "Graphics", Label.ALIGN_RIGHT);
			_spacesBtn = new IconButton(this, Assets.SPACES, spacesBtn_Click, "Spaces", Label.ALIGN_RIGHT);
			_graphicsList = new List(this, [], 8, 150, 25, graphicsList_Select, graphicsList_Delete, graphicsList_Swap);
			_spacesList = new List(this, [], 8, 150, 25, spacesList_Select, spacesList_Delete, spacesList_Swap);
			_addGraphicBtn = new IconButton(this, Assets.ADD, addGraphicBtn_Click, "Add", Label.ALIGN_BELOW);
			_addSpaceBtn = new IconButton(this, Assets.ADD, addSpaceBtn_Click, "Add", Label.ALIGN_BELOW);
			_editGraphicBtn = new IconButton(this, Assets.EDIT, editGraphicBtn_Click, "Edit", Label.ALIGN_BELOW);
			_editSpaceBtn = new IconButton(this, Assets.EDIT, editSpaceBtn_Click, "Edit", Label.ALIGN_BELOW);
			
			// Bind to properties
			Designer.model.bind("spacesList", this, true);
			Designer.model.bind("graphicsList", this, true);
		}
		
		//}
		//{ ------------------------------------ Behaviour Overrides ------------------------------------
		
		override public function onEnter():void 
		{
			this.mouseEnabled = true;
			_graphicsList.hide();
			_spacesList.hide();
			_addGraphicBtn.hide();
			_addSpaceBtn.hide();
			_editGraphicBtn.hide();
			_editSpaceBtn.hide();
		}
		
		override public function onUpdate():void 
		{
			_saveBtn.move(Engine.stage.stageWidth - 42, 10);
			_loadBtn.move(Engine.stage.stageWidth - 42, 52);
			
			_spacesBtn.move(10, 10);
			_spacesBtn.setDepth(10);
			_spacesList.move(52, _spacesBtn.bottom - 3);
			_addSpaceBtn.move(_spacesList.left + 80, _spacesList.bottom + 5);
			_editSpaceBtn.move(_spacesList.left + 122, _spacesList.bottom + 5);
			
			_graphicsBtn.move(10, 52);
			_graphicsBtn.setDepth(10);
			_graphicsList.move(52, _graphicsBtn.bottom - 3);
			_addGraphicBtn.move(_graphicsList.left + 80, _graphicsList.bottom + 5);
			_editGraphicBtn.move(_graphicsList.left + 122, _graphicsList.bottom + 5);
		}
		
		//}
		//{ ------------------------------------ Event handlers ------------------------------------
		
		private function graphicsList_Select(index:int):void 
		{
		}
		
		private function spacesList_Select(index:int):void 
		{
		}
		
		private function spacesList_Swap(indexA:int, indexB:int):void 
		{
			var success:Boolean = Engine.assets.spaces.swap(indexA, indexB);
			if (success) Designer.model.update("spacesList", null, true);
		}
		
		private function spacesList_Delete(index:int):void 
		{
			Designer.removeSpace(index);
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
		
		private function editSpaceBtn_Click(b:BaseButton):void 
		{
			
		}
		
		private function editGraphicBtn_Click(b:BaseButton):void 
		{
			
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
				_editSpaceBtn.show();
				hideGraphicList();
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
			}
			else hideGraphicList();
		}
		
		private function hideSpaceList():void 
		{
			_spacesBtn.unfreeze();
			_spacesList.hide();
			_addSpaceBtn.hide();
			_editSpaceBtn.hide();
		}
		
		private function hideGraphicList():void 
		{
			_graphicsBtn.unfreeze();
			_graphicsList.hide();
			_addGraphicBtn.hide();
			_editGraphicBtn.hide();
		}
		//}
	}
}