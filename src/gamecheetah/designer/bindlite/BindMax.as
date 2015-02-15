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
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * Replacement for Flex data binding. For smaller applications needing only one
	 * model consider BindLite at http://www.oynor.com/blog/bindlite  
	 * @author Oyvind Nordhagen
	 * @private
	 * @date 26. may 2011
	 */
	public class BindMax {
		private var _autoDisposeBindings:Boolean;
		protected var bindings:Dictionary;
		protected var classDefinition:XML;

		/**
		 * Constructor. Can enumerate all publicly accessible properties, including those defined
		 * by getter/setter pairs, and initialize bindings for them.
		 * @param autoEnumerate Enumerates bindings upon instantiation if true (default)   
		 * @return BindMax instance
		 */
		public final function BindMax ( autoEnumerate:Boolean = true, allowNull:Boolean = true ) {
			init();
			if (autoEnumerate) enumerateBindings( allowNull );
		}

		/**
		 * Sets whether a binding ignores comparison between old and new value when update is called.
		 * If forcePropagation is true, a call to update will always propagate the new value even
		 * if the new value is equal to the old value. 
		 * @param key The property name
		 * @param forcePropagation true to always propagate, false (default) to only propagate changed values
		 * @return void
		 */
		public final function setForcedPropagation ( key:String, forcePropagation:Boolean ):void {
			getBinding( key ).forcePropagation = forcePropagation;
		}

		/**
		 * Sets the compare function for a binding. 
		 * @param key The property name 
		 * @param compareFunction Reference to a function that takes two instances of this binding's datatype as arguments and returns true if they are equal
		 * @return void
		 */
		public final function setCompareFunction ( key:String, compareFunction:Function ):void {
			getBinding( key ).compareFuction = compareFunction;
		}

		/**
		 * Returns the compare function defined for a binding. 
		 * @param key The property name
		 * @return Function or null if not defined
		 */
		public final function getCompareFunction ( key:String ):Function {
			return getBinding( key ).compareFuction;
		}

		/**
		 * Changes the value of a bindable property and propagates the change to all bound targets if new value differs from old. 
		 * @param key The predefined bindable property name
		 * @param value The new value
		 * @return void
		 */
		public final function update ( key:String, value:*, forcePropagation:Boolean = false ):Boolean {
			var binding:Binding = getBinding( key );
			if ((value != null || binding.allowNull) || value is binding.dataType) {
				if (forcePropagation || binding.forcePropagation || !binding.equals( value )) {
					binding.lastValue = clone( binding.value );
					binding.value = value;
					propagate( binding );
					return true;
				}
			}
			else {
				throw new ArgumentError( "Type mismatch in binding \"" + key + "\". Expected " + getQualifiedClassName( binding.dataType ) + ", was " + getQualifiedClassName( value ) );
			}
			return false;
		}

		/**
		 * Binds a target to a bindable property. The target object must contain a public var or a setter by the same name as the bindable property.
		 * @param key The predefined bindable property name
		 * @param target The target object to push changes to the property value to
		 * @param initialPush If true, updates the property on the target immediately after binding
		 * @return void
		 */
		public final function bind ( key:String, target:Object, initialPush:Boolean = false ):void {
			if (!hasBinding( key, target )) {
				var binding:Binding = getBinding( key );
				validateBindable( target, key, binding );
				getBinding( key ).targets.push( target );
				if (initialPush) target[key] = getBinding( key ).value;
			}
			else {
				trace( "Warning: Attempted duplicate binding from " + target + " to " + key );
			}
		}

		/**
		 * Returns true if the specified binding exists, false if not
		 * @param key The predefined bindable property name
		 * @param target The target object to check agains the binding
		 * @return void
		 */
		public final function hasBinding ( key:String, target:Object ):Boolean {
			var binding:Binding = getBinding( key );

			for each (var boundTarget:Object in binding.targets) {
				if (boundTarget == target ) {
					return true;
				}
			}
			return false;
		}

		/**
		 * Removes a target from binding(s). Specifying a property to unbind is optional. Without a key argument, the target will be removed from
		 * all bindings, effectively releasing it from data binding all together. 
		 * @param target The object to remove a binding from
		 * @param key Optional predefined bindable property name. If specified, only this binding is removed.
		 * @return void
		 */
		public final function unbind ( target:Object, key:String = null ):void {
			if (key) {
				var binding:Binding = getBinding( key );
				binding.targets.splice( binding.targets.indexOf( target ), 1 );
				if (_autoDisposeBindings) evalAutoDispose( binding );
			}
			else {
				unbindTargetFromAllKeys( target );
			}
		}

		/**
		 * Retrieves the value of a bindable property manually
		 * @param key The predefined bindable property name
		 * @return Value of bound property
		 */
		public final function retrieve ( key:String ):* {
			return getBinding( key ).value;
		}

		/**
		 * Retrieves the previous value of a bindable property
		 * @param key The predefined bindable property name
		 * @return Previous value of bound property
		 */
		public final function retrieveLast ( key:String ):* {
			return getBinding( key ).lastValue;
		}

		/**
		 * Manually removes the data binding
		 * @param key The predefined bindable property name of the binding
		 */
		public final function disposeBinding ( key:String ):void {
			dispose( getBinding( key ) );
		}

		/**
		 * Defines whether bindings are automatically disposed when their list of listeners goes empty
		 */
		public final function get autoDisposeBindings ():Boolean {
			return _autoDisposeBindings;
		}

		/**
		 * Defines whether bindings are automatically disposed when their list of listeners goes empty
		 */
		public final function set autoDisposeBindings ( autoDisposeBindings:Boolean ):void {
			_autoDisposeBindings = autoDisposeBindings;
			if (_autoDisposeBindings) {
				for each (var binding:Binding in bindings) {
					evalAutoDispose( binding );
				}
			}
		}

		/**
		 * Resets the supplied binding keys to the value they had at the time they were defined.
		 * If no keys are supplied, all bindings will be reset.
		 * @param keys Comma separated list of predefined bindable property names
		 */
		public final function reset ( ...keys ):void {
			if (keys.length) {
				for each (var key:String in keys) {
					bindings[key].reset();
				}
			}
			else {
				for each (var item:Binding in bindings) {
					item.reset();
				}
			}
		}

		/**
		 * Force propagates the values of all bindings to all targets at their current state.
		 * TIP: If resetting the application/module with the reset function, you may call this function
		 * afterwards to propagate the default values of all bindings to all targets. 
		 * @return void
		 */
		public final function propagateAll ():void {
			for each (var binding:Binding in bindings) {
				propagate( binding );
			}
		}

		protected final function evalAutoDispose ( binding:Binding = null ):void {
			if (binding && binding.targets.length == 0) {
				dispose( binding );
			}
			else {
				for each (binding in bindings) {
					if (binding.targets.length == 0) dispose( binding );
				}
			}
		}

		protected final function dispose ( binding:Binding ):void {
			delete bindings[binding.key];
			binding.dispose();
		}

		protected final function clone ( value:* ):* {
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject( value );
			myBA.position = 0;
			return(myBA.readObject());
		}

		protected final function propagate ( binding:Binding ):void {
			for each (var target:Object in binding.targets) {
				target[binding.key] = binding.value;
			}
		}

		protected final function getBinding ( key:String ):Binding {
			if (bindings[key] != undefined) {
				return bindings[key];
			}
			else {
				throw new ArgumentError( "No binding named \"" + key + "\"" );
			}
		}

		protected final function unbindTargetFromAllKeys ( target:Object ):void {
			for (var key:String in bindings) {
				var binding:Binding = bindings[key];
				if (binding.targets.indexOf( target ) != -1) {
					binding.targets.splice( binding.targets.indexOf( target ), 1 );
					if (_autoDisposeBindings) evalAutoDispose( binding );
				}
			}
		}

		/**
		 * Defines a new binable property as a string representation of an available property on the source argument.
		 * This property must be either a public var or getter/setter pair.
		 * @param key The property name 
		 * @param compareFunction Reference to a function that takes two instances of this binding's datatype as arguments and returns true if they are equal
		 * @return void
		 */
		protected final function define ( key:String, allowNull:Boolean = true, forcePropagation:Boolean = false, compareFunction:Function = null ):void {
			if (!bindings) init();
			if (bindings[key] != undefined) {
				return;
			}

			var dataTypeName:String;
			if (classDefinition.variable.(@name == key).length() > 0) {
				dataTypeName = classDefinition.variable.(@name == key)[0].@type;
			}
			else if (classDefinition.accessor.(@name == key).length() > 0) {
				if (classDefinition.accessor.(@name == key)[0].@access == "readwrite") {
					dataTypeName = classDefinition.accessor.(@name == key)[0].@type;
				}
				else {
					throw new ArgumentError( "Accessor \"" + key + "\" is read or write only" );
				}
			}
			else {
				throw new ArgumentError( "No property/accessor named \"" + key + "\"" );
			}

			bindings[key] = new Binding( key, this, getDefinitionByName( dataTypeName ) as Class, allowNull, forcePropagation, compareFunction );
		}

		protected final function enumerateBindings ( allowNull:Boolean = true ):void {
			var publiclyAccessibleData:XMLList = classDefinition.variable + classDefinition.accessor.(@access == "readwrite");
			var key:String;
			if (!bindings) init();
			for each (var item:XML in publiclyAccessibleData) {
				key = item.@name;
				if (bindings[key] == undefined) bindings[key] = new Binding( key, this, getDefinitionByName( item.@type ) as Class, allowNull );
			}
		}

		protected final function validateBindable ( target:Object, key:String, binding:Binding ):void {
			var def:XML = describeType( target );
			var dataTypeName:String;
			if (def.variable.(@name == key).length() > 0) {
				dataTypeName = def.variable.(@name == key)[0].@type;
			}
			else if (def.accessor.(@name == key).length() > 0) {
				if (def.accessor.(@name == key)[0].@access.indexOf( "write" ) != -1) {
					dataTypeName = def.accessor.(@name == key)[0].@type;
				}
				else {
					throw new ArgumentError( "Accessor \"" + key + "\" in " + target + " is read only" );
				}
			}
			else {
				throw new ArgumentError( "No property/accessor named \"" + key + "\" in " + target );
			}

			if (binding.dataType !== getDefinitionByName( dataTypeName )) {
				throw new ArgumentError( "Binding data type mismatch on key \"" + key + "\" from " + binding.source + " to " + target );
			}
		}

		protected final function init ():void {
			classDefinition = describeType( this );
			bindings = new Dictionary( true );
		}
	}
}
