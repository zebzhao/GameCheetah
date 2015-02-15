package gamecheetah.strix.hashtable.error
{
    /**
	 * @private
	 */
    public class InvalidKeyError extends Error
	{
        
        public function InvalidKeyError( message:*="", id:*=0 ) {
            super(message, id);
        }
        
    }
    
}