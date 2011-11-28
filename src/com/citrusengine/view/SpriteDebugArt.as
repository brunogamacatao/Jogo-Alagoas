package com.citrusengine.view 
{
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.objects.CitrusSprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class SpriteDebugArt extends MovieClip 
	{
		
		public function SpriteDebugArt() 
		{
			addEventListener(Event.ADDED, handleAddedToParent);
		}
		
		private function handleAddedToParent(e:Event):void 
		{
			
		}
		
		public function initialize(object:CitrusObject):void
		{
			var citrusSprite:CitrusSprite = object as CitrusSprite;
			
			if (citrusSprite)
			{
				graphics.lineStyle(1, 0x222222);
				graphics.beginFill(0x888888);
				if (citrusSprite.registration == "topLeft")
					graphics.drawRect(0, 0, citrusSprite.width, citrusSprite.height);
				else
					graphics.drawRect( -citrusSprite.width / 2, -citrusSprite.height / 2, citrusSprite.width, citrusSprite.height);
				graphics.endFill();
			}
		}
	}

}