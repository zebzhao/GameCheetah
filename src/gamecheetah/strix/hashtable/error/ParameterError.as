package gamecheetah.strix.hashtable.error {
	
    /**
	 * @private
	 */
    public class ParameterError extends Error {
        
        public function ParameterError( message:*="", id:*=0 ) {
            super(message, id);
        }
        
    }
    
}