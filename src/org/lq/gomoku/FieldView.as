package org.lq.gomoku {
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Bitmap;
	import flash.geom.Point;

    import flash.filters.GlowFilter;
	
	import flash.events.MouseEvent;
	import com.whirled.game.GameControl;
	
	import org.lq.gomoku.logic.BoardModel;	
	
	public class FieldView extends Sprite {
		
		private var _p : Point, _parent : GobanView;
	
		private var _model : BoardModel;
		private var _current : Bitmap;
        private var _lastValue : int;
	
		private var _hoverMode : Boolean, _highlightMode :Boolean;
		
		public function FieldView(parent: GobanView, x:int, y:int)
		{
			_parent = parent;
			_p = new Point(x, y);			
			
			_model = _parent.model;			
			
			_current = null;
			_hoverMode = false;
            _lastValue = -2;
			
			redraw();
		}
		
		public function setHover( state : Boolean) : void 
		{
			if(state != _hoverMode) {
				_hoverMode = state;
				redraw ();
			}			
		}
		
		public function redraw() : void
		{
			/* clear */
			graphics.clear();			
			
			var bitmap :Bitmap = null;			
			var value :int = _model.field(_p);

            if(_lastValue != value) {
                if(value == BoardModel.WHITE_PL)
                    bitmap = new _parent.media._imgWhitePiece();
			
                if(value == BoardModel.BLACK_PL)
                    bitmap = new _parent.media._imgBlackPiece();

                if(_current)
					removeChild(_current);						

                if(bitmap) 
					addChildAt(bitmap, 0);

                _current = bitmap;
            }

            if(_current)
                if(_highlightMode)
                    _current.filters =  [ new GlowFilter(0x3a3afa, 1.0, 6.0, 6.0, 3, 2, false, false) ];
                else 
                    _current.filters = [];	
			
			if(_hoverMode && _parent.enabled) {
				graphics.beginFill(0xff8080, 0.45);
				graphics.drawRect(0, 0, _parent.PIECE_W, _parent.PIECE_H);
				graphics.endFill();
			}
		}

        public function get hover():Boolean {
            return _hoverMode;
        }

        public function set hover(state : Boolean) : void 
		{
			if(state != _hoverMode) {
				_hoverMode = state;
				redraw ();
			}			
		}

        public function get highlight():Boolean {
            return _highlightMode;
        }

        public function set highlight(state : Boolean) : void 
		{
			if(state != _highlightMode) {
				_highlightMode = state;
				redraw ();
			}			
		}


	}
}