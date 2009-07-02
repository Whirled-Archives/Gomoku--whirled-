package org.lq.gomoku.ai
{

    import org.lq.gomoku.logic.BoardModel;

    public class BoardState
    {
        public var data:Array;
        public var size:int;

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
          s += (gcount[me][5][0] + gcount[me][5][1] + gcount[me][5][2])
                * (-2000);
          if(s < 0) return s;

          // instant lose
          s += (gcount[1-me][5][0] + gcount[1-me][5][1] + gcount[1-me][5][2])
                * 2000;
          s += gcount[1-me][4][2] * 2000;
          s += gcount[1-me][4][1] * 500;
          if(s > 0) return s;

          // sure win
          s += (gcount[me][4][2]) * (-1000);
          
          s += gcount[1-me][3][2] * 100;
          s += gcount[1-me][2][2] * 5;
          s += gcount[1-me][1][2] * 2;

          var dist_sum:Number = 0;

          for(var x:Number=0; x < data.length; x += 1)
          {
            if(data[x] == me)
                dist_sum += (x-data.length/2)*(x-data.length/2);
          }

          print_counts(gcount, me);
          trace('DS: ' + (s + (dist_sum/100000)) );

          return (s + (dist_sum/100000));
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

        private static function print_counts(a:Array, me:int):void
        {
            var i:int;

            for (i=1; i <= 5; i++) {
                trace('[my:' + me + '] ' + i + ' - '+ a[me][i][0]+' '+a[me][i][1]+' '+a[me][i][2]);
            }

            for (i=1; i <= 5; i++) {
                trace('[his:' + (1-me) + '] ' + i + ' - '+ a[1-me][i][0]+' '+a[1-me][i][1]+' '+a[1-me][i][2]);
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
            for(i=0; i < 3; i++) {
                x = int(Math.random() * data.length);
                if(data[x] < 0)
                    a.push(x);
            }
            
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