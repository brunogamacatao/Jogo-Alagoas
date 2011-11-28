package com.citrusengine.view
{
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.utils.LoadManager;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * This is an abstract class that is extended by any view managers, such as the SpriteView. It provides default properties
	 * and functionality that all game views need, such as camera controls, parallaxing, and graphics object displaying and management.
	 * 
	 * <p>This is the class by which you will grab a reference to the graphical representations of your Citrus Objects,
	 * which will be useful if you need to add mouse event handlers to them, or add graphics effects and filter.</p>
	 * 
	 * <p>The CitrusView was meant to be extended to support multiple rendering methods, such as blitting, or even 3D. The goal 
	 * is to provide as much decoupling as possible of the data/logic from the view. In the near future, it is our goal to
	 * provide multiple rendering methods such as blitting right out of the box, so that the developer can choose which method
	 * they would like to work with.</p> 
	 */	
	public class CitrusView
	{
		/**
		 * This is the manager object that keeps track of the asynchronous load progress of all graphics objects that are loading.
		 * You will want to use the load manager's bytesLoaded and bytesTotal properties to monitor when your state's graphics are
		 * completely loaded and ready for revealing.
		 * 
		 * <p>Normally, you will want to hide your state from the player's view until the load manager dispatches its onComplete event,
		 * notifying you that all graphics have been loaded. This is the object that you will want to reference in your loading screens.
		 * </p> 
		 */		
		public var loadManager:LoadManager;
		
		//Camera properties
		/**
		 * The thing that the camera will follow. 
		 */		
		public var cameraTarget:Object;
		
		/**
		 * The distance from the top-left corner of the screen that the camera should offset the target. 
		 */		
		public var cameraOffset:MathVector = new MathVector();
		
		/**
		 * A value between 0 and 1 that specifies the speed at which the camera catches up to the target.
		 * 0 makes the camera not follow the target at all and 1 makes the camera follow the target exactly. 
		 */		
		public var cameraEasing:MathVector = new MathVector(0.25, 0.05);
		
		/**
		 * A rectangle specifying the minimum and maximum area that the camera is allowed to follow the target in. 
		 */		
		public var cameraBounds:Rectangle;
		
		/**
		 * The width of the visible game screen. This will usually be the same as your stage width unless your game has a border.
		 */		
		public var cameraLensWidth:Number;
		
		/**
		 * The height of the visible game screen. This will usually be the same as your stage width unless your game has a border.
		 */		
		public var cameraLensHeight:Number;
		
		protected var _viewObjects:Dictionary = new Dictionary();
		protected var _root:Sprite;
		protected var _viewInterface:Class;
		
		/**
		 * There is one CitrusView per state, so when a new state is initialized, it creates the view instance.
		 * You can override which type of CitrusView you would like to create via the State.createView() protected method.
		 * At the time of this writing, only the SpriteView is available, but in the future, blitting is expected to be supported.
		 */		
		public function CitrusView(root:Sprite, viewInterface:Class)
		{
			_root = root;
			_viewInterface = viewInterface;
			
			var ce:CitrusEngine = CitrusEngine.getInstance();
			
			cameraLensWidth = ce.stage.stageWidth;
			cameraLensHeight = ce.stage.stageHeight;
			
			loadManager = new LoadManager();
		}
		
		public function destroy():void
		{
			loadManager.destroy();
		}
		
		/**
		 * This should be implemented by a CitrusView subclass. The update method's job is to iterate through all the CitrusObjects,
		 * and update their graphical counterparts on every frame. See the SpriteView's implementation of the update() method for
		 * specifics. 
		 */		
		public function update():void
		{
			
		}
		
		/**
		 * The active state automatically calls this method whenever a new CitrusObject is added to it. It uses the CitrusObject
		 * to create the appropriate graphical representation. It also tells the LoadManager to begin listening to Loader events
		 * on the graphics object.
		 */		
		public function addArt(citrusObject:Object):void
		{
			if (!(citrusObject is _viewInterface))
				return;
			
			var art:Object = createArt(citrusObject);
			
			if (art)
				_viewObjects[citrusObject] = art;
			
			//Recurses through the art to see if it can find a loader to monitor
			if (loadManager.onLoadComplete.numListeners > 0) //only do this if someone is listening
				loadManager.add(art);
		}
		
		/**
		 * This is called by the active state whenever a CitrusObject is removed from the state, effectively also removing the
		 * art representation. 
		 */		
		public function removeArt(citrusObject:Object):void
		{
			if (!(citrusObject is _viewInterface))
				return;
			
			destroyArt(citrusObject);
			delete _viewObjects[citrusObject];
		}
		
		/**
		 * Gets the graphical representation of a CitrusObject that is being managed by the active state's view.
		 * This is the method that you will want to call to get the art for a CitrusObject.
		 * 
		 * <p>For instance, if you want to perform an action when the user clicks an object, you will want to call
		 * this method to get the MovieClip that is associated with the CitrusObject that you are listening for a click upon.
		 * </p>
		 */		
		public function getArt(citrusObject:Object):Object
		{
			if (!citrusObject is _viewInterface)
			{
				throw new Error("The object " + citrusObject + " does not have a graphical counterpart because it does not implement " + _viewInterface + ".");
				return;
			}
			
			return _viewObjects[citrusObject];
		}
		
		/**
		 * Gets a reference to the CitrusObject associated with the provided art object.
		 * This is useful for instances such as when you need to get the CitrusObject for a graphic that got clicked on or otherwise interacted with.
		 * @param	art The graphical object that represents the CitrusObject you want.
		 * @return The CitrusObject associated with the provided art object.
		 */
		public function getObjectFromArt(art:Object):Object
		{
			for (var object:Object in _viewObjects)
			{
				if (_viewObjects[object] == art)
					return object;
			}
			return null;
		}
		
		/**
		 * This is a non-critical helper function that allows you to quickly set all the available camera properties in one place. 
		 * @param target The thing that the camera should follow.
		 * @param offset The distance from the upper-left corner that you want the camera to be offset from the target.
		 * @param bounds The rectangular bounds that the camera should not extend beyond.
		 * @param easing The x and y percentage of distance that the camera will travel toward the target per tick. Lower numbers are slower. The number should not go beyond 1.
		 */		
		public function setupCamera(target:Object = null, offset:MathVector = null, bounds:Rectangle = null, easing:MathVector = null):void
		{
			if (target)
				cameraTarget = target;
			if (offset)
				cameraOffset = offset;
			if (bounds)
				cameraBounds = bounds;
			if (easing)
				cameraEasing = easing
		}
		
		/**
		 * A CitrusView subclass will extend this method to provide specifics on how to create the graphical representation of a CitrusObject.
		 * @param object The object for which to create the art.
		 * @return The art object.
		 * 
		 */		
		protected function createArt(citrusObject:Object):Object
		{
			return null;
		}
		
		/**
		 * A CitrusView subclass will extend this method to update the graphical representation for each CitrusObject.
		 * @param object A CitrusObject whose graphical counterpart needs to be updated.
		 * @param art The graphics object that will be updated based on the provided CitrusObject.
		 */		
		protected function updateArt(citrusObject:Object, art:Object):void
		{
			
		}
		
		/**
		 * A CitrusView subclass will extend this method to destroy the art associated with the provided CitrusObject. 
		 */		
		protected function destroyArt(citrusObject:Object):void
		{
			
		}
	}
}