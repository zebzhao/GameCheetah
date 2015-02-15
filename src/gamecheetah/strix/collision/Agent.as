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