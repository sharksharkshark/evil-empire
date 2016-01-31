package evil 
{
	/**
	 * ...
	 * @author Nolen Tabner
	 */
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	// visually counts down from a value and alerts when complete
	public class CountdownTimer extends MovieClip
	{
		// event type string
		public static const COUNTDOWN_EXPIRED:String = "countdownExpired";
		
		// our max time
		public var maxTime:int = 60;
		
		// reference to an object on the stage
		public var textBox:TextField;
		
		// the internal timer object we will use for counting
		private var timer:Timer;
		
		// the remaining time in seconds
		private var timeRemaining:int;
		
		public function CountdownTimer() 
		{
			// this could be made much more dynamic
			this.timeRemaining = this.maxTime;
			
			// one tick every second
			this.timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, this.onTime);
		}
		
		// called for every 'tick' of our timer
		public function onTime(event:TimerEvent):void
		{
			// make sure the textfield is showing the appropriate values
			this.updateText();
			
			// counting down
			timeRemaining--;
			
			// we've run out of time, let anyone listening know about it
			if (timeRemaining < 0)
			{
				this.timer.stop();
				this.dispatchEvent(new Event(COUNTDOWN_EXPIRED));
			}
		}
		
		// format our single numbers into double digit style
		private function formatDigit(digit:int):String
		{
			var dig:String = digit.toString();
			
			if (digit < 10)
			{
				return "0" + dig;
			}
			else
			{
				return dig;
			}
		}
		
		// public accessor method
		public function startTimer():void
		{
			timer.start();
		}
		
		// public accessor method
		public function stopTimer():void
		{
			timer.stop();
		}
		
		// resets the countdown back to the maximum
		public function reset():void
		{
			this.timeRemaining = this.maxTime;
			this.updateText();
		}
		
		// visually updates our textfield on the stage
		private function updateText():void
		{
			var minutes:int = timeRemaining / 60;
			var seconds:int = timeRemaining % 60;
			
			this.textBox.text = (minutes + ":" + this.formatDigit(seconds));
		}
	}

}