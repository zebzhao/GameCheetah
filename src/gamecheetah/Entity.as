/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import gamecheetah.graphics.*;
	import gamecheetah.namespaces.*;
	import gamecheetah.strix.collision.Agent;
	import gamecheetah.utils.Restorable;
	
	use namespace hidden;
	
	/**
	 * Extendable this class for handling game logic of graphics.
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}
	 */
	public class Entity extends Restorable 
	{
		private static var _matrix:Matrix = new Matrix();
		private static const RAD_PER_DEG:Number = Math.PI / 180;
		
		/**
		 * Instantiated when parent space set to active.
		 */
		public final function get renderable():Renderable
		{
			/*CONFIG::developer
			{
				// NOT FOR RELEASE: Helps developer debug the engine's internal issues.
				if (!_activated) throw new GCError("attempt to access inactivated entity detected! (DEBUG)")
			}*/
			return _renderable;
		}
		public final function set renderable(value:Renderable):void 
		{
			_renderable = value;
			
			// Attempt casting renderable to other graphic types.
			_clip = _renderable as Clip;
			_textClip = _renderable as TextClip;
			
			if (_renderable != null && _renderable.buffer != null)
			{
				_resizeAgent(_renderable.width, _renderable.height);
				_renderable._entity = this; // For when renderable is resized.
				_renderable.tint = _tint;
				_renderable.tintAlpha = _tintAlpha;
			}
			else _agent.resize(0, 0);
		}
		private var _renderable:Renderable;
		private var _halfWidth:Number, _halfHeight:Number;
		
		/**
		 * [Read-only] The renderable casted as a Clip object. Null if renderable is not a Clip.
		 */
		public final function get clip():Clip 
		{
			return _clip;
		}
		private var _clip:Clip;
		
		/**
		 * The renderable casted as a TextClip object. Null if renderable is not a TextClip.
		 */
		public final function get textClip():TextClip 
		{
			return _textClip;
		}
		public final function set textClip(value:TextClip):void
		{
			_textClip = value;
			renderable = value;
		}
		private var _textClip:TextClip;
		
		/**
		 * An unique string used to identity this entity.
		 */
		public var tag:String;
		
		/**
		 * Graphic this entity.
		 */
		public final function get graphic():Graphic 
		{
			return _graphic;
		}
		public final function set graphic(value:Graphic):void 
		{
			// Check if clip has been created.
			if (_renderable != null && _renderable.buffer != null)
				_renderable.dispose();
			
			// Update clip
			_graphic = value;
			_graphicTag = _graphic.tag;
			
			if (_graphic != null)
			{
				_halfWidth = _graphic.frameRect.width / 2;
				_halfHeight = _graphic.frameRect.height / 2;
				
				_agent.group = _graphic.group;
				_agent.action = _graphic.action;
				
				// Update clip object upon setting graphic
				this.renderable = _graphic.newRenderable();
			}
		}
		private var _graphic:Graphic;
		
		/**
		 * The collision group this entity belongs to. Default is set based on Graphic.group value.
		 * Bitwise AND is used to find suitable collision partners.
		 */
		public final function get collisionGroup():uint 
		{
			return _agent.group;
		}
		public final function set collisionGroup(value:uint):void 
		{
			_agent.group = value;
		}
		
		/**
		 * The collision groups to collide with. Default is set based on Graphic.action value.
		 * Bitwise AND is used to find suitable collision partners.
		 */
		public final function get collisionAction():uint 
		{
			return _agent.action;
		}
		public final function set collisionAction(value:uint):void 
		{
			_agent.action = value;
		}
		
		/**
		 * Saved graphic tag information.
		 */
		hidden var _graphicTag:String;
		
		/**
		 * [Read-only] Parent container of this entity.
		 */
		public final function get space():Space 
		{
			return _space;
		}
		hidden var _space:Space;
		
		/**
		 * True if entity consumes mouse events. Default is false.
		 * If false, entity becomes invisible to the mouse.
		 */
		public var mouseEnabled:Boolean = false;
		
		/**
		 * Render depth of the entity.
		 */
		public var depth:int;
		
		/**
		 * True if entity is actively checking for collisions.
		 * Default is <b>true</b>, set to <b>false</b> to stop checking.
		 */
		public var collidable:Boolean = true;
		
		/**
		 * True if entity can be queried via Space::queryArea, Space::queryPoint methods.
		 * Default is <b>true</b>, set to <b>false</b> to disallow querying.
		 */
		public var queriable:Boolean = true;
		
		/**
		 * The renderable transforms (scaleX, scaleY, rotation) are applied to the collision masks as well.
		 * Default is <b>true</b>, set to <b>false</b> use original masks (better performance).
		 */
		public var applyTransformToMask:Boolean = true;
		
		/**
		 * Internal property, displacement in x and y.
		 */
		protected var dx:Number, dy:Number;
		
		/**
		 * Position of the entity in Space object. (Top-left corner)
		 */
		public var location:Point = new Point();
		
		/**
		 * [Read-only] Center of the entity in Space object.
		 */
		public final function get center():Point 
		{
			_center.setTo(location.x + _halfWidth, location.y + _halfHeight);
			return _center;
		}
		public function setCenter(x:Number, y:Number):void 
		{
			_center.setTo(x, y);
			location.setTo(x - _halfWidth, y - _halfHeight);
		}
		private var _center:Point = new Point();
		
		/**
		 * The position of "location" is relative to this origin value.
		 */
		public var origin:Point = new Point();
		
		/**
		 * [Read-only] The absolute position is the sum of the origin and relative location.
		 */
		public final function get absoluteLocation():Point
		{
			_absoluteLocation.setTo(origin.x + location.x, origin.y + location.y);
			return _absoluteLocation;
		}
		private var _absoluteLocation:Point = new Point();
		
		/**
		 * [Read-only] The absolute center is the sum of the origin and relative center.
		 */
		public final function get absoluteCenter():Point
		{
			_absoluteCenter.setTo(origin.x + location.x + _halfWidth, origin.y + location.y + _halfHeight);
			return _absoluteCenter;
		}
		private var _absoluteCenter:Point = new Point();
		
		/**
		 * [Read-only] Gets the bounding rectangle for the entity.
		 */
		public final function get bounds():Rectangle 
		{
			return _agent.clone();
		}
		
		/**
		 * [Read-only] Properties this entity.
		 */
		/*public function get properties():Array 
		{
			return _properties;
		}
		private var _properties:Array;*/
		
		
		/**
		 * [Read-only] True if renderable is created.
		 */
		public final function get activated():Boolean 
		{
			return _activated;
		}
		
		/**
		 * Internal property, true for runtime created entities.
		 */
		hidden var _runtime:Boolean = true;
		
		
		// Entity information
		hidden var _activated:Boolean;
		hidden var _agent:Agent;
		hidden var _onScreenStatus:int;
		private var _transformData:TransformData;
		private var _invokeStarted:Boolean;
		private var _tint:uint, _tintAlpha:Number=0;
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Overridables
		
		public function onActivate():void 
		{
		}
		
		public function onDeactivate():void 
		{
		}
		
		public function onUpdate():void 
		{
		}
		
		public function onCollision(other:Entity):void 
		{
		}
		
		public function onMove(dx:Number, dy:Number):void 
		{
		}
		
		public function onMouseUp():void 
		{
		}
		
		public function onMouseDown():void 
		{
		}
		
		public function onMouseOver():void 
		{
		}
		
		public function onMouseOut():void 
		{
		}
		
		//} Overridables
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		/**
		 * A game entity storing state information.
		 */
		public function Entity() 
		{
			//_properties = getProperties();
			//super(_properties.concat(["_graphicTag", "tag", "depth", "location"]));
			super(["_graphicTag", "tag", "depth", "location"]);
			
			_transformData = new TransformData(0, 1, 1, new Point(), null);
			this._agent = new Agent(0, 1, 0, 0, 0);
		}
		
		/*override public function restore(obj:Object):void 
		{
			super.restore(obj);
		}*/
		
		public function setTint(color:uint, tintAlpha:Number=1):void 
		{
			_tint = color;
			_tintAlpha = tintAlpha;
			
			if (_renderable != null && _renderable.buffer != null)
			{
				_renderable.tint = _tint;
				_renderable.tintAlpha = _tintAlpha;
			}
		}
		
		/**
		 * Return true if entity will be rendered to the screen.
		 */
		public function checkOnScreen():Boolean 
		{
			// Typically, screen status is set in Space class.
			if (_onScreenStatus == -1) return false;
			else if (_onScreenStatus == 1) return true;
			else
			{
				// Not an elegant solution, but can't see the harm in updating the agent.
				_agent.moveTo(absoluteLocation.x, absoluteLocation.y);
				_onScreenStatus = _space != null && _space._screenBounds.intersects(_agent) ? 1 : -1;
				return _onScreenStatus == 1 ? true : false;
			}
		}
		
		/**
		 * Create another copy of this object.
		 */
		public function duplicate():Entity
		{
			return super.clone() as Entity;
		}
		
		
		/**
		 * [Internal] Resizes the renderable agent.
		 */
		hidden function _resizeAgent(w:int, h:int):void 
		{
			_halfWidth = w / 2;
			_halfHeight = h / 2;
			_agent.resize(w, h);
		}
		
		/**
		 * Return the collision mask for the renderable clip.
		 * @return	A BitmapData or Rectangle object.
		 */
		hidden function _getMask():*
		{
			if (_graphic && _graphic._frameMasks.length > 0)
			{
				var clip:Clip = _renderable as Clip;
				var result:*;
				
				if (clip != null)
				{
					result = _graphic._frameMasks[_graphic.alwaysUseDefaultMask ? 0 : clip.frame];
				}
				else result = _graphic._frameMasks[0];
				
				if (result == null || !applyTransformToMask || _renderable.rotation == 0 && _renderable.scaleX == 1 && _renderable.scaleY == 1)
				{
					// Return unmodified mask. (no rotation/scaling)
					return result;
				}
				else if (_transformData.equals(_renderable.rotation, _renderable.scaleX, _renderable.scaleY, _renderable.transformAnchor))
				{
					// Return already transformed mask. (same as previous)
					return _transformData.data;
				}
				else
				{
					// Dispose previously stored transformed collision bitmap.
					if (_transformData.data != null) _transformData.data.dispose();
					
					// Apply rotation and transform to mask.
					var newBmd:BitmapData = new BitmapData(_renderable.width, _renderable.height, true, 0);
					_transformData.setTo(_renderable.rotation, _renderable.scaleX, _renderable.scaleY, _renderable.transformAnchor, newBmd);
					
					// Reset transformation matrix.
					_matrix.identity();
					_matrix.translate(-_transformData.tAx, -_transformData.tAy);
					
					// Apply scale and rotation to the matrix.
					_matrix.scale(_transformData.scaleX, _transformData.scaleY);
					_matrix.rotate(_transformData.rotation * RAD_PER_DEG);
					
					_matrix.translate(_transformData.tAx, _transformData.tAy);
					
					// Tricky: Must convert rotated rectangle to bitmap unless figure out reliable way to test for collision with bitmap.
					var rect:Rectangle = result as Rectangle;
					var bmd:BitmapData = result as BitmapData;
					
					if (rect != null)
					{
						bmd = new BitmapData(_graphic.frameRect.width, _graphic.frameRect.height, true, 0);
						bmd.fillRect(rect, 0x90ff0000);
						newBmd.draw(bmd, _matrix);
						bmd.dispose();
					}
					else newBmd.draw(bmd, _matrix);
					
					return newBmd;
				}
			}
		}
		
		/**
		 * Retrieves all IProperty members from this class.
		 */
		/*private function getProperties():Array 
		{
			var result:Array = [];
			
			//Get an XML description of this class and return the variable types as XMLList with e4x
			var classInfo:XML = describeType(this)
			var variables:XMLList = classInfo..variable;
			var i:int, name:String;

			for (i = 0; i < variables.length(); i++)
			{
				name = variables[i].@name
				if (this[name] is IProperty)
				{
					result.push(name);
				}
			}
			return result;
		}*/
		
		/**
		 * Stop any tweens started by tweenClip().
		 */
		public function stopTween():void 
		{
			if (_renderable != null) Engine.cancelTweens(_renderable);
		}
		
		/**
		 * Tweens the text clip object. If not activated yet will delegate call to next frame.
		 * @param	from	If null uses the current properties.
		 * @param	to		If null uses the current properties.
		 */
		public function tweenClip(from:Object=null, to:Object=null, duration:Number=0.5, ease:Function=null, delayStart:Number=0, transformAnchor:Point=null, onComplete:Function=null, onCompleteParams:Array=null):void 
		{
			if (_renderable == null)
			{
				CONFIG::developer
				{
					trace("Warning: trying to tween an entity with no renderable object!");
				}
				return;
			}
			else
			{
				if (transformAnchor != null) _renderable.transformAnchor = transformAnchor;
				Engine.cancelTweens(_renderable);
				Engine.startTween(_renderable, delayStart, duration, from, to, ease, onComplete, onCompleteParams, true);
			}
		}
	}

}
import flash.display.BitmapData;
import flash.geom.Point;

class TransformData
{
	public var scaleX:Number;
	public var scaleY:Number;
	public var rotation:Number;
	public var tAx:Number;
	public var tAy:Number;
	public var data:BitmapData;
	
	public function TransformData(rotation:Number, scaleX:Number, scaleY:Number, transformAnchor:Point, data:BitmapData) 
	{
		setTo(rotation, scaleX, scaleY, transformAnchor, data);
	}
	
	public function setTo(rotation:Number, scaleX:Number, scaleY:Number, transformAnchor:Point, data:BitmapData):void
	{
		this.rotation = rotation;
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		this.tAx = transformAnchor.x;
		this.tAy = transformAnchor.y;
		this.data = data;
	}
	
	public function equals(rotation:Number, scaleX:Number, scaleY:Number, transformAnchor:Point):Boolean 
	{
		return this.rotation == rotation && this.scaleX == scaleX && tAx == transformAnchor.x && transformAnchor.y == tAy && this.scaleY == scaleY;
	}
}