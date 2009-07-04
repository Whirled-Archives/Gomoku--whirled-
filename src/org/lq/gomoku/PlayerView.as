package org.lq.gomoku {
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	import flash.filters.GlowFilter;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

    import com.threerings.flash.DisablingButton;

	import com.whirled.game.GameControl;
		
	import org.lq.gomoku.logic.PlayerModel;
	import org.lq.gomoku.logic.WhirledPlayer;

    import flash.events.MouseEvent;
	
	
	public class PlayerView extends Sprite {
		
		private var _plr : PlayerModel;
		private var _headshot : DisplayObject;		
		private var _label : TextField;		
		private var _bg : DisplayObject;

        private var _rmbutton : DisablingButton;
	
		private var _ctrl : GameControl;
	
		private static var _glow : GlowFilter = 
			new GlowFilter(0xf04040, 1.0, 8.0, 8.0, 2);
		
		public function PlayerView (ctrl:GameControl, plr : PlayerModel)
		{
			_ctrl = ctrl;
			_plr = plr;
			_plr.notify = function(m:PlayerModel):void { update(); };
						
			_bg = new MediaLibrary._playerView();
			_bg.x = 5;
			_bg.y = 5;
			addChild(_bg);
			
			_headshot = _plr.headshot(MediaLibrary) as DisplayObject;
			_headshot.x = 10;
			_headshot.y = 9;			
			addChild(_headshot);
			
			_label = new TextField();
			_label.text = (_plr.name == null ? "<absent>" : _plr.name);
			// _label.autoSize = TextFieldAutoSize.RIGHT;			
			_label.x = 5;
			_label.y = 82;
			_label.width = 90;
			_label.height = 20;
			_label.background = true;
			_label.backgroundColor = 0xafafff;
			addChild(_label);

            if(_plr.net_id == ctrl.game.getMyId())
            {

            _rmbutton = new DisablingButton(
                    new MediaLibrary._button_rematch_up,
                    new MediaLibrary._button_rematch_up,
                    new MediaLibrary._button_rematch_down,
                    new MediaLibrary._button_rematch_up,
                    new MediaLibrary._button_rematch_off );

            _rmbutton.x = 10;
            _rmbutton.y = 120;

            _rmbutton.width = 80;
            _rmbutton.height = 26;
            _rmbutton.addEventListener(MouseEvent.CLICK, 
                function(event:MouseEvent):void {
                  _rmbutton.enabled = false;
                  (_plr as WhirledPlayer).rematch();
                }
            );

            _rmbutton.enabled = false;
            addChild(_rmbutton);
            }
            else {
                _rmbutton = null;
            }
		}
		
		public function get model () : PlayerModel {
			return _plr;
		}
		
		public function reset() : void
		{
			_bg.filters = [];
            if(_rmbutton)
                _rmbutton.enabled = true;
		}
		
		public function update() : void
		{            
			if(_plr._active) {
				_bg.filters = [ new GlowFilter(0xf04040, 1.0, 8.0, 8.0, 2) ];
			}
			else {
				_bg.filters = [];
			}			
		}		
	}
}