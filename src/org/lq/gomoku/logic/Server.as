package org.lq.gomoku.logic {
	
import com.whirled.ServerObject;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.NetSubControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.OccupantChangedEvent;

import org.lq.gomoku.ai.AIPlayer;

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
    private var _lastid : int = 0;
	private var _board : BoardModel;
    private var _bmodel : BoardGroupModel;

	private var _current : PlayerModel;
    private var _aiplayers : Array;
    
    private static const AI_DEPTH:Object = {'Normal': 1, 'Hard': 2};
    public static const AI_LOG:Boolean = false;

    private var _firstRun : Boolean = true;

	public static const PROP_BOARD : String = "PROP_BOARD";

    public static const PMSG_DATA : String = "PMSG_DATA";
    public static const PMSG_TURN : String = "PMSG_TURN";

    public static const MSG_MOVE : String = "MSG_MOVE";
    public static const MSG_MOVE_ACK : String = "MSG_MOVE";

    public static const MIN_PLAYER_FILL :int = 2;
	
	private var state : int;
	
	private static const STATE_PREINIT :int = 0;
	private static const STATE_STARTING :int = 1;
	private static const STATE_STARTED :int = 2;
	private static const STATE_ENDED :int = 3;

    private var _config : Object;
	
    /**
     * Constructs a new server agent.
     */
    public function Server ()
    {    	
        _control = new GameControl( new ServerObject (), false);
        _control.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _control.game.addEventListener(StateChangedEvent.GAME_ENDED, gameEnded);
        // _control.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);

        _control.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, occupantIn);
        _control.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantOut);

        _control.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        
        state = STATE_PREINIT;

        _config = _control.game.getConfig();

        // players in order of seating
        _players = new Array();
        _aiplayers = new Array();
    }

    private static function randomlyShuffle(a:Array):void 
    {
        var i:int;
        var b:Array = new Array();

        log('shuffling: ' + a);

        for(i=0; i < a.length; i++) {
            b[i] = int(Math.random()*a.length*2);
        }

        log('with: ' + b + ' l: ' + b.length );

        var t:int, tt:*;
        var s:Boolean = false;

        do
        {
            s = false;
            for(i=0; i < b.length-1; i++)
            {                
                if (b[i] > b[i+1])
                {             
                    t = b[i]; tt = a[i];
                    b[i] = b[i+1]; a[i] = a[i+1];
                    b[i+1] = t; a[i+1] = tt;
                    s = true;
                }
            }
       }
       while(s)

       log('shuffled: ' + b + ' | ' + a);
    }

    
    protected function gameStarted (event :StateChangedEvent) :void
    {
        log("Game started");

        if(_board != null)
        {
    		/* clean-up the board first */
    		_board.unpublish();
    		_board = null;
    	}

        
            /* initialize the board */
        _board = BoardModel.newBoard(_control, 
           (_config.boardSize ? _config.boardSize : 13), PROP_BOARD);

        _bmodel = new BoardGroupModel( (_config.boardSize ? _config.boardSize : 13) );
        log('Board:\n' + _bmodel);

        _board.fieldChanged = onBoardChanged;
        _board.publish();

        _current = null;
        
        if(_firstRun)
        {
            /* fill in missing spots */
            for(var i:int=_lastid; i < MIN_PLAYER_FILL; i++)
            {
                var p : PlayerModel = new AIPlayer(_lastid++,
                    _config.ailevel ? AI_DEPTH[_config.ailevel] : 2 );
                _players[p.game_id] = p;
                _aiplayers.push(p);
                log("Added AI player.");
            }

            _firstRun = false;
        }

        randomlyShuffle(_players);
   
        /* update ids */
        _players.forEach( function(p:PlayerModel, i:int, a:Array):void {
                p.game_id = i;
        } );

        /* send player info */
        var dataset :Array = new Array();
        _players.forEach( function(e:PlayerModel, i:int, a:Array):void {
                log("" + i + ": " + e.name)
                dataset.push( e.pickle() );
        });

        _control.net.sendMessage(PMSG_DATA, dataset);
        log('Player info sent.')
    	
    	state = STATE_STARTING;
        switchTurn(0);
    }


    protected function switchTurn(playerId : int): void
    {
        var o : Object = new Object();
        if(_current)
            o.old = _current.game_id
        else
            o.old = -1

        _current = _players[playerId];
        o.next = _current.game_id;

        _current.active(true);
        _control.net.sendMessage(PMSG_TURN, o);
    }
    
    protected function gameEnded (event :StateChangedEvent) :void
    {
    	trace("Game ended. Winner: " + _current.name);

        for each(var p:PlayerModel in _players )
        {
            if(! (p is AIPlayer) )
                updatePrivateData(p, (p == _current));
        }
    	
    	/* flush the data */    	
    	_current = null;
    	//_players = null;
    	
    	state = STATE_ENDED;
    }
    
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        log("Got message " + event.name + " from " + event.senderId);

        if (event.name.substr(0, 5) == "PMSG_")
        {
            _aiplayers.forEach( function(ai:AIPlayer, i:int, a:Array):void
            {
                ai.playerMessage(event.name, event.value,
                    {'control': _control, 'board': _board, 'bmodel': _bmodel} );
            });

            return;
        }
    	
    	if(event.name == Server.MSG_MOVE) 
        {
    		
    		if(_current == null) 
    		{
    			log("[WARNING] Got move, but turn not inialized yet");
    			return;
    		}
    		
    		if( (event.senderId != _current.net_id)
             || (event.value.player_id != _current.game_id) )
            {
                _control.net.sendMessage(MSG_MOVE_ACK,
    				{'player_id': event.value.player_id, 'result': false},
                    event.senderId);
                return;
            }

            log("" + _current.name + "'s move: (" + (event.value.point.x+1) +','+ (event.value.point.y+1) + ')');    	
    		_board.placePieceAt(event.value.point as Point, _current);
    	}
    }

    private function otherPlayersIds(p :PlayerModel = null) : Array
    {
        return _players.
            filter( function(o:*,i:int,a:Array):Boolean
                { return (o == p) && (o != NetSubControl.TO_SERVER_AGENT); } ).
            map( function(o:*,i:int,a:Array):int
                { return o.net_id; } );
    }

    private function allPlayersIds() : Array
    {
        return _players.
            filter( function(o:*,i:int,a:Array):Boolean
                { return o != NetSubControl.TO_SERVER_AGENT; } ).
            map( function(o:*,i:int,a:Array):int
                { return o.net_id; } );
    }

    private function nextPlayerId() : int
    {
        return (_current.game_id + 1) % _players.length;
    }
    
    private function onBoardChanged(p : Point, _old : int, _new :int) : void
    {
        _bmodel.putPiece(p.x+1, p.y+1, _new);
        log('Board: \n' + _bmodel);

    	/* check win condition */
    	if( checkFiveOrMore(p, _current) )
    	{
            if(_current.net_id == NetSubControl.TO_SERVER_AGENT)
            { // ai player won
                _control.game.endGameWithWinners([], allPlayersIds(),
                    GameSubControl.WINNERS_TAKE_ALL );
            }
            else {
                _control.game.endGameWithWinners([_current.net_id], otherPlayersIds(_current),
                    GameSubControl.WINNERS_TAKE_ALL );
            }
    		return;
    	}   		
    	
    	switchTurn( nextPlayerId() );
    }
    
    private function checkFiveOrMore( p : Point, plr : PlayerModel) : Boolean 
    {    	
    	var axises : Array = [ new Point(1,0), new Point(0,1), new Point(1,1), new Point(-1, 1) ];
    
    	for each (var axis : Point in axises) {
    		var c : Point = new Point(p.x + axis.x, p.y + axis.y);
    		var len : int = 1;
    	
    		// trace("Checking axis " + axis.x + ", " + axis.y);
    	
    		while( _board.isValid(c) ) {
    			// trace("Piece is: " + _board.field(c));
    			
    			if( _board.field(c) != plr.game_id)
    				break;
    					
    			c.x += axis.x;
    			c.y += axis.y;
    			len++;
    		}
    		
    		c.x = p.x - axis.x;
    		c.y = p.y - axis.y;
    		
    		while( _board.isValid(c) ) {
    			// trace("Piece is: " + _board.field(c));
    			
    			if( _board.field(c) != plr.game_id)
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
        var player : PlayerModel = 
            new WhirledPlayer(_control, event.occupantId, _lastid++);

        _players[player.game_id] = player;
    }

    private function occupantOut(event : OccupantChangedEvent): void
    {
        if(!event.player) {
            trace("Watcher left: " + event.occupantId);
            return;
        }

        trace("Player left: " + event.occupantId);
        _control.game.endGameWithWinners( allPlayersIds().filter(
            function(id:int, i:int, a:Array):Boolean { return (id  != event.occupantId) }),
            [event.occupantId], GameSubControl.WINNERS_TAKE_ALL ); 
    }

    private static const TROPHY_DEFAULTS:Object = {
            'games_played': 0,
            'wins_black': 0,
            'wins_white': 0,
            'mp_games_played': 0, 'mp_wins': 0
    }


    private function updatePrivateData(p:PlayerModel, win:Boolean):void
    {
        _control.player.getCookie( function (cookie :Object, pid:int):void
        {
            if(cookie == null)
                cookie = new Object();

            // fix the defaults
            for(var key:String in TROPHY_DEFAULTS) {                
                cookie[key] = (cookie[key] ? cookie[key] : TROPHY_DEFAULTS[key]);
            }

            log(p.name + "'s cookie:");
            for(key in cookie) {
                log(key + ': ' + cookie[key]);
            }

            cookie.games_played += 1;

            if(win && (p.game_id == BoardModel.BLACK_PL))
                cookie.wins_black += 1;

            if(win && (p.game_id == BoardModel.WHITE_PL))
                cookie.wins_white += 1;

            if(_aiplayers.length == 0) {
                cookie.mp_games_played += 1;
                if(win) cookie.mp_wins += 1;
            }

            _control.player.setCookie(cookie, p.net_id);
            awardTrophiesToPlayer(p, cookie);
        }, p.net_id );
    }

    private function awardTrophiesToPlayer(p:PlayerModel, cookie:Object):void
    {
        if(cookie.games_played > 100)
            _control.player.awardTrophy('sensei_trophy_1', p.net_id);

        if(cookie.wins_white > 50)
            _control.player.awardTrophy('yang_wins', p.net_id);

        if(cookie.wins_black > 50)
            _control.player.awardTrophy('yin_wins', p.net_id);

        if(cookie.mp_wins >= 25)
            _control.player.awardTrophy('multi_wins_25', p.net_id);
    }

    public static function ai_log(txt : String) : void {
        if(Server.AI_LOG)
            trace("[ai] " + txt);
    }

    public static function log(txt : String) : void {
        trace("[server] " + txt);
    }

    public static function profile_log(txt : String) : void {
        trace("[profiler] " + txt);
    }

    protected var _control :GameControl;
}

}
