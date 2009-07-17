package org.lq.gomoku.logic {

    /*
        Board model for Gomoku game. Pieces are stored in groups.
    */
    public class BoardGroupModel
    {
        /* all pieces */
        public var pieces:Array;
        public var board_size:int;

        /* piece groups */
        public var groups :Array;

        public static const C_NONE :int = -1;
		public static const C_BLACK :int = 0;
        public static const C_WHITE :int = 1;
        public static const C_BORDER :int = 9;

        private static var EMPTY_PIECE :Piece = new Piece(-1,-1,C_NONE);
        private static var BORDER_PIECE :Piece = new Piece(-1,-1,C_BORDER);

        public function BoardGroupModel(size:int)
        {
            var x:int, y:int;

            board_size = size;
            pieces = [];

            /* top border */
            pieces[0] = [];
            for(x=0; x < size+2; x++)
                    pieces[0][x] = BORDER_PIECE;

            for(y=1; y < size+1; y++)
            {
                pieces[y] = [];

                pieces[y][0] = BORDER_PIECE;
                for(x=1; x < size+1; x++)
                    pieces[y][x] = EMPTY_PIECE;
                pieces[y][size+1] = BORDER_PIECE;
            }

            pieces[size+1] = [];
            for(x=0; x < size+2; x++)
                    pieces[size+1][x] = BORDER_PIECE;
            
            groups = [];
        }

        public function toString():String
        {
            var x:int, y:int, s:String='';
            var chars :Array = [];
            chars[C_NONE] = '.';
            chars[C_BLACK] = 'X';
            chars[C_WHITE] = 'O';
            chars[C_BORDER] = '#';

            for(y=0; y < board_size+2; y++)
            {
                for(x=0; x < board_size+2; x++)
                    s += chars[pieces[y][x].color];
                s += '\n';
            }

            return s;
        }

        public function removePieceIdx(i:int):void {
            removePiece( i%board_size + 1, int(i/board_size) + 1 );
        }

        public function removePiece(x:int, y:int):void
        {
            if(x < 1 || x > board_size || y < 1 || y > board_size)
                throw new Error('Coordinates out of board bounds.');

            if( pieces[y][x] == C_NONE)
                throw new Error("Can't remove from an empty field.");

            var g:PieceGroup, h:PieceGroup;

            for(var i:int=0; i < 4; i++)
            {
                g = pieces[y][x].group[i];              

                // print_groups('Before split with: ' + pieces[y][x]);
                h = g.split(pieces[y][x]);
                // print_groups('After split.');

                if(g.length == 0)
                    remove_group(g);
                
                if(h.length > 0) {
                    // trace('Adding group: ' + h);
                    groups.push(h);
                }

            }

            pieces[y][x] = EMPTY_PIECE;
        }

        private function remove_group(g:PieceGroup):void
        {
            // trace('Removing group: ' +  g);
            // print_groups('Before remove.');
            for(var i:int=0; i < groups.length ; i++)
                if(groups[i] == g) {
                    groups.splice(i, 1);
                    // print_groups('After remove.');
                    return;
                }

             throw new Error('No group found: ' + g);
        }

        /* private function join_groups(a:PieceGroup, b:PieceGroup):void
        {
            trace('Joining ' + a + ' with: ' + b);
            print_groups('Before join.');
            a.join(b);
            print_groups('After join.');
        } */

        public function putPieceIdx(i:int, color:int):Piece
        {
            return putPiece( i%board_size +1, int(i/board_size) +1, color );
        }

        public function putPiece(x:int, y:int, color:int):Piece
        {
            if(color != C_BLACK && color != C_WHITE)
                throw new Error('Can only put colored pieces on the board.');

            if(x < 1 || x > board_size || y < 1 || y > board_size)
                throw new Error('Coordinates out of board bounds.');

            if( pieces[y][x].color != C_NONE )
                throw new Error('Field not empty.');
            
            // put the piece
            var piece:Piece = pieces[y][x] = new Piece(x, y, color);            

            // horizontal
            if( pieces[y][x-1].color == piece.color )
            {
                pieces[y][x-1].group[PieceGroup.T_LR].add(piece);
                if( pieces[y][x+1].color == piece.color ) {
                    remove_group(pieces[y][x+1].group[PieceGroup.T_LR]);
                    pieces[y][x-1].group[PieceGroup.T_LR].join(pieces[y][x+1].group[PieceGroup.T_LR]);                    
                }
            } else if( pieces[y][x+1].color == piece.color ) {
                pieces[y][x+1].group[PieceGroup.T_LR].add(piece);
            } else {     
                groups.push( new PieceGroup(PieceGroup.T_LR, [piece]) );
            }

            // vertical
            if( pieces[y-1][x].color == piece.color )
            {
                pieces[y-1][x].group[PieceGroup.T_TD].add(piece);
                if( pieces[y+1][x].color == piece.color ) {
                    remove_group(pieces[y+1][x].group[PieceGroup.T_TD]);
                    pieces[y-1][x].group[PieceGroup.T_TD].join(pieces[y+1][x].group[PieceGroup.T_TD]);                    
                }
            } else if( pieces[y+1][x].color == piece.color ) {
                pieces[y+1][x].group[PieceGroup.T_TD].add(piece);
            } else {
                groups.push( new PieceGroup(PieceGroup.T_TD, [piece]) );
            }

            // top-to-right
            if( pieces[y-1][x-1].color == piece.color )
            {
                pieces[y-1][x-1].group[PieceGroup.T_TR].add(piece);
                if( pieces[y+1][x+1].color == piece.color ) {
                    remove_group(pieces[y+1][x+1].group[PieceGroup.T_TR]);
                    pieces[y-1][x-1].group[PieceGroup.T_TR].join(pieces[y+1][x+1].group[PieceGroup.T_TR]);                    
                }
            } else if( pieces[y+1][x+1].color == piece.color ) {
                pieces[y+1][x+1].group[PieceGroup.T_TR].add(piece);
            } else {
                groups.push( new PieceGroup(PieceGroup.T_TR, [piece]) );
            }

            // top-to-left
            if( pieces[y-1][x+1].color == piece.color )
            {
                pieces[y-1][x+1].group[PieceGroup.T_TL].add(piece);
                if( pieces[y+1][x-1].color == piece.color ) {
                    remove_group(pieces[y+1][x-1].group[PieceGroup.T_TL]);
                    pieces[y-1][x+1].group[PieceGroup.T_TL].join(pieces[y+1][x-1].group[PieceGroup.T_TL]);                    
                }
            } else if( pieces[y+1][x-1].color == piece.color ) {
                pieces[y+1][x-1].group[PieceGroup.T_TL].add(piece);
            } else {
                groups.push( new PieceGroup(PieceGroup.T_TL, [piece]) );
            }

            // Server.log('After put: ');
            // for each(var g:PieceGroup in groups)
            //    Server.log('' + g);
            return piece;
         }

        public function availble_moves(): Array
        {
            var a:Array = [], y:int, x:int;           

            for( y=1; y <= board_size; y++)
                for(x=1; x <= board_size; x++)
                {                    
                    if( (pieces[y][x].color < 0) && hasNeighbour(x,y) )
                        a.push([x,y]);
                }

            for(var i:int=0; i < 5; i++)
            {
                x = int(Math.random() * board_size) + 1;
                y = int(Math.random() * board_size) + 1;
                // Server.log("added random move: " + x + "," + y);
            
                if(pieces[y][x].color < 0 )
                    a.push([x,y]);
            }                

             return a;
        }

        private function hasNeighbour(x:int, y:int):Boolean
        {            
            return ((pieces[y][x+1].color == C_BLACK) || (pieces[y][x+1].color == C_WHITE))
                || ((pieces[y][x-1].color == C_BLACK) || pieces[y][x-1].color == C_WHITE)
                || (pieces[y+1][x].color == C_BLACK || pieces[y+1][x].color == C_WHITE)
                || (pieces[y-1][x].color == C_BLACK || pieces[y-1][x].color == C_WHITE)
                || (pieces[y+1][x+1].color == C_BLACK || pieces[y+1][x+1].color == C_WHITE)
                || (pieces[y+1][x-1].color == C_BLACK || pieces[y+1][x-1].color == C_WHITE)
                || (pieces[y-1][x+1].color == C_BLACK || pieces[y-1][x+1].color == C_WHITE)
                || (pieces[y-1][x-1].color == C_BLACK || pieces[y-1][x-1].color == C_WHITE);
        }

    } // end of class
} // end of package