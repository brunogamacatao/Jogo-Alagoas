package jogo.entidades {
import Box2DAS.Controllers.b2BuoyancyEffect;

import com.citrusengine.core.CitrusEngine;

import com.citrusengine.objects.PhysicsObject;
import com.citrusengine.objects.platformer.Platform;

import flash.display.Graphics;

import flash.display.GraphicsPath;
import flash.display.IGraphicsData;

import flash.display.Shape;

import misc.Waves;

public class Agua extends Platform {
    private var water:Waves;
    private var waterShape:Shape;

    public function Agua(name:String, params:Object = null) {
        super(name,  params);

        water = new Waves(width, height, width / 10);

        waterShape = new Shape();
        waterShape.x = x;
        waterShape.y = y;

        CitrusEngine.getInstance().addChild(waterShape);
        water.createTurbulance(10, 5, 100);
        water.createTurbulance(10, -5, 200);
    }

    override public function update(timeDelta:Number):void {
        super.update(timeDelta);

        water.step();

        var g:Graphics = waterShape.graphics;
        g.clear();
        g.lineStyle(1, 0xffffff);
        g.beginFill(0x5FA5FF, 0.5);
        g.drawGraphicsData(Vector.<IGraphicsData>([water.stroke()]));
        g.endFill();
    }
}
}
