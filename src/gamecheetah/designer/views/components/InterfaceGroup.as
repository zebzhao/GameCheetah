/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views.components 
{
	import gamecheetah.designer.bit101.components.Component;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	/**
	 * A generic abstract class for managing a group of UI components.
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}
	 * @private
	 */
	public class InterfaceGroup extends Component
	{
		public function InterfaceGroup(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0) 
		{
			super(parent, xpos, ypos);
		}
		
		
		override protected function init():void 
		{
			preinitialize();
			
			super.init();
			
			build();
			
			initialize();
			
			addListeners();
			
			this.addEventListener(Event.RESIZE, onResizeHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, onResizeHandler);
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Default event handlers
		
		/**
		 * @private	Internal resize handler.
		 */
		private function onResizeHandler(e:Event):void 
		{
			onResize();
		}
		
		/**
		 * Override this. Construct layout of UI components here.
		 */
		protected function onResize():void 
		{
			
		}
		
		//} Default event handlers
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Override this. Run code before initialization here.
		 */
		protected function preinitialize():void 
		{
			
		}
		
		/**
		 * Override this. Create components here.
		 */
		protected function build():void 
		{
			
		}
		
		/**
		 * Override this. Initialize components here.
		 */
		protected function initialize():void 
		{
			
		}
		
		/**
		 * Override this. Register event handlers used by this class here.
		 */
		protected function addListeners():void 
		{
			
		}
	}

}