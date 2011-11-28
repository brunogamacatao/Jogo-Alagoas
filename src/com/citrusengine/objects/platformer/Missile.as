package com.citrusengine.objects.platformer 
{
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Filter;
	import Box2DAS.Dynamics.ContactEvent;
	import com.citrusengine.objects.PhysicsObject;
	import com.citrusengine.physics.CollisionCategories;
	import flash.display.MovieClip;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import org.osflash.signals.Signal;
	
	/**
	 * A missile is an object that moves at a particular trajectory and speed, and explodes when it comes into contact with something.
	 * Often you will want the object that it exploded on to also die (or at least get hurt), such as a hero or an enemy.
	 * Since the missile can potentially be used for any purpose, by default the missiles do not do any damage or kill the object that
	 * they collide with. You will have to handle this manually using the onExplode() handler.
	 * 
	 * Properties:
	 * angle - In degrees, the angle that the missile will fire at. Right is zero degrees, going clockwise.
	 * speed - The speed that the missile moves at.
	 * fuseDuration - In milliseconds, how long the missile lasts before it explodes if it doesn't touch anything.
	 * explodeDuration - In milliseconds, how long the explode animation lasts before the missile object is destroyed.
	 * 
	 * Events
	 * onExplode - Dispatched when the missile explodes. Passes two parameters:
	 * 		1. The Missile (Missile)
	 * 		2. The Object it exploded on (PhysicsObject)
	 */
	public class Missile extends PhysicsObject 
	{
		/**
		 * In degrees, the angle that the missile will fire at. Right is zero degrees, going clockwise.
		 */
		public var speed:Number = 2;
		/**
		 * The speed that the missile moves at.
		 */
		public var angle:Number = 0;
		/**
		 * In milliseconds, how long the explode animation lasts before the missile object is destroyed.
		 */
		public var explodeDuration:Number = 1000;
		/**
		 * In milliseconds, how long the missile lasts before it explodes if it doesn't touch anything.
		 */
		public var fuseDuration:Number = 10000;
		/**
		 * Dispatched when the missile explodes. Passes two parameters:
		 * 		1. The Missile (Missile)
		 * 		2. The Object it exploded on (PhysicsObject)
		 */
		public var onExplode:Signal;
		
		private var _velocity:V2;
		private var _exploded:Boolean = false;
		private var _explodeTimeoutID:Number = 0;
		private var _fuseDurationTimeoutID:Number = 0;
		private var _contact:PhysicsObject;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, angle:Number, view:* = null, speed:Number = 2, fuseDuration:Number = 10000, explodeDuration:Number = 1000):Missile
		{
			if (view == null) view = MovieClip;
			return new Missile(name, { x: x, y: y, width: width, height: height, angle: angle, view: view, speed: speed, fuseDuration: fuseDuration, explodeDuration: explodeDuration } );
		}
		
		public function Missile(name:String, params:Object = null) 
		{
			super(name, params);
			onExplode = new Signal(Missile, PhysicsObject);
			
			_velocity = new V2(speed, 0);
			_velocity.rotate(angle * Math.PI / 180);
			gravity = 0;
			
			_fuseDurationTimeoutID = setTimeout(explode, fuseDuration);
			_body.SetLinearVelocity(_velocity);
		}
		
		override public function destroy():void
		{
			onExplode.removeAll();
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			clearTimeout(_explodeTimeoutID);
			clearTimeout(_fuseDurationTimeoutID);
			
			super.destroy();
		}
		
		override public function get rotation():Number
		{
			return angle;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			if (!_exploded)
			{
				_body.SetLinearVelocity(_velocity);
			}
			else
			{
				_body.SetLinearVelocity(new V2());
			}
			
			updateAnimation();
		}
		
		/**
		 * Explodes the missile
		 */
		public function explode():void
		{
			if (_exploded)
				return;
			
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_exploded = true;
			
			//Not collideable with anything anymore.
			_fixture.SetFilterData({ maskBits: CollisionCategories.GetNone() });
			
			onExplode.dispatch(this, _contact);
			
			clearTimeout(_fuseDurationTimeoutID);
			_explodeTimeoutID = setTimeout(killMissile, explodeDuration);
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.bullet = true;
			_bodyDef.angle = angle * Math.PI / 180;
			_bodyDef.fixedRotation = true;
			_bodyDef.allowSleep = false;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			
			_fixture.m_reportBeginContact = true;
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		}
		
		protected function handleBeginContact(e:ContactEvent):void
		{
			_contact = e.other.GetBody().GetUserData() as PhysicsObject;
			if (!e.other.IsSensor())
				explode();
		}
		
		protected function updateAnimation():void
		{
			if (_exploded)
			{
				_animation = "exploded";
			}
			else
			{
				_animation = "normal";
			}
		}
		
		protected function killMissile():void
		{
			kill = true;
		}
	}

}