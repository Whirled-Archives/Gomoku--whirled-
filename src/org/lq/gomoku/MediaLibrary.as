
package org.lq.gomoku {

import mx.core.BitmapAsset;
import flash.display.Bitmap;
import com.whirled.game.GameControl;

public class MediaLibrary {
	
	private var _parent : GameControl;

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
	
	public function MediaLibrary(parent : GameControl) {
		_parent = parent;		
		
		imgWoodPattern = new _imgWoodPattern() as Bitmap;		
		imgWhitePiece = new _imgWhitePiece() as Bitmap;
		imgBlackPiece = new _imgBlackPiece() as Bitmap;		
	}	
	
}

}