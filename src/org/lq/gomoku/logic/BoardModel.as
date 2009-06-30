package org.lq.gomoku.logic {
	
	import flash.geom.Point;
	import com.whirled.game.GameControl;
	import com.whirled.net.ElementChangedEvent;

	public class BoardModel {
	
		private var _size : int;		
		private var _fields : Array;		
		private var _ctrl : GameControl;
	
		private var _prop : String;
		
		public static const EMPTY : int = -1;
		public static const WHITE_PL : int = 1;
		public static const BLACK_PL : int = 2;		
		public static const MARKERS : Array = [ BLACK_PL, WHITE_PL ];
		
		public var fieldChanged : Function;
		
		public function BoardModel() {	
		}
		
		public static function newBoardFromProp(ctrl : GameControl, prop : String,
				value : Array = null ): BoardModel
		{
			var b : BoardModel = new BoardModel();
		
			b._ctrl = ctrl;		
			b._prop = prop;
			b.fieldChanged = null;			
			
			if(value == null)
				b._fields = ctrl.net.get(b._prop);
			else 
				b._fields = value;
			
			b._size = int(Math.sqrt(b._fields.length));
			
			if( (b._size * b._size) !=  b._fields.length)
				b._ctrl.local.feedback("[Warning #1001] not a square array");
			
			b._ctrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, 
					b._changed);
			
			return b;
		}
			
		public static function newBoard(ctrl : GameControl, 
				size : int, prop : String): BoardModel
		{		
			var b : BoardModel = new BoardModel();
		
			b._ctrl = ctrl;		
			b._prop = prop;
			b.fieldChanged = null;
						
			if(size < 3)
				throw Error("Invalid board size");
				
			b._fields = new Array(size * size);
			b._size = size;
			
			for ( var i:int = 0; i < b._size*b._size; i++) {
				b._fields[i] = EMPTY;				
			}
			
			return b;
		}				
		
		public function publish() : void
		{
			_ctrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, _changed);
			_ctrl.net.set(_prop, _fields);			
		}
		
		public function unpublish() : void 
		{
			_ctrl.net.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, _changed);
			_ctrl.net.set(_prop, null);	
		}
		
		public function get size() :int {
			return _size;
		}
		
		public function field(p : Point):int {
			return _fields[int(p.y) * _size + int(p.x)];
		}
		
		private function _nonlocalMark(p : Point, v :int) :void 
		{
			_fields[int(p.y) * _size + int(p.x)] = v;
			_ctrl.net.setAt(_prop, p.y * _size + p.x, v);			
		}		
		
		private function _changed( event : ElementChangedEvent ) : void {
			if(event.name != _prop)
				return;
			
			/* we don't need to update it by hand */
			var p : Point = new Point( int(event.index % _size), 
					int(event.index / _size) );
			
			/* _ctrl.local.feedback("LOCAL update of point :" + p + " value is " 
					+ event.newValue + " was " + event.oldValue + "\n" ); */
			
			if(fieldChanged != null)
				fieldChanged.call(fieldChanged, p, event.oldValue, 
						event.newValue);
		}
		
		public function placePieceAt(p : Point, pl : PlayerModel) : void 
		{			
			/* validate game rules */
			if( field(p) != EMPTY )
				throw new IllegalMove("Piece already exists");
			
			if(!_ctrl.game.amServerAgent()) {				
				_ctrl.net.agent.sendMessage(Server.MSG_MOVE, p);				
			}	
			else {
				this._nonlocalMark(p, pl.boardMarker);				
			}						
		}
		
		public function isValid( p : Point ) : Boolean 
		{
			// trace("Checking field " + p.x + ", " + p.y);			
			return ((p.x >= 0) && (p.y >= 0) && (p.x < _size) && (p.y < _size));
		}
	}	
}	