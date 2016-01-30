package evil 
{
	/**
	 * ...
	 * @author Nolen Tabner
	 */
	
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public class CountdownTimer extends MovieClip
	{
		// reference to an object on the stage
		public var textBox:TextField;
		
		private var timer:Timer;
		
		// the remaining time in seconds
		private var timeRemaining:int;
		
		public function CountdownTimer() 
		{
			this.timeRemaining = 60;
			this.timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, this.onTime);
			timer.start();
		}
		
		public function onTime(event:TimerEvent):void
		{
			var minutes:int = timeRemaining / 60;
			var seconds:int = timeRemaining % 60;
			
			this.textBox.text = (minutes + ":" + this.formatDigit(seconds));
			
			timeRemaining--;
			
			if (timeRemaining < 0)
			{
				this.timer.stop();
				trace("TIME'S UP. YOU LOSE");
			}
		}
		
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
		
		public function reset():void
		{
			this.timeRemaining = 60;
			this.timer.start();
		}
	}

}