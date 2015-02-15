package com.oynor.bindlite {
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * Minimal replacement for Flex data binding. Access is fully static. For larger applications needing multiple
	 * models check out BindMax at http://www.oynor.com/blog/bindlite  
	 * @author Oyvind Nordhagen
	 * @date 4. feb. 2011
	 */
	public class BindLite {
		public static var autoDisposeBindings:Boolean;
		private static var _bindings:Dictionary = new Dictionary( true );

		/**
		 * Defines a new binable property as a string representation of an available property on the source argument.
		 * This property must be either a public var or getter/setter pair.
		 * @param key The property name 
		 * @param source The object containing the property
		 * @param compareFunction Reference to a function that takes two instances of this binding's datatype as arguments and returns true if they are equal
		 * @return void
		 */
		public static function define ( key:String, source:Object, allowNull:Boolean = true, forcePropagation:Boolean = false, compareFunction:Function = null ):void {
			if (_bindings[key] != undefined) {
				throw new IllegalOperationError( "Bindable key \"" + key + "\" is already defined" );
			}

			var def:XML = describeType( source );
			var dataTypeName:String;
			if (def.variable.(@name == key).length() > 0) {
				dataTypeName = def.variable.(@name == key)[0].@type;
			}
			else if (def.accessor.(@name == key).length() > 0) {
				if (def.accessor.(@name == key)[0].@access == "readwrite") {
					dataTypeName = def.accessor.(@name == key)[0].@type;
				}
				else {
					throw new ArgumentError( "Accessor \"" + key + "\" in " + source + " is read or write only" );
				}
			}
			else {
				throw new ArgumentError( "No property/accessor named \"" + key + "\" in " + source );
			}

			_bindings[key] = new Binding( key, source, getDefinitionByName( dataTypeName ) as Class, allowNull, forcePropagation, compareFunction );
		}

		/**
		 * Changes the value of a bindable property and propagates the change to all bound targets if new value differs from old. 
		 * @param key The predefined bindable property name
		 * @param value The new value
		 * @return void
		 */
		public static function update ( key:String, value:*, forcedPropagation:Boolean = false ):void {
			var binding:Binding = _getBinding( key );
			if (value is binding.dataType) {
				if (forcedPropagation || binding.forcePropagation || !binding.equals( value )) {
					binding.lastValue = _clone( binding.value );
					binding.value = value;
					_propagate( binding );
				}
			}
			else {
				throw new ArgumentError( "Type mismatch in binding " + key + ". Expected " + getQualifiedClassName( binding.dataType ) + ", was " + getQualifiedClassName( value ) );
			}
		}

		/**
		 * Binds a target to a bindable property. The target object must contain a public var or a setter by the same name as the bindable property.
		 * @param key The predefined bindable property name
		 * @param target The target object to push changes to the property value to
		 * @param initialPush If true, updates the property on the target immediately after binding
		 * @return void
		 */
		public static function bind ( key:String, target:Object, initialPush:Boolean = false ):void {
			var binding:Binding = _getBinding( key );
			_validateBindable( target, key, binding );
			_getBinding( key ).targets.push( target );
			if (initialPush) target[key] = _getBinding( key ).value;
		}

		/**
		 * Removes a target from binding(s). Specifying a property to unbind is optional. Without a key argument, the target will be removed from
		 * all bindings, effectively releasing it from data binding all together. 
		 * @param target The object to remove a binding from
		 * @param key Optional predefined bindable property name. If specified, only this binding is removed.
		 * @return void
		 */
		public static function unbind ( target:Object, key:String = null ):void {
			if (key) {
				var binding:Binding = _getBinding( key );
				binding.targets.splice( binding.targets.indexOf( target ), 1 );
				if (autoDisposeBindings) _evalAutoDispose( binding );
			}
			else {
				_unbindTargetFromAllKeys( target );
			}
		}

		/**
		 * Retrieves the value of a bindable property manually
		 * @param key The predefined bindable property name
		 * @return Value of bound property
		 */
		public static function retrieve ( key:String ):* {
			return _getBinding( key ).value;
		}

		/**
		 * Retrieves the previous value of a bindable property
		 * @param key The predefined bindable property name
		 * @return Previous value of bound property
		 */
		public static function retrieveLast ( key:String ):* {
			return _getBinding( key ).lastValue;
		}

		/**
		 * Manually removes the data binding
		 * @param key The predefined bindable property name of the binding
		 */
		public static function desposeBinding ( key:String ):void {
			_dispose( _getBinding( key ) );
		}
		
		/**
		 * Resets the supplied binding keys to the value they had at the time they were defined
		 * @param keys Comma separated list of predefined bindable property names
		 */
		public function reset ( ...keys ):void {
			for each (var key:String in keys) {
				_bindings[key].reset();
			}
		}

		private static function _evalAutoDispose ( binding:Binding = null ):void {
			if (binding && binding.targets.length == 0) {
				_dispose( binding );
			}
			else {
				for each (binding in _bindings) {
					if (binding.targets.length == 0) _dispose( binding );
				}
			}
		}

		private static function _dispose ( binding:Binding ):void {
			delete _bindings[binding.key];
			binding.dispose();
		}

		private static function _clone ( value:* ):* {
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject( value );
			myBA.position = 0;
			return(myBA.readObject());
		}

		private static function _propagate ( binding:Binding ):void {
			for each (var target:Object in binding.targets) {
				target[binding.key] = binding.value;
			}
		}

		private static function _getBinding ( key:String ):Binding {
			if (_bindings[key] != undefined) {
				return _bindings[key];
			}
			else {
				throw new ArgumentError( "No binding named \"" + key + "\"" );
			}
		}

		private static function _unbindTargetFromAllKeys ( target:Object ):void {
			for (var key:String in _bindings) {
				var binding:Binding = _bindings[key];
				if (binding.targets.indexOf( target ) != -1) {
					binding.targets.splice( binding.targets.indexOf( target ), 1 );
					if (autoDisposeBindings) _evalAutoDispose( binding );
				}
			}
		}

		private static function _validateBindable ( target:Object, key:String, binding:Binding ):void {
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
	}
}
