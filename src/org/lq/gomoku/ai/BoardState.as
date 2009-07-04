package org.lq.gomoku.ai
{

    import org.lq.gomoku.logic.BoardModel;
    import org.lq.gomoku.logic.Server;

    public class BoardState
    {
        public var data:Array;
        public var size:int;

        /* rate how good this position is for the given player */
        public function value(me:int):Number
        {
            var gcount:Array = new Array();

            var i:int,j:int, k:int;
            var counter:int = 0;
            var marker:int = 100;
            var pmarker:int = 100;
            var v:int;
            
            gcount[me] = new Array(); // me
            gcount[1-me] = new Array(); // him

            for(i=1; i <= 5; i++) {
                gcount[me][i] = new Array(0,0,0);
                gcount[1-me][i] = new Array(0,0,0);
            }

            var group_counter:Function = function(marker:int, count:int, ends:int):void
            {
                if( (marker == me) || (marker == 1-me))
                    gcount[marker][count][ends] += 1;
            }

            /* horizontal */
            group_iter( iterator(0, size, 1,
                function(r:int, start:int):Boolean { return start < data.length; },
                function(r:int, idx:int):Boolean { return (idx - (r*size)) < size;}),
                group_counter);

            /* vertical */
            group_iter( iterator(0, 1, size,
                function(r:int, start:int):Boolean { return r < size; },
                function(r:int, idx:int):Boolean {return (idx / size) < size;}),
                group_counter);

            /* diagonal 1 */
            group_iter( iterator(0, 1, size+1,
                function(r:int, start:int):Boolean {return start < size; },
                function(r:int, idx:int):Boolean {return idx < (size-r) * size; }),
                group_counter);

            /* diag 1 c.d. */
            group_iter( iterator(size, size, size+1,
                function(r:int, start:int):Boolean {return start < data.length; },
                simple_end),
                group_counter);

            /* diag 2 */
            group_iter( iterator(size-1, size, size-1,
                function(r:int, start:int):Boolean {return start < data.length; },
                function(r:int, idx:int):Boolean {return idx <= r+(size-1)*size; }),
                group_counter);

            /* diag 2 c.d.*/
            group_iter( iterator(size-2, -1, size-1,
                function(r:int, start:int):Boolean {return start >= 0; },
                function(r:int, idx:int):Boolean {return idx <= (size-(r+2))*size; }),
                group_counter);

          var s:Number = 0;

          // instant win
          s += (gcount[me][5][2]) * 5000;
          s += (gcount[me][5][1]) * 5000;
          s += (gcount[me][5][0]) * 5000;

          if(s > 0) {
            print_board();
            Server.ai_log("winning position for player: " + me);
            return s;
          }

          // instant lose
          s += gcount[1-me][5][0] * -2000;
          s += gcount[1-me][5][1] * -2000;
          s += gcount[1-me][5][2] * -2000;
                    
          if(s < 0) {
            print_board();
            Server.ai_log("losing position for player: " + me);
            return s;
          }

          // sure win
          s += (gcount[me][4][2]) * 3000;
          s += (gcount[me][4][1]) * 3000;

          if(s > 0) {
            print_board();
            Server.ai_log("winning position for player: " + me);
            return s;
          }

          // sure lose
          s += gcount[1-me][4][2] * -1000;

          if(s < 0) {
            print_board();
            Server.ai_log("losing position for player: " + me);
            return s;
          }

          s += gcount[me][3][2] * 100;

          // good moves
          s += gcount[me][2][2] * 10;
          s += gcount[me][1][2] * 1;

          // not so good
          s -= gcount[1-me][3][2] * 8;
          s -= gcount[1-me][2][2] * 4;

          if(Server.AI_LOG)
              print_counts(gcount, me);

          return s;
        }

        private static function group_iter(next_row:Function, group_end:Function):void
        {           
            var count:int = 0;
            var free_ends:int = 0;
            var gc:int = BORDER;
            var gp:int = BORDER;

            var current:*;
            var next_item:Function;

            for(next_item = next_row(); next_item != null; next_item = next_row())
            {
                for(current = next_item(); current != ITER_END; current = next_item())
                {
                    if(count == 0) {
                        count = 1;
                        gp = gc;
                        gc = current;

                        continue;
                    }

                    // group continuation
                    if(gc == current) {
                        count = Math.min(count+1, 5);
                        continue;
                    }

                    // end of group
                    free_ends = 0;
                    if(gp < 0) free_ends++;
                    if(current < 0) free_ends++;

                    group_end(gc, count, free_ends);
                    gp = gc;
                    gc = current;
                    count = 1;                    
               }

               /* we assume iter ends with BORDER */
               count = 0;
               gc = BORDER;
               gp = BORDER;               
            }
       }


       private function print_board():void 
       {
            var s:String = '';
            var x:int,y:int, i:int;

            Server.ai_log('Board state: ');
            for(y=0; y < size; y++) {
                s = '';

                for(x=0; x < size; x++) {
                    i = data[y*size + x];
                    if (i < 0) s += '.';
                    else if(i == 0) s += 'X';
                    else if(i == 1) s += 'O';
                    else s += '?';
                }
                Server.ai_log(s);
            }
        }

        private static function print_counts(a:Array, me:int):void
        {
            var i:int;

            for (i=1; i <= 5; i++) {
                Server.ai_log('[my:' + me + '] ' + i + ' - '+ a[me][i][0]+' '+a[me][i][1]+' '+a[me][i][2]);
            }

            for (i=1; i <= 5; i++) {
                Server.ai_log('[his:' + (1-me) + '] ' + i + ' - '+ a[1-me][i][0]+' '+a[1-me][i][1]+' '+a[1-me][i][2]);
            }
        }

        public function occupied(index:int):Boolean {
            return (index >= 0) && (index < data.length) && data[index] >= 0;
        }

        public function availble_moves(): Array
        {
            var a:Array = new Array();
            var i:int, x:int;

            // for(var i:int = 0; i < data.length; i++)
            //    if(data[i] < 0) a.push(i);

            for(i = 0; i < data.length; i++)
            {
                if(data[i] >= 0)
                    continue;

                if( occupied(i-1) || occupied(i+1)
                 || occupied(i-size) || occupied(i+size)
                 || occupied(i-size-1) || occupied(i-size+1)
                 || occupied(i+size-1) || occupied(i+size+1) )
                    a.push(i);
            }

            // put in some randomness
            // also, makes sure there are any moves
            // for(i=0; i < 2; i++) {
            //    x = int(Math.random() * data.length);
            //    if(data[x] < 0)
            //        a.push(x);
            //}
            
            return a;
        }

        public function make_move(idx:int, player:int):BoardState
        {
            var b:BoardState = new BoardState();
            b.data = data.slice();
            b.size = size;

            b.data[idx] = player;
            return b;
        }

        public static function fromModel(b:BoardModel):BoardState
        {
            var state:BoardState = new BoardState();

            state.size = b._size;
            state.data = b._fields.slice();
            return state;
        }

        private static const BORDER:int = 100;
        private static const ITER_END:int = 1001;


        private function simple_end(row:int, idx:int):Boolean {
            return idx < data.length;
        }


        /* diagonal iterator */
        private function iterator(start:int, skip:int, advance:int,
            cont_cond:Function, row_end_cond:Function):Function
        {
            var row:int = 0;            

            return function():Function
            {
                if(! cont_cond(row, start) )
                    return null;

                var idx:int = start;
                var last:Boolean = false;
                var crow:int = row;

                // trace("Section #"+ row + " start=" + start);

                start += skip;
                row++;            

                return function():int
                {                    
                    if( row_end_cond(crow, idx) )
                    {
                        // trace("Item ("+(idx%size) + "," + int(idx/size) + "): " + data[idx]);
                        idx += advance;                        
                        return data[idx-advance];
                    }
                    else {
                        if(last) 
                            return ITER_END;
                        else {
                            last = true;
                            return BORDER;
                        }
                    }
               }
             }
        } /* end of iterator */
    } /* end of class */

        




} /* end of package */