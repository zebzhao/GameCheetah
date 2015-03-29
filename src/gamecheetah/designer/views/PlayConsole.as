/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import gamecheetah.designer.components.*;
	import gamecheetah.*;
	import gamecheetah.designer.Designer;
	import flash.utils.getTimer;
	import flash.system.System;
	
	public class PlayConsole extends BaseComponent 
	{
		private var
			_main:MainConsole;
			
		private var
			_playStopBtn:IconToggleButton, _statsBtn:IconButton,
			_text:Label,
			_bgRect:Rectangle;
			
		private var
			_framesElapsed:uint,
			_time:Number = 0,
			_fps:int;
			
		public function PlayConsole(parent:DisplayObjectContainer, main:MainConsole) 
		{
			_main = main;
			_bgRect = new Rectangle();
			_playStopBtn = new IconToggleButton(this, Assets.GAME, Assets.EXIT, playStopBtn_Click, "Run!", "Exit", Label.ALIGN_ABOVE);
			_statsBtn = new IconButton(this, Assets.STATS, statsBtn_Click, "Stats", Label.ALIGN_ABOVE);
			_text = new Label(this, "", Style.FONT_BASE, null, TextFormatAlign.LEFT);
			super(parent);
		}
		
		//{ ------------------------------------ Behaviour Overrides ------------------------------------
		
		override public function onActivate():void 
		{
			_statsBtn.unfreeze();
			this.graphics.clear();
			_bgRect.setEmpty();
			_text.hide();
			onUpdate();
		}
		
		override public function onUpdate():void 
		{
			var stageWidth:int = Engine.buffer.width;
			var stageHeight:int = Engine.buffer.height;
			
			_statsBtn.move(stageWidth * 0.1 - 16, stageHeight - 42);
			_playStopBtn.move(stageWidth * 0.9 - 16, stageHeight - 42);
			
			if (_text.visible)
			{
				var qtStats:Array = Engine.space.quadtreeStats;
				
				_text.text = "Space: " + trimObjectMeta(String(Engine.space)) + " \nConsole: " + trimObjectMeta(String(Engine.console));
				_text.text += "\nCamera: " + int(Engine.space.camera.x) + ", " + int(Engine.space.camera.y);
				_text.text += "\nRendered: " + Engine.space.screenCount.toString() + " / " +  Engine.space.totalEntities +
					"\nMEM: " + Number(System.totalMemory / 1024 / 1024).toFixed(2) + " MB\nFPS: " + _fps;
				_text.text += "\nPixel-CD: " + Engine.space.totalPixelCollisionChecks + " / " + Engine.space.totalCollisionChecks +
					"\nQt-Bins: Max=" + int(qtStats[0]) + ",  Mean=" + int(qtStats[1]) + ",  Std=" + int(qtStats[2]);
				_text.move(_statsBtn.left, _statsBtn.top - _text.height - 35);
				
				if (_bgRect.width < _text.width || _bgRect.height < _text.height)
				{
					_bgRect.setTo(0, 0, _text.width + 5, _text.height + 5);
					Style.drawBaseRect(this.graphics, _text.x - 5, _text.y - 5, _text.width + 10, _text.height + 10, 0, 0.5, false);
				}
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
		
		//{ ------------------------------------ Component event handlers ------------------------------------
		
		private function playStopBtn_Click(b:IconToggleButton):void 
		{
			if (b.selected)
			{
				Designer.play();
				_main.removeConsoles();
			}
			else
			{
				Designer.stop();
				this.parent.addChild(_main);
			}
		}
		
		private function statsBtn_Click(b:BaseButton):void 
		{
			if (_statsBtn.frozen)
			{
				_statsBtn.unfreeze();
				this.graphics.clear();
				_bgRect.setEmpty();
				_text.hide();
			}
			else
			{
				_statsBtn.freeze();
				_text.show();
				this.bringToFront();
			}
		}
		
		private function trimObjectMeta(str:String):String 
		{
			str = str.substring(8);
			return str.substring(0, str.length - 1);
		}
	}

}