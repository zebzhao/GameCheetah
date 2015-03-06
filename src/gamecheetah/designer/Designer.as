/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.designer 
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import gamecheetah.*;
	import gamecheetah.designer.views.*;
	import gamecheetah.gameutils.*;
	import gamecheetah.graphics.*;
	import gamecheetah.namespaces.*;
	import gamecheetah.utils.*;
	
	use namespace hidden;
	
	/**
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}
	 * @private
	 */
	public final class Designer extends Sprite
	{
		public static var model:DesignerModel;
		public static var mainView:MainView;
		public static var playView:PlayView;
		
		public static var context:Dictionary;
		public static var instance:Designer;
		
		/**
		 * Stores event identifiers.
		 */
		public static function get events():Events { return Events.instance };
		
		/**
		 * Shared event dispatcher.
		 */
		public static var dispatcher:EventDispatcher = new EventDispatcher();
		
		/**
		 * Provides the means to scroll the current space.
		 */
		public static var scroller:Scroller;
		
		/**
		 * Status if engine is stopped or running.
		 */
		public static var engineIsPlaying:Boolean;
		
		
		public function Designer() 
		{
			super();
			
			instance = this;
			
			addListeners();
			
			// Start the engine paused and in design mode
			Engine.paused = true;
			Engine._designMode = true;
			Input._eventsEnabled = false;
			
			model = new DesignerModel();
			context = new Dictionary();
			// Set up scroller.
			scroller = new Scroller(0.1, 1.5, null, Scroller.ARROW_KEYS);
			
			// Create space for sandbox
			if (Engine.assets.spaces.length == 0)
			{
				var newSpace:Space = Engine.createSpace("Space", Engine.stage.stageWidth, Engine.stage.stageHeight);
				newSpace.invokeCallbacks = false;  // Tricky: Disable callbacks as engine is paused.
				Engine.swapSpace(newSpace);
			}
			
			// Create main view (top-level display)
			mainView = new MainView();
			playView = new PlayView();
			this.addChild(mainView);
			
			model.update("selectedSpace", Engine.space, true);
		}
		
		private function addListeners():void 
		{
			Engine.instance.addEventListener(Engine.events.E_LOAD_CONTEXT, onContextLoadComplete);
			Engine.instance.addEventListener(Engine.events.E_SPACE_CHANGE, onSpaceChange);
		}
		
		/**
		 * Request to create an error message alert box.
		 */
		private static function errorMessage(msg:String):void 
		{
			model.update("errorMessage", msg);
		}
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//{ Event listeners
		
		/**
		 * Event handler to test-play the Engine.
		 */
		public static function play():void 
		{
			if (engineIsPlaying) return;
			engineIsPlaying = true;
			
			// Activate all callbacks such as onUpdate, onActivate, onDeactivate, etc.
			var space:Space;
			var spaces:Array = Engine.assets.spaces.values;
			for each (space in spaces) space.invokeCallbacks = true;
			
			// Remove old UI
			instance.addChild(playView);
			instance.removeChild(mainView);
			
			// Create restore point for all Space objects.
			for each (space in spaces) space._resetInfo = space.export();
			
			// Unpause the engine
			Engine.paused = false;
			Engine._designMode = false;
			
			// Enable key events to be fired
			Input._eventsEnabled = true;
			
			// Disable designer stage listeners
			scroller.disable();
			MainView.spaceCanvas.disabled = true;
			
			// Reset the game state.
			space = Engine.space;
			space.resetCamera();
			Engine.instance.onReset();
			
			space.onSwapIn();
			
			// Call onActivate() for all existing active entities.
			for each (var entity:Entity in space.entities)
			{
				entity.onActivate();
				space.onEntityActivate(entity);
			}
			
			space.onEnter();
			
			// Notify the engine is playing.
			dispatcher.dispatchEvent(new Event(events.E_PLAY_ENGINE));
		}
		
		/**
		 * Event handler to stop test-play of the Engine.
		 */
		public static function stop():void 
		{
			if (!engineIsPlaying) return;  // Tricky: PlayView may dispatch more than 1 Close event.
			engineIsPlaying = false;
			
			// Stop all callbacks such as onUpdate, onActivate, onDeactivate, etc.
			var space:Space;
			var spaces:Array = Engine.assets.spaces.values;
			for each (space in spaces) space.invokeCallbacks = false;
			
			// Remove old UI
			instance.addChild(mainView);
			instance.removeChild(playView);
			
			// Remove game UI
			Engine.swapConsole(null);
			
			/*Engine.space.onSwapOut();
			// Call onDeactivate() for all existing active entities.
			for each (var entity:Entity in Engine.space.entities)
			{
				entity.onDeactivate();
				Engine.space.onEntityDeactivate(entity);
			}
			Engine.space.onExit();*/
			
			// Tricky: Interrupt any delayed events from calling onDeactivate()
			Engine.stopAll();
			
			// Disable keyboard dispatched events
			Input._eventsEnabled = false;
			
			// Pause the engine
			Engine.paused = true;
			Engine._designMode = true;
			
			// Reset all Space objects.
			for each (space in spaces) space.reset();
			
			// Enable designer stage listeners
			scroller.enable();
			MainView.spaceCanvas.disabled = false;
			
			// Swap to the default Space object.
			Engine.swapSpace(Engine.assets.spaces.getAt(0));
			Engine.space.resetCamera();
			
			// Notify the engine has stopped.
			dispatcher.dispatchEvent(new Event(events.E_STOP_ENGINE));
		}
		
		public static function enableScrolling():void 
		{
			scroller.enable();
		}
		
		public static function disableScrolling():void 
		{
			scroller.disable();
		}
		
		/**
		 * Cast the Space to a different class.
		 */
		public static function castSpaceAs(klass:Class):void 
		{
			var newObj:Space = Space.convertClass(model.selectedSpace, klass);
			
			if (model.selectedSpace == Engine.space)
				Engine.swapSpace(newObj);
			
			Engine.assets.spaces.updateValue(model.selectedSpace.tag, newObj);
			model.update("selectedSpace", newObj, true);
		}
		
		/**
		 * Loads Designer settings.
		 */
		public static function loadDesignerContext(context:Dictionary):void 
		{
			if (context == null) throw DesignerError("an invalid value found for context object!");
			Designer.context = context;
		}
		
		/**
		 * Retrieve a particular setting from the designer context.
		 */
		public static function getDesignerContextSetting(name:String):* 
		{
			return Designer.context[name];
		}
		
		/**
		 * Update Designer settings.
		 */
		public static function updateDesignerContext(obj:Object):void 
		{
			for (var key:String in obj) Designer.context[key] = obj[key];
		}
		
		/**
		 * Add a Space object.
		 */
		public static function addSpace():void 
		{
			Engine.createSpace(getUniqueKey("Space", Engine.assets.spaces), Engine.stage.stageWidth, Engine.stage.stageHeight);
			model.update("spacesList", null, true);
		}
		
		/**
		 * Add an entity to the current space.
		 */
		public static function addEntity(x:int, y:int):void 
		{
			if (model.selectedGraphic == null) return;
			Engine.space.createEntity(model.selectedGraphic.tag, new Point(x, y), false);
		}
		
		/**
		 * Create a new Graphic object.
		 */
		public static function addGraphic():void 
		{
			var graphic:Graphic = new Graphic(getUniqueKey("graphic", Engine.assets.graphics));
			Engine.assets.graphics.add(graphic.tag, graphic);
			model.update("graphicsList", null, true);
		}
		
		/**
		 * Add animation data to an existing Graphic.
		 */
		public static function addAnimation():void 
		{
			if (model.selectedGraphic == null || !model.selectedGraphic.hasSpritesheet) return;
			model.selectedGraphic.addAnimation(getUniqueKey("animation", model.selectedGraphic.animations), new <int> [0], 1, true);
			model.update("activeClip", model.selectedGraphic.newRenderable() as Clip, true);
		}
		
		/**
		 * Remove animation data from an existing Graphic.
		 */
		public static function removeAnimation():void 
		{
			if (model.selectedAnimation == null) return;
			model.selectedGraphic.removeAnimation(model.selectedAnimation.tag);
			model.update("selectedAnimation", null, true);
			model.update("activeClip", model.selectedGraphic.newRenderable() as Clip, true);
		}
		
		/**
		 * Remove active entity from the current space.
		 */
		public static function removeEntity():void 
		{
			Engine.space.remove(model.selectedEntity);
			model.update("selectedEntity", null, true);
		}
		
		/**
		 * Remove selected Space object.
		 */
		public static function removeSpace():void 
		{
			if (model.selectedSpace == null) return;
			
			if (!model.selectedSpace.active)
			{
				Engine.removeSpace(model.selectedSpace.tag);
				model.update("selectedSpace", null, true);
				model.update("spacesList", null, true);
			}
			else errorMessage("Selected space is active and cannot be removed.\nClick Edit > Open to change the active space");
		}
		
		/**
		 * Remove selected Graphic object.
		 */
		public static function removeGraphic():void 
		{
			if (model.selectedGraphic == null) return;
			
			Engine.assets.graphics.remove(model.selectedGraphic.tag);
			model.selectedGraphic.removeEntities();
			
			model.update("selectedGraphic", null, true);
			model.update("graphicsList", null, true);
		}
		
		/**
		 * Event handler for changing the active Space object.
		 */
		public static function swapSpace():void 
		{
			// Tricky: If invokeCallbacks is true, then onUpdate(), etc. will execute.
			model.selectedSpace.invokeCallbacks = engineIsPlaying;
			model.update("selectedEntity", null, true);
			Engine.swapSpace(model.selectedSpace);
		}
		
		/**
		 * Change of the current Space "tag" property.
		 */
		public static function changeSpaceTag(tag:String):Boolean 
		{
			tag = tag.toLowerCase();
			
			if (model.selectedSpace == null || Engine.assets.spaces.contains(tag))
				return false;
			
			Engine.assets.spaces.updateKey(model.selectedSpace.tag, tag);
			
			// Update the starting space "tag".
			model.selectedSpace._tag = tag;
			model.update("spacesList", model.spacesList, true);
			model.update("selectedSpace", model.selectedSpace);
			
			return true;
		}
		
		/**
		 * Return true if change is successful.
		 */
		public static function changeGraphicTag(tag:String):Boolean 
		{
			tag = tag.toLowerCase();
			
			if (model.selectedGraphic == null || Engine.assets.graphics.contains(tag))
				return false;

			// Change to new graphic tag.
			Engine.assets.graphics.updateKey(model.selectedGraphic.tag, tag);
			model.selectedGraphic._tag = tag;
			model.update("graphicsList", model.graphicsList, true);
			
			// Change all graphic's entities' tags.
			for each (var entity:Entity in model.selectedGraphic.entities) entity._graphicTag = tag;
			
			return true;
		}
		
		/**
		 * Changes the tag of the selected entity object.
		 */
		public static function changeEntityTag(tag:String):void 
		{
			if (model.selectedEntity != null) model.selectedEntity.tag = tag;
		}
		
		/**
		 * Return true if change is successful.
		 */
		public static function changeAnimationTag(tag:String):Boolean 
		{
			tag = tag.toLowerCase();
			
			if (model.selectedAnimation == null || model.selectedGraphic.animations.contains(tag))
				return false;

			// Change to new tag.
			if (model.selectedGraphic.defaultAnimation == model.selectedAnimation._tag)
				model.selectedGraphic.defaultAnimation = tag;  // Change default animation tag also.
				
			model.selectedGraphic.animations.updateKey(model.selectedAnimation.tag, tag);
			model.selectedAnimation._tag = tag;
			
			return true;
		}
		
		/**
		 * Handles a request to update the image of a Graphic.
		 * Does not need to be called to update animations.
		 */
		public static function updateImage(bmd:BitmapData):void 
		{
			if (model.selectedGraphic == null) return;
			
			// Assign new bitmap data object to Graphic.
			model.selectedGraphic.spritesheet = bmd;
			
			var clip:Clip = model.selectedGraphic.newRenderable() as Clip;
			model.update("activeClip", clip, true);
		}
		
		/**
		 * Update the scroller bounds to reflect any changes in the active space bounds.
		 */
		public static function updateScrollBounds():void 
		{
			// Updates the scroll bounds in case active space size has changed.
			scroller.scrollBounds = Engine.space.bounds.clone();
			scroller.scrollBounds.offset( -Engine.stage.stageWidth / 2, -Engine.stage.stageHeight / 2);
			scroller.setTo(scroller.point.x, scroller.point.y);
			model.update("activeSpace", model.activeSpace, true);
		}
		
		/**
		 * Event handler for image load progress event.
		 */
		private static function onImageLoad(e:Event):void 
		{ 
			var bitmapData:BitmapData = ((e.target as LoaderInfo).content as Bitmap).bitmapData;
			updateImage(bitmapData);
		}
		
		/**
		 * Event handler for context file load event.
		 */
		private static function onContextLoad(e:Event):void 
		{
			Engine.loadContextData((e.target as FileReference).data as ByteArray);
		}
		
		/**
		 * Event handler after Engine finishes loading of context file.
		 */
		private function onContextLoadComplete(e:Event):void 
		{
			// Check for any missing interaction class definitions.
			if (Restorable.__missing.length > 0)
				errorMessage("Not all interactions were successfully loaded!\nThe following classes are missing:\n\n" + Restorable.__missing.join("\n"));
			
			// Update UI.
			Designer.loadDesignerContext(Engine.assets._designerContext);
			Designer.model.propagateAll();
		}
		
		/**
		 * Event handler for when active is changed.
		 */
		private function onSpaceChange(e:Event):void 
		{
			scroller.point = Engine.space.camera;
			updateScrollBounds();
			Designer.model.update("activeSpace", Engine.space);
		}
		
		/**
		 * Event handler for image load progress event.
		 */
		private static function onImageLoadError(e:IOErrorEvent):void 
		{
			errorMessage("Error encountered in loading image.");
		}
		
		/**
		 * Event handler for context file progress event.
		 */
		private static function onContextLoadError(e:IOErrorEvent):void 
		{
			errorMessage("Error encountered in loading file.");
		}
		
		/**
		 * Save context data and media into a single file to be embedded.
		 */
		public static function saveContext():void 
		{
			var dialog:FileReference = new FileReference();
			dialog.save(Engine.saveContextFile(), "resource.amf");
		}
		
		/**
		 * Load context data and media from a single file during runtime.
		 */
		public static function loadContext():void 
		{
			var dialog:FileReference = new FileReference();
			dialog.addEventListener(Event.SELECT, function (e:Event):void { dialog.load(); }, false, 0, true);
			dialog.addEventListener(Event.COMPLETE, onContextLoad);
			dialog.addEventListener(IOErrorEvent.IO_ERROR, onContextLoadError);
			
			try
			{
				dialog.browse([new FileFilter("Action Message Format (*.amf)", "*.amf")]);
			}
			catch (err:Error)
			{
				errorMessage("An error occurred trying to open browse file dialog!");
			}
		}
		
		/**
		 * Load a local mask image.
		 */
		public static function loadMaskImage():void 
		{
			var dialog:FileReference = new FileReference();
			dialog.addEventListener(Event.SELECT, function (e:Event):void { dialog.load(); }, false, 0, true);
			dialog.addEventListener(Event.COMPLETE, onMaskLoadComplete);
			dialog.addEventListener(IOErrorEvent.IO_ERROR, onMaskLoadError);
			
			try
			{
				dialog.browse([new FileFilter("PNG (*.png)", "*.png")]);
			}
			catch (err:Error)
			{
				errorMessage("An error occurred trying to open browse file dialog!");
			}
		}
		
		private static function onMaskLoadComplete(e:Event):void 
		{
			var ba:ByteArray = (e.target as FileReference).data as ByteArray;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onMaskImageChange);
			loader.loadBytes(ba);
		}
		
		private static function onMaskImageChange(e:Event):void
		{
			var bm:Bitmap = e.currentTarget.loader.content as Bitmap;
			bm.bitmapData.colorTransform(bm.bitmapData.rect, generateTintTransform(0xff0000, 1));
			model.selectedGraphic._frameMasks[model.selectedMaskFrame] = bm.bitmapData;
			Designer.model.update("selectedMaskFrame", model.selectedMaskFrame, true);
		}
		
		private static function onMaskLoadError(e:IOErrorEvent):void 
		{
			Designer.model.update("errorMessage", "Error encountered in loading file.");
		}
		
		private static function generateTintTransform(tint:uint, tintAlpha:Number):ColorTransform 
		{
			var ct:ColorTransform = new ColorTransform();
			ct.greenMultiplier =ct.blueMultiplier = ct.redMultiplier = 1 - tintAlpha;
			ct.redOffset = Math.round(tintAlpha * ((tint >> 16) & 255));
			ct.greenOffset = Math.round(tintAlpha * ((tint >> 8) & 255));;
			ct.blueOffset = Math.round(tintAlpha * (tint & 255));
			return ct;
		}
		
		/**
		 * Load a local image file.
		 */
		public static function loadImage():void 
		{
			var imageParser:Loader = new Loader();
			
			// Update spritesheet data (requires updated image hash)
			imageParser.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoad); 
			
			var dialog:FileReference = new FileReference();
			dialog.addEventListener(Event.SELECT, function (evt:Event):void { dialog.load(); }, false, 0, true);
			dialog.addEventListener(Event.COMPLETE, function (evt:Event):void { imageParser.loadBytes(evt.target.data as ByteArray); }, false, 0, true);
			dialog.addEventListener(IOErrorEvent.IO_ERROR, onImageLoadError);
			
			try
			{
				dialog.browse([new FileFilter("Images (*.jpg;*.gif;*.png)", "*.jpg;*.gif;*.png")]);
			}
			catch (err:Error)
			{
				errorMessage("An error occurred trying to open browse file dialog!");
			}
		}
		
		private static function getUniqueKey(base:String, dict:OrderedDict):String 
		{
			var key:String = base;
			var suffix:uint = 1;
			while (dict.contains(key))
			{
				key = base + " " + suffix.toString();
				suffix++;
			}
			return key;
		}
	}
}

/**
 * Static class for event identifiers.
 */
class Events
{
	public static const instance:Events = new Events();
	
	public const E_PLAY_ENGINE:String = "play engine";
	public const E_STOP_ENGINE:String = "stop engin";
}