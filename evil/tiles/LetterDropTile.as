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
	
	public class LetterDropTile extends MovieClip
	{
		// we'll use these for visual changes based on user input
		private static const hoverColor:uint = 0xDAEAEF;
		private static const errorColor:uint = 0xFF3D2E;
		private static const baseColor:Color = new Color();
		
		private var _targetLetter:String;
		
		// reference to our ColorTransform object
		private var colorTransform;
		
		public function LetterDropTile() 
		{
			this.colorTransform = this.transform.colorTransform;
		}
		
		public function DoHover():void
		{
			TweenMax.to(this, 0.3, {colorTransform:{tint:hoverColor, tintAmount:1}});
		}
		
		public function DoError():void
		{
			TweenMax.to(this, 0.3, {colorTransform:{tint:errorColor, tintAmount:1}, repeat: 1, onComplete: this.ResetHover});
		}
		
		public function ResetHover():void
		{
			TweenMax.to(this, 0.3, {colorTransform:{tint:hoverColor, tintAmount:0}});
		}
		
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