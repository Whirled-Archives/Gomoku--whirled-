//
// Gomoku - a game for Whirled

package org.lq.gomoku {

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import flash.geom.Point;

import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import org.lq.gomoku.logic.Server;
import org.lq.gomoku.logic.BoardModel;
import org.lq.gomoku.logic.PlayerModel;
import org.lq.gomoku.logic.IllegalMove;

[SWF(width="700", height="500")]
public class Gomoku extends Sprite
{ 
	protected var _ctrl :GameControl;
	private var _media : MediaLibrary;
	private var _board : BoardModel;
	private var _boardView : GobanView;
	private var _players : Array;
	private var _me : PlayerModel;

	private var _seatOne : PlayerView, _seatTwo : PlayerView;
	
    public function Gomoku ()
    {    	 
        /* listen for an unload event */
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);        

        _ctrl = new GameControl(this);
                
        _ctrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);        
        _ctrl.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_ENDED, gameEnded);

        _ctrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);           
        
        _media = new MediaLibrary(_ctrl);
        _players = new Array();
        
        with(graphics) 
        {
        	beginFill(0x202020);
        	drawRect(0, 0, 350, 500);
        	endFill();
        	
        	beginFill(0xf0f0f0);
        	drawRect(350, 0, 700, 500);
        	endFill();
        }
        
        if(! _ctrl.isConnected() )
        {
        	var logo : Bitmap = new MediaLibrary._logo();
        	logo.x = (700 - logo.width)/2;
        	logo.y = (500 - logo.height)/2;
        	addChild(logo);
        	return;
        }     
        
        // _ctrl.local.feedback("Waiting for game to start");  
    }

    /**
     * This is called when your game is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME
    	// _ctrl.game.removeEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _ctrl.game.removeEventListener(StateChangedEvent.GAME_ENDED, gameEnded);
        _ctrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
    }
    
    private function gameStarted(event : StateChangedEvent) : void
    {
    	_ctrl.local.feedback("The game has started.");    	
    	// _ctrl.local.feedback("Controller: " + _ctrl.game.getControllerId() + "\n");
    	// _ctrl.local.feedback("Turn holder: " + _ctrl.game.getTurnHolderId() + "\n");
    	    	    	
    	if(_seatOne == null) {
    		_seatOne = new PlayerView(_ctrl, _players[0]);
    		_seatOne.x = 8;
    		_seatOne.y = 50;
    		addChild(_seatOne);
    	}    	
        
    	if(_seatTwo == null) {
    		_seatTwo = new PlayerView(_ctrl, _players[1]);
    		_seatTwo.x = 592; /* 700 - 8 - 100 */
    		_seatTwo.y = 50;
    		addChild(_seatTwo);
    	}    	
    } 
    
    private function gameEnded(event : StateChangedEvent) : void
    {
    	_ctrl.local.feedback("Game is over\n");   
    	
    	_seatOne.reset();
    	_seatTwo.reset();
    }
    
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
    	_ctrl.local.feedback("Got message from server: " + event.name + " value: "
    			+ event.value );

        if(event.name == Server.MSG_PLAYER_IN)
        {
            _players[event.value.seat] = event.value;
            _ctrl.game.playerReady();
            return;
        }
            
    }
    	
   	protected function propertyChanged (event :PropertyChangedEvent) :void
   	{
    	if (event.name == Server.PROP_BOARD) 
    	{
    		if(event.newValue == null)
    		{
    			/* board has been cleared */
    			removeChild(_boardView);
    			_board = null;
    			_boardView = null;
    			return;
    		}
    		
    		/* New model has been set */
    		_board = BoardModel.newBoardFromProp(_ctrl, Server.PROP_BOARD, 
    				event.newValue as Array); 
    		
        	_boardView = new GobanView(_ctrl, _media, _board);
        	_boardView.setMoveListener( makeMove );
        	_boardView.x = 114;
        	_boardView.y = 10;
        	_boardView.enabled = false;        	
        	addChild(_boardView);
    	}
    }    
   	
   	private function makeMove( model : BoardModel, point : Point) : void
   	{
   		try {   			
   			_board.placePieceAt(point, _me);
   		} catch(e : IllegalMove) {
   			return;
   		}
   	}   
    
    protected function turnChanged (event :StateChangedEvent) :void
	{   
    	var th : int = _ctrl.game.getTurnHolderId();
        // _ctrl.local.feedback( "New turn holder: " +  th + "\n");
        
        if(th == 0)
        	return;
                        
        for each(var p :PlayerModel in _players) {
        	// _ctrl.local.feedback( "Setting " + p.id + " to " + (p.id == th) + "\n");               	
        	p.setActive( (p.id == th) );
        }
        	
        if(_boardView != null)
        	_boardView.enabled = (th == _me.id);		
	}
    
    public function get whirled () : GameControl
	{
		return _ctrl;
	}    
} /* end of class */

} /* end of package */
