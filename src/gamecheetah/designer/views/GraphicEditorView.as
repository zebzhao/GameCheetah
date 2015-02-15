/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import gamecheetah.designer.bit101.components.*;
	import flash.display.*;
	import flash.events.Event;
	import gamecheetah.*;
	import gamecheetah.designer.*;
	import gamecheetah.namespaces.*;
	import gamecheetah.designer.views.components.*;
	import gamecheetah.graphics.Animation;
	
	use namespace hidden;
	
	/**
	 * Manages the layout for Editor Panels.
	 * @private
	 */
	public class GraphicEditorView extends InterfaceGroup
	{
		private var
			window:DialogWindow,
			accordian:Accordion,
			tagInput:InputText,
			tagLabel:Label,
			classCombo:ComboBox,
			animationPanel:AnimationPanel,
			collisionPanel:CollisionPanel;
		
		
		public function get selectedGraphic():Graphic 
		{
			return _selectedGraphic;
		}
		public function set selectedGraphic(value:Graphic):void
		{
			if (value == null)
			{
				hide();
				return;
			}
			_selectedGraphic = value;
			classCombo.selectedIndex = classCombo.items.indexOf(Object(_selectedGraphic.master).constructor);
			tagInput.text = _selectedGraphic.tag;
			Designer.model.update("selectedAnimation", _selectedGraphic.animations.get(_selectedGraphic.defaultAnimation) as Animation, true);
		}
		private var _selectedGraphic:Graphic;
		
		
		public function GraphicEditorView(parent:DisplayObjectContainer) 
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
			window = new DialogWindow(this, 0, 0, "Graphic Editor");
			
			tagInput = new InputText(window.content, 0, 0, "", tagInput_onChange);
			tagLabel = new Label(window.content, 0, 0, "Tag");
			classCombo = new ComboBox(window.content);
			
			animationPanel = new AnimationPanel();
			collisionPanel = new CollisionPanel();
			
			accordian = new Accordion(window.content);
			accordian.addWindow("Animation");
			accordian.addWindow("Collision");
			
			accordian.getWindowAt(0).addChild(animationPanel);
			accordian.getWindowAt(1).addChild(collisionPanel);
		}
		
		override protected function initialize():void 
		{
			classCombo.items = Engine.__entityClasses;
			accordian.getWindowAt(0).minimized = false;
			tagInput.textField.background = true;
			tagInput.textField.backgroundColor = Style.BACKGROUND;
			Designer.model.bind("selectedGraphic", this, true);
		}
		
		override protected function addListeners():void 
		{
			classCombo.addEventListener(Event.SELECT, classCombo_onSelect);
		}
		
		override protected function onResize():void 
		{
			window.setSize(250, 370);
			accordian.setSize(250, 310);
			accordian.move(0, 40);
			
			tagInput.setSize(window.width, 20);
			tagInput.move(0, 0);
			tagLabel.move(tagInput.right - tagLabel.width - 5, tagInput.y);
			
			classCombo.setSize(tagInput.width + 1, 22);
			classCombo.move(0, tagInput.bottom);
			
			animationPanel.setSize(250, 300);
			animationPanel.move(0, 0);
			
			collisionPanel.setSize(250, 300);
			collisionPanel.move(0, 0);
		}
		
		/**
		 * Handles a text change in tag input.
		 */
		private function tagInput_onChange(e:Event):void 
		{
			var success:Boolean = Designer.changeGraphicTag(tagInput.text);
			if (!success) tagInput.textField.backgroundColor = 0xFFCCCC;
			else tagInput.textField.backgroundColor = Style.BACKGROUND;
		}
		
		private function classCombo_onSelect(e:Event):void 
		{
			if (classCombo.selectedItem == null || selectedGraphic.masterClass == String(classCombo.selectedItem))
			{
				return;
			}
			else if (selectedGraphic.masterClass != String(Entity))
			{
				MainView.errorWindow.displayPrompt("Are you sure? Changing the class will recreate all entities.", "Change graphic class");
				MainView.errorWindow.addEventListener(AlertWindow.EVENT_YES, graphicClass_Change);
				MainView.errorWindow.addEventListener(AlertWindow.EVENT_NO, updateGraphicClass);
			}
			else graphicClass_Change(null);
		}
		
		private function graphicClass_Change(e:Event):void 
		{
			if (classCombo.selectedItem != null)
				selectedGraphic.setClass(classCombo.selectedItem as Class);
		}
		
		private function updateGraphicClass(e:Event):void 
		{
			if (_selectedGraphic != null)
				classCombo.selectedIndex = classCombo.items.indexOf(Object(_selectedGraphic.master).constructor);
		}
	}
}

import gamecheetah.designer.bit101.components.*;
import flash.display.*;
import flash.events.*;
import flash.geom.Point;
import flash.geom.Rectangle;
import gamecheetah.*;
import gamecheetah.designer.*;
import gamecheetah.designer.views.*;
import gamecheetah.designer.views.components.*;
import gamecheetah.graphics.*;
import gamecheetah.namespaces.*;
import gamecheetah.utils.ArrayUtils;

use namespace hidden;

//===============================================================================================================================================
//{ Editor Panels

class AnimationMenu extends ItemMenu
{
	private var editor:AnimationEditorView;
	
	public function get selectedGraphic():Graphic 
	{
		return _selectedGraphic;
	}
	public function set selectedGraphic(value:Graphic):void
	{
		_selectedGraphic = value;
		if (value == null) return;
		Designer.model.update("animationsList", null, true);
	}
	private var _selectedGraphic:Graphic;
	
	public function set animationsList(value:Array):void 
	{
		if (value == null) return;
		setItems(value);
		if (this.mainCombo.items.length > 0)
			this.mainCombo.selectedIndex = this.mainCombo.selectedIndex;
	}
	
	override protected function build():void 
	{
		super.build();
		editor = new AnimationEditorView(this);
	}
	
	override protected function initialize():void 
	{
		Designer.model.bind("selectedGraphic", this, true);
		Designer.model.bind("animationsList", this, false);
		editor.setSize(150, 63);
		editor.hide();
		this.mainCombo.defaultLabel = "[Select an Animation]";
	}
	
	override protected function mainCombo_Select(e:Event):void 
	{
		if (_selectedGraphic != null)
			Designer.model.update("selectedAnimation", _selectedGraphic.animations.getAt(mainCombo.selectedIndex) as Animation, true);
	}
	
	override protected function addButton_Click(e:Event):void 
	{
		Designer.addAnimation();
		Designer.model.update("animationsList", null, true);
	}
	
	override protected function removeButton_Click(e:Event):void 
	{
		Designer.removeAnimation();
		Designer.model.update("animationsList", null, true);
	}
	
	override protected function upButton_Click(e:Event):void 
	{
		if (mainCombo.selectedIndex >= 1)
		{
			_selectedGraphic.animations.swap(mainCombo.selectedIndex, mainCombo.selectedIndex - 1);
			mainCombo.selectedIndex -= 1;
		}
	}
	
	override protected function downButton_Click(e:Event):void 
	{
		if (mainCombo.selectedIndex < _selectedGraphic.animations.length - 1)
		{
			_selectedGraphic.animations.swap(mainCombo.selectedIndex, mainCombo.selectedIndex + 1);
			mainCombo.selectedIndex += 1;
		}
	}
	
	override protected function editButton_Click(e:Event):void 
	{
		editor.display();
	}
}

/**
 * Animation Panel UI manages changing, updating animation data of Graphic objects.
 */
class AnimationPanel extends InterfaceGroup
{
	public function get selectedGraphic():Graphic 
	{
		return _selectedGraphic;
	}
	public function set selectedGraphic(value:Graphic):void
	{
		_selectedGraphic = value;
		if (value == null) return;
		rowInput.text = _selectedGraphic.rows.toString();
		columnInput.text = _selectedGraphic.columns.toString();
	}
	private var _selectedGraphic:Graphic;
	
	
	public function get selectedAnimation():Animation 
	{
		return _selectedAnimation;
	}
	public function set selectedAnimation(value:Animation):void
	{
		_selectedAnimation = value;
		if (value == null)
		{
			rateSlider.value = 0;
			rateLabel.text = "Rate (-%)";
		}
		else
		{
			rateSlider.value = _selectedAnimation.frameRate;
			rateLabel.text = "Rate (" + int(rateSlider.value * 100) + "%)";
		}
	}
	private var _selectedAnimation:Animation;
	
	
	public function get activeClip():Clip 
	{
		return _activeClip;
	}
	public function set activeClip(value:Clip):void
	{
		_activeClip = value;
	}
	private var _activeClip:Clip;
	
	
	public var
		animationsMenu:AnimationMenu,
		rateLabel:Label,
		rateSlider:HSlider,
		rowLabel:Label, columnLabel:Label,
		rowInput:TypedInput, columnInput:TypedInput,
		browseButton:IconPushButton,
		imagePane:ImagePane;
	
	
	override protected function build():void 
	{
		imagePane = new ImagePane(this);
		rowInput = new TypedInput(this, 0, 0, TypedInput.TYPE_INTEGER, rowInput_Change);
		columnInput = new TypedInput(this, 0, 0, TypedInput.TYPE_INTEGER, columnInput_Change);
		rowLabel = new Label(this, 0, 0, "R");
		columnLabel = new Label(this, 0, 0, "C");
		browseButton = new IconPushButton(this, 0, 0, "Choose Spritesheet", new Assets.Load, browseButton_onClick);
		rateSlider = new HSlider(this, 0, 0, rateSlider_Change);
		rateLabel = new Label(this, 0, 0, "Rate (" + int(rateSlider.value * 100) + "%)");
		animationsMenu = new AnimationMenu();
		this.addChild(animationsMenu);
	}
	
	override protected function initialize():void 
	{
		rowInput.minimum = columnInput.minimum = 1;
		rateSlider.maximum = 1;
		rateSlider.minimum = 0;
		rateSlider.value = 1;
		rateSlider.tick = 0.05;
		
		Designer.model.bind("selectedGraphic", this);
		Designer.model.bind("selectedAnimation", this);
		Designer.model.bind("activeClip", this);
	}
	
	override protected function addListeners():void 
	{
		super.addListeners();
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	override protected function onResize():void 
	{
		browseButton.setSize(_width + 1, 22);
		browseButton.move(0, 0);
		
		rowInput.setSize(_width / 2, 20);
		rowInput.move(browseButton.x, browseButton.bottom);
		rowLabel.move(rowInput.right - 15, rowInput.y);
		
		columnInput.setSize(rowInput.width + 1, 20);
		columnInput.move(rowInput.right, rowInput.y);
		columnLabel.move(columnInput.right - 15, columnInput.y);
		
		imagePane.setSize(_width, _height - 142);
		imagePane.move(rowInput.x, rowInput.bottom);
		
		rateLabel.move(imagePane.right - rateLabel.width - 15, imagePane.y + 3);
		
		rateSlider.setSize(_width, 10);
		rateSlider.move(imagePane.x, imagePane.bottom);
		
		animationsMenu.setSize(_width + 1, 64);
		animationsMenu.move(rateSlider.x, rateSlider.bottom);
	}
	
	private function onEnterFrame(e:Event):void 
	{
		if (_activeClip != null)
		{
			imagePane.image = _activeClip.buffer;
			_activeClip.update();
		}
		else if (imagePane.image != null) imagePane.image = null;
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//{ UI input event listeners
	
	/**
	 * When swap image button is clicked.
	 */
	private function browseButton_onClick(e:Event):void 
	{
		Designer.loadImage();
	}
	
	/**
	 * Handles a text change in row input.
	 */
	private function rowInput_Change(e:Event):void 
	{
		_selectedGraphic.rows = int(rowInput.text);
		Designer.model.update("activeClip", _selectedGraphic.newRenderable() as Clip, true);
	}
	
	/**
	 * Handles a text change in column input.
	 */
	private function columnInput_Change(e:Event):void 
	{
		_selectedGraphic.columns = int(columnInput.text);
		Designer.model.update("activeClip", _selectedGraphic.newRenderable() as Clip, true);
	}
	
	/**
	 * Handles a text change in framerate input.
	 */
	private function rateSlider_Change(e:Event):void 
	{
		if (_selectedAnimation == null) return;
		_selectedAnimation.frameRate = rateSlider.value;
		rateLabel.text = "Rate (" + int(rateSlider.value * 100) + "%)";
	}
	
	//} UI input event listeners
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

/**
 * Group Panel UI manages changing, matching collision groups for Graphic objects.
 */
class CollisionPanel extends InterfaceGroup
{
	private var
		accordian:Accordion,
		maskCombo:ComboBox,
		maskCanvas:MaskCanvas,
		scrollPane:ScrollPane,
		defaultCheckbox:CheckBox,
		buttons:Vector.<PushButton>;
	
	
	public function get selectedMaskFrame():int 
	{
		return _selectedMaskFrame;
	}
	public function set selectedMaskFrame(value:int):void 
	{
		_selectedMaskFrame = value;
		updateMask();
	}
	private var _selectedMaskFrame:int;
	
	
	public function get selectedGraphic():Graphic 
	{
		return _selectedGraphic;
	}
	public function set selectedGraphic(value:Graphic):void 
	{
		if (value == null) return;
		
		_selectedGraphic = value;
		createMaskComboList();
		updateMask();
		
		for (var i:uint = 0; i < 32; i++)
			buttons[i].selected = ((1 << i) & _selectedGraphic.action) != 0
		
		// Tricky: 1st collision group is reserved. (for querying)
		buttons[0].label = "[class Entity]";
		
		var classesCount:uint = Engine.__collisionClasses.length;
		for (i = 0; i < classesCount; i++)
			buttons[i + 1].label = Engine.__collisionClasses[i];
	}
	private var _selectedGraphic:Graphic;
	
	
	override protected function build():void 
	{
		accordian = new Accordion(this);
		accordian.addWindow("> Mask");
		accordian.addWindow("> Collide With");
		
		maskCanvas = new MaskCanvas(accordian.getWindowAt(0));
		maskCombo = new ComboBox(accordian.getWindowAt(0));
		defaultCheckbox = new CheckBox(accordian.getWindowAt(0), 0, 0, "Always use default", defaultCheckbox_Select);
		scrollPane = new ScrollPane(accordian.getWindowAt(1));
		
		buttons = new Vector.<PushButton>();
		for (var i:uint = 0; i < 32; i++)
			buttons[i] = new PushButton(scrollPane.content);
	}
	
	override protected function initialize():void 
	{
		Designer.model.bind("selectedGraphic", this,  true);
		Designer.model.bind("selectedMaskFrame", this,  true);
		
		accordian.getWindowAt(0).minimized = false;
		scrollPane.autoHideScrollBar = true;
		scrollPane.dragContent = false;
		
		for (var i:uint = 0; i < 32; i++)
			buttons[i].toggle = true;
	}
	
	override protected function addListeners():void 
	{
		for (var i:uint = 0; i < 32; i++)
		{
			buttons[i].addEventListener(MouseEvent.CLICK, toggleButton_Select);
		}
		maskCombo.addEventListener(Event.SELECT, maskCombo_Select);
		maskCanvas.addEventListener(MaskCanvas.E_MASK_SELECTED, mask_Selected);
		maskCanvas.addEventListener(MaskCanvas.E_POINT_SELECTED, point_Selected);
		maskCanvas.addEventListener(MaskCanvas.E_RECT_SELECTED, rect_Selected);
		maskCanvas.addEventListener(MaskCanvas.E_NONE_SELECTED, none_Selected);
		maskCanvas.addEventListener(MaskCanvas.E_LOAD_MASK, onLoadMask);
	}
	
	override protected function onResize():void 
	{
		accordian.setSize(_width, _height - 30);
		accordian.move(0, 0);
		
		maskCombo.setSize(_width, 22);
		maskCanvas.setSize(_width, _height - 114);
		maskCanvas.move(maskCombo.x, maskCombo.bottom);
		defaultCheckbox.move(maskCanvas.right - defaultCheckbox.width - 8, maskCanvas.y + 8);
		
		scrollPane.setSize(_width, _height - 70);
		scrollPane.move(0, 0);
		
		for (var i:uint = 0; i < 32; i++)
		{
			buttons[i].setSize(_width - 10, 22);
			buttons[i].move(1, i * 21);
		}
		scrollPane.update();
	}
	
	/**
	 * Populate mask combo list.
	 */
	private function createMaskComboList():void 
	{
		var frameCount:int = _selectedGraphic.frameCount;
		var i:uint = 0;
		var itemEntry:String;
		
		// Clear list
		maskCombo.items = [];
		
		// Create list items.
		for (i = 0; i < frameCount; i++)
		{
			itemEntry = i == 0 ? "0: (Default)" : i.toString() + ":";
			
			if (_selectedGraphic._frameMasks[i] is Rectangle)
				itemEntry += "\tRectangle";
			else if (_selectedGraphic._frameMasks[i] is BitmapData)
				itemEntry += "\tPixel Mask";
			else
				itemEntry += "\tNone";
				
			maskCombo.addItem(itemEntry);
		}
		if (frameCount > 0)
		{
			_selectedMaskFrame = 0;
			maskCombo.selectedIndex = _selectedMaskFrame;
		}
	}
	
	/**
	 * Handles update of mask information of the selected Graphic.
	 */
	private function updateMask():void 
	{
		if (_selectedGraphic != null)
		{
			if (selectedMaskFrame >= 0)
			{
				maskCanvas.image = _selectedGraphic._frameImages[selectedMaskFrame];
				maskCanvas.setMask(_selectedGraphic._frameMasks[selectedMaskFrame]);
			}
			else maskCanvas.image = null;
			
			defaultCheckbox.selected = _selectedGraphic.alwaysUseDefaultMask;
			
			// Update mask list items.
			var items:Array = [];
			var i:int, itemEntry:String;
			var frameCount:int = _selectedGraphic.frameCount;
			
			for (i = 0; i < frameCount; i++)
			{
				itemEntry = i == 0 ? "0: (Default)" : i.toString() + ":";
				
				if (_selectedGraphic._frameMasks[i] is Rectangle)
					itemEntry += "\tRectangle";
				else if (_selectedGraphic._frameMasks[i] is BitmapData)
					itemEntry += "\tPixel Mask";
				else
					itemEntry += "\tNone";
					
				items.push(itemEntry);
			}
			maskCombo.items = items;
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//{ UI input event listeners
	
	private function mask_Selected(e:Event):void 
	{
		if (selectedMaskFrame >= 0)
			_selectedGraphic._frameMasks[selectedMaskFrame] = new BitmapData(_selectedGraphic.frameRect.width, _selectedGraphic.frameRect.height, true, 0);
		updateMask();
	}
	
	private function point_Selected(e:Event):void 
	{
		if (selectedMaskFrame >= 0)
			_selectedGraphic._frameMasks[selectedMaskFrame] = new Point(_selectedGraphic.frameRect.width / 2, _selectedGraphic.frameRect.height / 2);
		updateMask();
	}
	
	private function rect_Selected(e:Event):void 
	{
		if (selectedMaskFrame >= 0)
			_selectedGraphic._frameMasks[selectedMaskFrame] = new Rectangle();
		updateMask();
	}
	
	private function none_Selected(e:Event):void 
	{
		if (selectedMaskFrame >= 0)
			_selectedGraphic._frameMasks[selectedMaskFrame] = null;
		updateMask();
	}
	
	private function defaultCheckbox_Select(e:Event):void 
	{
		_selectedGraphic.alwaysUseDefaultMask = defaultCheckbox.selected;
	}
	
	private function maskCombo_Select(e:Event):void 
	{
		Designer.model.update("selectedMaskFrame", maskCombo.selectedIndex, true);
	}
	
	/**
	 * Handles loading of mask
	 */
	private function onLoadMask(e:Event):void 
	{
		Designer.loadMaskImage();
	}
	
	/**
	 * Handles when a collision group checkbox is selected/unselected.
	 */
	private function toggleButton_Select(e:Event):void 
	{
		var target:PushButton = e.target as PushButton;
		var index:uint = buttons.indexOf(target);
		
		if (target.selected)
			selectedGraphic._collideWith.push(target.label);
		else
			ArrayUtils.removeItem(target.label, selectedGraphic._collideWith);
			
		// Recalculate action mask
		selectedGraphic.calculateActionMask();
	}
	
	//} UI input event listeners
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

//} Editor Panels
//===============================================================================================================================================

