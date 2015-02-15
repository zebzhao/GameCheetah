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
			    //
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
			this.addEventListener(Event.ADDED_TO_STAGE, onStageEnter);
		}
		
		/**
		 * Depixelize the current word.
		 */
		private function fadeOut(bmp:Bitmap):void 
		{
			Engine.startTween(bmp, 1.2, 1, null, { "alpha":0, "y":bmp.y - bmp.bitmapData.height + 5 }, null, dispose, [bmp], true);
			fadeIn(_copyrights[++_copyrightIndex]);
		}
		
		private function dispose(bmp:Bitmap):void 
		{
			if (bmp.parent != null) this.removeChild(bmp);
			if (bmp.bitmapData != null) bmp.bitmapData.dispose();
		}
		
		/**
		 * Pixelize animation of word on to screen.
		 */
		private function fadeIn(word:String):void 
		{
			_tf.text = word;
			var bmd:BitmapData = new BitmapData(_tf.width, _tf.height, true, 0);
			bmd.draw(_tf);
			var bmp:Bitmap = new Bitmap(bmd);
			bmp.y = Engine.stage.stageHeight - 20 - bmd.height / 2;
			bmp.x = 75 - bmd.width / 2;
			
			if (_copyrightIndex == _copyrights.length - 1)
			{
				Engine.startTween(bmp, 1.2, 1, { "alpha":0, "y":bmp.y + bmd.height }, null, null, null, null, true);
			}
			else
			{
				Engine.startTween(bmp, (_copyrightIndex == 0 ? 0 : 1.2), 1, { "alpha":0, "y":bmp.y + bmd.height }, null, null, fadeOut, [bmp], true);
			}
			
			this.addChild(bmp);
		}
		
		private function initialize():void 
		{
			this.graphics.beginFill(0xFFFFFF, 1);
			this.graphics.drawRect(0, Engine.stage.stageHeight - 40, 150, 40);
			this.graphics.endFill();
		}
		
		private function exit():void 
		{
			_copyrightIndex = 0;
			this.removeChildren();
			Engine.stage.removeChild(this);
		}
		
		private function onStageEnter(e:Event):void 
		{
			initialize();
			fadeIn(_copyrights[0]);
			Engine.cancelTweens(this);
			Engine.startTween(this, 0, (0.7 - this.alpha) * 3, null, { "alpha":0.7 }, null, null, null, true);
		}
		
		private function onMouseClick(e:Event):void 
		{
			Engine.cancelTweens(this);
			Engine.startTween(this, 0, this.alpha * 3, null, { "alpha":0 }, null, exit, null, true);
		}
		
		private var _copyrightIndex:uint;
		private var _copyrights:Vector.<String> = new < String > [
			"Contributions\nSpecial thanks to:   ",
			"Martin Kallman\ncollision-as3 (c) 2012",
			"Chevy Ray Johnston\nFlashpunk (c) 2015",
			"Keith Peters\nMinimalComps (c) 2011",
			"Oyvind Nordhagen\nBindMax (c) 2011",
			"Zeb Zhao\nGameCheetah 1.0 (c) 2015\nwww.gamecheetah.net"];
	}

}