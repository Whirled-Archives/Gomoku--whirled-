package org.lq.gomoku.logic {

    public class Piece {
        public var x :int;
        public var y :int;

        public var color :int;

        /* vertical group the piece belongs to */
        public var group :Array = [null, null, null, null];

        public function Piece(_x:int, _y:int, _color:int = -1)
        {
            x = _x;
            y = _y;
            color = _color;
        }

        public function toString():String
        {
            return '(' + color + ': ' + x + ',' + y + ')';
        }
    }

}