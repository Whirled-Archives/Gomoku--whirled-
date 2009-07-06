package org.lq.gomoku.ai
{

    import org.lq.gomoku.logic.Server;
    import org.lq.gomoku.logic.BoardGroupModel;
    import org.lq.gomoku.logic.Piece;
    import org.lq.gomoku.logic.PieceGroup;

    public class MinMax 
    {
        private static var end_nodes_visited:int;
        private static var other_nodes_visited:int;

        private static var search_start_time:Date;

        public static function start_measure():void {
            MinMax.end_nodes_visited = 0;
            MinMax.other_nodes_visited = 0;
            MinMax.search_start_time = new Date();
        }

        public static function end_measure():Object {
            return {'leaf_count': MinMax.end_nodes_visited,
                    'node_count': MinMax.other_nodes_visited,
                    'duration': ((new Date()).time - MinMax.search_start_time.time) };
        }
        
        public static function alphabeta(bmodel:BoardGroupModel,
                depth:int, player:int, alpha:Number, beta:Number, deadline:Date):Array
        {
            var moves:Array = bmodel.availble_moves();
            var max:int = -1, i:int, x:Number, y:Number;
            var tmp:Array;     
            
            if(moves.length == 0)
                return [null, 0];

            if(depth == 0) {
                MinMax.end_nodes_visited++;         
                return [null, evaluate(bmodel, player)]
            }

            for(i=0; i < moves.length; i++)
            {
                bmodel.putPiece( moves[i][0], moves[i][1], player);
                tmp = alphabeta(bmodel, depth-1, 1-player, -beta, -alpha, deadline);
                bmodel.removePiece( moves[i][0], moves[i][1] );

                x = (moves[i][0]*2 - bmodel.board_size);
                y = (moves[i][1]*2 - bmodel.board_size);
                tmp[1] += (x*x+y*y)/10000;

                if( -tmp[1] > alpha) {
                    max = i;
                    alpha = -tmp[1];
                }

               if( beta <= alpha) break;

               if( (new Date()).time > deadline.time ) {
                    trace('[ai] timeout - early exit');
                    break;
               }
            }

            MinMax.other_nodes_visited++;
            if(max < 0)
                return [ moves[0], alpha ]
            else
                return [ moves[max], alpha ];
        }

        private static function evaluate(b: BoardGroupModel, p:int):Number
        {
            var ec:int;
            var sum:int = 0;

            for each(var g:PieceGroup in b.groups)
            {
                ec = 0;
                if( g.previous(b).color < 0) ec++;
                if( g.next(b).color < 0) ec++;

                // trace('[eval] ' + g + ' ends:' + ec);

                if(g.length >= 5)
                    return 5000 * (p == g.color ? 1 : -1);                

                if(g.length == 4)
                {
                    if( (g.color == p) && (ec > 0))
                        return 3000;

                    if( (g.color == 1-p) && (ec == 2))
                        return -1000;
                    continue;
                }

                sum += (g.length*5)*(ec+1)*(g.length > 2 ? 3 : 1) * (g.color == p ? 1 : -1);
            }

            return sum;
        }
        
    } /* end of class */

} /* end of package */