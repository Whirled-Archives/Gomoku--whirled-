package org.lq.gomoku.logic {

    public class HumanPlayer extends PlayerModel
    {
        public function HumanPlayer(_ctrl : GameControl, _id : int)
        {
            super(_ctrl, _id, 
                _ctrl.game.seating.getPlayerPosition(_id),
                _ctrl.game.getOccupantName(_id) );
		}
    }

}