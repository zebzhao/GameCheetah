/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer.views 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import gamecheetah.designer.bit101.components.*;
	import gamecheetah.designer.views.components.*;
	import gamecheetah.graphics.Animation;
	import gamecheetah.designer.Designer;
	
	/**
	 * @private
	 */
	public class AnimationEditorView extends DialogWindow 
	{
		
		protected var
			tagInput:InputText,
			tagLabel:Label,
			framesInput:TypedInput,
			loopButton:IconPushButton;
			
			
		public function get selectedAnimation():Animation
		{
			return _selectedAnimation;
		}
		public function set selectedAnimation(value:Animation):void 
		{
			_selectedAnimation = value;
			if (value == null)
			{
				this.hide();
				return;
			}
			
			tagInput.text = _selectedAnimation.tag;
			loopButton.selected = _selectedAnimation.looping;
			framesInput.text = _selectedAnimation.frames.toString();
		}
		private var _selectedAnimation:Animation;
			
			
		public function AnimationEditorView(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0) 
		{
			super(parent, xpos, ypos, "Animation Editor");
		}
		
		override public function display():void 
		{
			this.move(0, 0);
			if (_selectedAnimation != null) super.display();
		}
		
		override protected function build():void 
		{
			tagInput = new InputText(this.content, 0, 0, "", tagInput_Change);
			tagLabel = new Label(this.content, 0, 0, "Tag");
			framesInput = new TypedInput(this.content, 0, 0, TypedInput.TYPE_PINT_VECTOR, framesInput_Change);
			loopButton = new IconPushButton(this.content, 0, 0, "Loop", new Assets.Undo, loopButton_Click);
		}
		
		override protected function initialize():void 
		{
			Designer.model.bind("selectedAnimation", this, true);
			
			loopButton.toggle = true;
		}
		
		override protected function onResize(e:Event):void 
		{
			tagInput.setSize(_width, 22);
			tagLabel.move(tagInput.right - tagLabel.width - 5, tagInput.y);
			framesInput.setSize(_width - 60, 22);
			framesInput.move(tagInput.x, tagInput.bottom);
			loopButton.setSize(61, 22);
			loopButton.move(framesInput.right + 1, framesInput.y);
		}
		
		private function framesInput_Change(e:Event):void 
		{
			_selectedAnimation.frames = framesInput.value;
		}
		
		private function tagInput_Change(e:Event):void 
		{
			var success:Boolean = Designer.changeAnimationTag(tagInput.text);
			if (success)
			{
				tagInput.textField.backgroundColor = 0xFFCCCC;
				Designer.model.update("animationsList", null, true);
			}
			else tagInput.textField.backgroundColor = Style.BACKGROUND;
		}
		
		private function loopButton_Click(e:MouseEvent):void 
		{
			_selectedAnimation.looping = loopButton.selected;
		}
	}

}