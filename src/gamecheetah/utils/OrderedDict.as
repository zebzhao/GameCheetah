/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.utils 
{
	import gamecheetah.namespaces.hidden;
	
	use namespace hidden;
	
	/**
	 * @author 		Zeb Zhao
	 * @private
	 */
	public class OrderedDict extends Restorable
	{
		/**
		 * Return ordered array of values.
		 */
		public function get values():Array 
		{
			return _values;
		}
		
		/**
		 * Return ordered array of keys.
		 */
		public function get keys():Array
		{
			return _keys;
		}
		
		hidden var _values:Array;
		hidden var _keys:Array;
		
		public function OrderedDict() 
		{
			super(["_values", "_keys"]);
			_values = [];
			_keys = [];
		}
		
		public function get length():int 
		{
			return _keys.length;
		}
		
		public function get(key:String):* 
		{
			return _values[_keys.indexOf(key)];
		}
		
		public function getAt(index:uint):* 
		{
			return _values[index];
		}
		
		public function swap(indexA:int, indexB:int):Boolean 
		{
			if (indexA >= _keys.length || indexB >= _keys.length)
				return false;
				
			var a:* = _values[indexA];
			_values[indexA] = _values[indexB];
			_values[indexB] = a;
			
			var k:String = _keys[indexA];
			_keys[indexA] = _keys[indexB];
			_keys[indexB] = k;
			
			return true;
		}
		
		public function contains(key:String):Boolean 
		{
			return _keys.indexOf(key) != -1;
		}
		
		public function updateKey(key:String, updated:String):void 
		{
			var index:int = _keys.indexOf(key);
			if (index == -1) throw new GCError("key doesn't exist");
			_keys[index] = updated;
		}
		
		public function updateValue(key:String, value:*):void 
		{
			var index:int = _keys.indexOf(key);
			if (index == -1) throw new GCError("key doesn't exist");
			_values[index] = value;
		}
		
		public function add(key:String, value:*):void 
		{
			if (_keys.indexOf(key) != -1) throw new GCError("key already exists");
			
			_keys.push(key);
			_values.push(value);
		}
		
		public function remove(key:String):void 
		{
			var index:int = _keys.indexOf(key);
			if (index == -1) throw new GCError("key does not exist");
			
			_keys.splice(index, 1);
			_values.splice(index, 1);
		}
	}

}