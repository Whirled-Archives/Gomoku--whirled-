package org.lq.gomoku.logic {

    import com.whirled.game.NetSubControl;
    import flash.geom.Point;

    import org.lq.gomoku.ai.MinMax;
    import org.lq.gomoku.ai.BoardState;

    public class AIPlayer extends PlayerModel
    {
        public function AIPlayer(_gameid : int)
        {
            super("AI Player", NetSubControl.TO_SERVER_AGENT, _gameid);
		}

        public override function pickle() : Object
        {
            var d :Object = super.pickle();
            d.klass = "ai";
            return d;
        }
    

        public override function headshot(library : Object): Object
        {
            return new library._headshot();
        }

        public function playerMessage(msg:String, value:*, context:Object) : void
        {
            if((msg == Server.PMSG_TURN) && (value.next == game_id))
            {
                /* create boardstate */
                var b:BoardState = BoardState.fromModel(context.board)

                var move:* = MinMax.alphabeta(b, 1, game_id, -10000, 10000);

                if(move.move < 0)
                    throw new Error("no move availble.");

                var p:Point = new Point();
                p.x = move.move % b.size;
                p.y = int(move.move / b.size)
                trace('Selected: ' + p);
                context.board.placePieceAt(p, this);
            }
       }
    } /* end of class */

} /* end of package */