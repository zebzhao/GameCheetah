package gamecheetah.strix.collision.error {

	/**
	 * @private
	 */
    public final class IllegalBoundsError extends Error {
        
        public function IllegalBoundsError( message:*="", id:*=0 ) {
            super(message, id);
        }
        
    }
    
}