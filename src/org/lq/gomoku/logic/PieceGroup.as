package org.lq.gomoku.logic {

    public class PieceGroup
    {        
        private var pieces :Array;
        private var _length :int;

        public var type :int;

        private var min_x :int, max_x :int, min_y :int, max_y :int;

        public static const T_LR:int = 0;
        public static const T_TD:int = 1;
        public static const T_TR:int = 2;
        public static const T_TL:int = 3;

        public function PieceGroup(type:int, pieces:Array = null)
        {            
            this.type = type;
            this.pieces = [];
            this._length = 0;

            max_x = max_y = 0;
            min_x = min_y = 100;

            if(pieces != null)
                for each(var p:Piece in pieces) this.add(p);
        }

        public function add(p :Piece):void
        {
            pieces[_length++] = p;
            p.group[type] = this;

            if(p.x > max_x) max_x = p.x;
            if(p.x < min_x) min_x = p.x;
            if(p.y > max_y) max_y = p.y;
            if(p.y < min_y) min_y = p.y;
        }

        public function join(group :PieceGroup):void
        {           
            for(var i:int; i < group._length; i++)
                this.add(group.pieces[i]);
        }

        public function split(p:Piece):PieceGroup
        {
            var r:PieceGroup = new PieceGroup(type);
            var l:Array = pieces, i:int;            

            max_x = max_y = 0;
            min_x = min_y = 100;
            pieces = [];
            _length = 0;

            for(i=0; i < l.length; i++)
            {                                
                if( l[i] == p )
                    continue;

                if( (l[i].y < p.y) || ((l[i].y == p.y) && (l[i].x < p.x)) )
                    this.add(l[i]);
                else
                    r.add(l[i]);
            }

            return r;
        }

        public function next(b:BoardGroupModel):Piece
        {
            switch(type) {
                case T_LR:
                    return b.pieces[max_y][max_x+1];
                case T_TD:
                    return b.pieces[max_y+1][max_x];
                case T_TR:
                    return b.pieces[max_y+1][max_x+1];
                case T_TL:
                    return b.pieces[max_y+1][min_x-1];
            }

            throw new Error('Wrong group type.');
        }

        public function previous(b:BoardGroupModel):Piece
        {
            switch(type) {
                case T_LR:
                    return b.pieces[min_y][min_x-1];
                case T_TD:
                    return b.pieces[min_y-1][min_x];
                case T_TR:
                    return b.pieces[min_y-1][min_x-1];
                case T_TL:
                    return b.pieces[min_y-1][max_x+1];
            }

            throw new Error('Wrong group type.');
        }

        public function toString():String
        {
            var s:String;;
            s = '[' + type + ', ' + _length + ': ';
            for(var i:int=0; i < _length; i++)
                s += pieces[i]
            s += ']';
            return s;
        }

        public function get length():int { return _length; }
        public function get color():int { return pieces[0].color; }

    } // end of class

}