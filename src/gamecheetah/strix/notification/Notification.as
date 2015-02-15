package gamecheetah.strix.notification {
    
	/**
	 * @private
	 */
    public class Notification  {
        
        public static const
            ALL : uint = 0xffffffff;
        
        private var callbacks : Vector.<Function>;
        private var contexts  : Vector.<Object>;
        private var types     : Vector.<uint>;
        
            
        private function initialize() : void {
            callbacks = new Vector.<Function>;
            contexts = new Vector.<Object>,
            types = new Vector.<uint>;
        }
        
        
        public function reset() : void {
            if( callbacks == null )
                return;
            
            callbacks = new Vector.<Function>;
            contexts = new Vector.<Object>,
            types = new Vector.<uint>;
        }
        
        
        public function addListener( notification:uint, callback:Function, context:Object=null ) : Notification {
            if( callbacks == null ) {
                initialize();
            }
            
            for( var i : uint = 0; i < callbacks.length; i++ ) {
                if( callbacks[i] === callback ) {
                    types[i] |= notification;
                    
                    return this;
                }
            }
            
            callbacks.push(callback);
            contexts.push(context);
            types.push(notification);
            
            return this;
        }
        
        
        public function removeListener( notification:uint, callback:Function ) : Notification {
            if( callbacks == null ) {
                return this;
            }
            
            for( var i : uint = 0; i < callbacks.length; i++ ) {
                if( callbacks[i] === callback ) {
                    types[i] = types[i] & (types[i] ^ notification);
                    
                    if( types[i] == 0 ) {
                        callbacks.splice(i, 1);
                        types.splice(i, 1);
                    }
                    
                    return this;
                }
            }
            
            return this;
        }
        
  
        public function dispatch( notifications:uint, data:* ) : void {
            if( callbacks == null ) {
                return;
            }
            
            for( var i : uint = 0; i < types.length; i++ ) {
                var applicable : uint = uint(notifications & types[i]);
                
                if( applicable != 0 ) {
                    if( callbacks[i] != null ) {
                        callbacks[i](contexts[i], applicable, data);
                    }
                }
            }
        }
        
    }
    
}