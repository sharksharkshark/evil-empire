package evil.tiles 
{
	/**
	 * ...
	 * @author Nolen Tabner
	 */
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	// the draggable letter tiles
	public class Tile extends MovieClip
	{
		// sound refs
		private const spawnSound:SpawnSound = new SpawnSound();
		
		// the top-left starting position of the tile grid
		private static const tileStartingPosition:Point = new Point(79.95, 511.00);
		
		// the amount of space between each tile origin point
		private static const positionIncrement:Point = new Point(120, 125);
		
		// event type strings
		public static const TILE_GRABBED:String = "tileGrabbed";
		public static const TILE_DROPPED:String = "tileDropped";
		
		// store the position of the tile when it is at rest
		// used for snapping back when dropping a tile incorrectly
		public var originalPosition:Point = new Point();
		
		// this is a reference to an object already on the stage
		// this is also where you will retreive the letter value for this tile via .text
		public var textBox:TextField;
		
		// another object already on the stage
		// this is a visual indicator of dragging/selection of a tile
		public var highlight:MovieClip;
		
		public function Tile(x:Number, y:Number, newLetter:String) 
		{
			// assigning appropriate values and repositioning
			this.setOffsetPosition(x, y);
			this.letter = newLetter;
			this.scaleX = 0;
			this.scaleY = 0;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		// useful for debugging purposes, though nothing is unique
		override public function toString():String 
		{
			return "Tile: " + this.letter;
		}
		
		// wait until the tile has been added to the stage to do any intro animation
		private function onAddedToStage(event:Event):void
		{
			TweenLite.to(this, 0.5, { scaleX: 1, scaleY: 1, ease: BackOut.ease } );
			spawnSound.play();
			
			// cleaning up
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		// called when we press down on a tile
		private function onMouseDown(event:MouseEvent):void
		{
			// scale it up to look like we've 'picked up' the tile
			// could possibly benefit from a shadow or something if you wanted to get fancy
			TweenLite.to(this, 0.5, { scaleX: 1.1, scaleY: 1.1, ease: BackOut.ease} );
			
			// update visuals for dragging
			this.highlight.visible = true;
			
			this.startDrag(true);
			
			this.dispatchEvent(new MouseEvent(TILE_GRABBED));
		}
		
		// called when we release a tile
		private function onMouseUp(event:MouseEvent):void
		{
			// update visuals back to neutral
			this.highlight.visible = false;
			
			this.stopDrag();
			
			this.dispatchEvent(new MouseEvent(TILE_DROPPED));
		}
		
		// moves the tile back to its original position
		public function reset():void
		{
			TweenLite.to(this, 0.4, { x: this.originalPosition.x, y: this.originalPosition.y, scaleX: 1, scaleY: 1, ease: BackOut.ease } );			
		}
		
		// used for initializing the tile's position
		private function setOffsetPosition(x:Number, y:Number):void
		{
			this.x = tileStartingPosition.x + (x*positionIncrement.x);
			this.y = tileStartingPosition.y + (y * positionIncrement.y);
			
			this.originalPosition.x = this.x;
			this.originalPosition.y = this.y;
		}
		
		// effectively disables this tile from being dragged again
		public function lockToPoint(x:Number, y:Number):void
		{
			TweenLite.to(this, 0.5, { x: x, y: y, scaleX: 1, scaleY: 1, ease: BackOut.ease} );
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		// get/set for our letter textfield
		public function get letter():String
		{
			return this.textBox.text;
		}
		
		public function set letter(value:String):void
		{
			this.textBox.text = value;
		}
	}

}