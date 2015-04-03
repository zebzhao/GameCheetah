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
	import gamecheetah.designer.components.BaseButton;
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
	public final class Designer extends BaseButton
	{
		public static var main:MainConsole;
		public static var model:DesignerModel;
		public static var context:Dictionary;
		
		/**
		 * Temporary storage for deleted spaces in case they need to be recovered.
		 */
		public static var deletedSpaces:Vector.<Space> = new Vector.<Space>();
		
		/**
		 * Temporary storage for deleted graphics in case they need to be recovered.
		 */
		public static var deletedGraphics:Vector.<Graphic> = new Vector.<Graphic>();
		
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
		
		
		public function Designer(parent:DisplayObjectContainer) 
		{	
			trace("Compiling in developer mode.")
			
			// Start the engine paused and in design mode
			Engine.main.paused = true;
			Engine._designMode = true;
			Input._eventsEnabled = false;
			
			// Create an empty space if none currently exists.
			if (Engine.assets.spaces.length == 0)
			{
				var newSpace:Space = Engine.createSpace("Space", Engine.stage.stageWidth, Engine.stage.stageHeight);
				newSpace.invokeCallbacks = false;  // Tricky: Disable callbacks as engine is paused.
				Engine.swapSpace(newSpace);
			}
			
			model = new DesignerModel();
			context = new Dictionary();
			scroller = new Scroller(0.1, 1.5, Engine.space.camera, Scroller.ARROW_KEYS);
			main = new MainConsole(this);
			
			super(parent);
			
			addListeners();
		}
		
		private function addListeners():void 
		{
			Engine.main.addEventListener(Engine.events.E_LOAD_CONTEXT, onContextLoadComplete);
			Engine.main.addEventListener(Engine.events.E_SPACE_CHANGE, onSpaceChange);
		}
		
		/**
		 * Request to create an error message alert box.
		 */
		private static function errorMessage(msg:String):void 
		{
			model.update("errorMessage", msg);
		}
		
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
			
			// Create restore point for all Space objects.
			for each (space in spaces) space._resetInfo = space.export();
			
			// Unpause the engine
			Engine.main.paused = false;
			Engine._designMode = false;
			
			// Enable key events to be fired
			Input._eventsEnabled = true;
			
			// Disable designer stage listeners
			scroller.disable();
			
			// Reset the game state.
			space = Engine.space;
			space.resetCamera();
			Engine.main.onReset();
			
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
			Engine.main.paused = true;
			Engine._designMode = true;
			
			// Reset all Space objects.
			for each (space in spaces) space.reset();
			
			// Enable designer stage listeners
			scroller.enable();
			
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
			if (!klass || !model.selectedSpace) return;
			
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
		public static function addEntity(cx:int, cy:int):void 
		{
			if (model.selectedGraphic == null) return;
			var entity:Entity = Engine.space.createEntity(model.selectedGraphic.tag, null, false);
			entity.setCenter(cx, cy);
		}
		
		/**
		 * Make a specific graphic the active graphic.
		 */
		public static function selectGraphic(index:int):void 
		{
			var graphic:Graphic = index != -1 ? Engine.assets.graphics.getAt(index) : model.selectedGraphic;
			model.update("selectedGraphic", graphic, true);
			model.update("animationsList", null, true);
			model.update("activeClip", null, true);
			model.update("selectedAnimation", graphic.animations.length > 0 ? graphic.animations.getAt(0) as Animation : null, true);
		}
		
		/**
		 * Create a new Graphic object.
		 */
		public static function addGraphic():void 
		{
			var graphic:Graphic = new Graphic(getUniqueKey("Graphic", Engine.assets.graphics));
			Engine.assets.graphics.add(graphic.tag, graphic);
			model.update("graphicsList", null, true);
		}
		
		/**
		 * Add animation data to an existing Graphic.
		 */
		public static function addAnimation():void 
		{
			if (model.selectedGraphic == null || !model.selectedGraphic.hasSpritesheet) return;
			model.selectedGraphic.addAnimation(getUniqueKey("Animation", model.selectedGraphic.animations), new <int> [0], 1, true);
			model.update("activeClip", model.selectedGraphic.newRenderable() as Clip, true);
			model.update("animationsList", null, true);
		}
		
		/**
		 * Remove animation data from an existing Graphic.
		 */
		public static function removeAnimation(index:int):void 
		{
			if (index == -1) return;
			
			var animation:Animation = model.selectedGraphic.animations.getAt(index);
			model.selectedGraphic.animations.removeAt(index);
			
			if (animation == model.selectedAnimation)
				model.update("selectedAnimation", null, true);
				
			model.update("activeClip", model.selectedGraphic.newRenderable() as Clip, true);
			model.update("animationsList", null, true);
		}
		
		/**
		 * Remove active entity from the current space.
		 */
		public static function removeEntity():void 
		{
			// Sanity checks.
			if (!model.selectedEntity) return;
			
			Engine.space.remove(model.selectedEntity);
			model.update("selectedEntity", null, true);
		}
		
		/**
		 * Remove selected Space object.
		 */
		public static function removeSpace(index:int):void 
		{
			if (index == -1) return;
			
			var space:Space = Engine.assets.spaces.getAt(index);
			if (model.activeSpace != space)
			{
				Engine.removeSpace(space.tag);
				
				deletedSpaces.push(space);
				
				if (space == model.selectedSpace)
				{
					model.update("selectedSpace", null, true);
				}
				model.update("spacesList", null, true);
			}
			else errorMessage("Selected space is active and cannot be removed.\nClick Edit > Open to change the active space");
		}
		
		/**
		 * Remove selected Graphic object.
		 */
		public static function removeGraphic(index:int):void 
		{
			if (index == -1) return;
			
			var graphic:Graphic = Engine.assets.graphics.getAt(index);
			
			Engine.assets.graphics.removeAt(index);
			graphic.removeEntities();
			
			// Store deleted graphics for restoring.
			deletedGraphics.push(graphic);
			
			if (model.selectedGraphic == graphic)
			{
				model.update("selectedGraphic", null, true);
			}
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
		public static function changeSpaceTag(index:int, tag:String):Boolean 
		{
			if (Engine.assets.spaces.contains(tag))
				return false;
				
			Engine.assets.spaces.updateKeyAt(index, tag);
			model.update("spacesList", model.spacesList, true);
			
			// Update the starting space "tag".
			var space:Space = Engine.assets.spaces.getAt(index);
			space._tag = tag;
			
			if (space == model.selectedSpace)
				model.update("selectedSpace", model.selectedSpace);
				
			return true;
		}
		
		/**
		 * Return true if change is successful.
		 */
		public static function changeGraphicTag(index:int, tag:String):Boolean 
		{
			if (Engine.assets.graphics.contains(tag))
				return false;
				
			// Change to new graphic tag.
			Engine.assets.graphics.updateKeyAt(index, tag);
			model.update("graphicsList", model.graphicsList, true);
			
			// Change all graphic's entities' tags.
			var graphic:Graphic = Engine.assets.graphics.getAt(index);
			graphic._tag = tag;
			for each (var entity:Entity in graphic.entities) entity._graphicTag = tag;
			
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
		public static function changeAnimationTag(index:int, tag:String):Boolean 
		{
			if (model.selectedGraphic.animations.contains(tag))
				return false;
			
			var animation:Animation = model.selectedGraphic.animations.getAt(index);
			model.selectedGraphic.animations.updateKeyAt(index, tag);
			animation._tag = tag;
			
			Designer.model.update("animationsList", null, true);
			
			return true;
		}
		
		/**
		 * Gets the unscaled collision mask for the current frame of the selected Graphic.
		 */
		public static function getUnscaledCollisionMask():*
		{
			var selectedGraphic:Graphic = model.selectedGraphic;
			var frameMask:* = selectedGraphic._frameMasks[selectedGraphic.alwaysUseDefaultMask ? 0 : model.activeClip.frame];
			return frameMask;
		}
		
		/**
		 * Gets the collision mask for the current frame of the selected Graphic.
		 */
		public static function getCollisionMask():*
		{
			var selectedGraphic:Graphic = model.selectedGraphic;
			return selectedGraphic.master._getMask();
		}
		
		/**
		 * Sets the collision mask for the current frame of the selected Graphic.
		 */
		public static function setCollisionMask(value:*):void 
		{
			// Sanity checks.
			if (!model.activeClip) return;
			
			var selectedGraphic:Graphic = model.selectedGraphic;
			var selectedFrame:int = selectedGraphic.alwaysUseDefaultMask ? 0 : model.activeClip.frame;
			
			// Some sanity checks!
			if (selectedGraphic.frameCount <= selectedFrame || selectedFrame < 0)
				throw new DesignerError("index error: trying to set a mask frame out of bounds!");
				
			selectedGraphic._frameMasks[selectedFrame] = value;
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
			selectGraphic( -1);
		}
		
		/**
		 * Update the scroller bounds to reflect any changes in the active space bounds.
		 */
		public static function updateScrollBounds():void 
		{
			// Updates the scroll bounds in case active space size has changed.
			scroller.scrollBounds = Engine.space.bounds.clone();
			scroller.scrollBounds.offset( -Engine.buffer.width / 2, -Engine.buffer.height / 2);
			scroller.setTo(scroller.point.x, scroller.point.y);
			model.update("activeSpace", model.activeSpace, true);
		}
		
		/**
		 * Sets the frame sequence for the current animation.
		 */
		public static function updateAnimationFrames(value:Vector.<int>):void 
		{
			// Some sanity checks
			if (!model.selectedAnimation) return;
			model.selectedAnimation.frames = value;
			model.update("selectedAnimation", model.selectedAnimation, true);
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
			setCollisionMask(bm.bitmapData);
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
	public const E_STOP_ENGINE:String = "stop engine";
}