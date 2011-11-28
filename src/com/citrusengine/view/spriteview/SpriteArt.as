package com.citrusengine.view.spriteview 
{
	import com.citrusengine.view.ISpriteView;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	
	/**
	 * This is the class that all art objects use for the SpriteView state view. If you are using the SpriteView (as opposed to the blitting view, for instance),
	 * then all your graphics will be an instance of this class. This class does the following things:
	 * 
	 * 1) Creates the appropriate graphic depending on your CitrusObject's view property (loader, sprite, or bitmap), and loads it if it is a non-embedded graphic.
	 * 2) Aligns the graphic with the appropriate registration (topLeft or center).
	 * 3) Calls the MovieClip's appropriate frame label based on the CitrusObject's animation property.
	 * 4) Updates the graphic's properties to be in-synch with the CitrusObject's properties once per frame.
	 * 
	 * These objects will be created by the Citrus Engine's SpriteView, so you should never make them yourself. When you use state.getArt() to gain access to your game's graphics
	 * (for adding click events, for instance), you will get an instance of this object. It extends Sprite, so you can do all the expected stuff with it, 
	 * such as add click listeners, change the alpha, etc..
	 **/
	public class SpriteArt extends Sprite
	{
		public var content:DisplayObject;
		
		private var _citrusObject:ISpriteView;
		private var _registration:String;
		private var _view:*;
		private var _animation:String;
		private var _group:int;
		
		public function SpriteArt(object:ISpriteView) 
		{
			_citrusObject = object;
		}
		
		public function get registration():String
		{
			return _registration;
		}
		
		public function set registration(value:String):void 
		{
			if (_registration == value || !content)
				return;
				
			_registration = value;
			
			if (_registration == "topLeft")
			{
				content.x = 0;
				content.y = 0;
			}
			else if (_registration == "center")
			{
				content.x = -content.width / 2;
				content.y = -content.height / 2;
			}
		}
		
		public function get view():*
		{
			return _view;
		}
		
		public function set view(value:*):void
		{
			if (_view == value)
				return;
			
			_view = value;
			
			if (_view)
			{
				if (_view is String)
				{
					// view property is a path to an image?
					var classString:String = _view;
					var suffix:String = classString.substring(classString.length - 4).toLowerCase();
					if (suffix == ".swf" || suffix == ".png" || suffix == ".gif" || suffix == ".jpg")
					{
						var loader:Loader = new Loader();
						addChild(loader);
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleContentLoaded);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleContentIOError);
						loader.load(new URLRequest(classString));
					}
					// view property is a fully qualified class name in string form.
					else
					{
						var artClass:Class = getDefinitionByName(classString) as Class;
						content = new artClass();
						addChild(content);
					}
				}
				else if (_view is Class)
				{
					//view property is a class reference
					content = new citrusObject.view();
					addChild(content);
				}
				else
				{
					throw new Error("SpriteArt doesn't know how to create a graphic object from the provided CitrusObject " + citrusObject);
					return null;
				}
			}
		}
		
		public function get animation():String
		{
			return _animation;
		}
		
		public function set animation(value:String):void
		{
			if (_animation == value)
				return;
			
			_animation = value;
			
			if (content is MovieClip)
			{
				var mc:MovieClip = content as MovieClip;
				if (_animation != null && _animation != "" && hasAnimation(_animation))
					mc.gotoAndStop(_animation);
			}
		}
		
		public function get group():int
		{
			return _group;
		}
		
		public function set group(value:int):void
		{
			_group = value;
		}
		
		public function get citrusObject():ISpriteView
		{
			return _citrusObject;
		}
		
		public function update(stateView:SpriteView):void
		{
			//position = object position + (camera position * inverse parallax)
			x = _citrusObject.x + (-stateView.viewRoot.x * (1 - _citrusObject.parallax)) + _citrusObject.offsetX;
			y = _citrusObject.y + (-stateView.viewRoot.y * (1 - _citrusObject.parallax)) + _citrusObject.offsetY;
			rotation = _citrusObject.rotation;
			visible = _citrusObject.visible;
			scaleX = _citrusObject.inverted ? -1 : 1;
			registration = _citrusObject.registration;
			view = _citrusObject.view;
			animation = _citrusObject.animation;
			group = _citrusObject.group;
		}
		
		public function hasAnimation(animation:String):Boolean
		{
			for each (var anim:FrameLabel in MovieClip(content).currentLabels)
			{
				if (anim.name == animation)
					return true;
			}
			
			return false;
		}
		
		private function handleContentLoaded(e:Event):void
		{
			content = e.target.loader.content;
			
			if (content is Bitmap)
				Bitmap(content).smoothing = true;
		}
		
		private function handleContentIOError(e:IOErrorEvent):void 
		{
			throw new Error(e.text);
		}
	}

}