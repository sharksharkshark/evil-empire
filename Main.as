package 
{
	/**
	 * ...
	 * @author Nolen Tabner
	 */
	
	import evil.CountdownTimer;
	import evil.EndCard;
	import evil.tiles.LetterDropTile;
	import evil.tiles.Tile;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.utils.*;
	import com.greensock.TweenLite;
	import com.greensock.easing.BackOut;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.ColorTransformPlugin;
	
	// our entry point into the application and also the game manager
	public class Main extends Sprite
	{
		// used for building our draggable letter tile pool
		private const ROWS:int = 4;
		private const COLS:int = 5;
		
		// the basic english alphabet
		private static const alphabet:Vector.<String> = new <String>[ "A", "B", "C", "D", "E", "F", "G",
																	  "H", "I", "J", "K", "L", "M", "N",
																	  "O", "P", "Q", "R", "S", "T", "U",
																	  "V", "W", "X", "Y", "Z" ];

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
		
		// the pool of letters used to populate our tiles
		private var letterPool:Vector.<String>;
		
		// the number of correctly guessed letters
		private var numCorrect:int;
		
		// this is an object on the stage
		public var countdown:CountdownTimer;
		
		// this will show our win/lose information
		private var endCard:EndCard;
		
		// first time user experience tracking
		private var isFTUE:Boolean;
		private var doinker:Doinker;
		
		// sound references
		private const clickPressSound:ClickPressSound = new ClickPressSound();
		private const clickReturnSound:ClickReturnSound = new ClickReturnSound();
		private const correctSound:CorrectSound = new CorrectSound();
		private const errorSound:ErrorSound = new ErrorSound();
		private const gameOverSound:GameOverSound = new GameOverSound();
		private const winSound:WinSound = new WinSound();
		
		// lazy singleton-esque setup
		public static var instance:Main;
		
		public function Main()
		{
			this.init();
		}
		
		// this should only be called once per run
		private function init():void
		{
			if(Main.instance == null)
			{
				Main.instance = this;
			}
			
			this.isFTUE = true;
			
			// initalize our color transform plugin for greensock
			TweenPlugin.activate([ColorTransformPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.
			
			this.clickReturnSound
			this.letterTiles = new Vector.<Tile>();
			
			this.dropTiles = new Vector.<LetterDropTile>();
			
			this.letterPool = new Vector.<String>();
			
			this.numCorrect = 0;
			
			// this is a dirty hack to add our existing drop tiles from the stage
			// into our list of available drop targets.
			var i:int;
			
			for (i = 1; i <= 10; i++)
			{
				var s:String = answerPhrase.charAt(i - 1);
				var dt:LetterDropTile = this["drop" + i];
				dt.targetLetter = s;
				this.dropTiles.push(dt);	
			}
			
			this.populateLetterPool();
			
			this.buildTileGrid();
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			
			this.countdown.addEventListener(CountdownTimer.COUNTDOWN_EXPIRED, this.onCountdownExpired);
			
			// start the countdown
			this.countdown.startTimer();
		}
		
		// this resets all applicable objects to the starting values
		private function ResetGame():void
		{
			this.numCorrect = 0;
			
			// delete all tiles
			while(this.letterTiles.length > 0)
			{
				var t:Tile = this.letterTiles.pop();
				t.removeEventListener(Tile.TILE_GRABBED, this.onTileGrabbed);
				t.removeEventListener(Tile.TILE_DROPPED, this.onTileDropped);
				this.removeChild(t);
			}
			
			// reset the countdown timer
			this.countdown.reset();
			
			// repopulate letterPool
			while (letterPool.length > 0)
			{
				letterPool.pop();
			}
			
			// kill the doinker if we have one
			if (this.doinker != null)
			{
				this.removeChild(this.doinker);
				this.doinker = null;
			}
			
			this.populateLetterPool();			
		}
		
		// adds our letter tiles to the stage
		private function buildTileGrid():void
		{
			// add new tiles, based on our row and column count
			var r:int = 0;
			var c:int = 0;
			var i:int = 0;
			
			for (r = 0; r < ROWS; r++)
			{
				for (c = 0; c < COLS; c++)
				{
					// populate the tile with a character from a 'random' list
					var t:Tile = new Tile(c, r, this.letterPool[i]);
					t.addEventListener(Tile.TILE_GRABBED, this.onTileGrabbed);
					t.addEventListener(Tile.TILE_DROPPED, this.onTileDropped);
					setTimeout( this.addTile, (0.1 * (c+r)) * 1000, t); 
					
					this.letterTiles.push(t);
					i++;
				}
			}
		}
		
		// fills up our list of possible letters
		private function populateLetterPool():void
		{
			var i:int;
			var len:int = answerPhrase.length-1;
			
			for (i = 0; i <= len; i++)
			{
				//add the required letters to the pool
				this.letterPool.push(answerPhrase.charAt(i));
			}
			
			var poolSize:int = ROWS * COLS;
			
			// fill up the rest of our letter pool
			while (this.letterPool.length < poolSize)
			{
				this.letterPool.push(this.getRandomLetter());
			}
			
			// now shuffle the letter pool
			this.letterPool.sort(this.randomSort);
		}
		
		// this is only really a function because we are using it as a callback for a timeout
		// solely because of animating in tiles
		private function addTile(tile:Tile):void
		{
			// sloppy FTUE setup
			// effectively gives the user a free space while showing them what to do with the letter tiles
			if (tile.letter == "E" && this.isFTUE == true && this.doinker == null)
			{
				// add a doinker since this is the first time in the program
				this.doinker = new Doinker();
				this.doinker.targetLetter = tile;
				this.doinker.x = tile.x;
				this.doinker.y = tile.y;
				this.doinker.mouseEnabled = false;
				
				// make sure the doinker is pointing at the target letter
				this.resetDoinker();
				this.addChild(this.doinker);
				
				// always ensure our doinker is above other UI elements
				this.setChildIndex(this.doinker, this.numChildren - 1);
			}
			
			this.addChild(tile);
			
			// this is needed for tiles other than the target letter
			if (this.doinker != null)
			{
				this.swapChildren(tile, this.doinker);
			}
		}
		
		// returns a random letter between a-z
		private function getRandomLetter():String
		{
			var index:int = Math.floor(Math.random() * 26);
			
			return (alphabet[index]);
		}
		
		// used when we 'randomize' our letter pool
		private function randomSort(a:String, b:String):Number
		{
			if (Math.random() < 0.5) return -1;
			else return 1;
		}
		
		// positions the doinker back to the target tile
		private function resetDoinker():void
		{
			if (this.doinker == null)
			{
				return;
			}
			
			var t:Tile = this.doinker.targetLetter;
			
			// animate back to the target position instead of snapping
			TweenLite.to(this.doinker, 0.3, { x: t.originalPosition.x, y: t.originalPosition.y, ease: BackOut.ease } );
		}
		
		// called when we've picked up a letter tile
		private function onTileGrabbed(event:MouseEvent):void
		{
			this.clickPressSound.play();
			
			var tile:Tile = event.currentTarget as Tile;
			
			// move our grabbed tile to be above all other elements on the stage
			this.setChildIndex(tile, this.numChildren -1);
			
			// update the doinker index if needed
			if (this.doinker != null)
			{
				this.setChildIndex(this.doinker, this.numChildren -1);
			}
			
			// update our tile reference
			this.currentTile = tile;
			
			// FTUE logic
			if (this.isFTUE == true && this.doinker != null)
			{
				if (tile == this.doinker.targetLetter)
				{
					var dt:LetterDropTile = this.dropTiles[0];
					TweenLite.to(this.doinker, 0.3, { x: dt.x, y: dt.y, ease: BackOut.ease } );
				}
			}
		}
		
		// called when we release a letter tile
		private function onTileDropped(event:MouseEvent):void
		{			
			// check if we have hit a drop target and move the tile to that position
			// otherwise, reset it back to the original position
			var tile:Tile = event.currentTarget as Tile;
			
			var isWrongTile:Boolean = false;
			
			// we currently are dragging a tile and are touching a drop tile
			if (this.currentDrop != null)
			{
				// we dropped it on a correct tile
				if (this.currentDrop.targetLetter == tile.letter)
				{
					// tell the tile to animate to the locked position
					tile.lockToPoint(currentDrop.x, currentDrop.y);
					
					// increase our 'score'
					this.numCorrect++;
					
					this.correctSound.play();
					
					Main.addParticle(currentDrop.x, currentDrop.y);
					
					// kill the FTUE now that we have at least one correct tile
					if (this.isFTUE == true)
					{
						this.isFTUE = false;
						
						if (this.doinker != null)
						{
							this.removeChild(this.doinker);
							this.doinker = null;
						}
					}
				}
				// we dropped it on a wrong tile
				else
				{
					// there is a bit of code reuse here and i'd love to refactor this logic
					// if this were a longer project, we would probably combine the two following
					// conditional cases somehow
					isWrongTile = true;
					tile.reset();
					this.clickReturnSound.play();
					this.resetDoinker();
				}
			}
			else
			{
				tile.reset();
				this.clickReturnSound.play();
				this.resetDoinker();
			}
			
			this.currentTile = null;
			
			// clean up hover states for drop targets
			if (this.currentDrop != null)
			{
				// make sure we alert the user to an incorrect guess
				if (isWrongTile == true)
				{
					this.currentDrop.DoError();
					this.errorSound.play();
				}
				else
				{
					this.currentDrop.ResetHover();
				}
				
				this.currentDrop = null;
			}
			
			// check if we have correctly guessed all required tiles
			if (this.numCorrect == answerPhrase.length)
			{
				// successful game over condition met
				this.countdown.stopTimer();
				this.showEnd(true);
			}
		}
		
		// as we move our mouse, update hovers for dragged tiles
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
		
		// called when the countdown reaches zero
		private function onCountdownExpired(event:Event):void 
		{
			for each(var t:Tile in this.letterTiles)
			{
				t.mouseEnabled = false;
			}
			
			// setup our endcard to show the game over screen
			this.showEnd(false);
		}
		
		// dirty particle creation. nothing fancy or impressive.
		// static so that we can call it from other classes, though
		// ideally we would put this in a particle manager type class
		public static function addParticle(x:Number, y:Number):void
		{
			var star:StarParticle = new StarParticle();
			star.x = x;
			star.y = y;
			
			var rot:Number = Math.floor(Math.random() *180);
			
			// 'randomly' flip our rotation the other direction
			if (Math.random() < 0.5)
			{
				rot *= -1;
			}
			
			star.rotation = rot;
			
			Main.instance.addChild(star);
		}
		
		// this adds our game over/success screen to the stage
		private function showEnd(didWin:Boolean):void
		{
			this.endCard = new EndCard(didWin);
			this.endCard.x = stage.stageWidth / 2;
			this.endCard.y = stage.stageHeight / 2;
			
			if (didWin == true)
			{
				// this should be stored in constants
				this.endCard.message = "well ain't that something.\rgood job.";
				this.winSound.play();
			}
			else
			{
				// this too should be a constant
				this.endCard.message = "too bad, so sad.";
				this.gameOverSound.play();
			}
			
			this.endCard.addEventListener(Event.COMPLETE, this.onEndCardComplete);
			this.endCard.addEventListener(Event.CLOSE, this.onEndCardClose);
			
			this.addChild(this.endCard);
		}
		
		// called when the end card has finished animating out
		private function onEndCardComplete(event:Event):void
		{
			// cleanup the endCard reference
			this.removeChild(this.endCard);
			this.endCard.removeEventListener(Event.COMPLETE, this.onEndCardComplete);
			this.endCard.removeEventListener(Event.CLOSE, this.onEndCardClose);
			this.endCard = null;

			// rebuild our letter tiles
			this.buildTileGrid();
			
			// restart the countdown timer
			this.countdown.startTimer();
		}
		
		// called when the end card starts its closing animation
		// currently caused by the play again button press
		private function onEndCardClose(event:Event):void
		{
			this.ResetGame();
		}
	}
}