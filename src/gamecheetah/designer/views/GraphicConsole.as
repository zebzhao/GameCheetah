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
	import gamecheetah.utils.GCError;
	
	use namespace hidden;
	
	public class GraphicConsole extends BaseComponent 
	{
		private var
			_main:MainConsole;
			
		private var _zoomFactor:Number = 1;
		private var _mousePos:Point = new Point();
		
		private var
			_drawRect:Boolean,
			_drawBitmap:Boolean,
			_eraseBitmap:Boolean;
			
		private var
			_backBtn:IconButton, _classesBtn:IconButton, _animationsBtn:IconButton, _collisionsBtn:IconButton,
			_classesList:List, _animationsList:List, _collisionsList:List,
			_masksList:List, _viewList:List, _spriteSheetList:List, _toolsList:List,
			_addAnimationBtn:IconButton, _rateUpBtn:IconButton, _rateDownBtn:IconButton,
			_playBtn:IconToggleButton, _prevFrameBtn:IconButton, _nextFrameBtn:IconButton, _loopBtn:IconButton,
			_entityContainer:ZoomPanel, _zoomFactorLbl:Label,
			_spriteSheetBtn:IconButton, _maskBtn:IconButton, _viewBtn:IconButton, _toolsBtn:IconButton,
			_framesSlider:Slider,
			_framesInput:TextInput, _rateInput:TextInput,
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
					_collisionsList.selectItem(i, false);
				else
					_collisionsList.deselectItem(i, false);
					
			// Set spritesheet options
			if (!value.hasSpritesheet) _entityContainer.content = null;
			_rowsInput.text = value.rows.toString();
			_columnsInput.text = value.columns.toString();
		}
		
		public function get animationsList():Array { return null };
		public function set animationsList(value:Array):void
		{
			_animationsList.items = value ? value : [];
		}
		
		public function get selectedAnimation():Animation { return null };
		public function set selectedAnimation(value:Animation):void
		{
			if (!value || !Designer.model.activeClip)
			{
				_animationsList.deselectAll(false);
				_framesInput.text = "";
				_framesSlider.setBounds(0, 1, 1);
				_rateInput.text = "";
				_loopBtn.unfreeze();
				return;
			}
			
			Designer.model.activeClip.play(value.tag, true);
			
			_animationsList.selectItem(Designer.model.selectedGraphic.animations.indexOfKey(value.tag));
			_framesInput.text = value.frames.toString();
			_framesSlider.setBounds(0, value.frames.length - 1, 1);
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
			_entityContainer.mouseDown = entityContainer_MouseDown;
			_entityContainer.mouseUp = entityContainer_MouseUp;
			_zoomFactorLbl = new Label(_entityContainer, "1x", Style.FONT_HEADER, Label.ALIGN_INNER_TOP_LEFT);
			_zoomFactorLbl.alpha = 0;
			
			_prevFrameBtn = new IconButton(this, Assets.SEEK_BACK, prevFrameBtn_Click, "Next Frame", Label.ALIGN_ABOVE);
			_nextFrameBtn = new IconButton(this, Assets.SEEK_FORWARD, nextFrameBtn_Click, "Prev Frame", Label.ALIGN_ABOVE);
			_playBtn = new IconToggleButton(this, Assets.PAUSE, Assets.PLAY, playBtn_Click, "Pause", "Play", Label.ALIGN_ABOVE);
			_loopBtn = new IconButton(this, Assets.LOOP, loopBtn_Click, "Loop", Label.ALIGN_ABOVE);
			_rateUpBtn = new IconButton(this, Assets.ARROW_UP, rateUpBtn_Click, "", Label.ALIGN_RIGHT);
			_rateDownBtn = new IconButton(this, Assets.ARROW_DOWN, rateDownBtn_Click, "", Label.ALIGN_RIGHT);
			
			_framesSlider = new Slider(this, 250, 8, Slider.HORIZONTAL, 0, 0, 1, framesSlider_Slide);
			_framesInput = new TextInput(this, 195, 25, framesInput_Change, "Frame Sequence", TextInput.TYPE_UINT_VECTOR);
			_framesInput.setHint("Animation Sequence", Label.ALIGN_BELOW);
			_rateInput = new TextInput(this, 50, 25, rateInput_Change, "Rate", TextInput.TYPE_UINT);
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
			_masksList = new List(this, ["None", "Point", "Rectangle", "Bitmap"], 4, 100, 25, masksList_Select, null, null, null, null, false, false, false);
			_viewList = new List(this, ["Show Mask", "Zoom In", "Zoom Out"], 3, 100, 25, viewList_Select, null, null, null, null, false, false, false);
			_viewList.multiselect = true;
			_viewList.selectItem(0);
			_spriteSheetList = new List(this, ["Browse...", "Discard", "", ""], 4, 100, 25, spriteSheetList_Select, null, null, null, null, false, false, false);
			_toolsList = new List(this, [], 6, 100, 25, toolsList_Select, null, null, null, null, false, false, false);
			_toolsList.multiselect = true;
			
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

			_entityContainer.move(stageWidth * 0.5 - 125, stageHeight * 0.5 - (_entityContainer.height + 70) / 2);
			
			_framesInput.move(_entityContainer.left, _entityContainer.bottom + 100);
			_framesSlider.move(_framesInput.left, _framesInput.top - 15);
			_rateInput.move(_framesInput.right + 5, _framesInput.top);
			_rateUpBtn.move(_rateInput.right + 1, _rateInput.top);
			_rateDownBtn.move(_rateInput.right + 1, _rateInput.top + 12);
			
			var sliderWidth:Number = _framesSlider.width - 32;
			_playBtn.move(_framesSlider.left, _framesSlider.top - 40);
			_prevFrameBtn.move(_framesSlider.left + sliderWidth * 0.33, _framesSlider.top - 40);
			_nextFrameBtn.move(_framesSlider.left + sliderWidth * 0.66, _framesSlider.top - 40);
			_loopBtn.move(_framesSlider.left + sliderWidth, _framesSlider.top - 40);
			
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
			
			if (Designer.model.activeClip)
			{
				// Update frame slider position
				var activeClip:Clip = Designer.model.activeClip;
				_framesSlider.setValue(activeClip.index);
				
				// Update playback button
				_playBtn.selected = activeClip.paused || activeClip.completed;
				
				// Update mask selection
				var selectedGraphic:Graphic = Designer.model.selectedGraphic;
				var frameMask:* = Designer.getUnscaledCollisionMask();
				
				if (frameMask is BitmapData)
					_masksList.selectItem(3, false);
				else if (frameMask is Rectangle)
					_masksList.selectItem(2, false);
				else if (frameMask is Point)
					_masksList.selectItem(1, false);
				else if (frameMask == null)
					_masksList.selectItem(0, false);
				else
					throw new DesignerError("unrecognized frame mask found!");
					
				// Show extra options when editing Bitmap
				_toolsList.items = _masksList.selectedIndex == 3 ? ["Single Mask", "Load...", "Draw", "Erase", "Fill", "Clear"] : ["Single Mask"];
				_toolsList.selected[0] = Designer.model.selectedGraphic.alwaysUseDefaultMask;
				
				var currentPos:Point = new Point(
					int((_entityContainer.mouseX - _entityContainer.contentOffset.x) / _entityContainer.contentScale),
					int((_entityContainer.mouseY - _entityContainer.contentOffset.y) / _entityContainer.contentScale));
				
				// Draw collision mask
				if (_drawRect)
				{
					var rect:Rectangle = new Rectangle(
						Math.min(currentPos.x, _mousePos.x), Math.min(currentPos.y, _mousePos.y),
						Math.abs(currentPos.x - _mousePos.x), Math.abs(currentPos.y - _mousePos.y));
					
					Designer.setCollisionMask(rect.intersection(selectedGraphic.frameRect));
				}
				else if (_drawBitmap)
				{
					drawLine(frameMask as BitmapData, int(_mousePos.x), int(_mousePos.y), int(currentPos.x), int(currentPos.y), 0x90ff0000);
					_mousePos.copyFrom(currentPos);
				}
				else if (_eraseBitmap)
				{
					drawLine(frameMask as BitmapData, int(_mousePos.x), int(_mousePos.y), int(currentPos.x), int(currentPos.y), 0);
					_mousePos.copyFrom(currentPos);
				}
			}
		}
		
		//}
		//{ ------------------------------------ Event handlers ------------------------------------
		
		private function toolsList_Select(l:List, index:int):void 
		{
			if (l.items.length >= 6)
			{
				l.deselectItem(1);
				l.deselectItem(2);
				l.deselectItem(3);
				l.deselectItem(4);
				l.deselectItem(5);
			}
			
			// Sanity checks
			if (!Designer.model.activeClip) return;
			
			if (index == 0)
			{
				Designer.model.selectedGraphic.alwaysUseDefaultMask = l.selected[index];
			}
			else if (index == 1)
			{
				// Load collision bitmap object from  file.
				Designer.loadMaskImage();
			}
			else if (index == 5)
			{
				// Clear collision bitmap object.
				var bmd:BitmapData = Designer.getUnscaledCollisionMask() as BitmapData;
				bmd.fillRect(bmd.rect, 0);
			}
			else
			{
				l.selectItem(index, false);
			}
			
			// Pause playback
			Designer.model.activeClip.paused = true;
		}
		
		private function entityContainer_MouseUp(p:ZoomPanel):void 
		{
			_drawRect = false;
			_drawBitmap = false;
			_eraseBitmap = false;
		}
		
		private function entityContainer_MouseDown(p:ZoomPanel):void 
		{
			_drawRect = false;
			_drawBitmap = false;
			_eraseBitmap = false;
			
			// Start draw mode.
			_mousePos.setTo(int((p.mouseX - p.contentOffset.x) / p.contentScale), int((p.mouseY - p.contentOffset.y) / p.contentScale));
				
			if (_masksList.selectedIndex == 1)
			{
				Designer.setCollisionMask(new Point(_mousePos.x, _mousePos.y));
			}
			else if (_masksList.selectedIndex == 2)
			{
				_drawRect = true;
			}
			else if (_masksList.selectedIndex == 3)
			{
				if (_toolsList.selected[2])
				{
					_drawBitmap = true;
				}
				else if (_toolsList.selected[3])
				{
					_eraseBitmap = true;
				}
				else if (_toolsList.selected[4])
				{
					(Designer.getUnscaledCollisionMask() as BitmapData).floodFill(_mousePos.x, _mousePos.y, 0x90ff0000);
				}
			}
		}
		
		private function spriteSheetList_Select(l:List, index:int):void 
		{
			l.deselectItem(index);
			if (index == 0)
			{
				Designer.loadImage();
				Designer.selectGraphic(-1);
			}
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
			else
			{
				if (index == 1)
				{
					// Zoom in 2x
					l.deselectItem(index);
					_zoomFactor *= 2;
				}
				else if (index == 2)
				{
					// Zoom out 0.5x
					l.deselectItem(index);
					if (_zoomFactor > 1) _zoomFactor /= 2;
				}
				_zoomFactor = int(_zoomFactor);
				_entityContainer.contentScale = _zoomFactor;
				_zoomFactorLbl.text = _zoomFactor.toString() + "x";
				_zoomFactorLbl.tweenClip( { "alpha": 1 }, { "alpha": 0 }, 1, null, 1);
			}
		}
		
		private function nextFrameBtn_Click(b:BaseButton):void 
		{
			if (Designer.model.activeClip)
			{
				Designer.model.activeClip.paused = true;
				Designer.model.activeClip.index = Designer.model.activeClip.index + 1;
			}
		}
		
		private function prevFrameBtn_Click(b:BaseButton):void 
		{
			if (Designer.model.activeClip)
			{
				Designer.model.activeClip.paused = true;
				Designer.model.activeClip.index = Designer.model.activeClip.index - 1;
			}
		}
		
		private function rateDownBtn_Click(b:BaseButton):void 
		{
			if (_rateInput.value > 0)
				_rateInput.text = String(int(Math.max(0, _rateInput.value - 5)));
		}
		
		private function rateUpBtn_Click(b:BaseButton):void 
		{
			if (_rateInput.value < 100)
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
			if (Designer.model.selectedAnimation)
			{
				Designer.model.selectedAnimation.looping = !Designer.model.selectedAnimation.looping;
				if (Designer.model.selectedAnimation.looping) _loopBtn.freeze();
				else _loopBtn.unfreeze();
			}
		}
		
		private function playBtn_Click(b:IconToggleButton):void 
		{
			if (Designer.model.activeClip)
			{
				if (!b.selected)
				{
					// Pause playback
					Designer.model.activeClip.paused = true;
				}
				else if (Designer.model.selectedAnimation)
				{
					// Resume playback from current frame
					Designer.model.activeClip.paused = false;
					Designer.model.activeClip.play(Designer.model.selectedAnimation.tag, Designer.model.activeClip.completed);
				}
			}
		}
		
		private function rateInput_Change(t:TextInput):void 
		{
			if (Designer.model.selectedAnimation)
			{
				Designer.model.selectedAnimation.frameRate = t.value / t.maximum;
			}
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
		
		private function framesSlider_Slide(s:Slider):void 
		{
			if (Designer.model.activeClip)
			{
				Designer.model.activeClip.paused = true;
				Designer.model.activeClip.index = s.value;
			}
		}
		
		private function framesInput_Change(t:TextInput):void 
		{
			Designer.updateAnimationFrames(t.value);
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
			if (!b.frozen && Designer.model.activeClip)
			{
				hideAllDropDowns();
				b.freeze();
				_viewList.show();
			}
			else hideAllDropDowns();
		}
		
		private function toolBtn_Click(b:IconButton):void 
		{
			if (!b.frozen && Designer.model.activeClip)
			{
				hideAllDropDowns();
				b.freeze();
				_toolsList.show();
			}
			else hideAllDropDowns();
		}
		
		private function maskBtn_Click(b:IconButton):void 
		{
			if (!b.frozen && Designer.model.activeClip)
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
		
		private function masksList_Select(list:List, index:int):void 
		{
			// Sanity checks.
			if (!Designer.model.selectedGraphic.hasSpritesheet) return;
			
			// Update collision masks for the selected Graphic object.
			if (index == 0)
			{
				Designer.setCollisionMask(null);
			}
			else if (index == 1)
			{
				Designer.setCollisionMask(new Point());
			}
			else if (index == 2)
			{
				Designer.setCollisionMask(new Rectangle());
			}
			else if (index == 3)
			{
				Designer.setCollisionMask(
					new BitmapData(Designer.model.selectedGraphic.frameRect.width, Designer.model.selectedGraphic.frameRect.height, true, 0));
			}
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
			var collideWith:Array = Designer.model.selectedGraphic._collideWith;
			collideWith.splice(collideWith.indexOf(className), 1);
			
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
		
		//{ ------------------------------------ Private methods ------------------------------------
		
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
		
		/**
		 * Extremely Fast Line Algorithm written by Po-Han Lin
		 * Taken from: http://www.simppa.fi/blog/extremely-fast-line-algorithm-as3-optimized/
		 */
		public static function drawLine(bitmapData:BitmapData, x:int, y:int, x2:int, y2:int, color:uint):void
		{
			var shortLen:int = y2 - y;
			var longLen:int = x2 - x;
			if ((shortLen ^ (shortLen >> 31)) - (shortLen >> 31) > (longLen ^ (longLen >> 31)) - (longLen >> 31))
			{
				shortLen ^= longLen;
				longLen ^= shortLen;
				shortLen ^= longLen;
				
				var yLonger:Boolean = true;
			}
			else
			{
				yLonger = false;
			}
			
			var inc:int = longLen < 0 ? -1 : 1;
			
			var multDiff:Number = longLen == 0 ? shortLen : shortLen / longLen;
			
			if (yLonger)
			{
				for (var i:int = 0; i != longLen; i += inc)
				{
					bitmapData.setPixel32(x + i * multDiff, y + i, color);
				}
			}
			else
			{
				for (i = 0; i != longLen; i += inc)
				{
					bitmapData.setPixel32(x + i, y + i * multDiff, color);
				}
			}
		}
	}

}