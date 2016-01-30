package 
{
	/**
	 * ...
	 * @author Nolen Tabner
	 */
	
	import evil.tiles.Tile;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.*;
	
	// our entry point into the application and also the game manager
	
	public class Main extends Sprite
	{
		// used for building our draggable letter tile pool
		private const ROWS:int = 4;
		private const COLS:int = 5;
		
		// this tracks our letter tiles
		private var letterTiles:Vector.<Tile>;
		
		
		public function Main()
		{
			this.letterTiles = new Vector.<Tile>();
			
			var r:int = 0;
			var c:int = 0;
			var i:int = 0;
			
			for (r = 0; r < ROWS; r++)
			{
				for (c = 0; c < COLS; c++)
				{
					var t:Tile = new Tile(c, r, "X");
					t.addEventListener(Tile.TILE_GRABBED, this.onTileGrabbed);
					t.addEventListener(Tile.TILE_DROPPED, this.onTileDropped);
					setTimeout( this.addTile, (0.1 * (c+r)) * 1000, t); 
					i++;
					
					this.letterTiles.push(t);
				}
			}
		}
		
		private function addTile(tile:Tile):void
		{
			this.addChild(tile);
		}
		
		private function onTileGrabbed(event:Event):void
		{
			var tile:Tile = event.currentTarget as Tile;
			
			// move our grabbed tile to be above all other elements on the stage
			this.setChildIndex(tile, this.numChildren -1);
		}
		
		private function onTileDropped(event:Event):void
		{
			// TODO: check if we have hit a drop target and move the tile to that position
			// otherwise, reset it back to the original position like we are currently doing
			var tile:Tile = event.currentTarget as Tile;
			
			tile.reset();
		}
	}
}