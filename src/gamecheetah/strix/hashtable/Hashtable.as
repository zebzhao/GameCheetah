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

package gamecheetah.strix.hashtable {
    
    import gamecheetah.strix.hashtable.error.InvalidKeyError;
    import gamecheetah.strix.hashtable.error.ParameterError;
    
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;
    
    /**
	 * @private
	 */
    public final class Hashtable extends Proxy {
        
        public static const
            STRICT          : Boolean = true,
            DEFAULT_BUCKETS : uint = 16;
        
        private var
            buckets    : uint,
            bucketsMod : uint,
            key        : Vector.<Vector.<uint>>,
            bucket     : Vector.<Vector.<Object>>,
            strict     : Boolean;
        
        /**
        * Creates a new Hashtable.
        * 
        * @param buckets Number of buckets. A higher value means better add/get/remove performance, but consumes more memory and is costlier to initialize/reset
        * @param strict If set to <code>true</code>, exceptions will be thrown when attempting to perform illegal operations
        */
        public function Hashtable( buckets:uint=Hashtable.DEFAULT_BUCKETS, strict:Boolean=false ) {
            if( buckets == 0 || (buckets & (buckets-1)) != 0 ) {
                throw new ParameterError("buckets must be a power of 2");
            }
            
            this.buckets = buckets;
            this.bucketsMod = buckets-1;
            this.strict = strict;
            
            reset();
        }
        
        
        /**
        * Reset the Hashtable.
        */
        public function reset() : void {
            this.bucket = new Vector.<Vector.<Object>>(buckets, true);
            this.key = new Vector.<Vector.<uint>>(buckets, true);
            
            for( var i : uint = 0; i < buckets; i++ ) {
                this.bucket[i] = new Vector.<Object>;
                this.key[i] = new Vector.<uint>;
            }
        }
        
        
        private static function hash( k:uint ) : uint {
            //32-bit integer hash function by Thomas Wang
            k = (k ^ 61) ^ (k >> 16);
            k += (k << 3);
            k ^= (k >> 4);
            k *= 0x27d4eb2d;
            k ^= (k >> 15);
            
            return k;
        }
        
        
        /**
        * Add an object to the Hashtable.
        * 
        * @param key Key
        * @param object The object
        * 
        * @example
        * <listing version="3.0">
        *   var hashtable:Hashtable = new Hashtable;
        *   var object:MyClass = new MyClass;
        *   
        *   hashtable.add(123, object);
        *   object = hashtable.get(123) as MyClass;
        * </listing>
        */
        public function set( key:int, object:Object ) : void {
            var bucketIndex : uint = hash(key) & bucketsMod,
                bucketSize  : uint = bucket[bucketIndex].length;
            
            for( var i : uint = 0; i < bucketSize; i++ ) {
                if( this.key[bucketIndex][i] == key ) {
                    bucket[bucketIndex][i] = object;
                    return;
                }
            }
            
            this.key[bucketIndex].push(key);
            bucket[bucketIndex].push(object);
        }
        
        
        /**
        * Remove an object from the Hashtable.
        * 
        * @param key Key
        */
        public function remove( key:int ) : Boolean {
            var bucketIndex : uint = hash(key) & bucketsMod,
                bucketSize  : uint = bucket[bucketIndex].length;
            
            for( var i : uint = 0; i < bucketSize; i++ ) {
                if( this.key[bucketIndex][i] == key ) {
                    this.key[bucketIndex].splice(i, 1);
                    bucket[bucketIndex].splice(i, 1);
                    return true;
                }
            }
            
            if( strict )
                throw new InvalidKeyError("Object with key " + key + " does not exist.");
            
            return false;
        }
        
        /**
        * Get an object from the Hashtable.
        * 
        * @param key Key
        * 
        * @example
        * <listing version="3.0">
        *   var hashtable:Hashtable = new Hashtable;
        *   var object:MyClass = new MyClass;
        *   
        *   hashtable.add(123, object);
        *   object = hashtable.get(123) as MyClass;
        * </listing>
        */
        public function get( key:int ) : Object {
            var bucketIndex : uint = hash(key) & bucketsMod,
                bucketSize  : uint = bucket[bucketIndex].length;
            
            for( var i : uint = 0; i < bucketSize; i++ ) {
                if( this.key[bucketIndex][i] == key ) {
                    return bucket[bucketIndex][i];
                }
            }
            
            if( strict )
                  throw new InvalidKeyError("Object with key " + key + " does not exist.");
            
            return null;
        }
        
        
        /**
         * Determine if an object exists in the Hashtable.
         * 
         * @param key Key
         * 
         * @return <code>true</code> if object exists; <code>false</code> otherwise.
         */
        public function exists( key:int ) : Boolean {
            var bucketIndex : uint = hash(key) & bucketsMod,
                bucketSize  : uint = bucket[bucketIndex].length;
            
            for( var i : uint = 0; i < bucketSize; i++ ) {
                if( this.key[bucketIndex][i] == key ) {
                    return true;
                }
            }
            
            return false;
        }
        
       
        public function get keys() : Vector.<uint> {
            var keys : Vector.<uint> = new Vector.<uint>;
            
            for( var b : uint = 0; b < this.key.length; b++ ) {
                keys = keys.concat(this.key[b]);
            }
            
            return keys;
        }
        
        
        override flash_proxy function getProperty( key:* ) : * {
            return get(key);
        }
        
        
        override flash_proxy function setProperty( key:*, value:* ) : void {
            set(key, value);
        }
        
        
        override flash_proxy function deleteProperty( key:* ) : Boolean {
            return remove(key);
        }
        
    }
    
}