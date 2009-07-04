package org.lq.gomoku.logic {

    import com.whirled.game.NetSubControl;
    import flash.geom.Point;

    import org.lq.gomoku.ai.MinMax;
    import org.lq.gomoku.ai.BoardState;

    public class AIPlayer extends PlayerModel
    {

        private var depth: int = 1;

        public function AIPlayer(_gameid : int, _depth:int)
        {
            super("AI Player", NetSubControl.TO_SERVER_AGENT, _gameid);
            depth = _depth;
		}

        public override function pickle() : Object
        {
            var d :Object = super.pickle();
            d.klass = "ai";
            d.abdepth = depth;
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
                var deadline:Date = new Date();
                deadline.time += 10000;

                var move:* = MinMax.alphabeta(b, depth, game_id, -100000, 100000, deadline);

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