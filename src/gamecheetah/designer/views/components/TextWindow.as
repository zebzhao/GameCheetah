/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views.components 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import gamecheetah.designer.bit101.components.*;
	
	/**
	 * @private
	 */
	public class TextWindow extends DialogWindow
	{
		private var
			textField:Text,
			scrollPane:ScrollPane,
			updateButton:PushButton;
		
		private var _target:Object;
		private var _key:String;
		
		public function TextWindow(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, title:String = "Window")
		{
			super(parent, xpos, ypos, title);
		}
		
		/**
		 * Binds a target to a bindable property. The target object must contain a public var or a setter by the same name as the bindable property.
		 * @param key The predefined bindable property name
		 * @param target The target object to push changes to the property value to
		 */
		public function bind(key:String, target:Object):void 
		{
			_target = target;
			_key = key;
		}
		
		override protected function build():void 
		{
			updateButton = new PushButton(this.content, 0, 0, "Update", updateButton_Click);
			scrollPane = new ScrollPane(this.content);
			textField = new Text(scrollPane.content);
		}
		
		override protected function initialize():void 
		{
			scrollPane.autoHideScrollBar = true;
			textField.editable = false;
			textField.textField.wordWrap = false;	
		}
		
		override protected function onResize(e:Event):void 
		{
			scrollPane.setSize(_width, _height - 20 - 20 + 1);
			textField.setSize(scrollPane.width, scrollPane.height);
			updateButton.setSize(_width, 20);
			updateButton.move(0, textField.y + textField.height);
		}
		
		/**
		 * Handler for text update event.
		 */
		private function updateButton_Click(e:Event):void 
		{
			textField.text = _target[_key];
			textField.height = Math.max(_height - 20 - 20 + 1, textField.textField.textHeight + 15);
			textField.width = Math.max(_width, textField.textField.textWidth + 15);
			scrollPane.update();
		}
	}

}