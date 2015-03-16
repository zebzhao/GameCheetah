/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import gamecheetah.*;
	import gamecheetah.designer.Designer;
	import gamecheetah.designer.views.components.*;
	import gamecheetah.namespaces.*;
	
	use namespace hidden;
	
	/**
	 * Wraps the active Space object to provide a convenient interface for the Designer class.
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}. Game Cheetah (c) 2015. 
	 * @version		1.0
	 * @private
	 */
	CONFIG::developer
	public final class SpaceView extends InterfaceGroup
	{
		
		private static const GRID_COLOR:uint = 0xAAAAAA;
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Public properties
		
		/**
		 * The active space object.
		 */
		public function get activeSpace():Space 
		{
			return _activeSpace;
		}
		public function set activeSpace(value:Space):void 
		{
			if (value == null) return;
			_activeSpace = value;
			drawGrid();
			drawArrows();
		}
		private var _activeSpace:Space;
		
		/**
		 * Highlight the selected entity.
		 */
		public function get selectedEntity():Entity 
		{
			return _selectedEntity;
		}
		public function set selectedEntity(value:Entity):void 
		{
			if (value == null)
			{
				selection.graphics.clear();
				return;
			}
			_selectedEntity = value;
			drawSelectionRectangle();
		}
		private var _selectedEntity:Entity;
		
		/**
		 * True if topleft edge of entities snap to the grid.
		 */
		public var gridSnapping:Boolean;
		
		/**
		 * Width spacing of grid lines.
		 */
		public function get gridW():uint 
		{
			return _gridW;
		}
		public function set gridW(value:uint):void
		{
			_gridW = value;
			refresh();
		}
		private var _gridW:uint;
		
		/**
		 * Height spacing of grid lines.
		 */
		public function get gridH():uint 
		{
			return _gridH;
		}
		public function set gridH(value:uint):void
		{
			_gridH = value;
			refresh();
		}
		private var _gridH:uint;
		
		/**
		 * Enables space manipulating. (Uses stage as base for listeners.)
		 */
		public function get disabled():Boolean 
		{
			return _disabled; 
		}
		public function set disabled(value:Boolean):void 
		{
			if (value == _disabled) return;
			
			_disabled = value;
			if (_disabled) removeListeners();
			else addListeners();
		}
		private var _disabled:Boolean;
		
		//} Public properties
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private var _dirty:Boolean;
		private var _lastRenderedRect:Rectangle;
		
		private var _draggingMarker:Boolean;
		private var _draggingEntity:Boolean;
		private var _dragEntityMouseOffset:Point = new Point();
		
		private var
			overlay:Sprite,
			selection:Shape,
			startMarker:IconPushButton,
			leftArrow:IconPushButton,
			rightArrow:IconPushButton,
			upArrow:IconPushButton,
			downArrow:IconPushButton,
			upleftArrow:IconPushButton,
			uprightArrow:IconPushButton,
			downleftArrow:IconPushButton,
			downrightArrow:IconPushButton;
		
		
		public function SpaceView(parent:DisplayObjectContainer) 
		{
			this._lastRenderedRect = new Rectangle();
			super(parent, 0, 0);
		}
		
		/**
		 * Redraw arrows and grid next frame.
		 */
		public function refresh():void 
		{
			_dirty = true;
		}
		
		override protected function build():void 
		{
			leftArrow = new IconPushButton(this, 0, 0, "", new Assets.Arrow, Arrow_onClick);
			rightArrow = new IconPushButton(this, 0, 0, "", new Assets.Arrow, Arrow_onClick);
			upArrow = new IconPushButton(this, 0, 0, "", new Assets.Arrow, Arrow_onClick);
			downArrow = new IconPushButton(this, 0, 0, "", new Assets.Arrow, Arrow_onClick);
			upleftArrow = new IconPushButton(this, 0, 0, "", createBitmap(Assets.Arrow, true), Arrow_onClick);
			uprightArrow = new IconPushButton(this, 0, 0, "", createBitmap(Assets.Arrow, true), Arrow_onClick);
			downleftArrow = new IconPushButton(this, 0, 0, "", createBitmap(Assets.Arrow, true), Arrow_onClick);
			downrightArrow = new IconPushButton(this, 0, 0, "", createBitmap(Assets.Arrow, true), Arrow_onClick);
			startMarker = new IconPushButton(this, 0, 0, "", new Assets.Mark);
			overlay = new Sprite();
			selection = new Shape();
		}
		
		override protected function initialize():void 
		{
			Designer.model.bind("selectedEntity", this, true);
			Designer.model.bind("activeSpace", this, true);
			
			startMarker.backgroundVisible = false;
			leftArrow.rotation = 0;
			rightArrow.rotation = 180;
			upArrow.rotation = 90;
			downArrow.rotation = -90;
			upleftArrow.rotation = 45;
			uprightArrow.rotation = 135;
			downleftArrow.rotation = -45;
			downrightArrow.rotation = -135;
			
			startMarker.setSize(24, 24);
			leftArrow.setSize(24, 24);
			rightArrow.setSize(24, 24);
			upArrow.setSize(24, 24);
			downArrow.setSize(24, 24);
			upleftArrow.setSize(24, 24);
			uprightArrow.setSize(24, 24);
			downleftArrow.setSize(24, 24);
			downrightArrow.setSize(24, 24);
			
			leftArrow.visible = rightArrow.visible = upArrow.visible = downArrow.visible = false;
			upleftArrow.visible = uprightArrow.visible = downleftArrow.visible = downrightArrow.visible = false;
			
			leftArrow.backgroundVisible = rightArrow.backgroundVisible = upArrow.backgroundVisible = downArrow.backgroundVisible = false;
			upleftArrow.backgroundVisible = uprightArrow.backgroundVisible = downleftArrow.backgroundVisible = downrightArrow.backgroundVisible = false;
			
			overlay.alpha = 0.5;
			this.addChild(overlay);
			this.addChild(selection);
		}
		
		override protected function addListeners():void 
		{
			startMarker.addEventListener(MouseEvent.MOUSE_DOWN, startMarker_onMouseDown);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			Engine.instance.displayObject.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Engine.instance.displayObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Engine.instance.displayObject.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Engine.instance.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}
		
		private function removeListeners():void 
		{
			startMarker.removeEventListener(MouseEvent.MOUSE_DOWN, startMarker_onMouseDown);
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			Engine.instance.displayObject.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Engine.instance.displayObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Engine.instance.displayObject.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Input event listeners
		
		/**
		 * Mouse click event handler for Arrow buttons
		 */
		private function Arrow_onClick(e:Event):void
		{
			if (e.target == leftArrow)
				activeSpace.expand(-100, 0);
			
			else if (e.target == rightArrow)
				activeSpace.expand(100, 0);
			
			else if (e.target == upArrow)
				activeSpace.expand(0, -100);
			
			else if (e.target == downArrow)
				activeSpace.expand(0, 100);
			
			else if (e.target == upleftArrow)
				activeSpace.expand(-100, -100);
				
			else if (e.target == uprightArrow)
				activeSpace.expand(100, -100);
				
			else if (e.target == downleftArrow)
				activeSpace.expand(-100, 100);
				
			else if (e.target == downrightArrow)
				activeSpace.expand(100, 100);
				
			Designer.updateScrollBounds();
		}
		
		/**
		 * Called every frame.
		 */
		private function onEnterFrame(e:Event):void 
		{
			if (_activeSpace == null) return;
			
			// Update start marker location.
			if (!_draggingMarker)
			{
				startMarker.x = _activeSpace.startLocation.x - _activeSpace.camera.x - startMarker.width / 2;
				startMarker.y = _activeSpace.startLocation.y - _activeSpace.camera.y - startMarker.height / 2;
			}
			
			if (!_lastRenderedRect.equals(_activeSpace._screenBounds))
			{
				if (!_dirty)
				{
					leftArrow.visible = rightArrow.visible = upArrow.visible = downArrow.visible = false
					upleftArrow.visible = uprightArrow.visible = downleftArrow.visible = downrightArrow.visible = false;
					
					overlay.graphics.clear();
				}
				
				// Update last position, so display objects are only redrawn after screen moves or resizes.
				_lastRenderedRect.copyFrom(_activeSpace._screenBounds);
				_dirty = true;
				
				drawSelectionRectangle();
			}
			else if (_dirty)
			{
				_dirty = false;
				
				drawGrid();
				drawArrows();
				drawSelectionRectangle();
			}
		}
		
		private function startMarker_onMouseDown(e:MouseEvent):void 
		{
			startMarker.startDrag();
			_draggingMarker = true;
		}
		
		/**
		 * Mouse press event handler for Stage.
		 */
		private function onMouseDown(e:MouseEvent):void 
		{
			if (_activeSpace == null) return;
			
			// Get game coordinates of the mouse.
			var x:Number = e.stageX + _activeSpace.camera.x,
				y:Number = e.stageY + _activeSpace.camera.y;
			
			// Get entities under the mouse.
			var entities:Vector.<Entity> = _activeSpace.queryPoint(x, y);
			var entity:Entity;
			var selected:Entity;
			var point:Point = new Point();
			
			if (entities.length > 0)
			{
				for each (entity in entities)
				{
					// Select only the one topmost entity.
					if (selected == null || entity.depth > selected.depth)
					{
						// Check click is on opaque area of the bitmap.
						point.setTo(x, y);
						if (entity.renderable.buffer.hitTest(entity.location, 1, point)) selected = entity;
					}
				}
			}
			
			// Fires a notification that an entity was clicked.
			if (selected != null)
			{
				_draggingEntity = true;
				_dragEntityMouseOffset.setTo(x - selected.location.x, y - selected.location.y);
				Designer.model.update("selectedEntity", selected, true);
			}
		}
		
		/**
		 * Mouse move event handler for Stage.
		 */
		public function onMouseMove(e:MouseEvent):void 
		{
			if (_draggingEntity)
			{
				var x:int, y:int;
				
				if (gridSnapping)
				{
					// Snap entity to grid when being dragged
					var w:int = _gridW >= 1 ? _gridW : 1;
					var h:int = _gridH >= 1 ? _gridH : 1;
					x = Math.floor((e.stageX - _dragEntityMouseOffset.x + _activeSpace.camera.x) / w) * w;
					y = Math.floor((e.stageY - _dragEntityMouseOffset.y + _activeSpace.camera.y) / h) * h;
				}
				else
				{
					// Normal dragging
					x = e.stageX + _activeSpace.camera.x - _dragEntityMouseOffset.x;
					y = e.stageY + _activeSpace.camera.y - _dragEntityMouseOffset.y;
				}
				
				var clipRect:Rectangle = _selectedEntity.bounds.clone();
				var spaceRect:Rectangle = _activeSpace.bounds;
				
				selectedEntity.location.x = Math.max(spaceRect.left, Math.min(x, spaceRect.right - clipRect.width));
				selectedEntity.location.y = Math.max(spaceRect.top, Math.min(y, spaceRect.bottom - clipRect.height));
				drawSelectionRectangle();
			}
		}
		
		/**
		 * Needed for some drag and drop features.
		 */
		private function onStageMouseUp(e:MouseEvent):void 
		{
			// Stop drag start marker.
			if (_draggingMarker)
			{
				// Update start location.
				_activeSpace.startLocation.setTo(
					startMarker.x + _activeSpace.camera.x + startMarker.width / 2,
					startMarker.y + _activeSpace.camera.y + startMarker.height / 2);
					
				_draggingMarker = false;
				stopDrag();
			}
		}
		
		/**
		 * Mouse release event handler.
		 */
		private function onMouseUp(e:MouseEvent):void 
		{
			// Stop drag entity.
			if (_draggingEntity)
			{
				_draggingEntity = false;
				drawSelectionRectangle();
			}	
		}
		
		//} Input event listeners
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function createBitmap(klass:Class, smoothing:Boolean):Bitmap 
		{
			var result:Bitmap = new klass();
			result.smoothing = smoothing;
			return result;
		}
		/**
		 * Draws selection rectangle for entity.
		 */
		private function drawSelectionRectangle():void 
		{
			if (_selectedEntity != null)
			{
				var selectionRect:Rectangle = _selectedEntity.bounds;
				selection.graphics.clear();
				selection.graphics.lineStyle(1, 0x00FF00, 1);
				selection.graphics.drawRect(0, 0, selectionRect.width, selectionRect.height);
				selection.x = _selectedEntity.location.x - _activeSpace.camera.x;
				selection.y = _selectedEntity.location.y - _activeSpace.camera.y;
			}
		}
		
		/**
		 * Draw grid lines in the specified region.
		 */
		private function drawGrid():void 
		{
			var region:Rectangle = _activeSpace.bounds.intersection(_activeSpace._screenBounds);
			region.offset( -_activeSpace._screenBounds.x, -_activeSpace._screenBounds.y);
			
			overlay.graphics.clear();
			overlay.graphics.lineStyle(0, GRID_COLOR);
			var cameraX:Number = _activeSpace.camera.x;
			var cameraY:Number = _activeSpace.camera.y;
			
			if (_gridW > 1)
			{
				var x:Number, offsetX:Number;
				// Tricky: Java modulo is a remainder operator (not like C)
				var remainderX:Number = Math.abs(_activeSpace.bounds.left % _gridW);
				
				if (cameraX > _activeSpace.bounds.left)
					offsetX = Math.ceil(cameraX / gridW) * gridW - cameraX;
				else offsetX = remainderX;
				
				for (x = region.left + offsetX; x < region.right; x += _gridW)
				{
					overlay.graphics.moveTo(x, region.top);
					overlay.graphics.lineTo(x, region.bottom);
				}
			}
			
			if (_gridH > 1)
			{
				var y:Number, offsetY:Number;
				// Tricky: Java modulo is a remainder operator (not like C)
				var remainderY:Number = Math.abs(_activeSpace.bounds.top % _gridH);
				
				if (cameraY > _activeSpace.bounds.top)
					offsetY = Math.ceil(cameraY / gridH) * gridH - cameraY;
				else offsetY = remainderY;
				
				for (y = region.top + offsetY; y < region.bottom; y += _gridH)
				{
					overlay.graphics.moveTo(region.left, y);
					overlay.graphics.lineTo(region.right, y);
				}
			}
		}
		
		/**
		 * Draw arrows near the space's boundaries.
		 */
		private function drawArrows():void 
		{
			var region:Rectangle = _activeSpace.bounds.intersection(_activeSpace._screenBounds);
			region.offset( -_activeSpace._screenBounds.x, -_activeSpace._screenBounds.y);
			
			// Space boundaries that are currently visible on the screen.
			var leftBorderVisible:Boolean = region.left >= 1;
			var rightBorderVisible:Boolean = region.right <= Engine.stage.stageWidth - 1;
			var topBorderVisible:Boolean = region.top >= 1;
			var bottomBorderVisible:Boolean = region.bottom <= Engine.stage.stageHeight - 1;
			
			leftArrow.visible = leftBorderVisible;
			rightArrow.visible = rightBorderVisible;
			upArrow.visible = topBorderVisible;
			downArrow.visible = bottomBorderVisible;
			upleftArrow.visible = topBorderVisible && leftBorderVisible;
			uprightArrow.visible = topBorderVisible && rightBorderVisible;
			downleftArrow.visible = bottomBorderVisible && leftBorderVisible;
			downrightArrow.visible = bottomBorderVisible && rightBorderVisible;
			
			leftArrow.x = region.left - leftArrow.width / 2;
			leftArrow.y = region.y + region.height / 2;
			rightArrow.x = region.right + rightArrow.width / 2;
			rightArrow.y = region.y + region.height / 2;
			upArrow.x = region.x + region.width / 2;
			upArrow.y = region.top - upArrow.height / 2;
			downArrow.x = region.x + region.width / 2;
			downArrow.y = region.bottom + downArrow.height / 2;
			upleftArrow.x = region.left;
			upleftArrow.y = region.top - leftArrow.height * 0.667;
			uprightArrow.x = region.right + leftArrow.height * 0.667;
			uprightArrow.y = region.top;
			downleftArrow.x = region.left - leftArrow.height * 0.667;
			downleftArrow.y = region.bottom;
			downrightArrow.x = region.right;
			downrightArrow.y = region.bottom + leftArrow.height * 0.667;
		}
	}

}
