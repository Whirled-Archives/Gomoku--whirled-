package org.lq.gomoku.logic {
	
import com.whirled.ServerObject;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.NetSubControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.loopback.LoopbackGameControl;

import com.whirled.net.MessageReceivedEvent;

import flash.events.Event;

import flash.geom.Point;

/**
 * The server agent for gomoku. Automatically created by the 
 * whirled server whenever a new game is started. 
 */
public class Server
{
	private var _players : Array;
	private var _board : BoardModel; 
	private var _current : PlayerModel;

	public static const PROP_BOARD : String = "PROP_BOARD";
    public static const MSG_PLAYER_IN : String = "MSG_NEW_PLAYER";
	public static const MSG_MOVE : String = "MSG_MOVE";
	public static const MSG_MOVE_ACK : String = "MSG_MOVE_ACK";
	
	private var state : int;
	
	private static const STATE_PREINIT :int = 0;
	private static const STATE_STARTING :int = 1;
	private static const STATE_STARTED :int = 2;
	private static const STATE_ENDED :int = 3;
	
    /**
     * Constructs a new server agent.
     */
    public function Server ()
    {    	
        _control = new GameControl( new ServerObject (), true);
        _control.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _control.game.addEventListener(StateChangedEvent.GAME_ENDED, gameEnded);
        _control.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);

        _control.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, occupantIn);
        _control.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantOut);

        _control.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        
        state = STATE_PREINIT;

        _players = new Array();
    }
    
    protected function gameStarted (event :StateChangedEvent) :void
    {
    	trace("Game started on server-side");

        var ai_player:* = new LoopbackGameControl(null, true, false);

        trace("Game started on server-side");

    	if(_board != null) {
    		/* clean-up the board first */
    		_board.unpublish();
    		_board = null;
    	}

    	/* initialize the board */
    	_board = BoardModel.newBoard(_control, 19, PROP_BOARD);
    	_board.fieldChanged = onBoardChanged;
    	_board.publish();    	
    	    	
    	_current = null;  	    	
    	
    	state = STATE_STARTING;
    	
    	/* Black always starts */    	
    	//_control.game.startNextTurn(_players[0].id);
    }
    
    protected function gameEnded (event :StateChangedEvent) :void
    {
    	trace("Game ended");
    	
    	/* flush the data */    	
    	_current = null;
    	_players = null;    	
    	
    	state = STATE_ENDED;
    }
    
    protected function turnChanged (event :StateChangedEvent) :void
    {      		
    	
    	if( (state != STATE_STARTING) && (state != STATE_STARTED) ) 
    	{
    		trace("Game not started yet - ignoring");
    		return;
    	}
    	_current = _players[ _control.game.seating.getPlayerPosition(
    			_control.game.getTurnHolderId()) ];
    	
    	trace("current player: " + _current.id + "(" 
    		+ _current.seat + ")");    	
	}
    
    protected function messageReceived (event :MessageReceivedEvent) :void
    {    	
    	if (event.senderId == NetSubControl.TO_SERVER_AGENT )
    		return;
    	
    	trace("Got message " + event.name + " from " + event.senderId);
    	
    	/*if(event.name == "I_WIN") {
    		var player : PlayerModel = _players[
    		           _control.game.seating.getPlayerPosition(event.senderId)];
    		var other : PlayerModel = _players[1 - player.seat];
    	
    		_control.game.endGameWithWinners( 
    				[player.id], [other.id], GameSubControl.WINNERS_TAKE_ALL );
    		return;    		
    	}*/
    	
    	if(event.name == Server.MSG_MOVE) {
    		
    		if(_current == null) 
    		{
    			trace("[WARNING] Got move, but turn not inialized yet");
    			return;
    		}
    		
    		/* validate move */
    		var plr : PlayerModel = _players[
    		    _control.game.seating.getPlayerPosition(event.senderId)];
    	
    		if(plr.id != _current.id) {
    			_control.net.sendMessage(MSG_MOVE_ACK,
    					false, event.senderId);
    			return;
    		}
    	
    		_board.placePieceAt(event.value as Point,_current);
    	}
    }
    
    private function onBoardChanged(p : Point, _old : int, _new :int) : void
    {
    	var _other : PlayerModel = _players[1 - _current.seat];
    	
    	/* check win condition */
    	if( checkFiveOrMore(p, _current) )
    	{    		  		
    		_control.game.endGameWithWinners( 
    				[_current.id], [_other.id], GameSubControl.WINNERS_TAKE_ALL );    	
    		return;
    	}   		
    	
    	_control.game.startNextTurn(_other.id);    	
    }
    
    private function checkFiveOrMore( p : Point, plr : PlayerModel) : Boolean 
    {    	
    	var axises : Array = [ new Point(1,0), new Point(0,1), new Point(1,1), new Point(-1, 1) ];
    
    	for each (var axis : Point in axises) {
    		var c : Point = new Point(p.x + axis.x, p.y + axis.y);
    		var len : int = 1;
    	
    		trace("Checking axis " + axis.x + ", " + axis.y);
    	
    		while( _board.isValid(c) ) {
    			trace("Piece is: " + _board.field(c));
    			
    			if( _board.field(c) != plr.boardMarker)
    				break;
    					
    			c.x += axis.x;
    			c.y += axis.y;
    			len++;
    		}
    		
    		c.x = p.x - axis.x;
    		c.y = p.y - axis.y;
    		
    		while( _board.isValid(c) ) {
    			trace("Piece is: " + _board.field(c));
    			
    			if( _board.field(c) != plr.boardMarker)
    				break;
    			
    			c.x -= axis.x;
    			c.y -= axis.y;
    			len++;
    		}  
    		
    		if(len >= 5) return true;
    	}    	
    	
    	return false;
    }

    private function occupantIn(event : OccupantChangedEvent): void
    {
        if(!event.player) {
            trace("Watcher entered: " + event.occupantId);
            return;
        }
       
        trace("Player entered: " + event.occupantId);
        var player : PlayerModel = new PlayerModel(_control, event.occupantId);

        _control.net.sendMessage(Server.MSG_PLAYER_IN, player.id);
    }

    private function occupantOut(event : OccupantChangedEvent): void
    {
        if(!event.player) {
            trace("Watcher left: " + event.occupantId);
            return;
        }

        trace("Player left: " + event.occupantId);
        _control.game.takeOverPlayer(event.occupantId);
    }

    protected var _control :GameControl;
}

}
