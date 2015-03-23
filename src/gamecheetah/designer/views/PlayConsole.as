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
	import flash.utils.getTimer;
	import flash.system.System;
	
	public class PlayConsole extends Space 
	{
		private var
			_playStopBtn:IconToggleButton, _statsBtn:IconButton,
			_infoLabel:Label,
			_perfLbl:Label, _renderedLbl:Label,
			_pxCollisionLbl:Label,
			_binInfoLbl:Label,
			_cameraLbl:Label,
			_statsBg:BaseComponent;
			
		private var
			_framesElapsed:uint,
			_time:Number = 0,
			_fps:int;
			
		public function PlayConsole() 
		{
			_playStopBtn = new IconToggleButton(this, Assets.GAME, Assets.EXIT, null, "Run!", "Exit", Label.ALIGN_ABOVE);
			_statsBtn = new IconButton(this, Assets.STATS, statsBtn_Click, "Stats", Label.ALIGN_ABOVE);
			
			_renderedLbl = new Label(this, "", null, null, Style.FONT_DARK);
			_perfLbl = new Label(this, "", null, null, Style.FONT_DARK);
			_pxCollisionLbl = new Label(this, "", null, null, Style.FONT_DARK);
			_binInfoLbl = new Label(this, "", null, null, Style.FONT_DARK);
			_cameraLbl = new Label(this, "", null, null, Style.FONT_DARK);
			_infoLabel = new Label(this, "", null, null, Style.FONT_DARK);
		}
		
		//{ ------------------------------------ Behaviour Overrides ------------------------------------
		
		override public function onEnter():void 
		{
			this.mouseEnabled = true;
			statsBtn_Click(null);
			onUpdate();
		}
		
		override public function onUpdate():void 
		{
			var stageWidth:int = Engine.buffer.width;
			var stageHeight:int = Engine.buffer.height;
			
			_statsBtn.move(stageWidth * 0.1 - 16, stageHeight - 42);
			_playStopBtn.move(stageWidth * 0.9 - 16, stageHeight - 42);
			_renderedLbl.location.setTo(_statsBtn.left, stageHeight - 190);
			_perfLbl.location.setTo(_renderedLbl.left, _renderedLbl.bottom);
			_cameraLbl.location.setTo(_perfLbl.left, _perfLbl.bottom);
			_pxCollisionLbl.location.setTo(_cameraLbl.left, _cameraLbl.bottom);
			_binInfoLbl.location.setTo(_pxCollisionLbl.left, _pxCollisionLbl.bottom);
			_infoLabel.location.setTo(_binInfoLbl.left, _binInfoLbl.bottom);
			
			if (_perfLbl.visible)
			{
				var qtStats:Array = Engine.space.quadtreeStats;
				
				_renderedLbl.text = "Rendered: " + Engine.space.screenCount.toString() + " / " +  Engine.space.totalEntities;
				_perfLbl.text = "MEM: " + Number(System.totalMemory / 1024 / 1024).toFixed(2) + " MB  |  FPS: " + _fps;
				_cameraLbl.text = "Camera: " + Engine.space.camera.x.toFixed(1) + ", " + Engine.space.camera.y.toFixed(1);;
				_pxCollisionLbl.text = "Px-C.-Checks: " + Engine.space.totalPixelCollisionChecks + " / " + Engine.space._totalCollisionChecks;
				_binInfoLbl.text = "Qt-Bins:  Max: " + qtStats[0] + "  |  Mean: " + qtStats[1] + "  |  Std: " + qtStats[2];
				_infoLabel.text = "Space: " + trimObjectMeta(String(Engine.space)) + "  |  Console: " + trimObjectMeta(String(Engine.console));
			}
			
			var currentTime:Number = getTimer();
			var elapsed:Number = currentTime - _time;
			
			if (elapsed >= 1000)
			{
				_time = currentTime;
				_fps = Math.round(_framesElapsed * 1000 / elapsed);
				_framesElapsed = 1;
			}
			else _framesElapsed ++;
		}
		
		private function statsBtn_Click(b:BaseButton):void 
		{
			if (_perfLbl.visible)
			{
				_statsBtn.unfreeze();
				_perfLbl.hide();
				_renderedLbl.hide();
				_pxCollisionLbl.hide();
				_binInfoLbl.hide();
				_cameraLbl.hide();
				_infoLabel.hide();
			}
			else
			{
				_statsBtn.freeze();
				_perfLbl.show();
				_renderedLbl.show();
				_pxCollisionLbl.show();
				_binInfoLbl.show();
				_cameraLbl.show();
				_infoLabel.show();
			}
		}
		
		private function trimObjectMeta(str:String):String 
		{
			str = str.substring(8);
			return str.substring(0, str.length - 1);
		}
	}

}