package com.citrusengine.objects
{
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.view.ISpriteView;
	import com.citrusengine.view.SpriteDebugArt;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	
	/**
	 * You should override this class to create a visible game object such as a Spaceship, Hero, or Backgrounds. This is the equivalent
	 * of the Flash Sprite. It has common properties that are required for properly displaying and
	 * positioning objects. You can also add your logic to this sprite.
	 * 
	 * <p>With a CitrusSprite, there is only simple collision and velocity logic. If you'd like to take advantage of Box2D physics,
	 * you should extend the PhysicsObject class instead.</p>
	 */	
	public class CitrusSprite extends CitrusObject implements ISpriteView
	{
		public var velocity:MathVector = new MathVector();
		public var collisions:Dictionary = new Dictionary();
		
		public var onCollide:Signal = new Signal(CitrusSprite, CitrusSprite, MathVector, Number);
		public var onPersist:Signal = new Signal(CitrusSprite, CitrusSprite, MathVector);
		public var onSeparate:Signal = new Signal(CitrusSprite, CitrusSprite);
		
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _width:Number = 30;
		protected var _height:Number = 30;
		protected var _parallax:Number = 1;
		protected var _rotation:Number = 0;
		protected var _group:Number = 0;
		protected var _visible:Boolean = true;
		protected var _view:* = SpriteDebugArt;
		protected var _inverted:Boolean = false;
		protected var _animation:String = "";
		protected var _offsetX:Number = 0;
		protected var _offsetY:Number = 0;
		protected var _registration:String = "topLeft";
		
		public static function Make(name:String, x:Number, y:Number, view:*, parallax:Number = 1):CitrusSprite
		{
			return new CitrusSprite(name, { x: x, y: y, view: view, parallax: parallax } );
		}
		
		/**
		 * Creates a CitrusSprite instance. 
		 */		
		public function CitrusSprite(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		override public function destroy():void
		{
			onCollide.removeAll();
			onPersist.removeAll();
			onSeparate.removeAll();
			collisions = null;
			super.destroy();
		}
		
		/**
		 * @inherit 
		 */	
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			_x = value;
		}
		
		/**
		 * @inherit 
		 */	
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
		}
		
		public function get width():Number
		{
			return _width;
		}
		
		public function set width(value:Number):void
		{
			_width = value;
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function set height(value:Number):void
		{
			_height = value;
		}
		
		/**
		 * @inherit 
		 */	
		public function get parallax():Number
		{
			return _parallax;
		}
		
		public function set parallax(value:Number):void
		{
			_parallax = value;
		}
		
		/**
		 * @inherit 
		 */	
		public function get rotation():Number
		{
			return _rotation;
		}
		
		public function set rotation(value:Number):void
		{
			_rotation = value;
		}
		
		/**
		 * @inherit 
		 */	
		public function get group():Number
		{
			return _group;
		}
		
		public function set group(value:Number):void
		{
			_group = value;
		}
		
		/**
		 * @inherit 
		 */	
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
		}
		
		/**
		 * @inherit 
		 */	
		public function get view():*
		{
			return _view;
		}
		
		public function set view(value:*):void
		{
			_view = value;
		}
		
		/**
		 * @inherit 
		 */	
		public function get inverted():Boolean
		{
			return _inverted;
		}
		
		public function set inverted(value:Boolean):void
		{
			_inverted = value;
		}
		
		/**
		 * @inherit 
		 */	
		public function get animation():String
		{
			return _animation;
		}
		
		public function set animation(value:String):void
		{
			_animation = value;
		}
		
		/**
		 * @inherit 
		 */	
		public function get offsetX():Number
		{
			return _offsetX;
		}
		
		public function set offsetX(value:Number):void
		{
			_offsetX = value;
		}
		
		public function get offsetY():Number
		{
			return _offsetY;
		}
		
		/**
		 * @inherit 
		 */	
		public function set offsetY(value:Number):void
		{
			_offsetY = value;
		}
		
		/**
		 * @inherit 
		 */	
		public function get registration():String
		{
			return _registration;
		}
		
		public function set registration(value:String):void
		{
			_registration = value;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			x += (velocity.x * timeDelta);
			y += (velocity.y * timeDelta);
		}
	}
}