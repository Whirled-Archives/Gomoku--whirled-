package org.lq.gomoku.ai {

    import com.whirled.game.NetSubControl;
    import flash.geom.Point;

    import org.lq.gomoku.logic.PlayerModel;
    import org.lq.gomoku.logic.Server;

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
                // var b:BoardState = BoardState.fromModel(context.board)
                var deadline:Date = new Date();
                deadline.time += 12000;

                MinMax.start_measure()
                var move:Array = MinMax.alphabeta(context.bmodel, depth, game_id, -100000, 100000, deadline);
                var res:Object = MinMax.end_measure();

                Server.profile_log('Visited ' + res.leaf_count +' leaf nodes in ' + (res.duration/1000) + ' seconds. Avg: '
                    + ((res.leaf_count / res.duration) * 1000) + ' nodes/s.');

                if(move[0] == null)
                    throw new Error("no move availble.");

                var p:Point = new Point();
                p.x = move[0][0]-1;
                p.y = move[0][1]-1;
                trace('Selected: ' + (p.x+1) + ',' + (p.y+1));
                context.board.placePieceAt(p, this);
            }
       }
    } /* end of class */

} /* end of package */