package evil 
{
	/**
	 * ...
	 * @author Nolen Tabner
	 */
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import com.greensock.TweenLite;
	import flash.utils.Timer;

	// the game over/win screen shown after the game completes
	public class EndCard extends MovieClip
	{
		// this is a textfield already on the stage
		public var messageTextBox:TextField;
		
		// this is also already on the stage
		public var playAgainButton:MovieClip;
		
		// track if this was a winning game
		private var didWin:Boolean;
		
		// internal timer used for dumb particle effects
		private var particleTimer:Timer;
		
		public function EndCard(win:Boolean) 
		{
			this.didWin = win;
			this.playAgainButton.addEventListener(MouseEvent.MOUSE_UP, onPlayMouseUp);
			this.playAgainButton.addEventListener(MouseEvent.MOUSE_DOWN, onPlayMouseDown);
			this.playAgainButton.addEventListener(MouseEvent.MOUSE_OUT, onPlayMouseOut);
			this.addEventListener(Event.OPEN, this.onOpened);
		}
		
		// get/set for our message textfield
		public function get message():String
		{
			return this.messageTextBox.text;
		}
		
		public function set message(value:String):void
		{
			this.messageTextBox.text = value;
		}
		
		// called when we release up on the 'play again' button
		private function onPlayMouseUp(event:MouseEvent):void
		{
			TweenLite.to(this.playAgainButton, 0.3, { scaleX: 1, scaleY: 1 } );
			
			this.dispatchEvent(new Event(Event.CLOSE));
			
			// cleanup
			this.playAgainButton.removeEventListener(MouseEvent.MOUSE_UP, onPlayMouseUp);
			this.playAgainButton.removeEventListener(MouseEvent.MOUSE_DOWN, onPlayMouseDown);
			this.playAgainButton.removeEventListener(MouseEvent.MOUSE_OUT, onPlayMouseOut);
			
			if (this.particleTimer != null)
			{
				this.particleTimer.stop();
				this.particleTimer.removeEventListener(TimerEvent.TIMER, this.onParticleTime);
				this.particleTimer = null;
			}
			
			// another quick/dirty flash hack
			// this will eventually trigger a frame script that dispatches a COMPLETE event
			this.play();
		}
		
		// called when we press down on the 'play again' button
		private function onPlayMouseDown(event:MouseEvent):void
		{
			TweenLite.to(this.playAgainButton, 0.3, {scaleX: 1.2, scaleY: 1.2});
		}
		
		// edge-case when dragging out from the 'play again' button
		private function onPlayMouseOut(event:MouseEvent):void
		{
			TweenLite.to(this.playAgainButton, 0.3, {scaleX: 1, scaleY: 1});
		}
		
		// called for every 'tick' of the particle timer
		private function onParticleTime(event:TimerEvent):void
		{
			// adds a particle at a random location on the stage
			var randX:Number = Math.random() * stage.stageWidth;
			var randY:Number = Math.random() * stage.stageHeight;
			Main.addParticle(randX, randY);
		}
		
		// this is also triggered from a frame script
		private function onOpened(event:Event):void
		{
			// we need some 'fanfare' if we won
			// i will admit this is very weak
			if (this.didWin == true)
			{
				this.particleTimer = new Timer(500);
				this.particleTimer.addEventListener(TimerEvent.TIMER, this.onParticleTime);
				this.particleTimer.start();
			}
		}
	}

}