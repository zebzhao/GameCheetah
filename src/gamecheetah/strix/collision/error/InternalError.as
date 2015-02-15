package gamecheetah.strix.collision.error {
    
	/**
	 * @private
	 */
    public final class InternalError extends Error {
        
        public function InternalError( message:*="", id:*=0 ) {
            super(message, id);
        }
        
    }
    
}