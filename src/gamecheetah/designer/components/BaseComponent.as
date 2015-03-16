package gamecheetah.designer.components 
{
	import gamecheetah.Entity;

	public class BaseComponent extends Entity
	{
		protected var
			_children:Vector.<BaseComponent> = new Vector.<BaseComponent>();
		
		private var
			_visible:Boolean = true,
			_visibleAlpha:Number=1;
			
		public var
			depthOffset:int;
		
		
		internal function registerChildren(...children:Array):void 
		{
			for each (var child:BaseComponent in children)
			{
				if (child == null)
					throw new Error("Child detected to be null!");
				else if (child == this)
					throw new Error("Parent child self-reference detected!");
					
				_children.push(child);
			}
		}
			
		//{ ------------------- Public Properties -------------------
		
		/**
		 * Recursively update children depth.
		 */
		public function setDepth(value:int):void 
		{
			this.depth = value;
			
			for each (var child:BaseComponent in _children)
			{
				child.setDepth(this.depth + child.depthOffset);
			}
		}
		
		public function get visible():Boolean 
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void 
		{
			if(_visible) _visibleAlpha = this.renderable.alpha
			_visible = value;
			this.renderable.alpha = _visible ? _visibleAlpha : 0;
			
			for each (var child:BaseComponent in _children)
			{
				child.visible = _visible;
			}
			this.stopTween();
		}
		
		public function hide(...rest:Array):void 
		{
			this.visible = false;
		}
		
		public function show(...rest:Array):void 
		{
			this.visible = true;
		}
		
		public function move(x:int, y:int):void 
		{
			this.origin.x = x;
			this.origin.y = y;
			
			for each (var child:BaseComponent in _children)
			{
				child.move(x + this.location.x, y + this.location.y);
			}
		}
		
		public function get left():int
		{
			return this.absoluteLocation.x;
		}
		
		public function get right():int
		{
			return this.renderable.width + this.absoluteLocation.x;
		}
		
		public function get top():int
		{
			return this.absoluteLocation.y;
		}
		
		public function get bottom():int
		{
			return this.renderable.height + this.absoluteLocation.y;
		}
		
		//{ ------------------- Behaviour Overrides -------------------
		
		override public function onActivate():void 
		{
			this.mouseEnabled = true;
			this.renderable.smoothing = true;
		}
	}

}