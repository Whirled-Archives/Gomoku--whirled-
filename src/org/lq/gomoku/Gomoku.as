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
	private var _me : PlayerModel = null;

	private var _seatOne : PlayerView, _seatTwo : PlayerView;
	
    public function Gomoku ()
    {    	 
        /* listen for an unload event */
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);        

        _ctrl = new GameControl(this);
                
        _ctrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);        
        // _ctrl.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_ENDED, gameEnded);

        _ctrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);           
        
        _media = new MediaLibrary(_ctrl);
        
        with(graphics) 
        {
        	beginFill(0x202020);
        	drawRect(0, 0, 350, 500);
        	endFill();
        	
        	beginFill(0xf0f0f0);
        	drawRect(350, 0, 350, 500);
        	endFill();
        }

        var img:Bitmap = new MediaLibrary._decor_image();

        img.x = 620;
        img.y = 280;
        addChild(img);

        
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
    	log("The game has started.");
    }

    private function setUpViews() : void
    {
        if(_seatOne != null) {
            removeChild(_seatOne);
        }

        if(_seatTwo != null) {
            removeChild(_seatTwo);
        }
         
    	_seatOne = new PlayerView(_ctrl, _players[0]);
    	_seatOne.x = 15;
    	_seatOne.y = 50;
    	    	
    	_seatTwo = new PlayerView(_ctrl, _players[1]);
    	_seatTwo.x = 585; // 700 - 8 - 100
    	_seatTwo.y = 50;

        addChild(_seatOne);
    	addChild(_seatTwo);    	
    }
    
    private function gameEnded(event : StateChangedEvent) : void
    {
    	log("Game over.");
    	
    	_seatOne.reset();
    	_seatTwo.reset();
    }
    
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
    	/* _ctrl.local.feedback("Got message from server: " + event.name + " value: "
    			+ event.value + "\n"); */

        if(event.name == Server.PMSG_DATA)
        {
            var _pp:Array = event.value as Array;
            _players = new Array();

            _pp.forEach( function(obj:Object, i:int, a:Array):void {
                var player :PlayerModel = PlayerModel.unpickle(_ctrl, obj);
                _players[player.game_id] = player;

                if(player.net_id == _ctrl.game.getMyId())
                    _me = player;
            });



            if(_me == null)
                throw new Error("ID mismatch");

            this.setUpViews();
            return;
        }
        else if(event.name == Server.PMSG_TURN)
        {
            turnChanged(event.value);
            return;
        }
            
    }
    	
   	protected function propertyChanged (event :PropertyChangedEvent) :void
   	{
    	if (event.name == Server.PROP_BOARD) 
    	{
            //log('Board changed');
    		if(event.newValue == null)
    		{
                //log('Board reset');
    			/* board has been cleared */
    			removeChild(_boardView);
    			_board = null;
    			_boardView = null;
    			return;
    		}

            //log('Creating new board');
    		
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
            _boardView.enabled = true;
   			return;
   		}
   	}   
    
    protected function turnChanged (event: Object) :void
	{   
        //log("New turn holder: " +  event.next);
        
        for each(var p :PlayerModel in _players)
        {
        	//log( "Setting " + p.name + " to " + (p.game_id == event.next) + "\n");
        	p.active( (p.game_id == event.next) );
        }
        	
        if(_boardView != null)
        	_boardView.enabled = (event.next == _me.game_id);
	}
    
    public function get whirled () : GameControl
	{
		return _ctrl;
	}

    public function log(txt : String) : void {
        _ctrl.local.feedback("" + txt + '\n');
    }
} /* end of class */

} /* end of package */
