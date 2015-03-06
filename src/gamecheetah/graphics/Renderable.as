/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.graphics 
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import gamecheetah.Entity;
	import gamecheetah.strix.collision.Agent;
	import gamecheetah.namespaces.*;
	
	use namespace hidden;
	
	/**
	 * Basic renderable object providing the means to render bitmaps.
	 */
	public class Renderable
	{
		// Shared reusable geometry variables
		private static var _matrix:Matrix = new Matrix;
		private static var _ct:ColorTransform = new ColorTransform();
		private static var _point:Point = new Point;
		private static const RAD_PER_DEG:Number = Math.PI / 180;
		
		/**
		 * Clipping rectangle to crop renderable area.
		 */
		public var clipping:Rectangle;
		
		/**
		 * Secondary bitmap, alpha channel will be merged (multiplied) during rendering.
		 */
		public var alphaMask:BitmapData;
		
		/**
		 * Horizontal aspect ratio of the clip. Default is 1, any other value will cause a drop in rendering performance.
		 */
		public var scaleX:Number = 1;
		
		/**
		 * Vertical aspect ratio of the clip. Default is 1, any other value will cause a drop in rendering performance.
		 */
		public var scaleY:Number = 1;
		
		/**
		 * Rotation of the clip in degrees. Any non-zero value will cause a drop in rendering performance.
		 */
		public var rotation:int;
		
		/**
		 * Apply a tint to the clip.
		 */
		public var tint:uint;
		
		/**
		 * Value between 1 and 0. Any non-zero value causes a drop in performance.
		 */
		public var tintAlpha:Number = 0;
		
		/**
		 * Alpha transparency of the clip. Any value less than 1 will cause a drop in rendering performance.
		 */
		public var alpha:Number = 1;
		
		/**
		 * Apply bitmap smoothing after rotation.
		 * Causes further performance degradation, default is false.
		 */
		public var smoothing:Boolean;
		
		/**
		 * Origin point to stretch/rotate around, default is set to the center of the image.
		 */
		public var transformAnchor:Point = new Point;
		
		/**
		* Current image to render.
		*/
		public function get buffer():BitmapData { return _buffer; }
		protected function setBuffer(value:BitmapData):void 
		{
			_buffer = value;
			if (_buffer != null) 
			{
				var w:Number = scaleX * _buffer.width;
				var h:Number = scaleY * _buffer.height;
				
				if ((_lastHeight != h || _lastWidth != w) && _entity != null)
				{
					// Resize entity agent
					_lastWidth = w;
					_lastHeight = h;
					_entity._resizeAgent(w, h);
				}
			}
		}
		protected var _buffer:BitmapData;
		
		/**
		 * The assigned to entity.
		 */
		public function get entity():Entity { return _entity; }
		
		hidden var _entity:Entity;
		private var _lastWidth:Number = 0;
		private var _lastHeight:Number = 0;
		
		public function Renderable() 
		{
		}
		
		/**
		 * Overridable. Disposes the clip.
		 */
		public function dispose():void 
		{
		}
		
		/**
		 * Render a BitmapData object to the target with the specified transformations.
		 */
		public static function draw(source:BitmapData, target:BitmapData, dest:Point,
				rotation:int, transformAnchor:Point, alpha:Number, scaleX:Number, scaleY:Number, tint:uint, tintAlpha:Number, smoothing:Boolean, bounds:Rectangle):void 
		{
			// Check if applied transformation makes clip invisible.
			if (alpha <= 0.01 || Math.abs(scaleX) <= 0.001 || Math.abs(scaleY) <= 0.001) return;
			
			// Update color transform alpha.
			var ct:ColorTransform;
			if (alpha != 1 || tintAlpha != 0)
			{
				_ct.alphaMultiplier = alpha;
				_ct.greenMultiplier =_ct.blueMultiplier = _ct.redMultiplier = 1 - tintAlpha;
				_ct.redOffset = Math.round(tintAlpha * ((tint >> 16) & 0xff));
				_ct.greenOffset = Math.round(tintAlpha * ((tint >> 8) & 0xff));
				_ct.blueOffset = Math.round(tintAlpha * (tint & 0xff));
				ct = _ct;
			}
			
			// Reset transformation matrix.
			_matrix.identity();
			_matrix.translate( -transformAnchor.x, -transformAnchor.y);
			
			// Apply scale and rotation to the matrix.
			if (scaleX != 1 || scaleY != 1) _matrix.scale(scaleX, scaleY);
			if (rotation != 0) _matrix.rotate(rotation * RAD_PER_DEG);
			
			_matrix.translate(transformAnchor.x + dest.x, transformAnchor.y + dest.y);
			
			target.draw(source, _matrix, ct, null, bounds, smoothing);
		}
		
		/** Render the Clip to the target. */
		public function render(target:BitmapData, x:Number, y:Number):void
		{
			if (_buffer == null) return;
			
			_point.setTo(x, y);
			
			if (rotation != 0 || alpha < 1 || scaleX != 1 || scaleY != 1 || tintAlpha != 0)
			{
				if (alphaMask == null)
				{
					Renderable.draw(_buffer, target, _point, rotation, transformAnchor, alpha, scaleX, scaleY, tint, tintAlpha, smoothing, clipping);
				}
				else
				{
					var buffer:BitmapData = new BitmapData(_buffer.width, _buffer.height, true, 0);
					buffer.copyPixels(_buffer, clipping != null ? clipping : _buffer.rect, new Point, alphaMask, null, true);
					Renderable.draw(buffer, target, _point, rotation, transformAnchor, alpha, scaleX, scaleY, tint, tintAlpha, smoothing, clipping);
				}
			}
			else target.copyPixels(_buffer, clipping != null ? clipping : _buffer.rect, _point, alphaMask, null, true);
		}
		
		/** Width of the buffer with scaling */
		public function get width():Number 
		{
			return _buffer == null ? 0 : scaleX * _buffer.width;
		}
		public function set width(value:Number):void 
		{
			scaleX = value / _buffer.width;
		}
		
		/** Height of the buffer with scaling */
		public function get height():Number 
		{
			return _buffer == null ? 0 : scaleY * buffer.height;
		}
		public function set height(value:Number):void 
		{
			scaleY = value / buffer.height;
		}
	}

}