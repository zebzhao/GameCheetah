/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer 
{
	import flash.geom.Point;
	import gamecheetah.designer.bindlite.BindMax;
	import gamecheetah.Engine;
	import gamecheetah.Entity;
	import gamecheetah.Graphic;
	import gamecheetah.graphics.Animation;
	import gamecheetah.graphics.Clip;
	import gamecheetah.Space;
	
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
		}
		private var _selectedGraphic:Graphic;
		
		
		public function get selectedSpace():Space 
		{
			return _selectedSpace;
		}
		public function set selectedSpace(value:Space):void 
		{
			_selectedSpace = value;
		}
		private var _selectedSpace:Space;
		
		
		public function get activeClip():Clip 
		{
			return _selectedGraphic ? _selectedGraphic.master.clip : null;
		}
		public function set activeClip(value:Clip):void 
		{
		}
		
		
		public var selectedAnimation:Animation;
		public var selectedEntity:Entity;
		public var errorMessage:String;
	}

}