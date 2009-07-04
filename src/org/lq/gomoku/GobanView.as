package org.lq.gomoku {
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	
	import flash.geom.Point;
	
	import flash.events.MouseEvent;
	import com.whirled.game.GameControl;
	
	import org.lq.gomoku.logic.BoardModel;
		
	public class GobanView extends Sprite 
	{				
		private var _media : MediaLibrary;		
		private var _border : int; 
	
		private static const SPACING : int = 1;
		private static const MAX_SIZE : int = 19;
		
		private var _model : BoardModel;
		private var _ctrl : GameControl;
	
		private var _width :int,_height :int;
		private var _piece_w :int,_piece_h : int, _piece_w2:int, _piece_h2:int;
		private var _hover : FieldView;		
		
		private var _enabled : Boolean;
		
		private var _subviews : Array;
		private var _listener : Function;
		
		public function GobanView(gctrl : GameControl, 
				media : MediaLibrary, model : BoardModel ) 
		{			
			_ctrl = gctrl;
			_media = media;			
			_model = model;
			
			if (_model.size > MAX_SIZE)
				throw new Error("Model size too large for this display");
			
			_model.fieldChanged = onFieldChanged;
			
			_subviews = new Array();
			
			mouseChildren = false;
			opaqueBackground = 0x000000;
			
			var fv : FieldView;
			
			resize();
			_redraw();
			
			for(var j:int = 0; j < _model.size; j++)
			{
				for(var i:int = 0; i < _model.size; i++)
				{
					fv = new FieldView(this, i, j);					
					fv.x = _border + i * (_piece_w+SPACING);
					fv.y = _border + j * (_piece_h+SPACING);					
					_subviews.push(fv);
					addChild(fv);
				}
			}
			
			_listener = null;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}		
			
		private function resize () : void
		{	
			_hover = null;
			
			_piece_w = _media.imgWhitePiece.bitmapData.width;
			_piece_w2 = int(_piece_w/2);
			_piece_h = _media.imgWhitePiece.bitmapData.height;
			_piece_h2 = int(_piece_h/2);
						
			_width = (_model.size) * (_piece_w+SPACING);
			_height = (_model.size) * (_piece_h+SPACING);
			
			/* border */
			_border = (MAX_SIZE - _model.size) * (_piece_w+SPACING) / 2;			
		}	
		
		
		public function _redraw() :void 
		{						
			with(graphics) 
			{			
				beginBitmapFill(_media.imgWoodPattern.bitmapData);		
				drawRect(_border,_border,_width,_height);
				endFill();
				lineStyle(SPACING, 0);
				
				for(var idx:int = 0; idx < _model.size; idx++) 
				{
					moveTo(_border+_piece_w2,
						_border + _piece_h2 + (_piece_h+SPACING)*idx);
					lineTo(_border+_width-_piece_w2, 
						_border + _piece_h2 + (_piece_h+SPACING)*idx);					
					moveTo(_border + _piece_w2 + (_piece_w+SPACING)*idx, 
						_border + _piece_h2);
					lineTo(_border + _piece_w2 + (_piece_w+SPACING)*idx, 
						_border + _height - _piece_h2);
				}				
			}
		}
		
		public function modelFromView(x:int, y:int) : Point 
		{
			var q : Point = new Point( 
				int( (x - _border)/(_piece_w+SPACING) ),
				int( (y - _border)/(_piece_h+SPACING) ) );
			
			if(q.x < 0 || q.x >= _model.size ||
					q.y < 0 || q.y >= _model.size)
				return null;
			
			return q;
		}
		
		public function modelFromViewPoint(p : Point) : Point 
		{
			return modelFromView(p.x, p.y);
		}
		
		public function onMouseOut(event : MouseEvent) : void
		{
			if(_hover) {
				_hover.setHover(false);
				_hover = null;
			}
		}				
		
		public function onMouseClick( event : MouseEvent) : void 
		{
			if(!_enabled)
				return;
			
			/* _ctrl.local.feedback("Mouse click " 
					+ event.localX + " , " + event.localY); */
			
			var p : Point = modelFromView(event.localX, event.localY);
						
			// try to make the move
			if(_listener != null)
				_listener.call(_listener, _model, p);
		}
		
		public function onMouseMove( event : MouseEvent) : void 
		{
			var p : Point = modelFromView(event.localX, event.localY);						
			var active : FieldView = null;
		
			/* _ctrl.local.feedback("Point :" + p) */
			
			if( p != null )
				active = _subviews[p.y*_model.size+p.x];
			
			if(active == _hover) 
				return;		
			
			if(_hover)
				_hover.setHover(false);
			
			if(active)
				active.setHover(true);
			
			_hover = active;						
			event.updateAfterEvent();			
		}
		
		public function onFieldChanged( p : Point, oV : int, nV : int): void 
		{
			//_ctrl.local.feedback("point :" + p + " value is " + nV
			//		+ " was " + oV );			
			
			_subviews[p.y*_model.size+p.x].redraw();
		}
		
		public function setMoveListener(callback : Function) : void {
			_listener = callback;
		}		
		
		public function get media () : MediaLibrary
		{
			return _media;
		}
		
		public function get model () : BoardModel
		{
			return _model;
		}		
		
		public function get whirled () : GameControl
		{
			return _ctrl;
		}
		
		public function get PIECE_W () : int
		{
			return _piece_w;
		}
		
		public function get PIECE_H () : int
		{
			return _piece_h;
		}	
		
		public function get maxWidth () : int
		{
			return _width + 2*_border;
		}
		
		public function get maxHeight () : int
		{
			return _height + 2*_border;
		}
		
		public function get enabled () : Boolean
		{
			return _enabled;
		}
		
		public function set enabled (value : Boolean) : void
		{
			_enabled = value;
		}			
	}
}