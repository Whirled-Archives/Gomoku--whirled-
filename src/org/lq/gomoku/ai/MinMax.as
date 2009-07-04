package org.lq.gomoku.ai
{

   import org.lq.gomoku.logic.Server;

    public class MinMax 
    {
        
        public static function alphabeta(state:BoardState, 
                depth:int, player:int, alpha:Number, beta:Number, deadline:Date):Object
        {
            var moves:Array = state.availble_moves();
            var max_move:int = moves[0];
            var tmp:Object;

            Server.ai_log('[ai] Depth ' + depth + 'player: ' + player);

            if(moves.length == 0)
                return {'move': null, 'alpha': 0};

            if(depth == 0) {
                var v:Number = state.value(player);
                Server.ai_log('[ai] End node value: ' + v);
                return {'move': null, 'alpha': v};
            }

            for each(var idx:int in moves)
            {
               Server.ai_log('[ai] Descending to move: ' + idxstr(idx, state.size) + "; a= " + alpha + " b=" + beta);
               tmp = alphabeta(state.make_move(idx, player), depth-1, 1-player, -beta, -alpha, deadline);

               tmp.alpha += (idx - state.data.length/2)*(idx - state.data.length/2)/10000;

               // greater alpha is worse, for us, chose the least negative -alpha //
               Server.ai_log('[ai] Value for move: ' + idxstr(idx, state.size) + ': ' + (-tmp.alpha) + ", current_max: " + alpha);

               if( -tmp.alpha > alpha) {
                    max_move = idx;
                    alpha = -tmp.alpha;                    
               }

               if( beta <= alpha) {
                    // trace('[ai] cut-off');
                    break;
               }

               if( (new Date()).time > deadline.time ) {
                    trace('[ai] timeout - early exit');
                    break;
               }
            }

            return {'move': max_move, 'alpha': alpha};
        }

        private static function idxstr(idx:int, s:int):String {
            return '(' +  ((idx%s)+1) + ', ' + (int(idx/s)+1) + ')';
        }

        
    } /* end of class */

} /* end of package */