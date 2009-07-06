package org.lq.gomoku {
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Bitmap;
	import flash.geom.Point;
	
	import flash.events.MouseEvent;
	import com.whirled.game.GameControl;
	
	import org.lq.gomoku.logic.BoardModel;	
	
	public class FieldView extends Sprite {
		
		private var _p : Point, _parent : GobanView;
	
		private var _model : BoardModel;
		private var _current : Bitmap;
	
		private var _hoverMode : Boolean;
		
		public function FieldView(parent: GobanView, x:int, y:int)
		{
			_parent = parent;
			_p = new Point(x, y);			
			
			_model = _parent.model;			
			
			_current = null;
			_hoverMode = false;
			
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
			
			var bitmap : Bitmap = null;			
			var type : int = _model.field(_p);
			
			if(type == BoardModel.WHITE_PL)
				bitmap = new _parent.media._imgWhitePiece();
			
			if( type == BoardModel.BLACK_PL)
				bitmap = new _parent.media._imgBlackPiece();
			
			if( _current != bitmap ) {
				if(_current)
					removeChild(_current);						
				
				if(bitmap) 
					addChildAt(bitmap, 0)
					
				_current = bitmap;
			}			
			
			if(_hoverMode && _parent.enabled) {
				graphics.beginFill(0xff8080, 0.45);
				graphics.drawRect(0, 0, _parent.PIECE_W, _parent.PIECE_H);
				graphics.endFill();
			}
		}
	}
}