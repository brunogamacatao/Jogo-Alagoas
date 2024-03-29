package misc {

	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.ui.*;

	public class Util {
		
		/// Multiply to convert degrees to radians.
		public static const D2R:Number = Math.PI / 180;
		
		/// Multiply to convert radians to degrees.
		public static const R2D:Number = 180 / Math.PI;
		
		/// 360 degrees in radians.
		public static const PI2:Number = Math.PI * 2;
		
		/**
		 * Remove a display object.
		 */
		public static function remove(o:DisplayObject):void {
			if(o && o.parent) {
				o.parent.removeChild(o);
			}
		}
		
		/**
		 * Remove a display object and add it somewhere else, keeping its position / rotation the same.
		 */
		public static function relocate(obj:DisplayObject, to:DisplayObjectContainer, depth:int = -1, cb:Function = null):void {
			var m:Matrix = localizeMatrix(to, obj);
			obj.transform.matrix = m;
			remove(obj);
			if(cb != null) cb();
			to.addChildAt(obj, (depth == -1 ? to.numChildren : depth));
		}
		
		/**
		 * Set the position of a display object.
		 */
		public static function setPos(o:DisplayObject, p:*):void {
			o.x = p.x;
			o.y = p.y;
		}
		
		
		/**
		 * Add a child to a container at a specified position.
		 */
		public static function addChildAtPos(o:DisplayObjectContainer, child:DisplayObject, pos:*, depth:int = -1):void {
			setPos(child, pos);
			depth == -1 ? o.addChild(child) : o.addChildAt(child, depth);
		}
		
		/**
		 * Add a child to a container at a position relative to a different display object.
		 */
		public static function addChildAtPosOf(o:DisplayObjectContainer, child:DisplayObject, of:DisplayObject, depth:int = -1, p:Point = null):void {
			addChildAtPos(o, child, Util.localizePoint(o, of, p), depth);
		}
		
		/**
		 * Add a display object underneath another one.
		 */
		public static function addChildUnder(child:DisplayObject, under:DisplayObject, pos:Boolean = true):void {
			if(under.parent) {
				if(under.parent == child.parent) {
					remove(child);
				}
				under.parent.addChildAt(child, under.parent.getChildIndex(under));
				if(pos) setPos(child, under);
			}
		}
		
		/**
		 * Add a display object above another one.
		 */
		public static function addChildAbove(child:DisplayObject, above:DisplayObject, pos:Boolean = true):void {
			if(above.parent) {
				if(above.parent == child.parent) {
					remove(child);
				}				
				var d:int = above.parent.getChildIndex(above) + 1;
				above.parent.addChildAt(child, d);
				if(pos) setPos(child, above);
			}
		}
		
		/**
		 * Add a display object underneath another one - if the "under" object is not a direct descendent of "o", then find the direct descendant containing "under".
		 */
		public static function addChildUnderNested(o:DisplayObject, child:DisplayObject, under:DisplayObject, pos:Boolean = true):void {
			addChildUnder(child, findChildContaining(o, under), pos);
		}

		/**
		 * Add a display object above another one - if the "above" object is not a direct descendent of "o", then find the direct descendant containing "above".
		 */
		public static function addChildAboveNested(o:DisplayObject, child:DisplayObject, above:DisplayObject, pos:Boolean = true):void {
			addChildAbove(child, findChildContaining(o, above), pos);
		}
		
		/**
		 * Removes all children from a display object container.
		 */
		public static function removeChildren(o:DisplayObjectContainer):void {
			while(o.numChildren > 0) {
				o.removeChildAt(0);
			}
		}
		
		/**
		 * Replace "o" with "w" in the display object hierarchy. "w" will have the same depth as "o".
		 */
		public static function replace(o:DisplayObject, w:DisplayObject):void {
			if(o.parent) {
				var p:DisplayObjectContainer = o.parent;
				var i:int = o.parent.getChildIndex(o);
				remove(o);
				p.addChildAt(w, i);
			}
		}

		
		/**
		 * If "o" contains child somewhere in its display object hierarchy, return the direct descendant of "o" that contains the child (or is the child itself).
		 */
		public static function findChildContaining(o:DisplayObject, child:DisplayObject):DisplayObject {
			while(child && child.parent != o) {
				child = child.parent;
			}
			return child;
		}
		
		/**
		 * Quick way to check if a dictionary contains anything.
		 */
		public static function dictionaryIsEmpty(d:Dictionary):Boolean {
			for(var k:* in d) {
				return false;
			}
			return true;
		}
		
		/**
		 * Go up the display hierarchy until an ancestor is found of the provided class.
		 */
		public static function findAncestorOfClass(o:DisplayObject, c:Class, self:Boolean = false):DisplayObject {
			if(self && o is c) {
				return o;
			}
			do {
				o = o.parent;
			} while(o && !(o as c));
			return o;
		}
		
		/**
		 * A simple object merger. obj1 will have all the key-values of obj2.
		 */
		public static function mergeObjects(obj1:Object, obj2:Object):void {
			for(var i:String in obj2) {
				obj1[i] = obj2[i];
			}
		}
		
		/**
		 * Rotate a point. Angle is radians.
		 */
		public static function rotateXY(xy:Array, r:Number):void {
			var _x:Number = xy[0];
			xy[0] = Math.cos(r) * _x - Math.sin(r) * xy[1];
			xy[1] = Math.sin(r) * _x + Math.cos(r) * xy[1];
		}
		
		/**
		 * Pass this a display object if you don't want its ENTER_FRAME events to fire when it's not
		 * on the stage.
		 */
		public static function stopInvisibleEnterFrame(o:DisplayObject):void {
			o.addEventListener(Event.ENTER_FRAME, checkInvisibleEnterFrame, false, 9999999, true);
		}
		
		/**
		 * Resume normal ENTER_FRAME behavior (see above).
		 */
		public static function resumeInvisibleEnterFrame(o:DisplayObject):void {
			o.removeEventListener(Event.ENTER_FRAME, checkInvisibleEnterFrame);
		}
		
		/**
		 * Stop an enter frame from propogating if the display object isn't on the stage.
		 */
		public static function checkInvisibleEnterFrame(e:Event):void {
			var o:DisplayObject = e.target as DisplayObject;
			if(!o.stage) {
				e.stopImmediatePropagation();
			}
		}
		
		/**
		 * Returns a matrix that reflects what "from"'s transform looks like from the perspective of "to".
		 */
		public static function localizeMatrix(to:DisplayObject, from:DisplayObject):Matrix {
			var m:Matrix = from.transform.concatenatedMatrix;
			var m2:Matrix = to.transform.concatenatedMatrix;
			m2.invert();
			m.concat(m2);
			if(from.cacheAsBitmap || to.cacheAsBitmap) {
				var p:Point = Util.localizePoint(to, from);
				m.tx = p.x;
				m.ty = p.y;			
			}
			return m;
		}
		
		/**
		 * Takes a point in "from" and finds the cooresponding point in "to".
		 */
		public static function localizePoint(to:DisplayObject, from:DisplayObject, p:Point = null):Point {
			return to.globalToLocal(from.localToGlobal(p ? p : new Point(0, 0)));
		}
		
		/**
		 * Gets the rotation of "from" relative to "to".
		 */
		public static function localizeRotation(to:DisplayObject, from:DisplayObject, r:Number = 0):Number {
			return r + globalRotation(from) - globalRotation(to);
		}
		
		/** 
		 * Returns the rotation of the object in global coordinate space.
		 */
		public static function globalRotation(o:DisplayObject):Number {
			var r:Number = o.rotation;
			while(o = o.parent) {
				r += o.rotation;
			}
			return r;
		}
		
		/**
		 * Traverses up the display object hierarchy until parent = null.
		 */
		public static function getRoot(o:DisplayObject):DisplayObject {
			while(o.parent) {
				o = o.parent;
			}
			return o;
		}
		
		/**
		 * Gets the untransformed bounds of a display object, as if it has no scale, rotation or skew transformation.
		 * If stroke is set to true, the width of any strokes are included in the bounds.
		 */
		public static function bounds(o:DisplayObject, stroke:Boolean = false):Rectangle {
			return stroke ? o.getBounds(o) : o.getRect(o);
		}
		
		/**
		 * Find a display object by name using file path notation.
		 */
		public static function getDisplayObjectByPath(pwd:DisplayObject, path:String, root:DisplayObjectContainer = null):DisplayObject {
			if(path.charAt(0) == '/') {
				pwd = root ? root : getRoot(pwd);
				path = path.substr(1);
			}
			else if(path.charAt(0) == '.') {
				path = path.substr(1);
			}
			var parts:Array = path.split('/');
			for(var i:uint = 0; i < parts.length; ++i) {
				if(parts[i] != '') {
					if(parts[i] == '..') {
						pwd = pwd.parent;
					}
					else if(parts[i] != '.') {
						pwd = (pwd as DisplayObjectContainer).getChildByName(parts[i]);
					}
				}
			}
			return pwd;
		}
		
		/**
		 * Like DisplayObject::getObjectsUnderPoint, but will also check parents of found objects, filters by class, can
		 * exclude objects to be found, and can stop collecting at a maximum amount.
		 */
		public static function getObjectsUnderPointByClass(o:DisplayObjectContainer, p:Point, c:Class, max:int = 0, exclude:Array = null, noAncestors:Boolean = true):Array {
			// According to Adobe's documentation I should be able to call getObjectsUnderPoint directly on "o", but it doesn't seem to work
			// in certain cases?
			var objs:Array = o.stage.getObjectsUnderPoint(p);
			var found:Array = [];
			exclude ||= [];
			for(var i:int = objs.length - 1; i >= 0; i--) {
				var obj:DisplayObject = objs[i];
				var f:Boolean = false;
				while(obj) {
					if(exclude.indexOf(obj) == -1) {
						if(obj is c) {
							found.push(obj);
							f = true && noAncestors;
							if(max > 0 && found.length == max) {
								return found;
							}
							exclude.push(obj);
						}
					}
					obj = f ? null : obj.parent;
				}
			}
			return found;
		}
				
		/**
		 *
		 */
		public static function sign(n:Number):int {
			return isNaN(n) ? 0 : (n > 0) ? 1 : (n < 0) ? -1 : 0;
		}
		
		/**
		 * Increment an angle a certain amount towards a target angle using the shortest path of rotation (see below).
		 */
		public static function incrementAngleToTarget(angle:Number, target:Number, inc:Number):Number {
			target = findBetterAngleTarget(angle, target);
			if(target > angle) {
				angle += inc;
				if(angle > target) {
					angle = target;
				}
			}
			else if(angle > target) {
				angle -= inc;
				if(target > angle) {
					angle = target;
				}
			}
			return angle;
		}
		
		/**
		 * For animating/tweening rotation, this find the shorted path to the desired rotation.
		 * Example: a DisplayObject has a rotation of -10 degrees, and I want to rotate it to 190 degrees. The shortest path
		 * would be to actual rotate it to -170, a change of -160 degrees. If I just tweened it, it would actually rotate
		 * 200 degrees.
		 */
		public static function findBetterAngleTarget(angle:Number, target:Number):Number {
			if(Math.abs(angle - target) == 180) {
				return target;
			}
			var rot2:Number = target % 360;
			rot2 = (angle + rot2 ) - (angle % 360);
			if((rot2 - angle) > 180) {
				rot2 = rot2 - 360;
			}
			else if((angle - rot2) > 180) {
				rot2 = rot2 + 360;
			}
			return rot2;
		}
		
		/**
		 * A default tween that can be used when we don't know if the mx.* (flex) or fl.* (flash) packages are available.
		 */
		public static function linearEase(t:Number, b:Number, c:Number, d:Number):Number {
			return b + c * t  / d;
		}
		
		/**
		 * Another ease function for when availability of mx.* or fl.* is not known.
		 */
		public static function sinEaseIn (t:Number, b:Number, c:Number, d:Number):Number {
			return -c * Math.cos(t/d * (Math.PI / 2)) + c + b;
		}
	
		/**
		 * Another ease function for when availability of mx.* or fl.* is not known.
		 */
		public static function sinEaseOut(t:Number, b:Number, c:Number, d:Number):Number {
			return c * Math.sin(t / d * (Math.PI / 2)) + b;
		}

		/**
		 * Another ease function for when availability of mx.* or fl.* is not known.
		 */		
		public static function sinEaseInOut(t:Number, b:Number, c:Number, d:Number):Number {
			return -c / 2 * (Math.cos(Math.PI * t / d) - 1) + b;
		}
		
		/**
		 * Stops execution for a given number of milliseconds.
		 */
		public static function sleep(t:int):void {
			var time:int = getTimer();
			while((getTimer() - time) < t) {}
		}
		
		/**
		 * A short cut for stopImmediatePropagation that can also be used as an event listener.
		 */
		public static function killEvent(e:Event):void {
			e.stopImmediatePropagation();
		}
		
	}
}