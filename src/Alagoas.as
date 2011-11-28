package {

import com.citrusengine.core.CitrusEngine;

import flash.events.KeyboardEvent;

import flash.ui.Keyboard;

import jogo.telas.TelaAjuda;

import jogo.telas.TelaInicial;
import jogo.telas.TelaPrimeiraFase;
import jogo.eventos.EventosDoJogo;
import jogo.telas.TelaRecordes;

[SWF(width="500", height="400", frameRate="60", backgroundColor="#000000")]
public class Alagoas extends CitrusEngine {
    public function Alagoas() {
        super();
        state = new TelaInicial();
        addEventListener(EventosDoJogo.TELA_INICIAL, telaInicial);
        addEventListener(EventosDoJogo.INICIAR_JOGO, iniciarJogo);
        addEventListener(EventosDoJogo.AJUDA, ajuda);
        addEventListener(EventosDoJogo.RECORDES, recordes);
    }

    public function telaInicial(event : EventosDoJogo) : void {
        state = new TelaInicial();
    }

    public function iniciarJogo(event : EventosDoJogo) : void {
        state = new TelaPrimeiraFase();
    }

    public function ajuda(event : EventosDoJogo) : void {
        state = new TelaAjuda();
    }

    public function recordes(event : EventosDoJogo) : void {
        state = new TelaRecordes();
    }
}
}
