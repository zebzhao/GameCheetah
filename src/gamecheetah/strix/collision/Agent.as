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

package gamecheetah.strix.collision {
	import flash.geom.Point;
	import gamecheetah.strix.notification.Notification;
	import flash.geom.Rectangle;
    
	/**
	 * @private
	 */
    public class Agent extends Rectangle {
        
		public static const
            ON_MOVE      : uint = 1 << 0,
            ON_TRANSLATE : uint = 1 << 1,
            ON_SWEEP     : uint = 1 << 2,
            ON_RESIZE    : uint = 1 << 3;
			
        public var
            id   : uint,
            group : uint,
			action: uint;
        
		public var
            onChange : Notification;
			
        public function Agent( id:uint, group:uint, action:uint, x:Number, y:Number, width:Number=NaN, height:Number=NaN ) {
            super(x, y, width, height);
            
			onChange = new Notification;
			
            this.id = id;
            this.group = group;
			this.action = action;
        }
		
		public function resize( width:Number, height:Number ) : void {
            this.width = width;
			this.height = height;
            
            onChange.dispatch(ON_RESIZE, null);
        }
		
		public function moveTo( x:Number, y:Number ) : void {
            this.x = x;
            this.y = y;
            
            onChange.dispatch(ON_MOVE, null);
        }
        
        
        public function translate( dx:Number, dy:Number ) : void {
            this.offset(dx, dy);      
            onChange.dispatch(ON_TRANSLATE, null);
        }
    }
    
}