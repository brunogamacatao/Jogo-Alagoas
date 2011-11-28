package com.citrusengine.physics.simple 
{
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.CitrusSprite;
	
	public class Collision 
	{
		public static const BEGIN:uint = 0;
		public static const PERSIST:uint = 1;
		
		public var self:CitrusSprite;
		public var other:CitrusSprite;
		public var normal:MathVector;
		public var impact:Number;
		public var type:uint;
		
		public function Collision(self:CitrusSprite, other:CitrusSprite, normal:MathVector, impact:Number, type:uint) 
		{
			this.self = self;
			this.other = other;
			this.normal = normal;
			this.impact = impact;
			this.type = type;
		}
	}

}