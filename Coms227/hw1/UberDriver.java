/*
 * Entry point for this project
 * @author Ji hoo Kim
 */
public class UberDriver 
{
	/* +++++++++++++++++++++++++++++++
	 * constant
	 * @author Ji hoo Kim
	 * +++++++++++++++++++++++++++++++
	 */
	public static final int MAX_PASSENGERS = 4;
	private static final int MIN_PASSENGERS = 0;
	public static final double OPERATING_COST = 0.5;
	/* ++++++++++++++++++++++++++++++++
	 * Instant Variables
	 * @author Ji hoo Kim
	 * ++++++++++++++++++++++++++++++++
	 */
	private int Miles;
	private int Minutes;
	private int passengers;
	private double MileRate;
	private double MinuteRate;
	private double credits;
	
	/* ++++++++++++++++++++++++++++++
	 * constructor
	 * @param givenPerMileRate, givenPerMinuteRate
	 * @return -
	 * @author Ji hoo Kim
	 * ++++++++++++++++++++++++++++++
	 */
	public UberDriver(double givenPerMileRate, double givenPerMinuteRate)
	{
		Miles = 0;
		Minutes = 0;
		passengers = 0;
		MileRate = givenPerMileRate;
		MinuteRate = givenPerMinuteRate;
	}
	/* +++++++++++++++++++++++++
	 * Method (Accessor)
	 * @author Ji hoo Kim
	 * ++++++++++++++++++++++++
	 */
	/*
	 * @param -
	 * Get the total Miles
	 * @return Miles
	 */
	public int getTotalMiles()
	{
		return Miles;
	}
	/*
	 * @param -
	 * Get the total Minutes
	 * @return Minutes
	 */
	public int getTotalMinutes()
	{
		return Minutes;
	}
	/*
	 * @param -
	 * get the passengers
	 * @return passengers
	 */
	public int getPassengerCount()
	{
		return passengers;
	}
	/*
	 * @param -
	 * get the credits
	 * @return credits
	 */
	public double getTotalCredits()
	{
		return credits;
	}
	/* +++++++++++++++++++++++++
	 * Method (Mutator)
	 * @author Ji hoo Kim
	 * ++++++++++++++++++++++++
	 */
	/*
	 * @param miles, minutes
	 * add the miles and minutes. Then calculate the credits.
	 * @return -
	 */
	public void drive(int miles, int minutes)
	{
		Miles = Miles + miles;
		Minutes = Minutes + minutes;
		credits = credits + miles * MileRate * passengers + minutes * MinuteRate * passengers;
		return;
	}
	/*
	 * @param minutes
	 * add a minute that the driver wait for the passengers
	 * @return -
	 */
	public void waitAround(int minutes)
	{
		drive(0, minutes);
		return;
	}
	/*
	 * @param miles, averageSpeed
	 * get the miles and minutes using averageSpeed
	 * @return -
	 */
	public void driveAtSpeed(int miles, double averageSpeed)
	{
		if(averageSpeed<0)
			return;
		drive(miles,(int) Math.round(miles/averageSpeed*60));
		return;
	}
	/*
	 * @param -
	 * add one passenger
	 * @return -
	 */
	public void pickUp()
	{
		passengers = Math.min(MAX_PASSENGERS, passengers+1);
		return;
	}
	/*
	 * @param -
	 * subtract one passenger
	 * @return -
	 */
	public void dropOff()
	{
		passengers = Math.max(MIN_PASSENGERS, passengers-1);
		return;
	}
	/*
	 * @param -
	 * calculate the credits that include the operating cost
	 * @return credits - Miles * OPERATING_COST
	 * 
	 */
	public double getProfit()
	{
		return credits - Miles * OPERATING_COST;
	}
	/*
	 * @param -
	 * calculate the average profit
	 * @return (credits - Miles * OPERATING_COST)*60/Minutes
	 */
	public double getAverageProfitPerHour()
	{
		return (credits - Miles * OPERATING_COST)*60/Minutes;
	}
}
