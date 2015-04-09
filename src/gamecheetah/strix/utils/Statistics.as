package gamecheetah.strix.utils 
{
	/**
	 * @private
	 */
	public class Statistics 
	{
		
		public static function max(values:Vector.<int>):Number 
		{
			var max:int = int.MIN_VALUE;
			var val:int;
			for each (val in values)
			{
				if (val > max) max = val;
			}
			return max;
		}
		
		public static function mean(values:Vector.<int>):Number 
		{
			var sum:int = 0;
			var val:int;
			for each (val in values)
			{
				sum += val;
			}
			return sum / values.length;
		}
		
		public static function std(values:Vector.<int>):Number 
		{
			var mu:Number = mean(values);
			var val:int;
			var msd:int = 0;
			for each (val in values)
			{
				msd += (val - mu) * (val - mu);
			}
			return Math.sqrt(msd / values.length);
		}
		
	}

}