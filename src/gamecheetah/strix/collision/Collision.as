package gamecheetah.strix.collision {
    
	/**
	 * @private
	 */
    public final class Collision {
        
        public var
            a          : Agent,
            b          : Agent;
            
        public function Collision( a:Agent, b:Agent ) {
			this.a = a;
			this.b = b;
        }
        
    }
    
}