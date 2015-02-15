package gamecheetah.strix.collision {
    
	/**
	 * @private
	 */
    internal final class Utils {
    
        public static const
            EPS : Number = 0.0000002;
        
        public static function dot( a1:Number, a2:Number, b1:Number, b2:Number ) : Number {
            return a1*a2 + b1*b2;
        }
        
    }
    
}