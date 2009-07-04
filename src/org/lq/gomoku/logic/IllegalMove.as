package org.lq.gomoku.logic {

	public class IllegalMove extends Error {
		/* nothing interesting */	
		
		public function IllegalMove (str : String)
		{
			super(str);
		}
	}
}