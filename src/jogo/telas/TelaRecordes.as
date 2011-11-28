/**
 * Created by IntelliJ IDEA.
 * User: brunocatao
 * Date: 25/11/11
 * Time: 16:28
 * To change this template use File | Settings | File Templates.
 */
package jogo.telas {
import com.citrusengine.core.CitrusEngine;
import com.citrusengine.core.State;
import com.citrusengine.objects.CitrusSprite;

import flash.ui.Keyboard;

import jogo.eventos.EventosDoJogo;

public class TelaRecordes extends State {
    override public function initialize() : void {
        super.initialize();
        var background:CitrusSprite = new CitrusSprite("Background", {view: "recursos/imagens/ScoreScreen.jpg"});
        add(background);
    }

    override public function update(timeDelta:Number):void {
        super.update(timeDelta);

        if (CitrusEngine.getInstance().input.isDown(Keyboard.ESCAPE)) {
            this.dispatchEvent(new EventosDoJogo(EventosDoJogo.TELA_INICIAL));
        }
    }
}
}
