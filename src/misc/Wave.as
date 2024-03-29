package misc {
	
	import misc.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	
	/**
	 * Stores data for an individual wave in a Waves object.
	 */
	public class Wave {
		
		/**
		 * The wave function (example: Math.sin).
		 */
		public var waveFunc:Function = null;
		
		/**
		 * Amount to stretch the wave function.
		 */
		public var wavelength:Number = 0;
		
		/** 
		 * Current amplitude of the wave.
		 */
		public var amplitude:Number = 0;
		
		/**
		 * Starting amplitude of the wave.
		 */
		public var startAmplitude:Number = 0;
		
		/**
		 * The current number of steps since the first step.
		 */
		public var currentStep:int = 0;
		
		/**
		 * Remove the wave at this step (if decayFunc is present).
		 */
		public var totalSteps:int = 0;
		
		/**
		 * Offset the position value fed into the wave function.
		 */
		public var offset:Number = 0;
		
		/**
		 * Amount to increment offset each step (the velocity of the wave within it's boundaries).
		 */
		public var increment:Number = 0;
		
		/**
		 * The decay function (takes the same arguments as a tween function, ie. Util.sinEaseOut).
		 */
		public var decayFunc:Function = null;
		
		/**
		 * The clamp function use to taper off the wave at it's boundaries (takes the same arguments as a tween function, ie. Util.sinEaseInOut).
		 */
		public var clampFunc:Function = null;
		
		/**
		 * Amount to move the wave boundaries each step.
		 */
		public var velocity:Number = 0;
		
		/**
		 * The left boundary of the wave.
		 */
		public var left:Number = 0;
		
		/**
		 * The right boundary of the wave.
		 */
		public var right:Number = 1000;
		
		/**
		 * Half the width of the full wave effect.
		 */
		public var halfWidth:Number;
		
		/**
		 * Middle of the wave effect.
		 */
		public var middle:Number;
		
		/** 
		 * Get the amplitude of the wave at a specific point.
		 */
		public function valueAt(position:Number):Number {
			if(position < left || position > right) {
				return 0;
			}
			var v:Number = (waveFunc != null ? waveFunc((position - left + offset) / wavelength) : 1) * amplitude;
			if(clampFunc != null) {
				v = clampFunc(Math.abs(position - middle), v, -v, halfWidth);
			}
			return v;
		}
		
		/**
		 * Step a wave - decay and move position.
		 */
		public function step():void {
			if(decayFunc != null) {
				amplitude = decayFunc(currentStep, startAmplitude, -startAmplitude, totalSteps);				
				currentStep++;
			}
			offset += increment;
			left += velocity;
			right += velocity;
			halfWidth = (right - left) / 2;
			middle = left + halfWidth;
		}
	}
}