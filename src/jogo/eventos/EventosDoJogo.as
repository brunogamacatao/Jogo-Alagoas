/**
 * Created by IntelliJ IDEA.
 * User: brunocatao
 * Date: 25/11/11
 * Time: 09:10
 * To change this template use File | Settings | File Templates.
 */
package jogo.eventos {
import flash.events.Event;

public class EventosDoJogo extends Event {
    public static const TELA_INICIAL:String = "TELA_INICIAL";
    public static const INICIAR_JOGO:String = "INICIAR_JOGO";
    public static const AJUDA:String        = "AJUDA";
    public static const RECORDES:String     = "RECORDES";

    public function EventosDoJogo(tipo:String, bubbles:Boolean = true, cancelable:Boolean = false) {
        super(tipo, bubbles, cancelable);
    }
}
}
