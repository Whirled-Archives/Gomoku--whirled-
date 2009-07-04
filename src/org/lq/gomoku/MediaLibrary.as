
package org.lq.gomoku {

import mx.core.BitmapAsset;
import flash.display.Bitmap;
import com.whirled.game.GameControl;

public class MediaLibrary {
	
	private var _parent : GameControl;

    [Embed(source="rematch_up.png")]
	public static var _button_rematch_up : Class;

    [Embed(source="rematch_down.png")]
	public static var _button_rematch_down : Class;

    [Embed(source="rematch_off.png")]
	public static var _button_rematch_off : Class;

    [Embed(source="gomokunarabe.png")]
	public static var _decor_image : Class;

	[Embed(source="wood.png")]	
	public var _imgWoodPattern : Class;
	public var imgWoodPattern : Bitmap;
	
	[Embed(source="white.png")]
	public var _imgWhitePiece : Class;
	public var imgWhitePiece : Bitmap;
	
	[Embed(source="black.png")]
	public var _imgBlackPiece : Class;
	public var imgBlackPiece : Bitmap;
	
	[Embed(source="playerview.png")]
	public static var _playerView : Class;	
	
	[Embed(source="logo.jpeg")]
	public static var _logo : Class;

    [Embed(source="aiplayer_headshot.png")]
    public static var _headshot : Class;
	
	public function MediaLibrary(parent : GameControl) {
		_parent = parent;		
		
		imgWoodPattern = new _imgWoodPattern() as Bitmap;		
		imgWhitePiece = new _imgWhitePiece() as Bitmap;
		imgBlackPiece = new _imgBlackPiece() as Bitmap;
	}	
	
}

}