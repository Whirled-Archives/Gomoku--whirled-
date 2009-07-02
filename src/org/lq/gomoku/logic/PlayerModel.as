package org.lq.gomoku.logic {

	import com.whirled.game.GameControl;

	public class PlayerModel {
        public var net_id : int;
        public var name : String;

        /* game internal id */
        public var game_id : int;
        public var _active : Boolean;
        public var notify : Function = null;
	
		public function PlayerModel(_name : String, _netid : int, _gameid : int)
        {
			net_id = _netid;
            name = _name;
            game_id = _gameid
		}

        public virtual function pickle() : Object {
            var d : Object = new Object();
            d.net_id = net_id;
            d.name = name;
            d.game_id = game_id;

            return d;
        }

        public static function unpickle(_ctrl :GameControl, o : Object) : PlayerModel
        {
            var p : PlayerModel;

            if(o.klass == "ai") {
                p = new AIPlayer(o.game_id);
            }
            else if(o.klass == "whirled") {
                p = new WhirledPlayer(_ctrl, o.net_id, o.game_id);
            }
            else
                throw new Error("Wrong player pickle klass:" + o.klass);

            return p;
        }

        public function headshot(library: Object): Object {
            throw new Error("Not implemented");
        }

        public function active(next : Boolean): void
        {
            var last : Boolean = _active;
            _active = next;

            if( (last != _active) && (this.notify != null))
                this.notify(this);
        }

	}
}