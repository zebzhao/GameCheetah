/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import flash.display.Shape;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import gamecheetah.designer.*;
	import gamecheetah.designer.views.*;
	import gamecheetah.designer.views.components.*;
	import gamecheetah.Engine;
	
	/**
	 * @author 		Zeb Zhao
	 * @version		1.0
	 * @private
	 */
	public final class MainView extends InterfaceGroup
	{
		public static var graphicEditor:GraphicEditorView;
		public static var spaceEditor:SpaceEditorView;
		public static var entityEditor:EntityEditorView;
		
		public static var errorWindow:AlertWindow;
		//public static var propertyPrompt:PropertyPrompt;
		public static var spaceCanvas:SpaceView;
		
		
		private var
			menus:MenuView,
			controlsLayout:ControlsLayout,
			quadtreeWindow:TextWindow;		// Used to show entities in the quadtree structure.
		
		// Context menu items
		private var viewQuadtreeMenuItem:ContextMenuItem;
		
		
		public function get errorMessage():String 
		{
			return errorWindow.text;
		}
		public function set errorMessage(value:String):void 
		{
			if (value == null) return;
			errorWindow.displayWarning(value, "Warning!");
		}
		
		
		public function MainView() 
		{
			super();
		}
		
		override protected function build():void 
		{
			// Create UI components.
			spaceCanvas = new SpaceView(this);
			controlsLayout = new ControlsLayout(this);
			menus = new MenuView(this);
			quadtreeWindow = new TextWindow(Engine.stage);
			
			graphicEditor = new GraphicEditorView(this);
			entityEditor = new EntityEditorView(this);
			spaceEditor = new SpaceEditorView(this);
			
			errorWindow = new AlertWindow(this);
			//propertyPrompt = new PropertyPrompt(this);
			
			// Build additional context menu items.
			viewQuadtreeMenuItem = new ContextMenuItem("View Quadtree");
			Engine.instance.contextMenu.customItems.unshift(viewQuadtreeMenuItem);
		}
		
		override protected function initialize():void 
		{
			Designer.model.bind("errorMessage", this, true);
			
			errorWindow.hide();
			//propertyPrompt.hide();
			graphicEditor.hide();
			entityEditor.hide();
			spaceEditor.hide();
			quadtreeWindow.hide();
		}
		
		override protected function addListeners():void 
		{
			viewQuadtreeMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onShowQuadtree);
			Engine.instance.addEventListener(Engine.events.E_SPACE_CHANGE, onSpaceChange);
			Engine.stage.addEventListener(Event.RESIZE, onStageResize);
			this.addEventListener(Event.ADDED_TO_STAGE, onStageResize);
		}
		
		/**
		 * Construct layout of UI components.
		 */
		override protected function onResize():void 
		{
			menus.setSize(_width, _height);
			controlsLayout.setSize(_width, _height);
			MainView.graphicEditor.setSize(_width, _height);
			MainView.entityEditor.setSize(_width, _height);
			MainView.spaceEditor.setSize(_width, _height);
			
			quadtreeWindow.setSize(200, 200);
			quadtreeWindow.move(_width - quadtreeWindow.width, _height - quadtreeWindow.height - 20);
			//MainView.propertyPrompt.move(_width / 2 - MainView.propertyPrompt.width / 2, _height / 2 - MainView.propertyPrompt.height / 2);
		}
		
		/**
		 * Handles when the active space is swapped.
		 */
		private function onSpaceChange(e:Event):void 
		{
			quadtreeWindow.bind("_quadtreeData", Engine.space);
			spaceCanvas.activeSpace = Engine.space;
		}
		
		/**
		 * Event handler to show Quadtree structure.
		 */
		private function onShowQuadtree(e:ContextMenuEvent):void 
		{
			quadtreeWindow.display();
		}
		
		/**
		 * Resize event propagated from the stage object.
		 */
		private function onStageResize(e:Event):void 
		{
			if (this.stage != null)
				this.setSize(Engine.stage.stageWidth, Engine.stage.stageHeight);
		}
		
	}
	
}

import gamecheetah.designer.bit101.components.*;
import flash.display.*;
import flash.events.*;
import flash.geom.Point;
import gamecheetah.*;
import gamecheetah.designer.*;
import gamecheetah.designer.views.*;
import gamecheetah.designer.views.components.*;
import gamecheetah.graphics.*;

/**
 * Control Icons which display hints about using the interface.
 */
class ControlsLayout extends InterfaceGroup
{
	private var
		graphicForeground:Sprite,
		graphicBitmap:Bitmap,
		graphicBackground:Bitmap,
		snapButton:PushButton,
		gridWidthInput:TypedInput,
		gridHeightInput:TypedInput,
		gridWidthLabel:Label,
		gridHeightLabel:Label,
		spaceTagLabel:Label,
		playButton:PushButton;
	
	
	public function get activeClip():Clip 
	{
		return _activeClip;
	}
	public function set activeClip(value:Clip):void
	{
		if (value == null) return;
		_activeClip = value;
		graphicBitmap.bitmapData = _activeClip.buffer;
		graphicBackground.bitmapData = _activeClip.buffer;
		graphicForeground.x = graphicBackground.x = _width - graphicBitmap.bitmapData.width;
		graphicForeground.y = graphicBackground.y = 0;
	}
	private var _activeClip:Clip;
	private var _isDraggingClip:Boolean;
	
	public function get selectedSpace():Space 
	{
		return _selectedSpace;
	}
	public function set selectedSpace(value:Space):void 
	{
		_selectedSpace = value;
		spaceTagLabel.text = Engine.space.tag;
	}
	private var _selectedSpace:Space;
	
	public function ControlsLayout(parent:DisplayObjectContainer) 
	{
		super(parent);
	}
	
	override protected function build():void 
	{
		gridWidthInput = new TypedInput(this, 0, 0, TypedInput.TYPE_INTEGER, gridInput_Change);
		gridHeightInput = new TypedInput(this, 0, 0, TypedInput.TYPE_INTEGER, gridInput_Change);
		gridWidthLabel = new Label(this, 0, 0, "W");
		gridHeightLabel = new Label(this, 0, 0, "H");
		spaceTagLabel = new Label(this, 0, 0, "");
		playButton = new PushButton(this, 0, 0, "Run Game!", playButton_Click);
		snapButton = new PushButton(this, 0, 0, "Snap to Grid", snapButton_Click);
		graphicBitmap = new Bitmap();
		graphicBackground = new Bitmap();
		graphicForeground = new Sprite();
	}
	
	override protected function addListeners():void 
	{
		graphicForeground.addEventListener(MouseEvent.MOUSE_DOWN, graphicForeground_onMouseDown);
		Engine.stage.addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
	}
	
	override protected function initialize():void 
	{
		graphicForeground.addChild(graphicBitmap);
		this.addChild(graphicBackground);
		this.addChild(graphicForeground);
		
		graphicBackground.visible = false;
		snapButton.toggle = true;
		
		Engine.instance.addEventListener(Engine.events.E_SPACE_CHANGE, activeSpace_Change);
		Designer.model.bind("activeClip", this);
		Designer.model.bind("selectedSpace", this);
	}
	
	override protected function onResize():void 
	{
		snapButton.setSize(110, 22);
		snapButton.move(_width - 109, _height - 64);
		gridWidthInput.setSize(55, 22);
		gridWidthInput.move(snapButton.x, snapButton.bottom);
		gridHeightInput.setSize(55, 22);
		gridHeightInput.move(gridWidthInput.right, gridWidthInput.y);
		gridWidthLabel.move(gridWidthInput.right - gridWidthLabel.width - 5, gridWidthInput.y + 3);
		gridHeightLabel.move(gridHeightInput.right - gridHeightLabel.width - 5, gridHeightInput.y + 3);
		playButton.setSize(110, 22);
		playButton.move(snapButton.x, gridWidthInput.bottom);
		spaceTagLabel.move(snapButton.x, snapButton.y - 20);
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//{ UI input event listeners
	
	private function activeSpace_Change(e:Event):void 
	{
		spaceTagLabel.text = Engine.space.tag;
	}
	
	private function playButton_Click(e:MouseEvent):void 
	{
		Designer.play();
	}
	
	private function gridInput_Change(e:Event):void 
	{
		MainView.spaceCanvas.gridW = gridWidthInput.value;
		MainView.spaceCanvas.gridH = gridHeightInput.value;
	}
	
	private function snapButton_Click(e:Event):void 
	{
		MainView.spaceCanvas.gridSnapping = snapButton.selected;
	}
	
	private function graphicForeground_onMouseDown(e:Event):void 
	{
		graphicForeground.startDrag();
		graphicBackground.visible = true;
		_isDraggingClip = true;
	}
	
	private function stage_onMouseUp(e:Event):void
	{
		// Drag and drop
		if (_isDraggingClip)
		{
			graphicForeground.stopDrag();
			_isDraggingClip = false;
			
			var dragDistance:Point = new Point(graphicForeground.x - graphicBackground.x, graphicForeground.y - graphicBackground.y);
			
			
			if (dragDistance.length <= 20)
			{
				//Ignore if drag distance is too small.
			}
			else
			{
				// Create new entity at specified location.
				Designer.addEntity(Engine.space.camera.x + graphicForeground.x, Engine.space.camera.y + graphicForeground.y);
			}
		}
		
		graphicForeground.x = graphicBackground.x;
		graphicForeground.y = graphicBackground.y;
		graphicBackground.visible = false;
	}
	
	//} UI input event listeners
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
