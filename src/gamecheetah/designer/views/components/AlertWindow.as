/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views.components 
{
	import gamecheetah.designer.bit101.components.*;
	import flash.display.*;
	import flash.events.*;
	
	/**
	 * Pop-up window to warn of errors or prompt for continuation.
	 * @private
	 */
	public class AlertWindow extends DialogWindow
	{
		public static const EVENT_OKAY:String = "okay";
		public static const EVENT_YES:String = "yes";
		public static const EVENT_NO:String = "no";
		
		private var
			messageLabel:Label,
			okayButton:PushButton,
			yesButton:PushButton,
			noButton:PushButton;
			
			
		public function get text():String 
		{
			return messageLabel.text;
		}
		
		public function AlertWindow(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, title:String = "Window")
		{
			super(parent, xpos, ypos, title);
		}
		
		override protected function build():void 
		{
			messageLabel = new Label(this.content, 0, 0, "");
			okayButton = new PushButton(this.content, 0, 0, "Okay", okayButton_Click);
			yesButton = new PushButton(this.content, 0, 0, "Yes", yesButton_Click);
			noButton = new PushButton(this.content, 0, 0, "No", noButton_Click);
		}
		
		override protected function initialize():void 
		{
			messageLabel.textField.multiline = true;
			//messageLabel.textField.autoSize = TextFieldAutoSize.LEFT;
		}
		
		override protected function onResize(e:Event):void 
		{
			messageLabel.move(15, 15);
			yesButton.setSize(_width / 2 - 25, 20);
			yesButton.move(_width - yesButton.width - 15, _height - yesButton.height - 15 - this.titleBar.height);
			noButton.setSize(_width / 2 - 25, 20);
			noButton.move(15, _height - noButton.height - 15 - this.titleBar.height);
			okayButton.setSize(100, 20);
			okayButton.move(_width / 2 - okayButton.width / 2, _height - okayButton.height - 15 - this.titleBar.height);
		}
		
		private function sizeToText():void 
		{
			this.setSize(messageLabel.textField.textWidth + 30, messageLabel.textField.textHeight + 90);
			center();
		}
		
		/**
		 * Display a warning box. Alert window will resize to text.
		 */
		public function displayWarning(text:String, title:String=""):void 
		{
			messageLabel.text = messageLabel.textField.text = text;
			this.title = title;
			
			okayButton.visible = true;
			yesButton.visible = noButton.visible = false;
			
			sizeToText();
			display();
		}
		
		/**
		 * Display a Yes/No prompt. Alert window will resize to text.
		 */
		public function displayPrompt(text:String, title:String=""):void 
		{
			messageLabel.text = messageLabel.textField.text = text;
			this.title = title;
			
			okayButton.visible = false;
			yesButton.visible = noButton.visible = true;
			
			sizeToText();
			display();
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ UI input event listeners
		
		private function okayButton_Click(e:Event):void 
		{
			hide();
			this.dispatchEvent(new Event(AlertWindow.EVENT_OKAY));
		}
		
		private function yesButton_Click(e:Event):void 
		{
			hide();
			this.dispatchEvent(new Event(AlertWindow.EVENT_YES));
		}
		
		private function noButton_Click(e:Event):void 
		{
			hide();
			this.dispatchEvent(new Event(AlertWindow.EVENT_NO));
		}
		
		//} UI input event listeners
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	}

}