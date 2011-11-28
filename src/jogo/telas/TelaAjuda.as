/**
 * Created by IntelliJ IDEA.
 * User: brunocatao
 * Date: 23/11/11
 * Time: 17:15
 * To change this template use File | Settings | File Templates.
 */
package jogo.telas {
import com.citrusengine.core.CitrusEngine;
import com.citrusengine.core.State;
import com.citrusengine.objects.CitrusSprite;

import flash.ui.Keyboard;

import jogo.eventos.EventosDoJogo;

public class TelaAjuda extends State {
    override public function initialize() : void {
        super.initialize();
        var background:CitrusSprite = new CitrusSprite("Background", {view: "recursos/imagens/Aporkalypse-Help-Screen.png"});
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
