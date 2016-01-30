package 
{
	/**
	 * ...
	 * @author Nolen Tabner
	 */
	
	import evil.tiles.LetterDropTile;
	import evil.tiles.Tile;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.*;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.ColorTransformPlugin;
	
	// our entry point into the application and also the game manager
	
	public class Main extends Sprite
	{
		// used for building our draggable letter tile pool
		private const ROWS:int = 4;
		private const COLS:int = 5;
		
		// this tracks our letter tiles
		private var letterTiles:Vector.<Tile>;
		
		// this tracks our drop targets
		// this could be reworked to be completely dynamic
		// but given the scope of this exercise, i'm pulling from the stage
		private var dropTiles:Vector.<LetterDropTile>;
		
		// the currently grabbed tile
		private var currentTile:Tile;
		
		// the currently hovered drop target
		private var currentDrop:LetterDropTile;
		
		// this could be made into something much more dynamic as well
		private const answerPhrase:String = "EVILEMPIRE"
		
		private var letterPool:Vector.<String>;
		
		public function Main()
		{
			// initalize our color transform plugin for greensock
			TweenPlugin.activate([ColorTransformPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

			this.letterTiles = new Vector.<Tile>();
			
			this.dropTiles = new Vector.<LetterDropTile>();
			
			// this is a dirty hack to add our existing drop tiles from the stage
			// into our list of available drop targets.
			var i:int;

			for (i = 1; i <= 10; i++)
			{
				var dt:LetterDropTile = this["drop" + i];
				dt.targetLetter = answerPhrase.charAt(i - 1);
				this.dropTiles.push(dt);
			}
			
			// add new tiles, based on our row and column count
			var r:int = 0;
			var c:int = 0;
			
			for (r = 0; r < ROWS; r++)
			{
				for (c = 0; c < COLS; c++)
				{
					// TODO: populate the tile with a character from a 'random' list
					var t:Tile = new Tile(c, r, "E");
					t.addEventListener(Tile.TILE_GRABBED, this.onTileGrabbed);
					t.addEventListener(Tile.TILE_DROPPED, this.onTileDropped);
					setTimeout( this.addTile, (0.1 * (c+r)) * 1000, t); 
					
					this.letterTiles.push(t);
				}
			}
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function addTile(tile:Tile):void
		{
			this.addChild(tile);
		}
		
		private function onTileGrabbed(event:MouseEvent):void
		{
			var tile:Tile = event.currentTarget as Tile;
			
			// move our grabbed tile to be above all other elements on the stage
			this.setChildIndex(tile, this.numChildren -1);
			
			this.currentTile = tile;
		}
		
		private function onTileDropped(event:MouseEvent):void
		{
			// check if we have hit a drop target and move the tile to that position
			// otherwise, reset it back to the original position
			var tile:Tile = event.currentTarget as Tile;

			// we currently are dragging a tile and are touching a drop tile
			if (this.currentDrop != null && this.currentDrop.targetLetter == tile.letter)
			{
				tile.lockToPoint(currentDrop.x, currentDrop.y);
			}
			else
			{
				tile.reset();
			}
			
			this.currentTile = null;
			
			this.currentDrop.ResetHover();
			this.currentDrop = null;
		}
		
		
		private function onMouseMove(event:MouseEvent):void
		{
			if (this.currentTile != null)
			{				
				var p:Point = new Point(event.stageX, event.stageY);
				
				var hovered:uint = 0;
				
				for each(var dt:LetterDropTile in this.dropTiles)
				{
					// we currently are dragging a tile and are touching a drop tile
					if (dt.hitTestPoint(p.x, p.y) == true)
					{
						dt.DoHover();
						this.currentDrop = dt;
						hovered++;
					}
					else
					{
						dt.ResetHover();
					}
				}
				
				if (hovered == 0)
				{
					this.currentDrop = null;
				}
			}
		}
	}
}