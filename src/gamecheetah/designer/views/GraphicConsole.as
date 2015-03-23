/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import gamecheetah.*;
	import gamecheetah.designer.components.*;
	import gamecheetah.designer.Designer;
	import gamecheetah.graphics.*;
	import gamecheetah.namespaces.*;
	import gamecheetah.utils.ArrayUtils;
	
	use namespace hidden;
	
	public class GraphicConsole extends Space 
	{
		private var
			_main:Space;
			
		private var
			_backBtn:IconButton, _classesBtn:IconButton, _animationsBtn:IconButton, _collisionsBtn:IconButton,
			_classesList:List, _animationsList:List, _collisionsList:List,
			_addAnimationBtn:IconButton, _rateUpBtn:IconButton, _rateDownBtn:IconButton,
			_playBtn:IconButton, _prevFrameBtn:IconButton, _nextFrameBtn:IconButton, _loopBtn:IconButton,
			_entityContainer:ZoomPanel,
			_spriteSheetBtn:IconButton, _deleteBtn:IconButton,
			_frameSlider:Slider,
			_dimensionsLbl:Label,
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
				_deleteBtn.show();
			}
			else
			{
				_rowsInput.hide();
				_columnsInput.hide();
				_deleteBtn.hide();
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
			
			_animationsList.selectItem(Designer.model.selectedGraphic.animations.indexOfKey(value.tag));
			_frameInput.text = value.frames.toString();
			_frameSlider.setBounds(0, value.frames.length - 1, 1);
			
			if (_spriteSheetBtn.clip) _spriteSheetBtn.clip.play(value.tag);
			
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
			_entityContainer.content = value;
			if (Designer.model.selectedAnimation)
				value.play(Designer.model.selectedAnimation.tag);
		}
		
		//}
		//{ ------------------------------------ Constructor ------------------------------------
		
		public function GraphicConsole(main:Space) 
		{
			_main = main;
			
			_entityContainer = new ZoomPanel(this, null, 250, 250);
			
			_backBtn = new IconButton(this, Assets.EXIT, backBtn_Click, "Back", Label.ALIGN_BELOW);
			_classesBtn = new IconButton(this, Assets.CLASSES, classesBtn_Click, "Classes", Label.ALIGN_BELOW);
			_animationsBtn = new IconButton(this, Assets.ANIMATIONS, animationsBtn_Click, "Animations", Label.ALIGN_BELOW);
			_collisionsBtn = new IconButton(this, Assets.COLLISIONS, collisionsBtn_Click, "Collide With...", Label.ALIGN_BELOW);
			
			_addAnimationBtn = new IconButton(this, Assets.ADD, addAnimationBtn_Click, "Add", Label.ALIGN_BELOW);
			
			_classesList = new List(this, Engine.__entityClasses, 8, 150, 25, classesList_Select, null, null, null, null, false, false, false); 
			_animationsList = new List(this, [], 8, 150, 25, animationsList_Select, null, animationsList_Delete, animationsList_Swap, animations_Edit, true, true, true);
			_collisionsList = new List(this, Engine.__collisionClasses, 8, 150, 25, collisionsList_Select, collisionsList_Deselect, null, null, null, false, false, false);
			_collisionsList.multiselect = true;
			
			_prevFrameBtn = new IconButton(this, Assets.SEEK_BACK, prevFrameBtn_Click, "Next Frame", Label.ALIGN_ABOVE);
			_nextFrameBtn = new IconButton(this, Assets.SEEK_FORWARD, nextFrameBtn_Click, "Prev Frame", Label.ALIGN_ABOVE);
			_playBtn = new IconButton(this, Assets.PLAY, playBtn_Click, "Replay", Label.ALIGN_ABOVE);
			_loopBtn = new IconButton(this, Assets.LOOP, loopBtn_Click, "Loop", Label.ALIGN_ABOVE);
			_spriteSheetBtn = new IconButton(this, Assets.SPRITESHEET, spriteSheetBtn_Click, "Choose Sprite Sheet", Label.ALIGN_ABOVE);
			_deleteBtn = new IconButton(this, Assets.CLEAR, deleteBtn_Click, "Discard Sprite Sheet", Label.ALIGN_ABOVE);
			_rateUpBtn = new IconButton(this, Assets.ARROW_UP, rateUpBtn_Click, "", Label.ALIGN_RIGHT);
			_rateDownBtn = new IconButton(this, Assets.ARROW_DOWN, rateDownBtn_Click, "", Label.ALIGN_RIGHT);
			
			_frameSlider = new Slider(this, 250, 8, Slider.HORIZONTAL, 0, 0, 1, frameSlider_Slide);
			_frameInput = new TextInput(this, 195, 25, frameInput_Change, "Frame Sequence", TextInput.TYPE_UINT_VECTOR);
			_rateInput = new TextInput(this, 50, 25, rateInput_Change, "Rate", TextInput.TYPE_UINT_VECTOR);
			_rateInput.minimum = 0;  _rateInput.maximum = 100;
			
			_rowsInput = new TextInput(this, 60, 25, rowsInput_Change, "Rows", TextInput.TYPE_UINT);
			_rowsInput.minimum = 1;  _rowsInput.maximum = 200;
			_columnsInput = new TextInput(this, 60, 25, columnsInput_Change, "Cols", TextInput.TYPE_UINT);
			_columnsInput.minimum = 1;  _columnsInput.maximum = 200;
			
			_dimensionsLbl = new Label(this, "Dimensions", _rowsInput, Label.ALIGN_VABOVE_LEFT, Style.HEADER_BASE);
			
			Designer.model.bind("selectedGraphic", this, true);
			Designer.model.bind("animationsList", this, true);
			Designer.model.bind("selectedAnimation", this, true);
			Designer.model.bind("activeClip", this, true);
		}
		
		//}
		//{ ------------------------------------ Behaviour Overrides ------------------------------------
		
		override public function onEnter():void 
		{
			this.mouseEnabled = true;
			hideClassesList();
			hideAnimationsList();
			hideCollisionsList();
			onUpdate();
		}
		
		override public function onUpdate():void 
		{
			var stageWidth:int = Engine.buffer.width;
			var stageHeight:int = Engine.buffer.height;
			
			_classesBtn.move(stageWidth * 0.1 - 16, 10);
			_classesBtn.setDepth(10);
			_classesList.move(_classesBtn.left, _classesBtn.bottom + 25);
			
			_animationsBtn.move(stageWidth * 0.367 - 16, 10);
			_animationsBtn.setDepth(10);
			_animationsList.move(_animationsBtn.left, _animationsBtn.bottom + 25);
			_addAnimationBtn.move(_animationsList.left, _animationsList.bottom + 5);
			
			_collisionsBtn.move(stageWidth * 0.633 - 16, 10);
			_collisionsBtn.setDepth(10);
			_collisionsList.move(_collisionsBtn.left, _collisionsBtn.bottom + 25);
			
			_backBtn.move(stageWidth * 0.9 - 16, 10);
			_backBtn.setDepth(10);
			
			_entityContainer.move(stageWidth * 0.5 - 125, stageHeight * 0.45 - 125);
			
			_frameInput.move(_entityContainer.left, _entityContainer.bottom + 90);
			_frameSlider.move(_frameInput.left, _frameInput.top - 15);
			if (Designer.model.activeClip) _frameSlider.setValue(Designer.model.activeClip.index);
			_rateInput.move(_frameInput.right + 5, _frameInput.top);
			_rateUpBtn.move(_rateInput.right + 1, _rateInput.top);
			_rateDownBtn.move(_rateInput.right + 1, _rateInput.top + 12);
			
			var sliderWidth:int = _frameSlider.renderable.width - 32;
			_playBtn.move(_frameSlider.left, _frameSlider.top - 40);
			_prevFrameBtn.move(_frameSlider.left + sliderWidth * 0.33, _frameSlider.top - 40);
			_nextFrameBtn.move(_frameSlider.left + sliderWidth * 0.66, _frameSlider.top - 40);
			_loopBtn.move(_frameSlider.left + sliderWidth, _frameSlider.top - 40);
			
			_rowsInput.move(_entityContainer.left, _entityContainer.top - 35);
			_columnsInput.move(_rowsInput.right + 5, _rowsInput.top);
			_deleteBtn.move(_entityContainer.right - 32, _entityContainer.top - 37);
			_spriteSheetBtn.move(_entityContainer.right - 90, _entityContainer.top - 37);
		}
		
		//}
		//{ ------------------------------------ Event handlers ------------------------------------
		
		private function nextFrameBtn_Click(b:BaseButton):void 
		{
			
		}
		
		private function prevFrameBtn_Click(b:BaseButton):void 
		{
			
		}
		
		private function rateDownBtn_Click(b:BaseButton):void 
		{
			
		}
		
		private function rateUpBtn_Click(b:BaseButton):void 
		{
			
		}
		
		private function spriteSheetBtn_Click(b:BaseButton):void 
		{
			Designer.loadImage();
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
				Designer.model.activeClip.play(Designer.model.selectedAnimation.tag, true);
		}
		
		private function rateInput_Change(t:TextInput):void 
		{
			Designer.model.selectedAnimation.frameRate = t.value / t.maximum;
		}
		
		private function columnsInput_Change(t:TextInput):void 
		{
			Designer.model.selectedGraphic.columns = int(t.value);
			Designer.model.update("activeClip", Designer.model.selectedGraphic.newRenderable() as Clip, true);
		}
		
		private function rowsInput_Change(t:TextInput):void 
		{
			Designer.model.selectedGraphic.rows = int(t.value);
			Designer.model.update("activeClip", Designer.model.selectedGraphic.newRenderable() as Clip, true);
		}
		
		private function frameSlider_Slide(s:Slider):void 
		{
			Designer.model.activeClip.paused = true;
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
		
		private function collisionsBtn_Click(b:BaseButton):void 
		{
			if (!_collisionsBtn.frozen)
			{
				_collisionsBtn.freeze();
				_collisionsList.show();
				hideAnimationsList();
				hideClassesList();
			}
			else hideCollisionsList();
		}
		
		private function animationsBtn_Click(b:BaseButton):void 
		{
			if (!_animationsBtn.frozen)
			{
				_animationsBtn.freeze();
				_animationsList.show();
				_addAnimationBtn.show();
				hideCollisionsList();
				hideClassesList();
			}
			else hideAnimationsList();
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
				_classesBtn.freeze();
				_classesList.show();
				hideAnimationsList();
				hideCollisionsList();
			}
			else hideClassesList();
		}
		
		private function backBtn_Click(b:BaseButton):void 
		{
			this.engine.swapSpace(_main);
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
	}

}