package com.oynor.bindlite {
	/**
	 * @author Oyvind Nordhagen
	 * @date 4. feb. 2011
	 */
	internal class Binding {
		internal var key:String;
		internal var source:Object;
		internal var dataType:Class;
		internal var compareFuction:Function;
		internal var lastValue:*;
		internal var forcePropagation:Boolean;
		internal var allowNull:Boolean;
		internal var targets:Vector.<Object> = new Vector.<Object>();
		private var defaultValue:*;

		public function Binding ( name:String, source:Object, dataType:Class = null, allowNull:Boolean = true, forcePropagation:Boolean = false, compareFuction:Function = null ) {
			this.allowNull = allowNull;
			this.forcePropagation = forcePropagation;
			this.dataType = dataType;
			this.source = source;
			this.key = name;
			this.compareFuction = compareFuction;
			this.defaultValue = source[key];
		}
		
		internal function reset():void {
			value = defaultValue;
		}

		internal function get value ():* {
			return source[key];
		}

		internal function set value ( val:* ):void {
			source[key] = val;
		}

		internal function equals ( val:* ):Boolean {
			if (compareFuction != null) {
				return compareFuction.apply( null, [ val, source[key] ] );
			}
			else if (source[key] !== val) {
				return false;
			}
			else {
				return true;
			}
		}

		internal function dispose ():void {
			source = null;
			dataType = null;
			compareFuction = null;
			targets.length = 0;
			value = null;
			lastValue = null;
			defaultValue = null;
		}
	}
}
