package evil 
{
	/**
	 * ...
	 * @author Nolen Tabner
	 */
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.greensock.TweenLite;
	
	public class EndCard extends MovieClip
	{
		// this is a textfield already on the stage
		public var messageTextBox:TextField;
		
		// this is also already on the stage
		public var playAgainButton:MovieClip;
		
		public function EndCard() 
		{
			this.playAgainButton.addEventListener(MouseEvent.MOUSE_UP, onPlayMouseUp);
			this.playAgainButton.addEventListener(MouseEvent.MOUSE_DOWN, onPlayMouseDown);
			this.playAgainButton.addEventListener(MouseEvent.MOUSE_OUT, onPlayMouseOut);
		}
		
		public function get message():String
		{
			return this.messageTextBox.text;
		}
		
		public function set message(value:String):void
		{
			this.messageTextBox.text = value;
		}
		
		private function onPlayMouseUp(event:MouseEvent):void
		{
			TweenLite.to(this.playAgainButton, 0.3, { scaleX: 1, scaleY: 1 } );
			
			this.dispatchEvent(new Event(Event.CLOSE));
			
			// another quick/dirty flash hack
			// this will eventually trigger a frame script that dispatches a COMPLETE event
			this.play();
		}
		
		private function onPlayMouseDown(event:MouseEvent):void
		{
			TweenLite.to(this.playAgainButton, 0.3, {scaleX: 1.2, scaleY: 1.2});

		}
		
		private function onPlayMouseOut(event:MouseEvent):void
		{
			TweenLite.to(this.playAgainButton, 0.3, {scaleX: 1, scaleY: 1});
		}
	}

}