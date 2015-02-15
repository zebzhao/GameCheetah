/**
 * Copyright (c) 2015 Zeb Zhao
 * 
 * This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 */
package gamecheetah.gameutils 
{
	/**
	 * Default tween functions used for the 'ease' parameter in Entity::tweenClip method.
	 * Code adapted from 'https://code.google.com/p/tweensy/wiki/TweensyZero'
	 */
	public class Easing 
	{
		
		public static function backEaseIn(t:Number, d:Number, b:Number=0, c:Number=1, s:Number = 0):Number
		{
			if (!s)
				s = 1.70158;
			
			return c * (t /= d) * t * ((s + 1) * t - s) + b;
		}
		
		public static function backEaseOut(t:Number, d:Number, b:Number=0, c:Number=1, s:Number = 0):Number
		{
			if (!s)
				s = 1.70158;
			
			return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
		}
		
		public static function backEaseInOut(t:Number, d:Number, b:Number=0, c:Number=1, s:Number = 0):Number
		{
			if (!s)
				s = 1.70158; 
			
			if ((t /= d / 2) < 1)
				return c / 2 * (t * t * (((s *= (1.525)) + 1) * t - s)) + b;
			
			return c / 2 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2) + b;
		}
		
		public static function bounceEaseOut(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			if ((t /= d) < (1 / 2.75))
				return c * (7.5625 * t * t) + b;
			
			else if (t < (2 / 2.75))
				return c * (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75) + b;
			
			else if (t < (2.5 / 2.75))
				return c * (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375) + b;
			
			else
				return c * (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375) + b;
		}
		
		public static function bounceEaseIn(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			return c - bounceEaseOut(d - t, 0, c, d) + b;
		}
		
		public static function bounceEaseInOut(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			if (t < d/2)
				return bounceEaseIn(t * 2, 0, c, d) * 0.5 + b;
			else
				return bounceEaseOut(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b;
		}
		
		public static function cubicEaseInOut(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			if ((t /= d / 2) < 1)
				return c / 2 * t * t * t + b;

			return c / 2 * ((t -= 2) * t * t + 2) + b;
		}
		
		public static function cubicEaseIn(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			return c * (t /= d) * t * t + b;
		}
		
		public static function cubicEaseOut(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			return c * ((t = t / d - 1) * t * t + 1) + b;
		}
		
		public static function quinticEaseInOut(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			if ((t /= d / 2) < 1)
				return c / 2 * t * t * t * t * t + b;

			return c / 2 * ((t -= 2) * t * t * t * t + 2) + b;
		}
		
		public static function quinticEaseOut(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
		}

		
		public static function quinticEaseIn(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			return c * (t /= d) * t * t * t * t + b;
		}
		
		public static function elasticEaseIn(t:Number, d:Number, b:Number=0, c:Number=1, a:Number = 0, p:Number = 0):Number
		{
			if (t == 0)
				return b;
			
			if ((t /= d) == 1)
				return b + c;
			
			if (!p)
				p = d * 0.3;
			
			var s:Number;
			if (!a || a < Math.abs(c))
			{
				a = c;
				s = p / 4;
			}
			else
			{
				s = p / (2 * Math.PI) * Math.asin(c / a);
			}

			return -(a * Math.pow(2, 10 * (t -= 1)) *
					 Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
		}
		
		public static function elasticEaseOut(t:Number, d:Number, b:Number=0, c:Number=1, a:Number = 0, p:Number = 0):Number
		{
			if (t == 0)
				return b;
				
			if ((t /= d) == 1)
				return b + c;
			
			if (!p)
				p = d * 0.3;

			var s:Number;
			if (!a || a < Math.abs(c))
			{
				a = c;
				s = p / 4;
			}
			else
			{
				s = p / (2 * Math.PI) * Math.asin(c / a);
			}

			return a * Math.pow(2, -10 * t) *
				   Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b;
		}
		
		public static function sineEaseIn(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			return -c * Math.cos(t / d * (Math.PI / 2)) + c + b;
		}
		
		public static function sineEaseOut(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			return c * Math.sin(t / d * (Math.PI / 2)) + b;
		}
		
		public static function sineEaseInOut(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			return -c / 2 * (Math.cos(Math.PI * t / d) - 1) + b;
		}
		
		public static function linearEaseNone(t:Number, d:Number, b:Number=0, c:Number=1):Number
		{
			return c * t / d + b;
		}
		
	}

}