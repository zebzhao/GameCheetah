/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import gamecheetah.Engine;
	
	/**
	 * Game Cheetah credits page
	 * @private
	 * @author Zeb Zhao
	 */
	public class ExtraCredits extends Sprite
	{
		private var _tf:TextField = new TextField();
		
		[Embed(source="/../lib/slkscr.ttf", embedAsCFF="false", fontName="Default Font", mimeType="application/x-font")]
		private var _SilkScreen:Class;
		
		public function ExtraCredits() 
		{
			_tf.embedFonts = true;
			_tf.selectable = false;
			_tf.mouseEnabled = false;
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.defaultTextFormat = new TextFormat("Default Font", 9, 0x555555);
			
			this.addChild(_tf);
			
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
			this.addEventListener(Event.ADDED_TO_STAGE, onStageEnter);
		}
		
		/**
		 * Pixelize animation of word on to screen.
		 */
		private function fadeIn(word:String):void 
		{
			_tf.text = word;
			_tf.x = -_tf.textWidth / 2 + 70;
			_tf.y = -_tf.textHeight / 2 + Engine.stage.stageHeight - 16;
			
			if (_copyrightIndex == _copyrights.length - 1)
			{
				Engine.cancelTweens(_tf);
				Engine.startTween(_tf, 0, 1.5, { "alpha":0 }, { "alpha":1 }, null, null, null, true);
			}
			else
			{
				_copyrightIndex++;
				Engine.cancelTweens(_tf);
				Engine.startTween(_tf, 0, 1.5, { "alpha":0 }, { "alpha":1 }, null, fadeIn, [_copyrights[_copyrightIndex]], true);
			}
			
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF, 1);
			this.graphics.drawRect(0, Engine.stage.stageHeight - 32, 150, 32);
			this.graphics.endFill();
		}
		
		private function exit():void 
		{
			Engine.stage.removeChild(this);
		}
		
		private function onStageEnter(e:Event):void 
		{
			_copyrightIndex = 0;
			fadeIn(_copyrights[_copyrightIndex]);
			Engine.startTween(this, 0, 0.7, null, { "alpha":0.7 }, null, null, null, true);
		}
		
		private function onMouseClick(e:Event):void 
		{
			Engine.startTween(this, 0, 0.7, null, { "alpha":0 }, null, exit, null, true);
		}
		
		private var _copyrightIndex:uint;
		private var _copyrights:Vector.<String> = new < String > [
			"Contributions\nSpecial thanks to:   ",
			"Martin Kallman\ncollision-as3 (c) 2012",
			"Chevy Ray Johnston\nFlashpunk (c) 2013",
			"Oyvind Nordhagen\nBindMax (c) 2011",
			"Zeb Zhao\nGameCheetah " + Engine.__VERSION + " (c) 2015\nwww.gamecheetah.net"];
	}

}