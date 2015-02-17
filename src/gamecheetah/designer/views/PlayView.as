/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import gamecheetah.designer.bit101.components.Label;
	import gamecheetah.designer.bit101.components.PushButton;
	import gamecheetah.designer.bit101.components.ScrollPane;
	import gamecheetah.designer.bit101.components.Text;
	import gamecheetah.designer.bit101.components.Window;
	import flash.events.Event;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import gamecheetah.designer.Designer;
	import gamecheetah.designer.views.components.InterfaceGroup;
	import gamecheetah.Engine;
	import gamecheetah.gameutils.Input;
	
	/**
	 * UI component visual interface for "play" mode.
	 * @author 		Zeb Zhao
	 * @private
	 */
	CONFIG::developer
	public final class PlayView extends InterfaceGroup
	{
		private var
			statusLabel:Label,
			debugButton:PushButton,
			debugWindow:Window,
			debugScrollPane:ScrollPane,
			debugText:Text;
		
		// Track the # of frames since the last second.
		private var
			_framesElapsed:uint,
			_time:Number = 0,
			_fps:String = "";
		
		// Arbitrary object to display in debug watch window.
		public var debugWatcher:Object;
		
		
		override protected function build():void 
		{
			statusLabel = new Label(this);
			debugWindow = new Window(this, 0, 0, "Debug Watch");
			debugScrollPane = new ScrollPane(debugWindow);
			debugText = new Text(debugScrollPane);
			debugButton = new PushButton(this, 0, 0, "Debug Watch", debugButton_onClick);
		}
		
		override protected function addListeners():void 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onStageEnter);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onStageExit);
			Engine.stage.addEventListener(Event.RESIZE, onStageResize);
			debugWindow.addEventListener(Event.CLOSE, debugWindow_onClose);
		}
		
		override protected function initialize():void 
		{
			debugWatcher = Engine.debugWatcher;
			debugText.editable = false;
			debugText.selectable = true;
			debugWindow.visible = false;
			debugWindow.hasCloseButton = true;
			debugScrollPane.autoHideScrollBar = false;
		}
		
		private function onStageEnter(e:Event):void 
		{
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			onStageResize(null);
		}
		
		private function onStageExit(e:Event):void 
		{
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		override protected function onResize():void 
		{
			debugWindow.setSize(Math.max(_width / 4, 200), _height / 2);
			debugScrollPane.setSize(debugWindow.width, debugWindow.height - debugWindow.titleBar.height);
			debugText.setSize(debugWindow.width - 10, debugWindow.height - debugWindow.titleBar.height - 10);
			debugButton.setSize(80, 20);
			debugButton.move(_width - debugButton.width, _height - 20);
			
			statusLabel.move(10, _height - 20);
			this.graphics.clear();
			this.graphics.beginFill(0xffffff, 0.5);
			this.graphics.drawRect(0, statusLabel.y, Engine.stage.stageWidth, 20);
			this.graphics.endFill();
		}
		
		/**
		 * Resize event propagated from the stage object.
		 */
		private function onStageResize(e:Event):void 
		{
			if (this.stage != null)
				this.setSize(Engine.stage.stageWidth, Engine.stage.stageHeight);
		}
		
		/**
		 * Called every frame.
		 */
		private function onEnterFrame(e:Event):void 
		{
			var currentTime:Number = getTimer();
			var elapsed:Number = currentTime - _time;
			if (elapsed >= 1000)
			{
				_time = currentTime;
				_fps = String(Math.round(_framesElapsed * 1000 / elapsed));
				_framesElapsed = 1;
			}
			else _framesElapsed ++;
			
			// Update status label
			var memUsage:String = Number(System.totalMemory / 1024 / 1024).toFixed(2) + " MB";
			statusLabel.text = "FPS: " + _fps + "    MEM: " + memUsage + "    EoS: " + Engine.space.screenCount.toString() + " / " +  Engine.space.totalEntities +
				"    PxCC: " + Engine.space.totalPixelCollisionChecks.toString() + "    Press 'Esc' to exit Play mode.";
			
			// Update debug watcher
			if (debugWindow.visible) debugText.text = PlayView.toString(debugWatcher);
			
			// Input poller for ESC press
			if (Input.checkKeySequence([Keyboard.ESCAPE], 1, true))
			{
				this.dispatchEvent(new Event(Event.CLOSE));
				Designer.stop();
			}
		}
		
		private static function toString(object:Object):String 
		{
			var output:String = "";
			var name:String;
			for (name in object)
			{
				if (object[name] is String)
				{
					output += name + " :\n" + object[name];
				}
				else
				{
					output += name + " :\n" + object[name].toString();
				}
				output += "\n";
			}
			return output;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Input event listeners
		
		private function debugWindow_onClose(e:Event):void 
		{
			debugWindow.visible = false;
		}
		
		private function debugButton_onClick(e:Event):void 
		{
			debugWindow.visible = true;
		}
		
		//} Input event listeners
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	}

}