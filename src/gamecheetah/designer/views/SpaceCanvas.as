/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import gamecheetah.*;
	import gamecheetah.designer.components.*;
	import gamecheetah.designer.Designer;
	import gamecheetah.namespaces.*;
	
	use namespace hidden;
	
	/**
	 * Wraps the active Space object to provide a convenient interface for the Designer class.
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}. Game Cheetah (c) 2015. 
	 * @private
	 */
	CONFIG::developer
	public final class SpaceCanvas extends BaseComponent
	{
		
		private static const GRID_COLOR:uint = 0xAAAAAA;
		
		//{ ------------------------------------ Property bindings ------------------------------------
		
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
			
			if (_disabled) onDeactivate();
			else onActivate();
		}
		private var _disabled:Boolean;
		
		//{ ------------------------------------ Private variables ------------------------------------

		private var _dirty:Boolean;
		private var _lastRenderedRect:Rectangle;
		
		private var _draggingMarker:Boolean;
		private var _draggingEntity:Boolean;
		private var _dragEntityMouseOffset:Point = new Point();
		
		private var
			overlay:Sprite,
			selection:Shape,
			startMarker:IconButton,
			leftArrow:IconButton,
			rightArrow:IconButton,
			upArrow:IconButton,
			downArrow:IconButton;
		
		//{ ------------------------------------ Constructor ------------------------------------
		
		public function SpaceCanvas(parent:DisplayObjectContainer) 
		{
			this._lastRenderedRect = new Rectangle();
			
			leftArrow = new IconButton(this, Assets.EXPAND_LEFT, Arrow_onClick, "Expand\nLeft", Label.ALIGN_RIGHT);
			rightArrow = new IconButton(this, Assets.EXPAND_RIGHT, Arrow_onClick, "Expand\nRight", Label.ALIGN_LEFT);
			upArrow = new IconButton(this, Assets.EXPAND_UP, Arrow_onClick, "Expand\nUp", Label.ALIGN_BELOW);
			downArrow = new IconButton(this, Assets.EXPAND_DOWN, Arrow_onClick, "Expand\nDown", Label.ALIGN_ABOVE);
			startMarker = new IconButton(this, Assets.HOME, null, "Start\nLocation", Label.ALIGN_ABOVE);
			overlay = new Sprite();
			selection = new Shape();
			
			leftArrow.visible = rightArrow.visible = upArrow.visible = downArrow.visible = false;
			overlay.alpha = 0.5;
			
			this.addChild(overlay);
			this.addChild(selection);
			
			Designer.model.bind("selectedEntity", this, true);
			Designer.model.bind("activeSpace", this, true);
			
			super(parent, 0, 0);
		}
		
		/**
		 * Redraw arrows and grid next frame.
		 */
		public function refresh():void 
		{
			_dirty = true;
		}
		
		override public function onActivate():void 
		{
			startMarker.addEventListener(MouseEvent.MOUSE_DOWN, startMarker_onMouseDown);
			Engine.displayObject.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Engine.displayObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Engine.displayObject.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Engine.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}
		
		override public function onDeactivate():void 
		{
			startMarker.removeEventListener(MouseEvent.MOUSE_DOWN, startMarker_onMouseDown);
			Engine.displayObject.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Engine.displayObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Engine.displayObject.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Engine.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}
		
		override public function onUpdate():void 
		{
			if (_activeSpace == null) return;
			
			// Update start marker location.
			if (!_draggingMarker)
			{
				startMarker.x = _activeSpace.startLocation.x - _activeSpace.camera.x - startMarker.width / 2;
				startMarker.y = _activeSpace.startLocation.y - _activeSpace.camera.y - startMarker.height / 2;
			}
			
			if (!_lastRenderedRect.equals(_activeSpace.screenBounds))
			{
				if (!_dirty)
				{
					leftArrow.visible = rightArrow.visible = upArrow.visible = downArrow.visible = false
					overlay.graphics.clear();
				}
				
				// Update last position, so display objects are only redrawn after screen moves or resizes.
				_lastRenderedRect.copyFrom(_activeSpace.screenBounds);
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
		
		//{ ------------------------------------ Event handlers ------------------------------------
		
		/**
		 * Mouse click event handler for Arrow buttons
		 */
		private function Arrow_onClick(b:BaseButton):void
		{
			if (b == leftArrow)
				activeSpace.expand(-100, 0);
			
			else if (b == rightArrow)
				activeSpace.expand(100, 0);
			
			else if (b == upArrow)
				activeSpace.expand(0, -100);
			
			else if (b == downArrow)
				activeSpace.expand(0, 100);
				
			Designer.updateScrollBounds();
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
		
		//{ ------------------------------------ Private function ------------------------------------

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
			var region:Rectangle = _activeSpace.bounds.intersection(_activeSpace.screenBounds);
			region.offset( -_activeSpace.screenBounds.x, -_activeSpace.screenBounds.y);
			
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
			var region:Rectangle = _activeSpace.bounds.intersection(_activeSpace.screenBounds);
			region.offset( -_activeSpace.screenBounds.x, -_activeSpace.screenBounds.y);
			
			// Space boundaries that are currently visible on the screen.
			var leftBorderVisible:Boolean = region.left >= 1;
			var rightBorderVisible:Boolean = region.right <= Engine.stage.stageWidth - 1;
			var topBorderVisible:Boolean = region.top >= 1;
			var bottomBorderVisible:Boolean = region.bottom <= Engine.stage.stageHeight - 1;
			
			leftArrow.visible = leftBorderVisible;
			rightArrow.visible = rightBorderVisible;
			upArrow.visible = topBorderVisible;
			downArrow.visible = bottomBorderVisible;
			
			leftArrow.move(region.left - 16, region.y + region.height / 2);
			rightArrow.move(region.right - 16, region.y + region.height / 2);
			upArrow.move(region.x + region.width / 2, region.top - 16);
			downArrow.move(region.x + region.width / 2, region.bottom - 16);
		}
	}

}
