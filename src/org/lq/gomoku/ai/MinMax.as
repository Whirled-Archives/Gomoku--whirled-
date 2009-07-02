package org.lq.gomoku.ai
{

    public class MinMax 
    {
        
        public static function minimax(state:BoardState, depth:int,player:int):Number
        {
            var moves:Array = state.availble_moves();

            if(moves.length == 0)
                return 0;

            if(depth == 0)
                return state.value(1-player)

            var alpha:Number = -10000;

            for each(var idx:int in moves)
            {
               // trace('[ai] Depth ' + depth + '| Move: ' + (idx%state.size) + ", " + int(idx/state.size) + "; a= " + alpha );
               alpha = Math.max( alpha,
                    -minimax(state.make_move(idx, player), depth-1, 1-player) );
            }

            return alpha;
        }

        public static function alphabeta(state:BoardState, 
                depth:int, player:int, alpha:Number, beta:Number):Object
        {
            var moves:Array = state.availble_moves();
            var max_move:int = -1;
            var tmp:Object;

            if(moves.length == 0)
                return {'move': null, 'alpha': 0};

            if(depth == 0)
                return {'move': null, 'alpha': state.value(1-player)};

            for each(var idx:int in moves)
            {
               // trace('[ai] Depth ' + depth + '| Move: ' + (idx%state.size) + ", " + int(idx/state.size) + "; a= " + alpha + " b=" + beta);
               tmp = alphabeta(state.make_move(idx, player), depth-1, 1-player, -beta, -alpha);

               // trace('[ai] Node value: ' + -tmp.alpha + ", current_max: " + alpha);

               if( -tmp.alpha > alpha) {
                    max_move = idx;
                    alpha = -tmp.alpha;
                    // trace('[ai] new max move: ' + max_move);
               }

               if( beta <= alpha) {
                    // trace('[ai] cut-off');
                    break;
               }
            }

            return {'move': max_move, 'alpha': alpha};
        }

        
    } /* end of class */

} /* end of package */