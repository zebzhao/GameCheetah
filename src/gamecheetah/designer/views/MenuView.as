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
	import gamecheetah.*;
	import gamecheetah.designer.*;
	import gamecheetah.designer.views.components.*;

	/**
	 * @author 		Zeb Zhao (Zeb Zhao)
	 * @version		1.0
	 * @private
	 */
	public class MenuView extends InterfaceGroup
	{
		private var
			accordian:Accordion,
			gameMenu:GameMenu, spaceMenu:SpaceMenu, graphicMenu:GraphicMenu;
			
			
		public function MenuView(parent:DisplayObjectContainer=null) 
		{
			super(parent);
		}
		
		override protected function build():void 
		{
			gameMenu = new GameMenu();
			spaceMenu = new SpaceMenu();
			graphicMenu = new GraphicMenu();
			
			// Create windows
			accordian = new Accordion(this);
			accordian.addWindow("Game Cheetah");
			accordian.addWindow("Graphics");
			accordian.addWindow("Spaces");
			
			accordian.getWindowAt(0).addChild(gameMenu);
			accordian.getWindowAt(1).addChild(graphicMenu);
			accordian.getWindowAt(2).addChild(spaceMenu);
		}
		
		/**
		 * Construct layout of UI components.
		 */
		override protected function onResize():void 
		{
			accordian.setSize(150, 122);
			accordian.move(0, 0);
			
			graphicMenu.setSize(150, 1);
			spaceMenu.setSize(150, 1);
			gameMenu.setSize(150, 1);
		}
	}
}

import gamecheetah.designer.bit101.components.*;
import flash.display.*;
import flash.events.*;
import flash.utils.getTimer;
import gamecheetah.*;
import gamecheetah.designer.*;
import gamecheetah.designer.views.*;
import gamecheetah.designer.views.components.*;
import gamecheetah.gameutils.Input;
import gamecheetah.gameutils.Scroller;
import gamecheetah.graphics.*;
import gamecheetah.namespaces.*;

use namespace hidden;

//===============================================================================================================================================
//{ Menu Panels

/**
 * File Menu UI manages loading, saving Graphic, Space object data.
 */
class GameMenu extends InterfaceGroup
{
	private var
		saveButton:IconPushButton, loadButton:IconPushButton,
		cameraXLabel:Label, cameraYLabel:Label,
		cameraXInput:TypedInput, cameraYInput:TypedInput,
		infoButton:PushButton;
	
	// Track the # of frames since the last second.
	private var
		_state:uint,
		_framesElapsed:uint,
		_time:Number = 0,
		_fps:String = "";
	
	override protected function build():void 
	{
		infoButton = new PushButton(this, 0, 0, "FPS: ", infoButton_Click);
		cameraXInput = new TypedInput(this, 0, 0, TypedInput.TYPE_INTEGER);
		cameraYInput = new TypedInput(this, 0, 0, TypedInput.TYPE_INTEGER);
		cameraXLabel = new Label(this, 0, 0, "X");
		cameraYLabel = new Label(this, 0, 0, "Y");
		saveButton = new IconPushButton(this, 0, 0, "Save", new Assets.Save, save_Click);
		loadButton = new IconPushButton(this, 0, 0, "Open", new Assets.Load, load_Click);
	}
	
	override protected function onResize():void 
	{
		infoButton.setSize(_width + 1, 22);
		infoButton.move(0, 0);
		
		cameraXInput.setSize(_width / 2 + 1, 22);
		cameraXInput.move(0, infoButton.bottom);
		cameraXLabel.move(cameraXInput.right - 15, cameraXInput.y + 3);
		
		cameraYInput.setSize(cameraXInput.width, 22);
		cameraYInput.move(cameraXInput.right, cameraXInput.y);
		cameraYLabel.move(cameraYInput.right - 15, cameraXInput.y + 3);
		
		saveButton.setSize(_width / 2 + 1, 22);
		saveButton.move(0, cameraYInput.bottom);
		loadButton.setSize(saveButton.width, 22);
		loadButton.move(saveButton.right, saveButton.y);
	}
	
	override protected function initialize():void 
	{
		cameraXInput.text = int(Engine.space.camera.x).toString();
		cameraYInput.text = int(Engine.space.camera.y).toString();
	}
	
	override protected function addListeners():void 
	{
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		Input.dispatcher.addEventListener(Input.events.E_ENTER_PRESSED, onEnterPressed);
		Designer.scroller.addEventListener(Scroller.events.E_MOVE, scroller_Move);
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//{ UI input event listeners
	
	private function onEnterFrame(e:Event):void 
	{
		var currentTime:Number = getTimer();
		var elapsed:Number = currentTime - _time;
		if (elapsed >= 1000)
		{
			_time = currentTime;
			_fps = String(Math.round(_framesElapsed * 1000 / elapsed));
			_framesElapsed = 1;
		}
		else _framesElapsed ++;
		
		if (_state == 0)
			infoButton.label = "FPS: " + _fps;
		else if (_state == 1)
			infoButton.label = "On-Screen: " + Engine.space.onScreenCount.toString() + " / " + Engine.space.totalEntities;
	}
	
	private function scroller_Move(e:Event):void 
	{
		cameraXInput.text = int(Engine.space.camera.x).toString();
		cameraYInput.text = int(Engine.space.camera.y).toString();
	}
	
	private function save_Click(e:Event):void 
	{
		Designer.saveContext();
	}
	
	private function load_Click(e:Event):void 
	{
		Designer.loadContext();
	}
	
	private function infoButton_Click(e:Event):void 
	{
		// Rotate through different stats.
		_state = (_state + 1) % 2;
	}
	
	private function onEnterPressed(e:Event):void 
	{
		if (cameraXInput.focused || cameraYInput.focused)
		{
			Designer.scroller.setTo(cameraXInput.value, cameraYInput.value);
			cameraXInput.text = int(Engine.space.camera.x).toString();
			cameraYInput.text = int(Engine.space.camera.y).toString();
		}
	}
	
	//} UI input event listeners
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}


/**
 * Space Menu UI manages adding, removing, expanding, and selecting Space containers.
 */
class SpaceMenu extends ItemMenu
{
	public function get spacesList():Array 
	{
		return mainCombo.items;
	}
	public function set spacesList(value:Array):void 
	{
		this.setItems(value);
	}
	
	override protected function initialize():void 
	{
		super.initialize();
		Designer.model.bind("spacesList", this, true);
		this.mainCombo.defaultLabel = "[Select a Space]";
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//{ UI input event listeners
	
	override protected function addButton_Click(e:Event):void 
	{
		Designer.addSpace();
	}
	
	override protected function removeButton_Click(e:Event):void 
	{
		Designer.removeSpace();
	}
	
	override protected function editButton_Click(e:Event):void 
	{
		if (Designer.model.selectedSpace != null)
			MainView.spaceEditor.display();
	}
	
	override protected function mainCombo_Select(e:Event):void 
	{
		Designer.model.update("selectedSpace", Engine.assets.spaces.getAt(mainCombo.selectedIndex), true);
	}
	
	override protected function upButton_Click(e:Event):void 
	{
		var success:Boolean = Engine.assets.spaces.swap(mainCombo.selectedIndex, mainCombo.selectedIndex - 1);
		if (success)
		{
			Designer.model.update("spacesList", null, true);
			mainCombo.selectedIndex = mainCombo.selectedIndex - 1;
			mainCombo_Select(null);
		}
	}
	
	override protected function downButton_Click(e:Event):void 
	{
		var success:Boolean = Engine.assets.spaces.swap(mainCombo.selectedIndex, mainCombo.selectedIndex + 1);
		if (success)
		{
			Designer.model.update("spacesList", null, true);
			mainCombo.selectedIndex = mainCombo.selectedIndex + 1;
			mainCombo_Select(null);
		}
	}
	
	//} UI input event listeners
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

/**
 * Graphic Menu UI manages adding, removing, and selecting for Graphic objects.
 */
class GraphicMenu extends ItemMenu
{
	public function get graphicsList():Array 
	{
		return mainCombo.items;
	}
	public function set graphicsList(value:Array):void 
	{
		this.setItems(value);
	}
	
	override protected function initialize():void 
	{
		super.initialize();
		Designer.model.bind("graphicsList", this, true);
		this.mainCombo.defaultLabel = "[Select a Graphic]";
	}
	
	/**
	 * Event handler for clicking add object button.
	 */
	override protected function addButton_Click(e:Event):void 
	{
		Designer.addGraphic();
	}
	
	/**
	 * Event handler for clicking remove object button.
	 */
	override protected function removeButton_Click(e:Event):void 
	{
		MainView.errorWindow.displayPrompt("Delete this Graphic?", "Delete Graphic");
		MainView.errorWindow.addEventListener(AlertWindow.EVENT_YES, removeGraphic_Yes);
	}
	
	private function removeGraphic_Yes(e:Event):void 
	{
		Designer.removeGraphic();
	}
	
	/**
	 * Event handle for selecting item in Graphic list.
	 */
	override protected function mainCombo_Select(e:Event):void
	{
		Designer.model.update("selectedGraphic", Engine.assets.graphics.getAt(mainCombo.selectedIndex), true);
	}
	
	override protected function editButton_Click(e:Event):void 
	{
		if (Designer.model.selectedGraphic != null)
			MainView.graphicEditor.display();
	}
	
	override protected function upButton_Click(e:Event):void 
	{
		var success:Boolean = Engine.assets.graphics.swap(mainCombo.selectedIndex, mainCombo.selectedIndex - 1);
		if (success)
		{
			Designer.model.update("graphicsList", null, true);
			mainCombo.selectedIndex = mainCombo.selectedIndex - 1;
			mainCombo_Select(null);
		}
	}
	
	override protected function downButton_Click(e:Event):void 
	{
		var success:Boolean = Engine.assets.graphics.swap(mainCombo.selectedIndex, mainCombo.selectedIndex + 1);
		if (success)
		{
			Designer.model.update("graphicsList", null, true);
			mainCombo.selectedIndex = mainCombo.selectedIndex + 1;
			mainCombo_Select(null);
		}
	}
}

//} Menu Panels
//===============================================================================================================================================
