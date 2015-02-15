/**
 * The MIT License (MIT)
 * 
 * Copyright (c) 2011 Oyvind Nordhagen
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package gamecheetah.designer.bindlite {
	/**
	 * @author Oyvind Nordhagen
	 * @private
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
