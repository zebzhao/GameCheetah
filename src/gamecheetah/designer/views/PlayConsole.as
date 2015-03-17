/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import gamecheetah.designer.components.*;
	import gamecheetah.*;
	
	public class PlayConsole extends Space 
	{
		private var
			_playStopBtn:IconToggleButton, _statsBtn:IconButton,
			_fpsLbl:Label, _memoryLbl:Label, _renderedLbl:Label,
			_pxCollisionLbl:Label, _quadtreeLbl:Label,
			_maxBinSizeLbl:Label, _binDispersityLbl:Label, _totalCollisionLbl:Label,
			_cameraLbl:Label,
			_statsBg:BaseComponent;
			
		public function PlayConsole() 
		{
			_playStopBtn = new IconToggleButton(this, Assets.PLAY, Assets.STOP, null, "Play", "Stop", Label.ALIGN_LEFT);
			_statsBtn = new IconButton(this, Assets.STATS, null, "Stats", Label.ALIGN_LEFT);
		}
		
		//{ ------------------------------------ Behaviour Overrides ------------------------------------
		
		override public function onEnter():void 
		{
			this.mouseEnabled = true;
		}
		
		override public function onUpdate():void 
		{
			_statsBtn.move(Engine.stage.stageWidth - 42, 10);
			_playStopBtn.move(Engine.stage.stageWidth - 42, Engine.stage.stageHeight - 42);
		}
		
		private function showStats():void 
		{
			
		}
		
		private function hideStats():void 
		{
			
		}
	}

}