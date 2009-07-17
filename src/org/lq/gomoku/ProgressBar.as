package org.lq.gomoku {

	import flash.display.Sprite;

    public class ProgressBar extends Sprite {

        private var fill : Number = 0.0;
        private var _width :int, _height :int;


        public function reset():void {
            this.fill = 0.0;
            _redraw();
        }

        private function _redraw():void {
            with(graphics) {
                clear();
                beginFill(0x000000);
                drawRect(0, 0, this._width, this._height);
                endFill();

                beginFill(0xe8e8e8);
                drawRect(1, 1, this._width-2, this._height-2);
                endFill();

                beginFill(0x48f848);
                drawRect(1, 1, int((this._width-2)*this.fill), this._height-2);
                endFill();
            }
        }

        public override function set width(value:Number):void {
            _width = value;
            _redraw();
            super.width = value;            
        }

        public override function set height(value:Number):void {
            _height = value;
            _redraw();
            super.height = value;            
        }

        public function get progress():Number {
            return this.fill;
        }

        public function set progress(value:Number):void {
            if( value < 0.0 || value > 1.0 )
                throw new Error("Progress must me a value from 0.0 to 1.0");
            this.fill = value;
            this._redraw();
        }

    }

}