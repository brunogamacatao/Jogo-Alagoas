package com.citrusengine.objects
{
	import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Collision.Shapes.b2Shape;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.Joints.b2Joint;
	import Box2DAS.Dynamics.Joints.b2JointDef;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2BodyDef;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2FixtureDef;
	import com.citrusengine.physics.CollisionCategories;
	
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.view.ISpriteView;
	
	import flash.display.MovieClip;
	
	/**
	 * You should extend this class to take advantage of Box2D. This class provides template methods for defining
	 * and creating Box2D bodies, fixtures, shapes, and joints. If you are not familiar with Box2D, you should first
	 * learn about it via the "Box2D Manual" (Google it).
	 */	
	public class PhysicsObject extends CitrusObject implements ISpriteView
	{
		/**
		 * The speed at which this object will be affected by gravity. 
		 */		
		public var gravity:Number = 1.6;
		
		protected var _ce:CitrusEngine;
		protected var _box2D:Box2D;
		protected var _bodyDef:b2BodyDef;
		protected var _body:b2Body;
		protected var _shape:b2Shape;
		protected var _fixtureDef:b2FixtureDef;
		protected var _fixture:b2Fixture;
		
		protected var _inverted:Boolean = false;
		protected var _parallax:Number = 1;
		protected var _animation:String = "";
		protected var _visible:Boolean = true;
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _view:* = MovieClip;
		protected var _rotation:Number = 0;
		protected var _width:Number = 1;
		protected var _height:Number = 1;
		
		private var _group:Number = 0;
		private var _offsetX:Number = 0;
		private var _offsetY:Number = 0;
		private var _registration:String = "center";
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, view:*):PhysicsObject
		{
			if (!view)
				view = MovieClip;
			return new PhysicsObject(name, { x: x, y: y, width: width, height: height, view: view } );
		}
		
		/**
		 * Creates an instance of a PhysicsObject. Natively, this object does not default to any graphical representation,
		 * so you will need to set the "view" property in the params parameter.
		 * 
		 * <p>You'll notice that the PhysicsObject constructor calls a bunch of functions that start with "define" and "create".
		 * This is how the Box2D objects are created. You should override these methods in your own PhysicsObject implementation
		 * if you need additional Box2D functionality. Please see provided examples of classes that have overridden
		 * the PhysicsObject.</p>
		 */		
		public function PhysicsObject(name:String, params:Object=null)
		{
			_ce = CitrusEngine.getInstance();
			_box2D = _ce.state.getFirstObjectByType(Box2D) as Box2D;
			
			super(name, params);
			
			if (!_box2D)
			{
				throw new Error("Cannot create PhysicsObject when a Box2D object has not been added to the state.");
				return;
			}
			
			//Override these to customize your Box2D initialization. Things must be done in this order.
			defineBody();
			createBody();
			createShape();
			defineFixture();
			createFixture();
			defineJoint();
			createJoint();
		}
		
		/**
		 * @inherit 
		 */	
		override public function destroy():void
		{
			_body.destroy();
			_fixtureDef.destroy();
			_shape.destroy();
			_bodyDef.destroy();
			
			super.destroy();
		}
		
		/**
		 * You should override this method to extend the functionality of your physics object. This is where you will 
		 * want to do any velocity/force logic. By default, this method also updates the gravitatonal effect on the object.
		 * I have chosen to implement gravity in each individual object instead of globally via Box2D so that it is easy
		 * to create objects that defy gravity (like birds or bullets). This is difficult to do naturally in Box2D. Instead,
		 * you can simply set your PhysicsObject's gravity property to 0, and baddabing: no gravity. 
		 */		
		override public function update(timeDelta:Number):void
		{
			if (_bodyDef.type == b2Body.b2_dynamicBody)
			{
				var velocity:V2 = _body.GetLinearVelocity();
				velocity.y += gravity;
				_body.SetLinearVelocity(velocity);
			}
		}
		
		
		/**
		 * @inherit 
		 */	
		public function get x():Number
		{
			if (_body)
				return _body.GetPosition().x * _box2D.scale;
			else
				return _x * _box2D.scale;
		}
		
		public function set x(value:Number):void
		{
			_x = value / _box2D.scale;
			
			if (_body)
			{
				var pos:V2 = _body.GetPosition();
				pos.x = _x;
				_body.SetTransform(pos, _body.GetAngle());
			}
		}
		
		
		/**
		 * @inherit 
		 */		
		public function get y():Number
		{
			if (_body)
				return _body.GetPosition().y * _box2D.scale;
			else
				return _y * _box2D.scale;
		}
		
		public function set y(value:Number):void
		{
			_y = value / _box2D.scale;
			
			if (_body)
			{
				var pos:V2 = _body.GetPosition();
				pos.y = _y;
				_body.SetTransform(pos, _body.GetAngle());
			}
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
			if (_body)
				return _body.GetAngle() * 180 / Math.PI;
			else
				return _rotation * 180 / Math.PI;
		}
		
		public function set rotation(value:Number):void
		{
			_rotation = value * Math.PI / 180;
			
			if (_body)
				_body.SetTransform(_body.GetPosition(), _rotation); 
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
		public function get animation():String
		{
			return _animation;
		}
		
		/**
		 * @inherit 
		 */	
		public function get inverted():Boolean
		{
			return _inverted;
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
		
		/**
		 * @inherit 
		 */	
		public function get offsetY():Number
		{
			return _offsetY;
		}
		
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
		
		/**
		 * This can only be set in the constructor parameters. 
		 */		
		public function get width():Number
		{
			return _width * _box2D.scale;
		}
		
		public function set width(value:Number):void
		{
			_width = value / _box2D.scale;
			
			if (_initialized)
			{
				trace("Warning: You cannot set " + this + " width after it has been created. Please set it in the constructor.");
			}
		}
		
		/**
		 * This can only be set in the constructor parameters. 
		 */	
		public function get height():Number
		{
			return _height * _box2D.scale;
		}
		
		public function set height(value:Number):void
		{
			_height = value / _box2D.scale;
			
			if (_initialized)
			{
				trace("Warning: You cannot set " + this + " height after it has been created. Please set it in the constructor.");
			}
		}
		
		/**
		 * A direction reference to the Box2D body associated with this object.
		 */
		public function get body():b2Body
		{
			return _body;
		}
		
		/**
		 * This method will often need to be overriden to provide additional definition to the Box2D body object. 
		 */		
		protected function defineBody():void
		{
			_bodyDef = new b2BodyDef();
			_bodyDef.type = b2Body.b2_dynamicBody;
			_bodyDef.position.v2 = new V2(_x, _y);
			_bodyDef.angle = _rotation;
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D body object. 
		 */	
		protected function createBody():void
		{
			_body = _box2D.world.CreateBody(_bodyDef);
			_body.SetUserData(this);
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D shape object.
		 * The PhysicsObject creates a rectangle by default, but you can replace this method's
		 * definition and instead create a custom shape, such as a line or circle.
		 */	
		protected function createShape():void
		{
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsBox(_width / 2, _height / 2);
		}
		
		/**
		 * This method will often need to be overriden to provide additional definition to the Box2D fixture object. 
		 */	
		protected function defineFixture():void
		{
			_fixtureDef = new b2FixtureDef();
			_fixtureDef.shape = _shape;
			_fixtureDef.density = 1;
			_fixtureDef.friction = 0.6;
			_fixtureDef.restitution = 0.3;
			_fixtureDef.filter.categoryBits = CollisionCategories.Get("Level");
			_fixtureDef.filter.maskBits = CollisionCategories.GetAll();
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D fixture object. 
		 */	
		protected function createFixture():void
		{
			_fixture = _body.CreateFixture(_fixtureDef);
		}
		
		/**
		 * This method will often need to be overriden to provide additional definition to the Box2D joint object.
		 * A joint is not automatically created, because joints require two bodies. Therefore, if you need to create a joint,
		 * you will also need to create additional bodies, fixtures and shapes, and then also instantiate a new b2JointDef
		 * and b2Joint object.
		 */	
		protected function defineJoint():void
		{
			
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D joint object. 
		 * A joint is not automatically created, because joints require two bodies. Therefore, if you need to create a joint,
		 * you will also need to create additional bodies, fixtures and shapes, and then also instantiate a new b2JointDef
		 * and b2Joint object.
		 */		
		protected function createJoint():void
		{
			
		}
	}
}