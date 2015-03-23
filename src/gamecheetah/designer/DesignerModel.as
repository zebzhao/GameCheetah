/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer 
{
	import gamecheetah.designer.bindlite.BindMax;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import gamecheetah.Engine;
	import gamecheetah.Entity;
	import gamecheetah.Graphic;
	import gamecheetah.graphics.Animation;
	import gamecheetah.graphics.Clip;
	import gamecheetah.graphics.Renderable;
	import gamecheetah.namespaces.hidden;
	import gamecheetah.Space;
	
	use namespace hidden;
	
	/**
	 * @private
	 */
	public class DesignerModel extends BindMax
	{
		public function DesignerModel() 
		{
			this.define("animationsList");
			this.define("graphicsList");
			this.define("spacesList");
			this.define("camera");
			this.define("selectedSpace");
			this.define("selectedGraphic");
			this.define("selectedEntity");
			this.define("selectedAnimation");
			this.define("selectedMaskFrame");
			this.define("activeClip");
			this.define("activeSpace");
			this.define("errorMessage");
		}
		
		
		public function get graphicsList():Array
		{
			var result:Array = [];
			var key:String;
			
			for each (key in Engine.assets.graphics.keys)
				result.push(key);
			
			return result;
		}
		public function set graphicsList(value:Array):void
		{
		}
		
		
		public function get animationsList():Array
		{
			var result:Array = [];
			var key:String;
			
			if (selectedGraphic != null)
			{
				for each (key in selectedGraphic.animations.keys)
					result.push(key);
			}
			
			return result;
		}
		public function set animationsList(value:Array):void 
		{
		}
		
		
		public function get spacesList():Array
		{
			var result:Array = [];
			var key:String;
			
			for each (key in Engine.assets.spaces.keys)
				result.push(key);
			
			return result;
		}
		public function set spacesList(value:Array):void
		{
		}
		
		
		public function get activeSpace():Space 
		{
			return Engine.space;
		}
		public function set activeSpace(value:Space):void 
		{
		}
		
		
		public function get camera():Point
		{
			if (Engine.space) return Engine.space.camera;
			else return null;
		}
		public function set camera(value:Point):void
		{
			Engine.space.camera.setTo(value.x, value.y);
		}
		
		
		public function get selectedGraphic():Graphic 
		{
			return _selectedGraphic;
		}
		public function set selectedGraphic(value:Graphic):void 
		{
			_selectedGraphic = value;
			if (value == null) return;
			this.update("activeClip", _selectedGraphic.newRenderable() as Renderable, true);
		}
		private var _selectedGraphic:Graphic;
		
		
		public var activeClip:Clip;
		public var selectedAnimation:Animation;
		public var selectedMaskFrame:int;
		public var selectedSpace:Space;
		public var selectedEntity:Entity;
		public var errorMessage:String;
	}

}