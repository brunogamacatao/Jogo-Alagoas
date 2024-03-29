package misc {
	
	import misc.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	
	/**
	 * Simulates waves on a 2D water surface using a series of points.
	 */
	public class Waves {
		
		/**
		 * The waves effecting the water surface.
		 */
		public var waves:Vector.<Wave>;
		
		/**
		 * The points being used to simulate the water surface.
		 */
		public var points:Vector.<Number>;
		
		/**
		 * Number of lines (between points) used to simulate the water surface.
		 */
		public var numLines:int;
		
		/**
		 * Number of waves in the waves vector.
		 */
		public var numWaves:int;
		
		/**
		 * Width of the water surface.
		 */
		public var width:Number;
		
		/**
		 * Height of the water surface (used only for drawing).
		 */
		public var height:Number;
		
		/**
		 * The horizontal distance between each point.
		 */
		public var lineWidth:Number;
		
		/**
		 * Create a new waves object with width, height, and number of lines (resolution).
		 */
		public function Waves(w:Number, h:Number, nl:int) {
			width = w;
			height = h;
			waves = new Vector.<Wave>();
			numWaves = 0;
			numLines = nl;
			lineWidth = width / numLines;
			points = new Vector.<Number>(numLines + 1, true);
			for(var i:int = 0; i <= numLines; ++i) {
				points[i] = 0;
			}
		}
		
		/**
		 * Add a wave.
		 */
		public function addWave(w:Wave):void {
			w.startAmplitude = w.amplitude;
			waves.push(w);
			numWaves++;
		}
		
		/**
		 * Creates a moving bulge / cavity on the water surface.
		 */
		public function createWave(pos:Number, h:Number, w:Number, v:Number) {
			var wv:Wave = new Wave();
			wv.clampFunc = Util.sinEaseInOut;
			wv.amplitude = h;
			wv.left = pos - w / 2;
			wv.right = pos - w / 2;
			wv.amplitude = h;
			wv.velocity = v;
			addWave(wv);
			return wv;
		}
		
		/**
		 * Creates a turbulence on the water surface.
		 */
		public function createTurbulance(h:Number, v:Number, l:Number) {
			var wv:Wave = new Wave();
			wv.waveFunc = Math.sin;
			wv.left = 0;
			wv.right = width;
			wv.wavelength = l;
			wv.increment = v;
			wv.amplitude = h;
			addWave(wv);
			return wv;
		}
		
		/**
		 * Creates 2 waves (3 bumps each) that move away from a point and decay.
		 */
		public function createSplash(pos:Number, h:Number, w:Number, t:Number):Array {
			var w1:Wave = new Wave();
			var w2:Wave = new Wave();
			w1.waveFunc = w2.waveFunc = Math.cos;
			w1.decayFunc = w2.decayFunc = Util.sinEaseOut;
			w1.clampFunc = w2.clampFunc = Util.sinEaseInOut;
			w1.amplitude = w2.amplitude = h / 2;
			var hw:Number = w / 2;
			w1.left = w2.left = pos - hw;
			w1.right = w2.right = w1.left + w;
			w1.totalSteps = w2.totalSteps = t;
			w1.wavelength = w2.wavelength = hw / (3 * Math.PI);
			var v = hw / t;
			w1.velocity = v;
			w2.velocity = -v;
			addWave(w1);
			addWave(w2);
			return [w1, w2];
		}
				
		/**
		 * Step the waves. Calculate the height of each point and move waves based on their velocity.
		 */
		public function step():void {
			var w:Wave;
			for(var i:int = 0; i < numWaves; ++i) {
				w = waves[i];
				w.step();
				var done:Boolean = w.decayFunc != null && (w.currentStep >= w.totalSteps);
				var outBounds:Boolean = (w.right <= 0 && w.velocity <= 0) || (w.left >= width && w.velocity >= 0);
				if(done || outBounds) {
					waves.splice(i, 1);
					numWaves--;
					i--;
				}
			}
			for(i = 0; i <= numLines; ++i) {
				points[i] = valueAt(i * lineWidth);
			}
		}
		
		/**
		 * Get the height of the water suface at a particular position.
		 */
		public function valueAt(pos:Number):Number {
			var y:Number = 0;
			for(var i:int = 0; i < numWaves; ++i) {
				y += waves[i].valueAt(pos);
			}
			return y;
		}
		
		/**
		 * Get a graphics stroke that can be used to draw the wave. Can pass in an offset to move the stroke.
		 */
		public function stroke(ox:Number = 0, oy:Number = 0):GraphicsPath {
			var gp:GraphicsPath = new GraphicsPath();
			gp.moveTo(0 + ox, points[0] + oy);
			for(var i = 1; i <= numLines; ++i) {
				gp.lineTo(lineWidth * i + ox, points[i] + oy);
			}
			gp.lineTo(width + ox, height + oy);
			gp.lineTo(0 + ox, height + oy);
			gp.lineTo(0 + ox, points[0] + oy);
			return gp;
		}
		
	}
	
}