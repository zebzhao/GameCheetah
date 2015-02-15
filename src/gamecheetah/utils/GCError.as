/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.utils 
{
	/**
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}
	 * @private
	 */
	public class GCError extends Error 
	{
		
		public function GCError(message:*="", id:*=0) 
		{
			super(message, id);
		}
		
	}

}