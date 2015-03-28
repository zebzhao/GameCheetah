/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import gamecheetah.*;
	import gamecheetah.designer.components.*;
	import gamecheetah.designer.Designer;
	import gamecheetah.designer.DesignerError;
	import gamecheetah.graphics.*;
	import gamecheetah.namespaces.*;
	import gamecheetah.utils.ArrayUtils;
	import gamecheetah.utils.GCError;
	
	use namespace hidden;
	
	public class GraphicConsole extends BaseComponent 
	{
		private var
			_main:MainConsole;
			
		private var
			_zoomFactor:Number = 1;
			
		private var
			_backBtn:IconButton, _classesBtn:IconButton, _animationsBtn:IconButton, _collisionsBtn:IconButton,
			_classesList:List, _animationsList:List, _collisionsList:List,
			_masksList:List, _viewList:List, _spriteSheetList:List, _toolsList:List,
			_addAnimationBtn:IconButton, _rateUpBtn:IconButton, _rateDownBtn:IconButton,
			_playBtn:IconButton, _prevFrameBtn:IconButton, _nextFrameBtn:IconButton, _loopBtn:IconButton,
			_entityContainer:ZoomPanel,
			_spriteSheetBtn:IconButton, _maskBtn:IconButton, _viewBtn:IconButton, _toolsBtn:IconButton,
			_frameSlider:Slider,
			_frameInput:TextInput, _rateInput:TextInput,
			_rowsInput:TextInput, _columnsInput:TextInput;
		
		//{ ------------------------------------ Property bindings ------------------------------------
		
		public function get selectedGraphic():Graphic { return null };
		public function set selectedGraphic(value:Graphic):void
		{
			if (!value) return;
			
			// Select class
			_classesList.selectItem(Engine.__entityClasses.indexOf(Object(value.master).constructor || Entity));
			
			// Select collision groups
			for (var i:uint = 0; i < _collisionsList.items.length; i++)
				if (((1 << i) & value.action) != 0)
					_collisionsList.selectItem(i);
					
			// Set spritesheet options
			if (value.hasSpritesheet)
			{
				_rowsInput.text = value.rows.toString();
				_columnsInput.text = value.columns.toString();
				
				_rowsInput.show();
				_columnsInput.show();
			}
			else
			{
				_rowsInput.hide();
				_columnsInput.hide();
			}
		}
		
		public function get animationsList():Array { return null };
		public function set animationsList(value:Array):void
		{
			if (!value) return;
			_animationsList.items = value;
		}
		
		public function get selectedAnimation():Animation { return null };
		public function set selectedAnimation(value:Animation):void
		{
			if (!value) return;
			
			Designer.model.activeClip.play(value.tag, true);
			
			_animationsList.selectItem(Designer.model.selectedGraphic.animations.indexOfKey(value.tag));
			_frameInput.text = value.frames.toString();
			_frameSlider.setBounds(0, value.frames.length - 1, 1);
			_rateInput.text = (value.frameRate * 100).toString();
			
			if (value.looping) _loopBtn.freeze();
			else _loopBtn.unfreeze();
		}
		
		public function get activeClip():Clip { return null; }
		public function set activeClip(value:Clip):void
		{
			if (!value)
			{
				_entityContainer.content = null;
				return;
			}
			_entityContainer.content = Designer.model.selectedGraphic.master;
			if (Designer.model.selectedAnimation)
				value.play(Designer.model.selectedAnimation.tag);
		}
		
		//}
		//{ ------------------------------------ Constructor ------------------------------------
		
		public function GraphicConsole(parent:DisplayObjectContainer, main:MainConsole) 
		{
			_main = main;
			
			_entityContainer = new ZoomPanel(this, null, 250, Math.min(Engine.buffer.height - 300, 250));
			
			_prevFrameBtn = new IconButton(this, Assets.SEEK_BACK, prevFrameBtn_Click, "Next Frame", Label.ALIGN_ABOVE);
			_nextFrameBtn = new IconButton(this, Assets.SEEK_FORWARD, nextFrameBtn_Click, "Prev Frame", Label.ALIGN_ABOVE);
			_playBtn = new IconButton(this, Assets.PLAY, playBtn_Click, "Play", Label.ALIGN_ABOVE);
			_loopBtn = new IconButton(this, Assets.LOOP, loopBtn_Click, "Loop", Label.ALIGN_ABOVE);
			_rateUpBtn = new IconButton(this, Assets.ARROW_UP, rateUpBtn_Click, "", Label.ALIGN_RIGHT);
			_rateDownBtn = new IconButton(this, Assets.ARROW_DOWN, rateDownBtn_Click, "", Label.ALIGN_RIGHT);
			
			_frameSlider = new Slider(this, 250, 8, Slider.HORIZONTAL, 0, 0, 1, frameSlider_Slide);
			_frameInput = new TextInput(this, 195, 25, frameInput_Change, "Frame Sequence", TextInput.TYPE_UINT_VECTOR);
			_frameInput.setHint("Animation Sequence", Label.ALIGN_BELOW);
			_rateInput = new TextInput(this, 50, 25, rateInput_Change, "Rate", TextInput.TYPE_UINT_VECTOR);
			_rateInput.setHint("Playback Rate", Label.ALIGN_BELOW);
			_rateInput.minimum = 0;  _rateInput.maximum = 100;
			
			_spriteSheetBtn = new IconButton(this, Assets.SPRITESHEET, spriteSheetBtn_Click, "SpriteSheet", Label.ALIGN_ABOVE);
			_maskBtn = new IconButton(this, Assets.MASKS, maskBtn_Click, "Mask", Label.ALIGN_ABOVE);
			_viewBtn = new IconButton(this, Assets.ZOOM, viewBtn_Click, "View", Label.ALIGN_ABOVE);
			_toolsBtn = new IconButton(this, Assets.TOOLS, toolBtn_Click, "Tools", Label.ALIGN_ABOVE);
			
			_classesList = new List(this, Engine.__entityClasses, 8, 150, 25, classesList_Select, null, null, null, null, false, false, false); 
			_animationsList = new List(this, [], 8, 150, 25, animationsList_Select, null, animationsList_Delete, animationsList_Swap, animations_Edit, true, true, true);
			_collisionsList = new List(this, Engine.__collisionClasses, 8, 150, 25, collisionsList_Select, collisionsList_Deselect, null, null, null, false, false, false);
			_collisionsList.multiselect = true;
			_masksList = new List(this, ["None", "Point", "Rect", "Bitmap"], 4, 100, 25, maskList_Select, null, null, null, null, false, false, false);
			_viewList = new List(this, ["Show Mask", "Zoom In", "Zoom Out"], 3, 100, 25, viewList_Select, null, null, null, null, false, false, false);
			_viewList.multiselect = true;
			_spriteSheetList = new List(this, ["Browse...", "Discard", "", ""], 4, 100, 25, spriteSheetList_Select, null, null, null, null, false, false, false);
			_toolsList = new List(this, ["Load...", "Draw", "Erase", "Clear"], 4, 100, 25, toolsList_Select, null, null, null, null, false, false, false);
			
			_spriteSheetList.getListItem(2).editable = true;
			_spriteSheetList.getListItem(3).editable = true;
			_rowsInput = _spriteSheetList.getListItem(2).editInput;
			_columnsInput = _spriteSheetList.getListItem(3).editInput;
			_rowsInput.minimum = 1;  _rowsInput.maximum = 200;
			_columnsInput.minimum = 1;  _columnsInput.maximum = 200;
			_rowsInput.type = TextInput.TYPE_UINT;
			_columnsInput.type = TextInput.TYPE_UINT;
			_rowsInput.placeholder = "Rows";
			_columnsInput.placeholder = "Columns";
			_rowsInput.setHint("Rows", Label.ALIGN_RIGHT);
			_columnsInput.setHint("Columns", Label.ALIGN_RIGHT);
			_rowsInput.onChange = rowsInput_Change;
			_columnsInput.onChange = columnsInput_Change;
			
			_backBtn = new IconButton(this, Assets.EXIT, backBtn_Click, "Back", Label.ALIGN_BELOW);
			_classesBtn = new IconButton(this, Assets.CLASSES, classesBtn_Click, "Classes", Label.ALIGN_BELOW);
			_animationsBtn = new IconButton(this, Assets.ANIMATIONS, animationsBtn_Click, "Animations", Label.ALIGN_BELOW);
			_collisionsBtn = new IconButton(this, Assets.COLLISIONS, collisionsBtn_Click, "Collide With...", Label.ALIGN_BELOW);
			_addAnimationBtn = new IconButton(this, Assets.ADD, addAnimationBtn_Click, "Add", Label.ALIGN_BELOW);
			
			Designer.model.bind("selectedGraphic", this, true);
			Designer.model.bind("animationsList", this, true);
			Designer.model.bind("selectedAnimation", this, true);
			Designer.model.bind("activeClip", this, true);
			
			super(parent);
		}
		
		//}
		//{ ------------------------------------ Behaviour Overrides ------------------------------------
		
		override public function onActivate():void 
		{
			this.mouseEnabled = true;
			hideAllDropDowns();
			onUpdate();
		}
		
		override public function onUpdate():void 
		{
			var stageWidth:int = Engine.buffer.width;
			var stageHeight:int = Engine.buffer.height;
			
			_classesBtn.move(stageWidth * 0.1 - 16, 10);
			_animationsBtn.move(stageWidth * 0.367 - 16, 10);
			_collisionsBtn.move(stageWidth * 0.633 - 16, 10);
			_backBtn.move(stageWidth * 0.9 - 16, 10);
			
			_classesList.move(_classesBtn.left, _classesBtn.bottom + 30);
			_animationsList.move(_animationsBtn.left, _animationsBtn.bottom + 30);
			_addAnimationBtn.move(_animationsList.left, _animationsList.bottom + 5);
			_collisionsList.move(_collisionsBtn.left, _collisionsBtn.bottom + 30);

			_entityContainer.move(stageWidth * 0.5 - 125, stageHeight * 0.5 - 160);
			
			_frameInput.move(_entityContainer.left, _entityContainer.bottom + 100);
			_frameSlider.move(_frameInput.left, _frameInput.top - 15);
			if (Designer.model.activeClip) _frameSlider.setValue(Designer.model.activeClip.index);
			_rateInput.move(_frameInput.right + 5, _frameInput.top);
			_rateUpBtn.move(_rateInput.right + 1, _rateInput.top);
			_rateDownBtn.move(_rateInput.right + 1, _rateInput.top + 12);
			
			var sliderWidth:Number = _frameSlider.width - 32;
			_playBtn.move(_frameSlider.left, _frameSlider.top - 40);
			_prevFrameBtn.move(_frameSlider.left + sliderWidth * 0.33, _frameSlider.top - 40);
			_nextFrameBtn.move(_frameSlider.left + sliderWidth * 0.66, _frameSlider.top - 40);
			_loopBtn.move(_frameSlider.left + sliderWidth, _frameSlider.top - 40);
			
			_maskBtn.move(_columnsInput.right + 15, _columnsInput.top);
			_masksList.move(_maskBtn.left, _maskBtn.bottom + 1);
			
			var containerWidth:Number = _entityContainer.width - 32;
			_spriteSheetBtn.move(_entityContainer.left, _entityContainer.top - 40);
			_maskBtn.move(_entityContainer.left + containerWidth * 0.33, _entityContainer.top - 40);
			_viewBtn.move(_entityContainer.left + containerWidth * 0.66, _entityContainer.top - 40);
			_toolsBtn.move(_entityContainer.left + containerWidth, _entityContainer.top - 40);
			
			_spriteSheetList.move(_spriteSheetBtn.left, _spriteSheetBtn.bottom + 10);
			_masksList.move(_maskBtn.left, _maskBtn.bottom + 10);
			_viewList.move(_viewBtn.left, _viewBtn.bottom + 10);
			_toolsList.move(_toolsBtn.left, _toolsBtn.bottom + 10);
		}
		
		//}
		//{ ------------------------------------ Event handlers ------------------------------------
		
		private function toolsList_Select(l:List, index:int):void 
		{
			
		}
		
		private function spriteSheetList_Select(l:List, index:int):void 
		{
			l.deselectItem(index);
			if (index == 0) Designer.loadImage();
			else if (index == 1)
			{
				Designer.model.selectedGraphic.spritesheet = null;
				Designer.selectGraphic(-1);
			}
		}
		
		private function viewList_Select(l:List, index:int):void 
		{
			if (index == 0)
			{
				_entityContainer.drawMask = l.selected[index];
			}
			else if (index == 1)
			{
				l.deselectItem(index);
				_zoomFactor *= 2;
			}
			else if (index == 2)
			{
				l.deselectItem(index);
				if (_zoomFactor > 1) _zoomFactor /= 2;
			}
			_zoomFactor = int(_zoomFactor);
			
			Designer.model.activeClip.scaleX = _zoomFactor;
			Designer.model.activeClip.scaleY = _zoomFactor;
		}
		
		private function nextFrameBtn_Click(b:BaseButton):void 
		{
			Designer.model.activeClip.paused = true;
			Designer.model.activeClip.index = Designer.model.activeClip.index + 1;
		}
		
		private function prevFrameBtn_Click(b:BaseButton):void 
		{
			Designer.model.activeClip.paused = true;
			Designer.model.activeClip.index = Designer.model.activeClip.index - 1;
		}
		
		private function rateDownBtn_Click(b:BaseButton):void 
		{
			if (_rateInput.value > 0 )
				_rateInput.text = String(int(Math.max(0, _rateInput.value - 5)));
		}
		
		private function rateUpBtn_Click(b:BaseButton):void 
		{
			if (_rateInput.value < 100 )
				_rateInput.text = String(int(Math.max(0, _rateInput.value + 5)));
		}
		
		private function deleteBtn_Click(b:BaseButton):void 
		{
			// Assign new bitmap data object to Graphic.
			Designer.model.selectedGraphic.spritesheet = null;
			Designer.selectGraphic(-1);
		}
		
		private function loopBtn_Click(b:BaseButton):void 
		{
			Designer.model.selectedAnimation.looping = !Designer.model.selectedAnimation.looping;
			if (Designer.model.selectedAnimation.looping) _loopBtn.freeze();
			else _loopBtn.unfreeze();
		}
		
		private function playBtn_Click(b:BaseButton):void 
		{
			if (Designer.model.selectedAnimation && Designer.model.activeClip)
			{
				Designer.model.activeClip.paused = false;
				Designer.model.activeClip.play(Designer.model.selectedAnimation.tag, Designer.model.activeClip.completed);
			}
		}
		
		private function rateInput_Change(t:TextInput):void 
		{
			Designer.model.selectedAnimation.frameRate = t.value / t.maximum;
		}
		
		private function columnsInput_Change(t:TextInput):void 
		{
			_spriteSheetList.items[3] = t.text;
			Designer.model.selectedGraphic.columns = int(t.value);
			Designer.model.update("activeClip", Designer.model.selectedGraphic.newRenderable() as Clip, true);
		}
		
		private function rowsInput_Change(t:TextInput):void 
		{
			_spriteSheetList.items[2] = t.text;
			Designer.model.selectedGraphic.rows = int(t.value);
			Designer.model.update("activeClip", Designer.model.selectedGraphic.newRenderable() as Clip, true);
		}
		
		private function frameSlider_Slide(s:Slider):void 
		{
			Designer.model.activeClip.paused = true;
			Designer.model.activeClip.index = s.value;
		}
		
		private function frameInput_Change(t:TextInput):void 
		{
			Designer.model.selectedAnimation.frames = t.value;
		}
		
		private function addAnimationBtn_Click(b:BaseButton):void 
		{
			Designer.addAnimation();
		}
		
		private function animations_Edit(index:int, text:String):void 
		{
			var valid:Boolean = Designer.changeAnimationTag(index, text);
		}
		
		private function animationsList_Swap(indexA:int, indexB:int):void 
		{
			var success:Boolean = Designer.model.selectedGraphic.animations.swap(indexA, indexB);
			if (success) Designer.model.update("animationsList", null, true);
		}
		
		private function animationsList_Delete(index:int):void 
		{
			Designer.removeAnimation(index);
		}
		
		private function animationsList_Select(list:List, index:int):void 
		{
			Designer.model.update("selectedAnimation", Designer.model.selectedGraphic.animations.getAt(index) as Animation, true);
		}
		
		private function maskList_Select(list:List, index:int):void 
		{
			var selectedGraphic:Graphic = Designer.model.selectedGraphic;
			var selectedFrame:int = Designer.model.activeClip.index;
			
			// Some sanity checks!
			if (selectedGraphic.frameCount >= selectedFrame || selectedFrame < 0)
				throw new DesignerError("index error: trying to set a mask frame out of bounds!");
			
			// Update collision masks for the selected Graphic object.
			if (index == 0)
			{
				selectedGraphic._frameMasks[selectedFrame] = null;
			}
			else if (index == 1)
			{
				selectedGraphic._frameMasks[selectedFrame] = new Point(selectedGraphic.frameRect.width / 2, selectedGraphic.frameRect.height / 2);
			}
			else if (index == 2)
			{
				selectedGraphic._frameMasks[selectedFrame] = new Rectangle();
			}
			else if (index == 3)
			{
				selectedGraphic._frameMasks[selectedFrame] = new BitmapData(selectedGraphic.frameRect.width, selectedGraphic.frameRect.height, true, 0);
			}
		}
		
		private function spriteSheetBtn_Click(b:IconButton):void 
		{
			if (!b.frozen)
			{
				hideAllDropDowns();
				b.freeze();
				_spriteSheetList.show();
			}
			else hideAllDropDowns();
		}
		
		private function viewBtn_Click(b:IconButton):void 
		{
			if (!b.frozen)
			{
				hideAllDropDowns();
				b.freeze();
				_viewList.show();
			}
			else hideAllDropDowns();
		}
		
		private function toolBtn_Click(b:IconButton):void 
		{
			if (!b.frozen)
			{
				hideAllDropDowns();
				b.freeze();
				_toolsList.show();
			}
			else hideAllDropDowns();
		}
		
		private function maskBtn_Click(b:IconButton):void 
		{
			if (!b.frozen)
			{
				hideAllDropDowns();
				b.freeze();
				_masksList.show();
			}
			else hideAllDropDowns();
		}
		
		private function hideButtonRow1():void 
		{
			_maskBtn.unfreeze();
			_spriteSheetBtn.unfreeze();
			_viewBtn.unfreeze();
			_toolsBtn.unfreeze();
			_masksList.hide();
			_spriteSheetList.hide();
			_viewList.hide();
			_toolsList.hide();
		}
		
		private function collisionsBtn_Click(b:IconButton):void 
		{
			if (!b.frozen)
			{
				hideAllDropDowns();
				_collisionsBtn.freeze();
				_collisionsList.show();
			}
			else hideAllDropDowns();
		}
		
		private function animationsBtn_Click(b:IconButton):void 
		{
			if (!b.frozen)
			{
				hideAllDropDowns();
				_animationsBtn.freeze();
				_animationsList.show();
				_addAnimationBtn.show();
			}
			else hideAllDropDowns();
		}
		
		private function collisionsList_Select(list:List, index:int):void 
		{
			var className:String = String(list.items[index]);
			if (Designer.model.selectedGraphic._collideWith.indexOf(className) == -1)
				Designer.model.selectedGraphic._collideWith.push(className);
				
			// Recalculate action mask
			Designer.model.selectedGraphic.calculateActionMask();
		}
		
		private function collisionsList_Deselect(list:List, index:int):void 
		{
			var className:String = String(list.items[index]);
			ArrayUtils.removeItem(className, Designer.model.selectedGraphic._collideWith);
			
			// Recalculate action mask
			Designer.model.selectedGraphic.calculateActionMask();
		}
		
		private function classesList_Select(list:List, index:int):void 
		{
			Designer.model.selectedGraphic.setClass(Engine.__entityClasses[index] as Class);
		}
		
		private function classesBtn_Click(b:BaseButton):void 
		{
			if (!_classesBtn.frozen)
			{
				hideAllDropDowns();
				_classesBtn.freeze();
				_classesList.show();
			}
			else hideAllDropDowns();
		}
		
		private function backBtn_Click(b:BaseButton):void 
		{
			this.parent.addChild(_main);
			this.parent.removeChild(this);
		}
		
		private function hideCollisionsList():void 
		{
			_collisionsBtn.unfreeze();
			_collisionsList.hide();
		}
		
		private function hideClassesList():void 
		{
			_classesBtn.unfreeze();
			_classesList.hide();
		}
		
		private function hideAnimationsList():void 
		{
			_animationsBtn.unfreeze();
			_animationsList.hide();
			_addAnimationBtn.hide();
		}
		
		private function hideAllDropDowns():void 
		{
			hideClassesList();
			hideAnimationsList();
			hideCollisionsList();
			hideButtonRow1();
		}
	}

}