package org.lq.gomoku.logic {
	
	import com.whirled.game.GameControl;

	public class PlayerModel {		
		public var id : int, seat :int, name : String;	
		public var boardMarker : int;
	
		public var active : Boolean;
		public var changeNotify : Function;
	
		public function PlayerModel(_ctrl : GameControl, 
                _id : int, _seat : int, _name : int)
        {
			id = _id;
            seat = _seat;
			name = _name;
		}
		
		public function setActive(flag : Boolean) : void {
			var last : Boolean = this.active;
				
			if(flag != last) { 
				this.active = flag;
				
				if( changeNotify != null) 
					changeNotify.call(changeNotify, flag);
			}
		}

	}
}