package org.lq.gomoku.logic {

    import com.whirled.game.GameControl;

    public class WhirledPlayer
        extends PlayerModel
    {
        private var game_ctrl : GameControl;

        public var whirled_seat : int;

        public function WhirledPlayer(_ctrl : GameControl, _id : int, _gameid : int)
        {
            super( _ctrl.game.getOccupantName(_id), _id, _gameid );
            game_ctrl = _ctrl;
		}

        public override function pickle() : Object {
            var d : Object = super.pickle();
            d.klass = "whirled";
            d.whirled_seat = whirled_seat;
            return d;
        }

        public override function headshot(library: Object) : Object
        {
            return game_ctrl.local.getHeadShot(net_id);
        }

    }

}