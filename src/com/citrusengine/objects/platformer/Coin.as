package com.citrusengine.objects.platformer
{
	import Box2DAS.Dynamics.ContactEvent;
	import flash.display.MovieClip;
	
	import flash.utils.getDefinitionByName;
	
	/**
	 * Coin is basically a sensor that destroys itself when a particular class type touches it. 
	 */	
	public class Coin extends Sensor
	{
		private var _collectorClass:Class = Hero;
		
		public static function Make(name:String, x:Number, y:Number, view:* = null):Coin
		{
			if (view == null) view = MovieClip;
			return new Coin(name, { x: x, y: y, view: view } );
		}
		
		public function Coin(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		/**
		 * The Coin uses the collectorClass parameter to know who can collect it.
		 * Use this setter to to pass in which base class the collector should be, in String form
		 * or Object notation.
		 * For example, if you want to set the "Hero" class as your hero's enemy, pass
		 * "com.citrusengine.objects.platformer.Hero" or Hero directly (no quotes). Only String
		 * form will work when creating objects via a level editor.
		 */		
		public function set collectorClass(value:*):void
		{
			if (value is String)
				_collectorClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_collectorClass = value;
		}
		
		override protected function handleBeginContact(e:ContactEvent):void
		{
			super.handleBeginContact(e);
			
			if (_collectorClass && e.other.GetBody().GetUserData() is _collectorClass)
			{
				kill = true;
			}
		}
	}
}