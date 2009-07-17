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

        private static const LOSE_SCORE :int = -2000;
        private static const WIN_SCORE :int = 2000;

        private static const WIN_SCORE2 :int = 1500;
        private static const LOSE_SCORE2 :int = -1500;

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
            var p:Piece, max:int = -1, i:int, x:Number, y:Number, tmp:Array;

            Server.ai_log("Alpha-beta: depth="+depth + " player="+player + " alpha=" + alpha + " beta="+ beta);
            
            if(moves.length == 0)
                return [null, 0];

            if(depth == 0) {
                MinMax.end_nodes_visited++;         
                return [null, evaluate(bmodel, player)]
            }

            for(i=0; i < moves.length; i++)
            {
                p = bmodel.putPiece( moves[i][0], moves[i][1], player);

                // Server.ai_log("Alpha-beta: depth="+depth + " player="+player + " alpha=" + alpha + " beta="+ beta);
                // Server.ai_log("Descending to ("+ moves[i][0] + ", " + moves[i][1] + ")");

                if( p.group[0].length >= 5 || p.group[1].length >= 5
                 || p.group[2].length >= 5 || p.group[3].length >= 5 )
                {                
                    //Server.ai_log('quick eval');
                    // we place the stone and make 5
                    // so the oponent loses immediatly - no need to descent
                    // the call would return LOSE_SCORE
                    // we know - we win with this move, so win can return now
                    bmodel.removePiece( moves[i][0], moves[i][1] );
                    return [ moves[i], WIN_SCORE ];
                }
                
                tmp = alphabeta(bmodel, depth-1, 1-player, -beta, -alpha, deadline);                

                //Server.ai_log("Alpha-beta: depth="+depth + " player="+player + " alpha=" + alpha + " beta="+ beta);
                //Server.ai_log("Move to ("+ moves[i][0] + ", " + moves[i][1] + ") value is: " + tmp[1]);

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
                    Server.log('[ai] Deadline reached.');
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
            var ec:int, x:int;
            var sum:int = 0;

            for each(var g:PieceGroup in b.groups)
            {
                ec = 0; x = 0;
                if( g.previous(b).color < 0) ec++;
                if( g.next(b).color < 0) ec++;
                
                switch(g.length) 
                {
                    case 5:
                        if(p == g.color)
                            x = WIN_SCORE;
                        else 
                            x = LOSE_SCORE;
                        break;
                    case 4:
                        if( (p == g.color) && (ec > 0))
                            x = WIN_SCORE;
                        else if( (g.color == 1-p) && (ec == 2))
                            x = LOSE_SCORE;
                        break;
                    default:
                        x = (g.length*5)*(ec+1)*g.length*(g.length > 2 ? 2 : 1)*(g.color == p ? 1 : -1);
                 }
                 sum += x;
                 // Server.ai_log('[eval] ' + g + '/' + ec + " VALUE: " + x + "SUM: " + sum);
            }

            return sum;
        }
        
    } /* end of class */

} /* end of package */