package org.lq.gomoku {
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	import flash.filters.GlowFilter;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	import com.whirled.game.GameControl;
		
	import org.lq.gomoku.logic.PlayerModel;
	
	
	public class PlayerView extends Sprite {
		
		private var _plr : PlayerModel;
		private var _headshot : DisplayObject;		
		private var _label : TextField;		
		private var _bg : DisplayObject;
	
		private var _ctrl : GameControl;
	
		private static var _glow : GlowFilter = 
			new GlowFilter(0xf04040, 1.0, 8.0, 8.0, 2);
		
		public function PlayerView (ctrl:GameControl, plr : PlayerModel)
		{
			_ctrl = ctrl;
			_plr = plr;
			_plr.changeNotify = _onChange;
						
			_bg = new MediaLibrary._playerView();
			_bg.x = 5;
			_bg.y = 5;
			addChild(_bg);
			
			_headshot = _ctrl.local.getHeadShot(_plr.id);
			_headshot.x = 10;
			_headshot.y = 9;			
			addChild(_headshot);
			
			_label = new TextField();
			_label.text = (_plr.name == null ? "<absent>" : _plr.name);
			// _label.autoSize = TextFieldAutoSize.RIGHT;			
			_label.x = 5;
			_label.y = 80;
			_label.width = 90;
			_label.height = 20;
			_label.background = true;
			_label.backgroundColor = 0xafafff;
			addChild(_label);
		}
		
		public function get model () : PlayerModel {
			return _plr;
		}
		
		public function reset() : void
		{
			_bg.filters = [];
		}
		
		public function _onChange( isActive : Boolean ) : void 
		{					
			if(isActive) {				
				_bg.filters = [ _glow ];
			}
			else {
				_bg.filters = [];
			}			
		}		
	}
}