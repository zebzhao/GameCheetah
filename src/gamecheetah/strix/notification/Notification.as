/*Copyright (c) 2012, Martin Källman
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of the FreeBSD Project.*/

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