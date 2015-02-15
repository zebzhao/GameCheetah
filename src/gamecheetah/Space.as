/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import gamecheetah.namespaces.*;
	import gamecheetah.strix.collision.Agent;
	import gamecheetah.strix.collision.Collision;
	import gamecheetah.strix.collision.quadtree.Quadtree;
	import gamecheetah.utils.*;
	
	use namespace hidden;
	
	/**
	 * A container which provides the means to spatially manage a group of Entity objects.
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}
	 */
	public class Space extends Restorable
	{
		// Shared reusable geometry objects.
		private static var _rect:Rectangle = new Rectangle();
		private static var _rect2:Rectangle = new Rectangle();
		private static var _point:Point = new Point();
		
		/**
		 * Cast space object to another class.
		 */
		hidden static function convertClass(space:Space, klass:Class):Space 
		{
			var result:Space = new klass() as Space;
			result._bounds = space._bounds;
			result._exportableEntities = space._exportableEntities;
			result._startLocation = space._startLocation;
			result._tag = space._tag;
			result.camera.setTo(space.camera.x, space.camera.y);
			result.mouseEnabled = space.mouseEnabled;
			result.paused = space.paused;
			result.invokeCallbacks = space.invokeCallbacks;
			return result;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Hidden Properties
		
		/**
		 * Get exportable entities.
		 */
		hidden function get _exportableEntities():Array
		{
			return _entities.filter(filterExportable);
		}
		hidden function set _exportableEntities(value:Array):void
		{
			_entities = value;
		}
		
		/**
		 * List of entities belonging to this container.
		 */
		private var _entities:Array;
		
		/**
		 * Filters out runtime entities. This is so entities created in onActivate() do not save to file.
		 */
		private function filterExportable(item:Entity, index:int, arr:Array):Boolean 
		{
			return !item._runtime;
		}
		
		//} Hidden Properties
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Public Properties
		
		/**
		 * Top left position of the render area.
		 */
		public const camera:Point = new Point();
		
		/**
		 * True if using collision masks for collision detection. Default is true.
		 * Set to false to manually handling pixel-perfect collision.
		 */
		public var useCollisionMasks:Boolean = true;
		
		/**
		 * Set to <b>true</b> to pause the space.
		 */
		public var paused:Boolean;
		
		/**
		 * [Read-only] Entity currently under the cursor if mouseEnabled property is true.
		 */
		public function get mouseFocus():Entity { return _mouseFocus };
		private var _mouseFocus:Entity;
		
		/**
		 * [Read-only] Name or tag of this Space object.
		 */
		public function get tag():String { return _tag };
		hidden var _tag:String;
		
		/**
		 * [Read-only] Spatial bounds of the container.
		 */
		public function get bounds():Rectangle { return _bounds };
		hidden var _bounds:Rectangle;
		
		/**
		 * [Read-only/Debug] Number of pixel-perfect collision checks.
		 */
		public function get totalPixelCollisionChecks():uint
		{
			return _totalPixelCollisionChecks;
		}
		private var _totalPixelCollisionChecks:uint;
		
		/**
		 * [Read-only] Number of entities that are rendered.
		 */
		public function get onScreenCount():uint
		{
			return _onScreenCount;
		}
		private var _onScreenCount:uint;
		
		/**
		 * [Read-only] Total number of entities in the space.
		 */
		public function get totalEntities():uint
		{
			return _entities.length;
		}
		
		/**
		 * [Read-only] True if this is the active space.
		 */
		public function get active():Boolean
		{
			return _active;
		}
		private var _active:Boolean;
		
		/**
		 * [Read-only] The starting location of the camera.
		 */
		public function get startLocation():Point 
		{
			return _startLocation;
		}
		hidden var _startLocation:Point = new Point();
		
		/**
		 * [Internal] True to invoke callbacks such as onActivate, onMouseDown, onMove, etc...
		 */
		hidden var invokeCallbacks:Boolean = true;
		
		/**
		 * [Read-only] Returns a copy of the internally stored entity array.
		 */
		public function get entities():Array 
		{
			return _entities.slice();
		}
		
		/**
		 * Alpha pixel value between 0-255. Used in bitmap-bitmap collision detection. Default is 1.
		 */
		public var alphaThreshold:uint = 1;
		
		/**
		 * Alpha pixel value between 0-255. Used in mouse focus detection. Default is 1.
		 */
		public var mouseAlphaThreshold:uint = 1;
		
		/**
		 * True the space will relay mouse events to entities.
		 */
		public var mouseEnabled:Boolean;
		
		/**
		 * Can be any subclass of the State class.
		 * Any properties defined in this class will be resetted upon onExit().
		 */
		public var state:State;
		
		/**
		 * [Read-only] Bounds of the render area rectangle.
		 */
		public function get screenBounds():Rectangle 
		{
			return _screenBounds;
		}
		hidden var _screenBounds:Rectangle = new Rectangle();
		
		//} Public Properties
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		// Quadtree information
		private var _quadtree:Quadtree;
		
		// Maps agent id to Entity objects.
		private var _hashtable:Dictionary;
		
		// Increments for each entity added.
		private var _agentCounter:uint;
		
		/**
		 * List of entities to be removed at the end of the frame.
		 */
		private var _removeQueue:Vector.<Entity>;
		
		/**
		 * List of entities to be added at the end of the frame.
		 */
		private var _addQueue:Array;
		
		/**
		 * Deactivate these entities at the end of the frame.
		 */
		private var _deactivateQueue:Array;
		
		/**
		 * Activate these entities at the end of the frame.
		 */
		private var _activateQueue:Array;
		
		/**
		 * Information to reset the Space to its original state.
		 */
		hidden var _resetInfo:Object;
		
		{
			Quadtree.throwExceptions = false;
		}
		
		
		/**
		 * A spatial container for a group of Entity objects.
		 */
		public function Space() 
		{
			super(["_bounds", "_exportableEntities", "_startLocation", "_tag", "mouseEnabled"]);
			
			_entities = [];
			_removeQueue = new Vector.<Entity>();
			_addQueue = new Array();
			_deactivateQueue = new Array();
			_activateQueue = new Array();
			_hashtable = new Dictionary(true);
			
			_bounds = new Rectangle();
			_quadtree = createQuadtree();
		}
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Public methods
		
		/**
		 * Check if the mask objects of the two entities collide.
		 */
		public function collisionTest(a:*, b:*, locationA:Point, locationB:Point):Boolean 
		{
			if (a is Rectangle)
			{
				_rect.copyFrom(a as Rectangle);
				_rect.offsetPoint(locationA);
				
				if (b is Rectangle)
				{
					_rect2.copyFrom(b);
					_rect2.offsetPoint(locationB);
					return _rect.intersects(_rect2);
				}
				else if (b is Point)
				{
					_point.copyFrom(b);
					_point.offset(locationB.x, locationB.y);
					Rectangle (a as Rectangle).containsPoint(_point);
				}
				else if (b is BitmapData)
				{
					_totalPixelCollisionChecks++;
					return (b as BitmapData).hitTest(locationB, alphaThreshold, _rect);
				}
			}
			else if (a is Point)
			{
				_point.copyFrom(a);
				_point.offset(locationA.x, locationA.y);
				
				if (b is Rectangle)
				{
					_rect.copyFrom(b);
					_rect.offsetPoint(locationB);
					return _rect.containsPoint(_point);
				}
				else if (b is BitmapData)
				{
					return (b as BitmapData).getPixel32(_point.x - locationB.x, _point.y - locationB.y) > (alphaThreshold << 24);
				}
				// Points shouldn't collide with other points!
			}
			else if (a is BitmapData)
			{
				if (b is Point)
				{
					_point.copyFrom(b);
					_point.offset(locationB.x, locationB.y);
					return (a as BitmapData).getPixel32(_point.x - locationA.x, _point.y - locationA.y) > (alphaThreshold << 24);
				}
				else if (b is BitmapData)
				{
					_totalPixelCollisionChecks++;
					return (a as BitmapData).hitTest(locationA, alphaThreshold, b, locationB, alphaThreshold);
				}
				else if (b is Rectangle)
				{
					_totalPixelCollisionChecks++;
					_rect.copyFrom(b as Rectangle);
					_rect.offsetPoint(locationB);
					return (a as BitmapData).hitTest(locationA, alphaThreshold, _rect);
				}
			}
			return false;
		}
		
		/**
		 * Adjust the rendering screen rectangle size.
		 */
		public final function setScreenSize(width:int, height:int):void 
		{
			_screenBounds.width = width;
			_screenBounds.height = height;
		}
		
		/**
		 * Render the entities surrounding the given screen center.
		 * @param	drawMasks	If true, renders the collision masks for debugging.
		 * 						Using this option can drastically lower performance.
		 */
		public function render(drawMasks:Boolean=false):void 
		{
			// Update screen render bounds. Tricky: There might be a lag between when _screenBounds update and the actual camera position.
			// However, _screenBounds is not used in any critical components of the Engine except this render function.
			_screenBounds.x = camera.x;
			_screenBounds.y = camera.y;
			
			// Re-query objects in quadtree.
			var agents:Vector.<Agent> = _quadtree.queryVolume(_screenBounds);
			
			if (agents == null)
			{
				_onScreenCount = 0;
				return;
			}
			
			// Update number of entities on screen.
			_onScreenCount = agents.length;
			
			// Reset entity onScreen status.
			var entity:Entity;
			for each (entity in _entities) entity._onScreenStatus = -1;
			
			var cameraX:Number = camera.x;
			var cameraY:Number = camera.y;
			
			var renderList:Vector.<Entity> = new Vector.<Entity>();
			var agent:Agent;
			for each (agent in agents) renderList.push(_hashtable[agent.id]);
			
			// Render entities in order.
			renderList.sort(compare);
			
			var mask:*, bmd:BitmapData;
			for each (entity in renderList)
			{
				entity._onScreenStatus = 1;
				if (entity.renderable != null)
				{
					entity.renderable.render(Engine.buffer, entity._agent.x - cameraX, entity._agent.y - cameraY);
				}
			}
			
			CONFIG::developer
			{
				if (drawMasks)
				{
					for each (entity in renderList)
					{
						if (entity.renderable == null) return;
						
						mask = entity._getMask();
						bmd = mask as BitmapData;
						
						// Tricky: Transformed rectangle masks are returned as bitmaps.
						if (mask is Rectangle)
						{
							_rect.copyFrom(mask);
							_rect.offset(entity._agent.x - cameraX, entity._agent.y - cameraY);
							Engine.buffer.fillRect(_rect, 0x90ff0000);
						}
						else if (bmd != null) Engine.buffer.copyPixels(bmd, bmd.rect, new Point(entity._agent.x - cameraX, entity._agent.y - cameraY), null, null, true);
					}
				}
			}
		}
		
		/**
		 * Retrieves all entities in the given area.
		 */
		public final function queryArea(x:Number, y:Number, w:Number, h:Number):Vector.<Entity> 
		{
			var agents:Vector.<Agent> = _quadtree.queryVolume(new Rectangle(x, y, w, h));
			var result:Vector.<Entity> = new Vector.<Entity>();
			var agent:Agent, entity:Entity;
			
			if (agents == null) return result;
			
			for each (agent in agents)
			{
				entity = _hashtable[agent.id];
				if (entity.queriable) result.push(entity);
			}
			return result;
		}
		
		/**
		 * Retrieves all entities touching the given point.
		 */
		public final function queryPoint(x:Number, y:Number):Vector.<Entity> 
		{
			var agents:Vector.<Agent> = _quadtree.queryPoint(new Point(x, y));
			var result:Vector.<Entity> = new Vector.<Entity>();
			var agent:Agent, entity:Entity;
			
			if (agents == null) return result;
			
			for each (agent in agents)
			{
				entity = _hashtable[agent.id];
				if (entity.queriable) result.push(entity);
			}
			return result;
		}
		
		/**
		 * Add an existing entity.
		 */
		public final function add(entity:Entity, dest:Point=null):void 
		{
			CONFIG::developer
			{
				if (entity == null) throw new GCError("Error: attempt add a null entity.");
			}
			if (entity.space != this && _addQueue.indexOf(entity) == -1)
			{
				if (dest != null) entity.location = dest;
				_addQueue.push(entity);
				entity._space = this;
				
				if (entity.renderable == null && entity.graphic != null)
				{
					entity.renderable = entity.graphic.newRenderable();
				}
				else if (CONFIG::developer && entity.renderable == null)
					throw new GCError("missing assignment: renderable and/or graphic not assigned to added entity!");
			}
		}
		
		/**
		 * Remove an existing entity immediately.
		 */
		hidden final function remove(entity:Entity):void 
		{
			if (entity == null)
			{
				CONFIG::developer
				{
					throw new GCError("Attempt to remove null object from Space!");
				}
				return;
			}
			
			entity._space = null;
			
			var addIndex:int = _addQueue.indexOf(entity);
			if (addIndex != -1)
			{
				// Added and removed in the same frame.
				_addQueue.splice(addIndex, 1);
			}
			else
			{
				removeEntity(entity, true, false);
			}
		}
		
		/**
		 * Remove all existing entities immediately.
		 */
		public final function removeAll():void 
		{
			while (_entities.length > 0) remove(_entities[0]);
		}
		
		/**
		 * Create a new entity given the Graphic tag.
		 * @param	graphicTag		The tag identifier of the Graphic.
		 * @param	dest			[Passed-by-reference] Location of the entity, default is (x=0,y=0).
		 * @param	runtime			Internal property, do not change!
		 * @return	The created entity.
		 */
		public final function createEntity(graphicTag:String, dest:Point=null, runtime:Boolean=true):Entity 
		{
			var entity:Entity = Engine.createEntity(graphicTag);
			
			if (entity != null && entity.space != this)
			{
				if (_active)
				{
					// Active space adds entity by appending to queue.
					if (_addQueue.indexOf(entity) == -1)
					{
						entity._runtime = runtime;
						entity._space = this;
						if (dest != null) entity.location = dest;
						_addQueue.push(entity);
					}
				}
				else
				{
					// Unactive space adds entity directly.
					entity._runtime = runtime;
					entity._space = this;
					if (dest != null) entity.location = dest;
					addEntity(entity);
				}
			}
			return entity;
		}
		
		/**
		 * Next frame, remove an existing entity from the space.
		 */
		public final function destroyEntity(entity:Entity):void 
		{
			if (entity == null)
			{
				CONFIG::developer
				{
					throw new GCError("Attempt to remove null object from Space!");
				}
				return;
			}
			else if (entity.space == this)
			{
				if (_active)
				{
					if (_removeQueue.indexOf(entity) == -1)
					{
						var addIndex:int = _addQueue.indexOf(entity);
						if (addIndex != -1)
						{
							// Added and removed in the same frame.
							_addQueue.splice(addIndex, 1);
						}
						else _removeQueue.push(entity);
					}
				}
				else
				{
					// Remove immediately if this space isn't active.
					remove(entity);
				}
			}
		}
		
		/**
		 * Remove all existing entities at the start of the next frame.
		 */
		public final function destroyAll():void 
		{
			for (var i:uint = 0; i < _entities.length; i++)
				destroyEntity(_entities[i]);
		}
		
		/**
		 * Reset to its original state, including all entities (at the end of the frame).
		 */
		public final function reset():void 
		{
			var entity:Entity;
			
			if (this._resetInfo != null)
			{
				// Temporarily Remove all entities from this space.
				while (_entities.length > 0)
				{
					entity = _entities[0];
					removeEntity(entity, true, true);
				}
				
				// Reset space state.
				_activateQueue.length = 0;
				_deactivateQueue.length = 0;
				_mouseFocus = null;
				_quadtree = createQuadtree();
				_hashtable = new Dictionary(true);
				
				// Reset entities.
				this.restore(_resetInfo);
			}
			else
			{
				// Run-time created space object, reset to initial state.
				while (_entities.length > 0)
				{
					// Remove all entities from this space.
					entity = _entities[0];
					removeEntity(entity, true, true);
				}
				// Reset space state.
				_activateQueue.length = 0;
				_deactivateQueue.length = 0;
				_mouseFocus = null;
				_quadtree = createQuadtree();
				_hashtable = new Dictionary(true);
			}
		}
		
		/**
		 * Return list of entity with the specified tag.
		 */
		public function getByTag(tag:String):Vector.<Entity> 
		{
			var result:Vector.<Entity> = new Vector.<Entity>();
			var entity:Entity;
			for each (entity in _entities)
			{
				if (entity.tag == tag) result.push(entity);
			}
			return result;
		}
		 
		/**
		 * Reset camera to be at the original starting location.
		 */
		public function resetCamera():void 
		{
			this.camera.setTo(this.startLocation.x, this.startLocation.y);
		}
		
		/**
		 * Restore a space object from its export data.
		 */
		override public function restore(obj:Object):void 
		{
			if (_entities != null)
			{
				// Clean up all entities of this Space.
				while (_entities.length > 0) removeEntity(_entities[0], true, true);
			}
			
			_resetInfo = obj;
			super.restore(obj);
			
			CONFIG::developer
			{
				// Clean up undefined entity (from removed classes)
				while (_entities.indexOf(undefined) != -1)
					_entities.splice(_entities.indexOf(undefined), 1);
			}
			
			var entity:Entity;
			for each (entity in _entities)
			{
				entity.graphic = Engine.assets.graphics.get(entity._graphicTag);
				entity.graphic.entities.push(entity);
				entity._runtime = false;    // This is a design-time user-created entity.
				addEntity(entity, true, true); 
			}
		}
		
		/**
		 * Expand the spatial bounds of the container.
		 * @param	dw	The sign determines which direction (left/right) to expand in.
		 * @param	dh	The sign determines which direction (up/down) to expand in.
		 */
		public final function expand(dw:Number, dh:Number):void 
		{
			if (dw > 0)
			{
				// No translation needed.
			}
			else if (dw < 0)
			{
				_bounds.offset(dw, 0);
			}
			
			if (dh > 0)
			{
				// No translation needed.
			}
			else if (dh < 0)
			{
				_bounds.offset(0, dh);
			}
			
			_bounds.width += Math.abs(dw);
			_bounds.height += Math.abs(dh);
			
			updateSize();
		}
		
		public final function updateSize():void 
		{
			if (_active)
			{
				// Quadtree must be reindexed as Space volume changed.
				reindexQuadtree();
			}
		}
		
		public final function resize(x:int, y:int, w:int, h:int):void 
		{
			_bounds.setTo(x, y, w, h);
			if (_active) reindexQuadtree();
		}
		
		
		//} Public methods
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Overridables
		
		/**
		 * Override this. Called every frame.
		 */
		public function onUpdate():void {}
		
		/**
		 * Override this. Called when swapped as the active space. Takes place before onEnter() and Entity::onActivate().
		 */
		public function onSwapIn():void { }
		
		/**
		 * Override this. Called when swapped to another the active space. Takes place before onExit() and Entity::onDeactivate().
		 */
		public function onSwapOut():void { }
		
		/**
		 * Override this. Called when set to the active space.
		 */
		public function onEnter():void { }
		
		/**
		 * Override this. Called when the active space is set to another.
		 */
		public function onExit():void { }
		
		/**
		 * Override this. Called after an entity is deactivated.
		 */
		public function onEntityDeactivate(entity:Entity):void { }
		
		/**
		 * Override this. Called after an entity is activated.
		 */
		public function onEntityActivate(entity:Entity):void { }
		
		//} Overridables
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Conditionally Compiled methods
		
		/**
		 * Optimize container bounds to the minimal needed by its objects.
		 * The minimum bounds will not be smaller than stage dimensions.
		 */
		CONFIG::developer
		hidden function _autoSize():void 
		{
			var newBounds:Rectangle = new Rectangle(0, 0, Engine.stage.stageWidth, Engine.stage.stageHeight);
			var xMin:Number, xMax:Number, yMin:Number, yMax:Number;
			
			var entity:Entity, entityRect:Agent;
			
			for each (entity in _entities)
			{
				entityRect = entity._agent;
				
				if (!newBounds.containsRect(entityRect))
				{
					// If entity volume is not contained, expand the volume.
					newBounds = newBounds.union(entityRect);
				}
			}
			_bounds = newBounds;
			
			if (_active)
			{
				// Quadtree must be reindexed as Space volume changed.
				reindexQuadtree();
			}
		}
		
		/**
		 * Convert Quadtree data to string.
		 */
		CONFIG::developer
		hidden function get _quadtreeData():String 
		{
			return _quadtree.print();
		}
		
		//} Conditionally Compiled methods
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Private and internal methods
		
		/**
		 * Used to activate the space. Called when set to the active space.
		 */
		hidden function _activate():void
		{
			if (!_active)
			{
				_active = true;
				
				// Set screen size to the full screen.
				setScreenSize(Engine.stage.stageWidth, Engine.stage.stageHeight);
				
				// Reset game camera
				resetCamera();
				
				// Call space callback if enabled.
				if (invokeCallbacks) onSwapIn();
				
				// Set or remove graphical data for entities.
				var entity:Entity;
				
				for each (entity in _entities)
				{
					activateEntity(entity, false);
				}
				
				// Call space callback if enabled.
				if (invokeCallbacks) onEnter();
			}
		}
		
		/**
		 * Used to deactivate the space. Called when this space is no longer the active space.
		 */
		hidden function _deactivate():void 
		{
			if (_active)
			{
				_active = false;
				
				// Call space callbacks if enabled.
				if (invokeCallbacks) onSwapOut();
				
				var entity:Entity;
				for each (entity in _entities)
					_deactivateQueue.push(entity, true);
					
				// Call space callbacks if enabled.
				if (invokeCallbacks) onExit();
			}
		}
		
		/**
		 * Complete the removal of any lingering entities.
		 */
		hidden function _finalize():void
		{
			var i:int;
			for (i = 0; i < _addQueue.length; i++) addEntity(_addQueue[i], false, false);
			for (i = 0; i < _removeQueue.length; i++) removeEntity(_removeQueue[i], false, false);
			
			_addQueue.length = 0;
			_removeQueue.length = 0;
			
			while (_activateQueue.length > 0)
			{
				activateEntity(_activateQueue.shift(), _activateQueue.shift());
			}
			while (_deactivateQueue.length > 0)
			{
				deactivateEntity(_deactivateQueue.shift(), _deactivateQueue.shift());
			}
		}
		
		/**
		 * Updates the space.
		 */
		hidden function _update():void
		{
			/**
			 * Execution order: onActivate() -> onUpdate() -> onMove() -> onCollision() -> (render)
			 */
			var entity:Entity;
			var entityX:Number, entityY:Number;
			var entityMoveX:Number, entityMoveY:Number;
			var i:int;
			
			// Add and remove entities at the end of the frame.
			// Prevents modifying the entity list while iterating.
			// Makes sure onDeactivate and onActivate are called at the end of the frame.
			// Always call onActivate and onDeactivate after processing add/remove queues.
			
			for (i = 0; i < _addQueue.length; i++) addEntity(_addQueue[i], false, false);
			for (i = 0; i < _removeQueue.length; i++) removeEntity(_removeQueue[i], false, false);
			
			_addQueue.length = 0;
			_removeQueue.length = 0;
			
			while (_activateQueue.length > 0)
			{
				activateEntity(_activateQueue.shift(), _activateQueue.shift());
			}
			while (_deactivateQueue.length > 0)
			{
				deactivateEntity(_deactivateQueue.shift(), _deactivateQueue.shift());
			}
			
			if (!invokeCallbacks)
			{
				for each (entity in _entities)
				{
					entityX = entity.location.x + entity.origin.x;
					entityY = entity.location.y + entity.origin.y;
					
					entityMoveX = entityX - entity._agent.x;
					entityMoveY = entityY - entity._agent.y;
					
					if (entityMoveX != 0 || entityMoveY != 0)
					{
						entity.absoluteLocation.setTo(entityX, entityY);
						entity._agent.moveTo(entityX, entityY);
					}
				}
			}
			else if (paused)
			{
				return; // Skip updating, collision handling
			}
			else
			{
				// Call onUpdate() last, after onActivate() call for entities.
				for each (entity in _entities)
				{
					entity.onUpdate();
					if (!paused && entity.clip != null) entity.clip.update();
				}
				
				// Calls onMove() for all entities.
				for each (entity in _entities)
				{
					entityX = entity.location.x + entity.origin.x;
					entityY = entity.location.y + entity.origin.y;
					
					entityMoveX = entityX - entity._agent.x;
					entityMoveY = entityY - entity._agent.y;
					
					if (entityMoveX != 0 || entityMoveY != 0)
					{
						entity.absoluteLocation.setTo(entityX, entityY);
						entity._agent.moveTo(entityX, entityY);
						entity.onMove(entityMoveX, entityMoveY);
					}
				}
				
				_totalPixelCollisionChecks = 0;
				
				// Get all overlap collisions with all entities.
				var collisions:Vector.<Collision> = _quadtree.queryCollisions();
				
				if (collisions != null)
				{
					var collision:Collision;
					var a:Entity, b:Entity;
					var aCb:Boolean, bCa:Boolean;
					var agentA:Agent, agentB:Agent;
					
					var collisionCount:uint = collisions.length;
					
					// Check if onCollision() calls are needed.
					for (i = 0; i < collisionCount; i++)
					{
						collision = collisions[i];
						agentA = collision.a;
						agentB = collision.b;
						a = _hashtable[agentA.id];
						b = _hashtable[agentB.id];
						
						aCb = (agentA.action & agentB.group) != 0;
						bCa = (agentA.group & agentB.action) != 0;
						
						if (!aCb && !bCa) continue;  // Collision cannot happen.
						else if (!a.collidable || !b.collidable) continue;	// Collision cannot happen.
						else if (useCollisionMasks && !collisionTest(a._getMask(), b._getMask(), a._agent.topLeft, b._agent.topLeft)) continue;  // Pixel-perfect collision did not happen.
						
						// Entity a collides against b.
						if (aCb)
						{
							// Invoke collision handler for Entity a.
							a.onCollision(b);
						}
						
						// Entity b collides against a.
						if (bCa)
						{
							b.onCollision(a);
						}
					}
				}
			}
			
			// Tricky: Since the entities themselves are moving, cannot depend on MOUSE_MOVE events.
			if (mouseEnabled) _onMouseFocusUpdate(Engine.stage.mouseX, Engine.stage.mouseY);
			
			// Call callback.
			if (invokeCallbacks && !paused) onUpdate();
		}
		
		/**
		 * Add an Entity to this container.
		 * @param 	entity			Entity object to add.
		 * @param 	dest			Location to add entity at.
		 * @param	restoreCall		True if function is called from Restorable::restore().
		 */
		private function addEntity(entity:Entity, restoreCall:Boolean=false, disableCallbacks:Boolean=false):void 
		{
			CONFIG::developer
			{
				if (restoreCall)
				{
					// A restore call iterates over existing entities in "_entities".
					if (_entities.indexOf(entity) == -1) throw new GCError("The restoreCall flag is improperly set to true!");
				}
			}
			if (!restoreCall) _entities.push(entity);
			
			// Ensure an unique agent id is used.
			entity._agent.id = _agentCounter++;
			
			// Set entity position.
			entity._agent.x = entity.location.x;
			entity._agent.y = entity.location.y;
			
			entity._space = this;
			
			if (_active)
			{
				// Activate entity immediately if called from restore().
				if (restoreCall) activateEntity(entity, disableCallbacks);
				else _activateQueue.push(entity, disableCallbacks);
			}
		}
		
		/**
		 * Remove an entity from this container.
		 * @param immediate		Deactivate entity immediately.
		 */
		private function removeEntity(entity:Entity, immediate:Boolean=false, disableCallbacks:Boolean=false):void 
		{
			var entityIndex:int = _entities.indexOf(entity);
			
			// Added and removed in the same frame.
			var addQueueIndex:int = _addQueue.indexOf(entity);
			if (addQueueIndex != -1) _addQueue.splice(addQueueIndex, 1);
			
			CONFIG::developer
			{
				if (addQueueIndex == -1 && entityIndex == -1)
					trace(String(entity) + " (" + entity._graphicTag  + ") to be removed is not contained by " + String(this));
			}
			
			if (entity._activated)
			{
				if (immediate) deactivateEntity(entity, disableCallbacks);
				else _deactivateQueue.push(entity, disableCallbacks);
			}
			
			entity._space = null;
			
			// Remove from graphic list
			if (entity.graphic != null) entity.graphic.entities.splice(entity.graphic.entities.indexOf(entity), 1);
			// Remove from space list
			if (entityIndex != -1) _entities.splice(entityIndex, 1);
		}
		
		/**
		 * Reindex quadtree objects. Needs to be called if quadtree resizes.
		 */
		private function reindexQuadtree():void 
		{
			_quadtree = createQuadtree();
			
			var entity:Entity;
			var id:uint;
			
			_hashtable = new Dictionary(true);
			
			for each (entity in _entities)
			{
				entity._agent.id = id;
				_quadtree.addAgent(entity._agent);
				_hashtable[id] = entity;
				id++;
			}
		}
		
		/**
		 * Sort object by depth.
		 */
		private function compare(a:Entity, b:Entity):int 
		{
			if (a.depth > b.depth) return 1
			else if (a.depth < b.depth) return -1;
			else return 0;
		}
		
		/**
		 * Creates the quadtree container from the current bounds.
		 */
		private function createQuadtree():Quadtree 
		{
			// Depth is based on the closest power of 2 that divides the bound range to stage size.
			var averageBound:Number = Math.sqrt(_bounds.width * _bounds.height) + 1;
			var averageStage:Number = Math.sqrt(Engine.stage.stageWidth * Engine.stage.stageHeight) + 1;
			var boundsToStageRatio:Number = averageBound / averageStage;
			
			var depth:int = 1;
			if (boundsToStageRatio > 30) depth = 8;
			else if (boundsToStageRatio > 10) depth = 4;
			else if (boundsToStageRatio > 2) depth = 2;
			
			// Limit max depth to be 8 for memory conservation reasons.
			return new Quadtree(_bounds, depth);
		}
		
		/**
		 * Adds entity to the quadtree container and create its graphical clip.
		 * Additionally the onActivate() method of its interactions gets called.
		 */
		private function activateEntity(entity:Entity, disableCallbacks:Boolean):void 
		{
			// Update entity agent location upon activation.
			entity._agent.x = entity.origin.x + entity.location.x;
			entity._agent.y = entity.origin.y + entity.location.y;
			
			// Tricky: The queriable property cannot be tied to the agent, otherwise the clip will not draw.
			_quadtree.addAgent(entity._agent);
			_hashtable[entity._agent.id] = entity;
			entity._activated = true;
			
			if (entity.renderable == null && entity.graphic != null)
			{
				entity.renderable = entity.graphic.newRenderable();
			}
			else if (CONFIG::developer && entity.renderable == null)
				throw new GCError("missing assignment: renderable and/or graphic not assigned to added entity!");
				
			if (invokeCallbacks && !disableCallbacks)
			{
				entity.onActivate();
				onEntityActivate(entity);
			}
		}
		
		/**
		 * Performs the opposite action of activateEntity().
		 */
		private function deactivateEntity(entity:Entity, disableCallbacks:Boolean):void 
		{
			// Entity has already been deactivated!
			if (!entity._activated)
			{
				CONFIG::developer
				{
					trace("Attempt to deactivate unactive entity " + String(entity) + " (" + entity._graphicTag + ") in " + String(this));
				}
				return;
			}
			
			// Tricky: The queriable property cannot be tied to the agent, otherwise the clip will not draw.
			_quadtree.deleteAgent(entity._agent);
			delete _hashtable[entity._agent.id];
			
			// Fire deactivation callback before disposing.
			if (invokeCallbacks && !disableCallbacks)
			{
				entity.onDeactivate();
				onEntityDeactivate(entity);
			}
			
			// Delete graphic clip.
			entity.renderable.dispose();
			entity.renderable = null;
			
			// Tricky: deactivate entity after disposing renderable
			entity._activated = false;
		}
		
		//} Private and hidden methods
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Mouse event listeners
		
		hidden function _onMouseDown(stageX:Number, stageY:Number):void 
		{
			if (invokeCallbacks && _mouseFocus != null) _mouseFocus.onMouseDown();
		}
		
		hidden function _onMouseUp(stageX:Number, stageY:Number):void 
		{
			if (invokeCallbacks && _mouseFocus != null) _mouseFocus.onMouseUp();
		}
		
		private function _onMouseFocusUpdate(stageX:Number, stageY:Number):void 
		{
			if (!invokeCallbacks) return;
			
			var mouseX:Number = stageX + camera.x;
			var mouseY:Number = stageY + camera.y;
			var entities:Vector.<Entity> = queryPoint(mouseX, mouseY);
			var topmost:Entity, entity:Entity, i:int, alpha:uint;
			for (i = 0; i < entities.length; i++)
			{
				entity = entities[i];
				
				if (entity.mouseEnabled && entity.renderable != null && entity.renderable.alpha > 0 && (topmost == null || topmost.depth < entity.depth))
				{
					if (mouseAlphaThreshold > 0)
					{
						// Pixel-perfect mouse collision detection.
						alpha = entity.renderable.buffer.getPixel32(mouseX - entity.absoluteLocation.x, mouseY - entity.absoluteLocation.y) >> 24 & 0xff;
						if (alpha >= mouseAlphaThreshold) topmost = entity;
					}
					else topmost = entity;
				}
			}
			
			// Mouse focus entity is no longer active.
			if (_mouseFocus != null && !_mouseFocus._activated) _mouseFocus = null;
			
			
			if (topmost != null)
			{
				if (_mouseFocus == null)
				{
					topmost.onMouseOver();
				}
				else if (topmost._agent.id != _mouseFocus._agent.id)
				{
					_mouseFocus.onMouseOut();
					topmost.onMouseOver();
				}
			}
			else if (_mouseFocus != null) _mouseFocus.onMouseOut();
			
			_mouseFocus = topmost;
		}
		
		//} Mouse event listeners
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	}

}
