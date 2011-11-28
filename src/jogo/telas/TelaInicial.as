package jogo.telas {
import Box2DAS.Dynamics.ContactEvent;

import com.citrusengine.core.CitrusEngine;

import com.citrusengine.core.State;
import com.citrusengine.objects.CitrusSprite;
import com.citrusengine.objects.platformer.Hero;
import com.citrusengine.objects.platformer.Platform;
import com.citrusengine.objects.platformer.Sensor;
import com.citrusengine.physics.Box2D;

import flash.ui.Keyboard;

import jogo.entidades.Agua;
import jogo.eventos.EventosDoJogo;

public class TelaInicial extends State {
    private const OPCAO_NOVO_JOGO:int = 0;
    private const OPCAO_AJUDA:int     = 1;
    private const OPCAO_RECORDES:int  = 2;

    private const DELAY_MENU:Number = 200;

    private var opcaoAtual:int = OPCAO_NOVO_JOGO;
    private var menu:CitrusSprite;
    private var opcaoNovoJogo:CitrusSprite;
    private var opcaoAjuda:CitrusSprite;
    private var opcaoRecordes:CitrusSprite;

    private var ultimaAtualizacao:Number = 0;

    override public function initialize() : void {
        super.initialize();

        var background:CitrusSprite = new CitrusSprite("Background", {view: "recursos/imagens/abertura_bg.jpg"});
        add(background);

        menu = new CitrusSprite("Menu Opcoes", {view: "recursos/imagens/menu_opcoes.png"});
        add(menu);

        //Centraliza o menu
        menu.x = (500 - 156) / 2;
        menu.y = (400 - 116) / 2;

        opcaoNovoJogo = new CitrusSprite("Opcao Novo Jogo", {view: "recursos/imagens/op_novo_jogo.png"});
        add(opcaoNovoJogo);
        opcaoNovoJogo.x = -200;
        opcaoNovoJogo.y = menu.y;

        opcaoAjuda = new CitrusSprite("Opcao Ajuda", {view: "recursos/imagens/op_ajuda.png"});
        add(opcaoAjuda);
        opcaoAjuda.x = -200;
        opcaoAjuda.y = menu.y + opcaoNovoJogo.height + 5;

        opcaoRecordes = new CitrusSprite("Opcao Recordes", {view: "recursos/imagens/op_recordes.png"});
        add(opcaoRecordes);
        opcaoRecordes.x = -200;
        opcaoRecordes.y = opcaoAjuda.y + opcaoAjuda.height + 11;
    }

    override public function update(timeDelta:Number):void {
        super.update(timeDelta);

        var tempoAtual:Number = new Date().getTime();

        if (tempoAtual - ultimaAtualizacao > DELAY_MENU) {
            if (CitrusEngine.getInstance().input.isDown(Keyboard.DOWN)) {
                opcaoAtual++;
                if (opcaoAtual > 2) opcaoAtual = 0;
                ultimaAtualizacao = tempoAtual;
            } else if (CitrusEngine.getInstance().input.isDown(Keyboard.UP)) {
                opcaoAtual--;
                if (opcaoAtual < 0) opcaoAtual = 2;
                ultimaAtualizacao = tempoAtual;
            }
        }

        if (opcaoAtual == OPCAO_NOVO_JOGO) {
            opcaoNovoJogo.x = menu.x;
            opcaoAjuda.x = -200;
            opcaoRecordes.x = -200;
        } else if (opcaoAtual == OPCAO_AJUDA) {
            opcaoNovoJogo.x = -200;
            opcaoAjuda.x = menu.x;
            opcaoRecordes.x = -200;
        } else if (opcaoAtual == OPCAO_RECORDES) {
            opcaoNovoJogo.x = -200;
            opcaoAjuda.x = -200;
            opcaoRecordes.x = menu.x;
        }

        if (CitrusEngine.getInstance().input.isDown(Keyboard.ENTER)) {
            if (opcaoAtual == OPCAO_NOVO_JOGO) {
                dispatchEvent(new EventosDoJogo(EventosDoJogo.INICIAR_JOGO));
            } else if (opcaoAtual == OPCAO_AJUDA) {
                dispatchEvent(new EventosDoJogo(EventosDoJogo.AJUDA));
            } else if (opcaoAtual == OPCAO_RECORDES) {
                dispatchEvent(new EventosDoJogo(EventosDoJogo.RECORDES));
            }
        }
    }
}

}
