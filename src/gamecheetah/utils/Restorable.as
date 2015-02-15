/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.utils 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import gamecheetah.namespaces.hidden;
	
	use namespace hidden;
	
	/**
	 * Objects can be saved to file and restored from saved data.
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}
	 * @private
	 */
	public class Restorable 
	{
		/**
		 * List of missing interaction class definitions.
		 */
		hidden static var __missing:Vector.<String> = new Vector.<String>();
		
		/**
		 * Class properties to export.
		 */
		protected var __exports:Array = [];
		
		
		public function Restorable(params:Array) 
		{
			if (params != null) __exports = params;
		}
		
		
		/**
		 * Export all data stored in _export variable name array.
		 */
		public function export():Object
		{
			var output:Object = { "__class":getQualifiedClassName(this) };
			
			var prop:String;
			for each (prop in __exports)
			{
				if (this[prop] === undefined) throw new GCError("The property '" + prop + "' is undefined!");
				output[prop] = simplify(this[prop]);
			}
			return output;
		}
		
		
		/**
		 * Simplifies data structures into basic/primitive form.
		 */
		private function simplify(value:*):*
		{
			var result:*;
			if (value is Restorable)
			{
				result = (value as Restorable).export();
			}
			else if (value is Array || value is Dictionary || getQualifiedClassName(value) == "Object")
			{
				if (value is Array) result = [];
				else if (value is Dictionary) result = new Dictionary();
				else result = new Object();
				
				var key:*;
				for (key in value)
				{
					result[key] = simplify(value[key]);
				}
			}
			else if (value is BitmapData)
			{
				var bmd:BitmapData = value as BitmapData;
				result = { "__class":"flash.display::BitmapData", "width":bmd.width, "height":bmd.height, "bytes":bmd.getPixels(bmd.rect) };
			}
			else if (value == null || value is int || value is uint || value is String || value is Number || value is Boolean ||
					 value is Vector.<int> || value is Vector.<uint> || value is Vector.<Number> || value is Vector.<Boolean>)
			{
				result = value;
			}
			else if (value is Rectangle)
			{
				result = { "__class":"flash.geom::Rectangle", "x":(value as Rectangle).x, "y":(value as Rectangle).y, "width":(value as Rectangle).width, "height":(value as Rectangle).height };
			}
			else if (value is Point)
			{
				result = { "__class":"flash.geom::Point", "x":(value as Point).x, "y":(value as Point).y };
			}
			return result;
		}
		
		
		/**
		 * Create another copy of this object.
		 * registerClassAlias() does not work with BitmapData, as ByteArray.readObject() does not pass any arguments to the constructor.
		 * Additionally, objects such as bitmapData should not be cloned.
		 */
		hidden function clone():* 
		{
			return parse(this.export());
		}
		
		/**
		 * Import data from obj, reverse operation of export().
		 */
		public function restore(obj:Object):void 
		{
			var prop:String, value:*;
			
			for each (prop in __exports)
			{
				value = parse(obj[prop]);
				// Set the property if it is of the same type or is currently null.
				if (this[prop] == null || value is Object(this[prop]).constructor) this[prop] = value;
				else if (CONFIG::developer) trace("Property not found: " + prop + " in " + this)
			}
		}
		
		/**
		 * Parse an unknown value recursively and restore any Restorable.
		 */
		private static function parse(value:*):* 
		{
			var result:*, type:Class;
			var index:int;
			
			if (getQualifiedClassName(value) == "Object")
			{
				if (value.hasOwnProperty("__class"))
				{
					try
					{
						type = getDefinitionByName(value["__class"]) as Class;
					}
					catch (err:ReferenceError)
					{
						trace("Critical error: " + value["__class"] + " class could not be found!");
						__missing.push(value["__class"]);
						return undefined;
					}
					
					if (type === Rectangle)
					{
						result = new Rectangle(value["x"], value["y"], value["width"], value["height"]);
					}
					else if (type === Point)
					{
						result = new Point(value["x"], value["y"]);
					}
					else if (type === BitmapData)
					{
						var bmd:BitmapData = new BitmapData(value["width"], value["height"]);
						bmd.setPixels(bmd.rect, value["bytes"] as ByteArray);
						result = bmd;
					}
					else
					{
						result = new type();
						if (result is Restorable) (result as Restorable).restore(value);
					}
				}
				else
				{
					for (var prop:String in value)
					{
						value[prop] = parse(value[prop]); 
					}
					result = value;
				}
			}
			else if (value == null || value is int || value is uint || value is String || value is Number || value is Boolean)
			{
				result = value;
			}
			else if (value is Array)
			{
				// Tricky: Produce a copy, instead of modifying the original object. Otherwise, the original state will not be retrievable!
				var original1:Array = value as Array;
				var array1:Array = [];
				
				for (index = original1.length - 1; index >= 0; index--)
				{
					array1[index] = parse(original1[index]);
				}
				result = array1;
			}
			else if (value is Vector.<int>)
			{
				var original2:Vector.<int> = value as Vector.<int>;
				var vector2:Vector.<int> = new Vector.<int>(original2.length);
				
				for (index = original2.length - 1; index >= 0; index--)
				{
					vector2[index] = original2[index];
				}
				result = vector2;
			}
			else if (value is Vector.<uint>)
			{
				var original3:Vector.<uint> = value as Vector.<uint>;
				var vector3:Vector.<uint> = new Vector.<uint>(original3.length);
				
				for (index = original3.length - 1; index >= 0; index--)
				{
					vector3[index] = original3[index];
				}
				result = vector3;
			}
			else if (value is Vector.<Number>)
			{
				var original4:Vector.<Number> = value as Vector.<Number>;
				var vector4:Vector.<Number> = new Vector.<Number>(original4.length);
				
				for (index = original4.length - 1; index >= 0; index--)
				{
					vector4[index] = original4[index];
				}
				result = vector4;
			}
			else if (value is Vector.<Boolean>)
			{
				var original5:Vector.<Boolean> = value as Vector.<Boolean>;
				var vector5:Vector.<Boolean> = new Vector.<Boolean>(original5.length);
				
				for (index = original5.length - 1; index >= 0; index--)
				{
					vector5[index] = original5[index];
				}
				result = vector5;
			}
			else if (value is Dictionary)
			{
				var dict:Dictionary = (value as Dictionary)
				for (var key:* in dict)
				{
					dict[key] = parse(dict[key]);
				}
				result = dict;
			}
			else
			{
				throw new GCError("unknown type encountered in Restorable object.");
			}
			return result;
		}
		
		/**
		 * Return True if one or more items overlap between two arrays.
		 */
		private static function checkOverlap(a:Array, b:Array):Boolean 
		{
			var shorter:Array = a.length < b.length ? a : b;
			for each (var item:String in shorter)
			{
				if (item in b) return true;
			}
			return false;
		}
	}

}