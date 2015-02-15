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
	import gamecheetah.graphics.*;
	import gamecheetah.namespaces.*;
	import gamecheetah.utils.*;
	
	use namespace hidden;
	
	/**
	 * Factory object used to create new Clip objects on the screen.
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}
	 * @version		1.0
	 */
	public class Graphic extends Restorable
	{
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Public properties
		
		/**
		 * Master entity. Acts as a template for new entities.
		 */
		public function get master():Entity
		{
			return _master;
		}
		hidden var _master:Entity;
		
		/**
		 * Master entity. Acts as a template for new entities.
		 */
		public function get masterClass():String
		{
			return _masterClass;
		}
		private var _masterClass:String = "[class Entity]";
		
		/**
		 * Name of classes to collide with. For designer use only.
		 */
		hidden var _collideWith:Array = [];
		
		/**
		 * [Read-only] Unique identifier for this Graphic.
		 */
		public function get tag():String 
		{
			return _tag;
		}
		hidden var _tag:String;
		
		
		/**
		 * Spritesheet bitmap data.
		 */
		public function get spritesheet():BitmapData
		{
			return _spritesheet;
		}
		public function set spritesheet(value:BitmapData):void 
		{
			_spritesheet = value;
			updateSpritesheet();
		}
		private var _spritesheet:BitmapData;
		
		
		/**
		 * Number of rows in the spritesheet.
		 */
		public function get rows():uint { return _rows; }
		public function set rows(value:uint):void 
		{
			if (value == _rows) return;
			_rows = value;
			updateSpritesheet();
		}
		private var _rows:uint = 1;
		
		/**
		 * Number of columns in the spritesheet.
		 */
		public function get columns():uint { return _columns; }
		public function set columns(value:uint):void 
		{
			if (value == _columns) return;
			_columns = value;
			updateSpritesheet();
		}
		private var _columns:uint = 1;
		
		
		/**
		 * [Read-only] Unique identifier for this Graphic.
		 */
		public function get hasSpritesheet():Boolean 
		{
			return _hasSpritesheet;
		}
		private var _hasSpritesheet:Boolean;
		
		
		/**
		 * Size of frame images.
		 */
		public function get frameRect():Rectangle 
		{
			return _frameRect;
		}
		private var _frameRect:Rectangle = new Rectangle();
		
		
		/**
		 * Keeps track of all entities belonging to this Graphic.
		 */
		public var entities:Vector.<Entity> = new Vector.<Entity>();
		
		
		/**
		 * The default animation.
		 */
		public var defaultAnimation:String;
		
		
		/**
		 * Stores animation data.
		 */
		public function get animations():OrderedDict
		{
			return _animations;
		}
		hidden var _animations:OrderedDict = new OrderedDict();
		
		
		/**
		 * [Read-only] The collision group id used for this Graphic. Finds collidable partners using bitwise AND.
		 */
		public function get group():uint { return _group; }
		hidden var _group:uint;
		
		/**
		 * [Read-only] Specifies which collision groups to collide with. Finds collidable partners using bitwise AND.
		 */
		public function get action():uint { return _action; }
		hidden var _action:uint;
		
		/**
		 * [Read-only] Number of frames for this graphic.
		 */
		public function get frameCount():int { return _rows * _columns; }
		
		/**
		 * If true, always use the collision mask specified for frame 0.
		 */
		public var alwaysUseDefaultMask:Boolean;
		
		//} Public Properties
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// Graphical information
		hidden var _frameMasks:Array;
		hidden var _frameImages:Array;				// Container of images originating from the spritesheet.
		
		private var _imageBounds:Vector.<Rectangle>;
		
		
		/**
		 * An generic object which links graphic data with abstract logic.
		 * @param	animations		Contains animation data for a spritesheet.
		 */
		public function Graphic(tag:String=null) 
		{
			super(["_master", "_tag", "_frameMasks", "_animations", "defaultAnimation", "rows", "columns", "spritesheet", "_group", "_collideWith", "alwaysUseDefaultMask"]);
			
			this._frameImages = [];
			this._frameMasks = [];
			this._master = new Entity();
			this._tag = tag;
			this._master.graphic = this;
			this._master._graphicTag = _tag;
			this._imageBounds = new Vector.<Rectangle>();
			// Tricky: Belong to collision group by default, otherwise screen collision detection fails.
			this._group = 1;
			this._action = 0;	// Default, do not look for collisions.
		}
		
		override public function restore(obj:Object):void 
		{
			super.restore(obj);
			
			if (_master == null)
			{
				trace("Critical error: master could not be loaded for [" + this.tag + "] graphic!");
				_master = new Entity();
			}
			else
			{
				// Tricky: In developer mode, create another master from its class.
				// Overwrite the default properties which don't match with the new ones.
				CONFIG::developer
				{
					var klass:Class = Object(_master).constructor;
					var masterNew:* = new klass();
					
					var prop:String, val:*;
					for (prop in masterNew)
					{
						val = masterNew[val];
						
						if (val is int || val is uint || val is Number || val is String || val is Boolean)
						{
							if (val != _master[prop]) _master[prop] = val;
						}
						else if (prop in __exports)
						{
							_master[prop] = val;
						}
					}
				}
			}
			
			this._masterClass = String(Object(_master).constructor);
			
			// Tricky: Base the graphic's collision group assignment on its entity class.
			var collisionIndex:int = Engine.__collisionClasses.indexOf(this._masterClass); 
			this._group = 1 << (collisionIndex + 1);
			calculateActionMask();
			
			// Tricky: Graphic assignment must be after Graphic initialization,
			// which is why it cannot be done in the Entity class.
			this._master.graphic = this;
		}
		
		/**
		 * Calculate the collision action mask, and remove unregistered classes.
		 */
		hidden function calculateActionMask ():void 
		{
			var className:String, collisionIndex:int, i:int;
			_action = 0;
			
			while (i < _collideWith.length)
			{
				className = _collideWith[i];
				collisionIndex = Engine.__collisionClasses.indexOf(className);
				
				if (collisionIndex == -1) _collideWith.splice(collisionIndex, 1);
				else
				{
					_action |= 1 << (collisionIndex + 1);
					i++;
				}
			}
		}
		
		/**
		 * Update the spritesheet. Process the source spritesheet into individual bitmapData objects.
		 */
		private function updateSpritesheet():void
		{
			if (_spritesheet == null)
				return; // Not all the parameters have been set to successfully load spritesheet.
			
			var frameWidth:uint = uint(_spritesheet.width / _columns);
			var frameHeight:uint = uint(_spritesheet.height / _rows);
			_frameImages.length = _rows * _columns;
			_frameMasks.length = _rows * _columns;
			
			var bitmapData:BitmapData;
			
			// Iterate through spritesheet frame by frame and copy each frame to an array.
			var r:int, c:int;
			for (r = 0; r < _rows; r++)
			{
				for (c = 0; c < _columns; c++)
				{
					bitmapData = new BitmapData(frameWidth, frameHeight, true, 0);
					bitmapData.copyPixels(_spritesheet, new Rectangle(frameWidth * c, frameHeight * r, frameWidth, frameHeight), new Point());
					_frameImages[r * _columns + c] = bitmapData;
					_imageBounds[r * _columns + c] = bitmapData.getColorBoundsRect(0xFF000000, 0, false);
				}
			}
			
			_hasSpritesheet = true;
			// Update frame size.
			_frameRect.setTo(0, 0, frameWidth, frameHeight);
		}
		
		/**
		 * Get the bounding rectangle of non-transparent pixels of the requested frame.
		 */
		public function getImageBounds(frame:uint):Rectangle 
		{
			return _imageBounds[frame];
		}
		
		/**
		 * Returns a new instance of an animated Clip.
		 */
		public function newRenderable():Renderable 
		{
			if (_rows == 0 || _columns == 0 || !_hasSpritesheet)
				return null;
			else
			{
				var clip:Clip = new Clip(_frameImages, animations);
				clip.play(defaultAnimation);
				return clip;
			}
		}
		
		/**
		 * Creates a clone of the master entity;
		 */
		public function newEntity():Entity 
		{
			var result:Entity = _master.clone()
			result.graphic = _master.graphic;
			entities.push(result);
			return result;
		}
		
		/**
		 * Set the entity class.
		 */
		CONFIG::developer
		hidden function setClass(klass:Class):void 
		{
			if (Entity.prototype.isPrototypeOf(klass.prototype))
			{
				_master = new klass();
				_master.graphic = this;
				_master._graphicTag = _tag;
				_masterClass = String(klass);
				
				
				var oldEntities:Vector.<Entity> = entities;  // Tricky
				entities = new Vector.<Entity>();  // Tricky
				
				for each (var oldEntity:Entity in oldEntities)
				{
					// Create replacement entity.
					var e:Entity = oldEntity.space.createEntity(this.tag, oldEntity.location.clone(), oldEntity._runtime);
					entities.push(e);
					
					CONFIG::developer
					{
						// Not suppose to happen.
						if (e == null) throw new GCError("critical internal error", 1);
					}
					
					// Destroy old entity.
					oldEntity.space.destroyEntity(oldEntity);
				}
			}
			else throw new GCError("class must be a subclass of the Entity class");
		}
		
		 /**
		 * Add an animation.
		 * @param	tag			Name of the animation.
		 * @param	frames		Vector of frame indices to animate through.
		 * @param	rate		Animation speed (percentage of normal speed).
		 * @param	loop		If the animation should loop.
		 */
		public function addAnimation(tag:String, frames:Vector.<int>, rate:Number=1, loop:Boolean=true):void 
		{
			_animations.add(tag, new Animation(tag, frames, rate, loop));
		}
		
		/**
		 * Remove an animation.
		 */
		public function removeAnimation(tag:String):void 
		{
			_animations.remove(tag);
		}
		
		/**
		 * Remove entities of this Graphic.
		 */
		CONFIG::developer
		hidden function removeEntities():void
		{
			for each (var entity:Entity in entities)
			{
				if (entity._space != null) entity.space.destroyEntity(entity);
			}
			entities.length = 0;
		}
		
	}

}

