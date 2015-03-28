/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah 
{
	import flash.display.*;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import gamecheetah.designer.*;
	import gamecheetah.gameutils.Easing;
	import gamecheetah.gameutils.Input;
	import gamecheetah.graphics.Clip;
	import gamecheetah.namespaces.*;
	import gamecheetah.utils.*;
	
	use namespace hidden;
	
	/**
	 * Engine core class, containing top-level methods.
	 * To use this class, extend this class (preferably from Main.as).
	 * @author 		Zeb Zhao {zeb.zhao(at)gamecheetah[dot]net}
	 */
	public class Engine extends Sprite
	{
		//{ ------------------------------------ Static properties ------------------------------------
		
		/**
		 * Internal. Version of the engine.
		 */
		public static const __VERSION:String = "1.2";
		
		/**
		 * Contains all game-related assets and asset information.
		 */
		public static const assets:Assets = new Assets();
		
		/**
		 * Stores event identifiers.
		 */
		public static function get events():Events { return Events.instance };
		
		/**
		 * Main instance of the engine.
		 */
		public static function get main():Engine { return _main };
		private static var _main:Engine;
		
		/**
		 * All instances of engine.
		 */
		private static var _instances:Vector.<Engine> = new Vector.<Engine>();
		
		/**
		 * True if the Engine is currently in "design" mode.
		 */
		public static function get designMode():Boolean { return _designMode; }
		hidden static var _designMode:Boolean;
		
		/**
		 * Clear the buffer with the background color every frame.
		 */
		public static var clearBuffer:Boolean = true;
		
		// Stage information. (Tricky: cannot be 0, will affect tweens!)
		private static var _frameRate:uint = 30;
		
		// List of all entity classes.
		hidden static var __entityClasses:Array = new Array();
		
		// List of all space classes.
		hidden static var __spaceClasses:Array = new Array();
		
		// List of all collidable classes.
		hidden static var __collisionClasses:Array = new Array();
		
		
		/**
		 * Background color of the Entity container.
		 */
		public static var backgroundColor:uint = 0xFFEEEEEE;
		
		/**
		 * Right-click menu.
		 */
		public static var menu:ContextMenu;
		
		/**
		 * True if the current stage size is fixed
		 */
		public static function get stageSizeFixed():Boolean { return _stageSizeFixed; }
		private static var _stageSizeFixed:Boolean;
		
		/**
		 * Flash player stage object.
		 */
		public static function get stage():Stage { return _stage; }
		private static var _stage:Stage;
		
		/**
		 * BitmapData canvas for graphics.
		 */
		public static function get buffer():BitmapData { return _buffer };
		private static var _buffer:BitmapData;
		
		/**
		 * Bitmap for the buffer.
		 */
		public static function get bitmap():Bitmap { return _bitmap };
		private static var _bitmap:Bitmap;
		
		/**
		 * Returns the current active console.
		 */
		public static function get console():Space { return _main._console; }
		
		/**
		 * The current space container for the main Engine.
		 */
		public static function get space():Space { return _main._space; }
		
		/**
		 * Prints these variables in the debug watcher. Converts objects to strings using its toString() method.
		 */
		public static const debugWatcher:Object = new Object;
		
		//}
		//{ ------------------------------------ Public Properties ------------------------------------
		
		/**
		 * True if the Engine is currently paused.
		 * If true, then Engine.onUpdate() is called every frame. Default is false.
		 */
		public var paused:Boolean;
		
		/**
		 * Display object of the buffer bitmap.
		 * BUG: Bitmap mouse events not propagated to top-level sprite object.
		 */
		public static const displayObject:Sprite = new Sprite();
		
		/**
		 * Number of frame elapsed since starting.
		 */
		public static var frameElapsed:uint;
		
		/**
		 * The current space container.
		 */
		public function get space():Space { return _space; }
		
		/**
		 * The current console container.
		 */
		public function get console():Space { return _console; }
		
		//}
		//{ ------------------------------------ Private properties ------------------------------------
		
		private var _console:Space;
		private var _space:Space;
		
		private static var _creditScreen:ExtraCredits = new ExtraCredits();
		private static var _delayCallbackList:Vector.<CallbackData> = new Vector.<CallbackData>();
		private static var _totalCallbacks:uint;
		
		//}
		//{ ------------------------------------ Static Initialize ------------------------------------
		
		{
			registerEntity(Entity, true);
			registerSpace(Space);
		}
		
		//}
		//{ ------------------------------------ Constructor ------------------------------------
		/**
		 * @param	frameRate		Sets the frame rate of the swf.
		 * @param	doNotRegister	Internal.
		 */
		public function Engine(frameRate:uint=30, registerAsMain:Boolean=true):void 
		{
			if (registerAsMain)
			{
				if (_main == null)
				{
					_main = this;
				}
				else throw new GCError("only one instance of Engine may be created as Main");
				
				menu = new ContextMenu();
				_frameRate = frameRate;
				
				// Set up stage properties
				this.addEventListener(Event.ADDED_TO_STAGE, onStageEnter, false, 10);
				this.addEventListener(Event.ADDED_TO_STAGE, onMainEnter, false, 9);
			}
			// Registers the game engine.
			_instances.push(this);
		}
		//}
		//{ ------------------------------------ Static methods ------------------------------------
		
		/**
		 * Call a function at the end of some number of frames ahead.
		 * @param	invoker				The object to apply the tween to.
		 * @param	delay				The number of frames to delay the tween by.
		 * @param	duration			The number of frames to tween for.
		 * @param	from				Contains the tweenable properties of invoker: e.g. {x:50, y:25}
		 * @param	to					Contains the tweenable properties of invoker: e.g. {x:50, y:25}
		 * @param	duration			The number of frames to tween for.
		 * @param	onComplete			The function to call when tween is over.
		 * @param	onCompleteParams	The parameter array for onComplete.
		 * @param	useSeconds			The delay is in seconds instead of number of frames.
		 */
		public static function startTween(
					invoker:Object, delay:Number, duration:Number, from:Object, to:Object, ease:Function=null,
					onComplete:Function=null, onCompleteParams:Array=null, useSeconds:Boolean=false):void 
		{
			// Argument checking
			CONFIG::developer
			{
				if (delay < 0) throw new GCError("invalid delay: cannot be less than 0!");
				if (duration < 0) throw new GCError("invalid duration: cannot be less than 0!");
			}
			
			var propName:String;
			
			if (useSeconds)
			{
				delay *= _frameRate;
				duration *= _frameRate;
			}
			
			if (from != null)
			{
				if (to == null)
				{
					// Tween object to current property values
					to = new Object();
					for (propName in from)
					{
						to[propName] = invoker[propName];
					}
				}
				
				for (propName in to)
				{
					// Check if value is number, int, or uint
					if (CONFIG::developer && !(from[propName] is Number)) throw new GCError("unaccepted value for tween property '" + propName + "': not a number!");
					else invoker[propName] = from[propName];
				}
			}
			else if (to != null)
			{
				// from Object takes on current properties
				from = new Object();
				for (propName in to)
				{
					from[propName] = invoker[propName];
				}
			}
			else
			{
				// Tweening from null to null... doesn't make sense
				CONFIG::developer
				{
					throw new GCError("invalid arguments: tweening from null to null!");
				}
				return;
			}
			
			var change:Object = new Object();
			for (propName in to) change[propName] = to[propName] - from[propName];
			
			var tween:CallbackData = new CallbackData(int(delay), onComplete, onCompleteParams, invoker);
			tween.isTween = true;
			tween.from = from;
			tween.to = to;
			tween.change = change;
			tween.duration = duration;
			tween.ease = ease == null ? Easing.quinticEaseOut : ease;
			
			_delayCallbackList.push(tween);
		}
		
		/**
		 * Stop all the tweens for the invoker.
		 * @param	complete	Force tween to completion upon stopping.
		 */
		public static function cancelTweens(invoker:Object=null, complete:Boolean=true):void 
		{
			var i:uint, data:CallbackData, propName:String;
			while (i < _delayCallbackList.length)
			{
				data = _delayCallbackList[i];
				if (data.isTween && data.invoker == invoker)
				{
					if (complete)
					{
						for (propName in data.to)
							data.invoker[propName] = data.to[propName];
					}
					_delayCallbackList.splice(i, 1);
				}
				else i++;
			}
		}
		
		/**
		 * Call a function at the end of some number of frames ahead.
		 * @param	delay		The number of frames to delay the call by.
		 * @param	callback	The function to call.
		 * @param	params		The parameter array.
		 * @param	invoker		The object to apply the function to.
		 * @param	useSeconds	The delay is in seconds instead of number of frames.
		 */
		public static function startInvoke(delay:Number, callback:Function, params:Array=null, invoker:Object=null, useSeconds:Boolean=false):void 
		{
			CONFIG::developer
			{
				if (delay < 0) throw new GCError("invalid delay: cannot be less than 0!");
			}
			if (useSeconds) delay *= _frameRate;
			_delayCallbackList.push(new CallbackData(int(delay), callback, params, invoker));
		}
		
		/**
		 * Remove all delayed callbacks for a given function and invoker.
		 */
		public static function cancelInvoke(callback:Function, invoker:Object=null):void 
		{
			var i:uint, data:CallbackData;
			while (i < _delayCallbackList.length)
			{
				data = _delayCallbackList[i];
				if (!data.isTween && data.callback == callback && data.invoker == invoker)
					_delayCallbackList.splice(i, 1);
				else i++;
			}
		}
		
		/**
		 * Stop all delayed invokes and tweens.
		 */
		public static function stopAll():void 
		{
			_delayCallbackList.length = 0;
		}
		
		/**
		 * Add a Space to the screen as the console.
		 * @param	src		Space object or "tag" of the space object.
		 * @return 	True if swap is successful. (Not already the active console)
		 */
		public static function swapConsole(src:*):Boolean 
		{
			return _main.swapConsole(src);
		}
		
		/**
		 * Change the current Space at the end of the frame.
		 * @param	src			Space object or "tag" of the space object.
		 * @return 	True if space exists and is not currently active.
		 */
		public static function swapSpace(src:*):Boolean 
		{
			return _main.swapSpace(src);
		}

		/**
		 * Delete the Space object matching the specified tag permanently.
		 */
		public static function removeSpace(tag:String):void 
		{
			assets.spaces.remove(tag);
		}
		
		/**
		 * Retrieve the Space object matching the specified tag.
		 */
		public static function getSpace(tag:String):Space 
		{
			return assets.spaces.get(tag);
		}
		
		/**
		 * Create a clip from a given graphic tag. Optionally can be set to an entity.
		 * @param	graphicTag		The tag identifier of the graphic.
		 * @param	entity			Set the renderable of this entity to the created clip.
		 */
		public static function createClip(graphicTag:String, entity:Entity=null):Clip 
		{
			var graphic:Graphic;
			var result:Clip;
			
			graphicTag = graphicTag.toLowerCase();
			
			if (Engine.assets.graphics.contains(graphicTag))
			{
				graphic = Engine.assets.graphics.get(graphicTag);
				
				if (graphic.hasSpritesheet)
				{
					result = graphic.newRenderable() as Clip;
					if (entity != null) entity.renderable = result;
				}
				else if (CONFIG::developer) throw new GCError("Cannot create clip. Graphic object does not contain a spritesheet!");
			}
			else if (CONFIG::developer) throw new GCError("Cannot create clip. Requested Graphic object missing!");
			
			return result;
		}
		
		/**
		 * Create an entity from a given graphic tag. The created entity will not belong to any space.
		 * @param	graphicTag		The tag identifier of the Graphic.
		 * @return	The created entity.
		 */
		public static function createEntity(graphicTag:String, dest:Point=null):Entity 
		{
			var entity:Entity;
			var graphic:Graphic;
			
			CONFIG::developer
			{
				// Argument checking
				if (graphicTag == null) throw new GCError("Argument error: 'graphicTag' cannot be null!");
			}
			graphicTag = graphicTag.toLowerCase();
			
			if (Engine.assets.graphics.contains(graphicTag))
			{
				graphic = Engine.assets.graphics.get(graphicTag);
				
				if (graphic.hasSpritesheet)
				{
					entity = graphic.newEntity();
					entity.renderable = graphic.newRenderable();
					if (dest != null) entity.location = dest;
				}
				else if (CONFIG::developer) throw new GCError("Cannot create entity. Graphic " + graphicTag + " does not contain a spritesheet!");
			}
			else if (CONFIG::developer) throw new GCError("Cannot create entity. Graphic " + graphicTag + " is missing!");
			
			return entity;
		}
		
		/**
		 * Create a new Space object and return it.
		 * @param	tag					A string which is later used to retrieve or identify the Space object.
		 * @param	width				The width of the space.
		 * @param	height				The height of the space.
		 */
		public static function createSpace(tag:String, width:uint, height:uint):Space 
		{
			var result:Space;
			
			if (!(tag in assets.spaces))
			{
				result = new Space();
				result._tag = tag;
				result.expand(width, height);
				assets.spaces.add(tag, result);
			}
			else if (CONFIG::developer) throw new GCError("Cannot create space. Requested Space tag already exists!");
			
			return result;
		}
		
		/**
		 * Load embedded resources such as media and context file.
		 */
		public static function loadEmbeddedFile(source:Class):void 
		{
			Restorable.__missing = new Vector.<String>();	// Holds missing Interaction definitions.
			loadContextData(new source() as ByteArray);
		}
		
		/**
		 * Entity subclasses must be registered prior to use.
		 * Set collidable to false, if choose not to use built-in collision filtering.
		 * @param	klass			Must be extended from Entity.
		 * @param	collidable		Maximum 32 collidable classes. If false, Entity.collisionGroup will be 0.
		 */
		public static function registerEntity(klass:Class, collidable:Boolean=true):void 
		{
			if (Entity.prototype.isPrototypeOf(klass.prototype) || klass == Entity)
			{
				__entityClasses.push(klass);
				if (collidable)
				{
					var str:String = String(klass);
					if (__collisionClasses.length >= 32) throw new GCError("maximum number of collision classes exceeded! (31 max.)");
					else if (__collisionClasses.indexOf(str) != -1) throw new GCError("naming conflict or collision class already registered!");
					else __collisionClasses.push(str);
				}
			}
			else throw new GCError("class must be a subclass of the Entity class");
		}
		
		/**
		 * Space subclasses must be registered prior to use.
		 * @param	klass			Must be extended from Space.
		 */
		public static function registerSpace(klass:Class):void 
		{
			if (Space.prototype.isPrototypeOf(klass.prototype) ||  klass == Space)
			{
				__spaceClasses.push(klass);
			}
			else throw new GCError("class must be a subclass of the Space class");
		}
		
		/**
		 * Updates tweens and delayed callbacks.
		 * Will not need to call in normal circumstances.
		 */
		public static function updateCallbacks():void 
		{
			var i:uint, data:CallbackData;
			while (i < _delayCallbackList.length)
			{
				data = _delayCallbackList[i];
				if (data.delayCountdown == 0)
				{
					// Start tweening, otherwise invoke callback.
					if (data.isTween)
					{
						// Continue tween
						data.durationCounter++;
						var finished:Boolean = data.durationCounter >= data.duration;
						var propName:String;
						
						if (finished)
						{
							// Tricky: Remove callback before proceeding to call it.
							_delayCallbackList.splice(i, 1);
							if (data.callback != null) data.callback.apply(data.invoker, data.params);
							
							// Update tweened property to finish value
							for (propName in data.to)
								data.invoker[propName] = data.to[propName];
						}
						else
						{
							var position:Number = data.ease.apply(null, [data.durationCounter, data.duration]);
							// Update tweened property
							for (propName in data.to)
								data.invoker[propName] = data.from[propName] + data.change[propName] * position;
								
							i++;  // Tricky: move on to the next tween/callback.
						}
					}
					else
					{
						// Tricky: Remove callback before proceeding to call it.
						_delayCallbackList.splice(i, 1);
						data.callback.apply(data.invoker, data.params);
					}
				}
				else
				{
					data.delayCountdown--;
					i++;
				}
			}
		}
		
		//}
		//{ ------------------------------------ Instance methods ------------------------------------
		
		/**
		 * Set the current stage size to be fixed. If size is null, auto-scaling will be the default behaviour.
		 */
		public function setSize(size:Point):void 
		{
			if (size != null)
			{
				if (isFinite(size.x) && isFinite(size.y))
				{
					_stageSizeFixed = true;
					resizeBuffer(size.x, size.y);
				}
				else throw new GCError("supplied size is not valid: stage size cannot be infinite!");
			}
			else _stageSizeFixed = false;
		}
		
		/**
		 * Change the current Space at the end of the frame.
		 * @param	src			Space object or "tag" of the space object.
		 * @return 	True if space exists and is not currently active.
		 */
		public function swapSpace(src:*):Boolean 
		{
			var space:Space = src as Space;
			if (src is String) space = assets.spaces.get(src as String) as Space;
			if (space == null || space.active) return false;
			
			// Remove previous Space container.
			if (_space != null)
			{
				_space._deactivate();
				_space._finalize();  // Tricky: Complete any entity removals.
				
				// Reset all properties in State object.
				if (_space.state != null)
					_space.state.reset();
			}
			
			_space = space;
			if (_buffer) _space.setScreenSize(_buffer.width, _buffer.height);
			_space._engine = this;
			_space._activate();
			
			// Fires an notification that the active space has been changed.
			this.dispatchEvent(new Event(events.E_SPACE_CHANGE));
			
			// Fires a delayed notification that the space is created.
			this.addEventListener(Event.ENTER_FRAME, onSpaceCreate);
			
			return true;
		}
		
		/**
		 * Add a Space to the screen as the console.
		 * @param	src		Space object or "tag" of the space object.
		 * @return 	True if swap is successful. (Not already the active console)
		 */
		public function swapConsole(src:*):Boolean 
		{
			var console:Space = src as Space;
			if (src is String) console = assets.spaces.get(src as String) as Space;
			if (console == _console) return false;
			
			// Remove previous Space container.
			if (_console != null)
			{
				_console._deactivate();
				_console._finalize();  // Tricky: Complete any entity removals.
				
				// Reset all properties in State object.
				if (_console.state != null)
					_console.state.reset();
			}
			
			_console = console;
			if (_console != null)
			{
				if (_buffer) _console.setScreenSize(buffer.width, buffer.height);
				_console._engine = this;
				_console._activate();
			}
			
			// Fires an notification that the active space has been changed.
			this.dispatchEvent(new Event(events.E_CONSOLE_CHANGE));
			
			return true;
		}
		
		/**
		 * Override this, no super-call needed. Entry point upon start-up. Should load resources, initialize classes, etc...
		 */
		public function onEnter():void 
		{
		}
		
		/**
		 * Override this, no super-call needed. Should reset the game to its initial state.
		 */
		public function onReset():void 
		{
		}
		
		/**
		 * Override this, no super-call needed. Updates every frame.
		 */
		public function onUpdate():void 
		{
		}
		
		/**
		 * Override this to do custom rendering of the active Space object.
		 * @param	renderConsole	If false, console will not be rendered.
		 * @param	drawMasks		If true, renders the collision masks for debugging.
		 * 							Using this option can drastically lower performance.
		 */
		public function render(renderConsole:Boolean=true, drawMasks:Boolean=false):void 
		{
			// Draws required entity objects on screen.
			if (_space != null) _space.render(drawMasks);
			// Draw all added consoles.
			if (renderConsole && _console != null) _console.render(drawMasks);
		}
		
		//}
		//{ ------------------------------------ Private/Hidden methods ------------------------------------
		
		/**
		 * Loads data and resources from binary context file.
		 */
		hidden static function loadContextData(binary:ByteArray):void 
		{
			binary.uncompress();
			
			// Extract State data.
			assets.restore(binary.readObject());
			
			var startingSpace:Space = assets.spaces.getAt(0);
			
			CONFIG::developer
			{
				// Tricky: deactivate callbacks when loading in developer mode
				startingSpace.invokeCallbacks = false;
			}
			// Load the default Space of the context file.
			swapSpace(startingSpace);
			
			// Notify internal classes that context file is loaded.
			_main.dispatchEvent(new Event(events.E_LOAD_CONTEXT));
		}
		
		//}
		//{ ------------------------------------ Conditionally Compiled methods ------------------------------------
		
		/**
		 * Save context data and media into a single file to be embedded.
		 */
		CONFIG::developer
		hidden static function saveContextFile():ByteArray 
		{
			var output:ByteArray = new ByteArray();
			
			// Exports State data.
			//var k:Object = state.export();
			output.writeObject(assets.export());
			
			output.compress();
			return output;
		}
		
		//}
		//{ ------------------------------------ Event handlers ------------------------------------
		
		/**
		 * Event handler for when Main is added to the stage.
		 */
		private function onMainEnter(e:Event):void 
		{
			CONFIG::developer {
				var designer:Designer = new Designer(this.parent);
			}
			this.onEnter();
			this.onReset();
		}
		
		//}
		//{ ------------------------------------ Static Event handlers ------------------------------------
		
		private static function onStageEnter(e:Event):void 
		{
			// Build and set context menu.
			var copyrightMenuItem:ContextMenuItem = new ContextMenuItem("Game Cheetah © 2015", true);
			copyrightMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onCopyrightClick);
			menu.hideBuiltInItems();
			menu.customItems = [copyrightMenuItem];
			_main.contextMenu = menu;
			
			// Set stage properties.
			_stage = _main.stage;
			_stage.frameRate = _frameRate;
			_stage.align = StageAlign.TOP_LEFT;
			_stage.quality = StageQuality.HIGH;
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.displayState = StageDisplayState.NORMAL;
			
			_bitmap = new Bitmap();
			displayObject.addChild(_bitmap);
			displayObject.mouseChildren = false;  // Tricky: Catch children mouse events.
			_stage.addChild(displayObject);
			
			resizeBuffer(_stage.stageWidth, _stage.stageHeight);
			
			_stage.addEventListener(Event.RESIZE, onStageResize);
			_stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrame, false, 1);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			
			// Enables key inputs
			Input.enabled = true;
		}
		
		/**
		 * Event handler for per-frame updates.
		 */
		private static function onStageEnterFrame(e:Event):void 
		{
			// Prevents unnecessary updating during drawing.
			_buffer.lock();
			
			if (clearBuffer) paintBuffer();
			
			frameElapsed++;
			
			var engine:Engine;
			for each (engine in _instances)
			{
				// Update engine after rendering!
				if (engine.space != null) engine.space._update();
				// Update consoles
				if (engine.console != null) engine.console._update();
				// Invoke engine onUpdate() callback
				if (!engine.paused) engine.onUpdate();
				// Render entities
				engine.render();
			}
			
			updateCallbacks();
			
			// Lets display object update.
			_buffer.unlock();
		}
		
		/**
		 * Event handler for mouse movement.
		 */
		private static function onStageMouseDown(e:MouseEvent):void 
		{
			var engine:Engine;
			for each (engine in _instances)
			{
				if (engine._space != null && engine._space.mouseEnabled)
					engine._space._onMouseDown(e.localX, e.localY);
				
				if (engine._console != null) engine._console._onMouseDown(e.localX, e.localY);
			}
		}
		
		/**
		 * Event static handler for mouse movement.
		 */
		private static function onStageMouseUp(e:MouseEvent):void 
		{
			var engine:Engine;
			for each (engine in _instances)
			{
				if (engine._space != null && engine._space.mouseEnabled)
					engine._space._onMouseUp(e.localX, e.localY);
				
				if (engine._console != null) engine._console._onMouseUp(e.localX, e.localY);
			}
		}
		
		/**
		 * Event handler for when stage resizes.
		 */
		private static function onStageResize(e:Event):void 
		{
			if (!stageSizeFixed) resizeBuffer(stage.stageWidth, stage.stageHeight);
		}
		
		/**
		 * Display credits when copyright context menu item is selected.
		 */
		private static function onCopyrightClick(e:Event):void 
		{
			stage.addChild(_creditScreen);
		}
		
		/**
		 * Notifies space has initialized and been fully created.
		 */
		private static function onSpaceCreate(e:Event):void 
		{
			_main.removeEventListener(Event.ENTER_FRAME, onSpaceCreate);
			_main.dispatchEvent(new Event(Events.instance.E_SPACE_CREATE));
		}
		
		/**
		 * Resizes the buffer.
		 */
		private static function resizeBuffer(width:Number, height:Number):void 
		{
			if (_buffer && width == _buffer.width && height == _buffer.height) return;
			
			_buffer = new BitmapData(width, height, true);
			_bitmap.bitmapData = _buffer;
			
			for each (var engine:Engine in _instances)
			{
				if (engine.space != null) engine.space.setScreenSize(width, height);
				if (engine.console != null) engine.console.setScreenSize(width, height);
			}
			paintBuffer();
		}
		
		/**
		 * Clear the buffer with the background color.
		 */
		public static function paintBuffer():void 
		{
			CONFIG::developer
			{
				_buffer.fillRect(_buffer.rect, (backgroundColor - 0xFF111111) + (backgroundColor < 0xFF111111 ? 0xFFFFFFFF : 0));
				
				// Draw boundaries of quadtree volume if in developer mode.
				if (_main.space != null)
				{
					var intersection:Rectangle = _main.space.screenBounds.intersection(_main.space._bounds);
					intersection.offset( -_main.space.screenBounds.x, -_main.space.screenBounds.y);
					_buffer.fillRect(intersection, backgroundColor);
				}
				
				return;
			}
			// Simply paint entire buffer as the background color.
			_buffer.fillRect(_buffer.rect, backgroundColor);
		}
		//}
	}

}

/**
 * Static class for event identifiers.
 */
class Events
{
	public static const instance:Events = new Events();
	
	/**
	 * Dispatched after the current Space is swapped.
	 */
	public const E_CONSOLE_CHANGE:String = "console change";
	
	/**
	 * Dispatched after the current Space is swapped.
	 */
	public const E_SPACE_CHANGE:String = "space change";
	
	/**
	 * Dispatched after the current Space is created (end of frame).
	 */
	public const E_SPACE_CREATE:String = "space change";
	
	/**
	 * Dispatched after a new context file is loaded.
	 */
	public const E_LOAD_CONTEXT:String = "load context";
}