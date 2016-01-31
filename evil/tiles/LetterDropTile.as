package evil.tiles 
{
	/**
	 * ...
	 * @author Nolen Tabner
	 */
	
	import fl.motion.Color;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.utils.*;
	import com.greensock.TweenMax;
	
	// the drop targets for our draggable tiles
	public class LetterDropTile extends MovieClip
	{
		// we'll use these for visual changes based on user input
		private static const hoverColor:uint = 0xDAEAEF;
		private static const errorColor:uint = 0xFF3D2E;
		private static const baseColor:Color = new Color();
		
		// the letter this drop target considers to be 'correct'
		private var _targetLetter:String;
		
		// reference to our ColorTransform object
		private var colorTransform;
		
		public function LetterDropTile() 
		{
			this.colorTransform = this.transform.colorTransform;
		}
		
		// visual updates when a tile has hovered over us
		public function DoHover():void
		{
			TweenMax.to(this, 0.3, {colorTransform:{tint:hoverColor, tintAmount:1}});
		}
		
		// visual updates when the wrong tile was dropped on us
		public function DoError():void
		{
			TweenMax.to(this, 0.3, {colorTransform:{tint:errorColor, tintAmount:1}, repeat: 1, onComplete: this.ResetHover});
		}
		
		// resets us back to our original tint
		public function ResetHover():void
		{
			TweenMax.to(this, 0.3, {colorTransform:{tint:hoverColor, tintAmount:0}});
		}
		
		
		// get/set for the 'correct' letter
		public function get targetLetter():String
		{
			return this._targetLetter;
		}
		
		public function set targetLetter(value:String):void
		{
			this._targetLetter = value;
		}
	}

}