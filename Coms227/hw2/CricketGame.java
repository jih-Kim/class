package hw2;

import api.Defaults;
import api.Outcome;

public class CricketGame 
{
	private int bowls;
	private int bowlsPerOver;
	private int overs;
	private int OverperInnings;
	private int totalInnings;
	private int completeInnings;
	private int outs;
	private int players;
	private int scores1;
	private int scores2;
	private int scores;
	private int sides;
	private boolean isPlaying;
	private boolean inRunning;
	private int countRun;
	
	public CricketGame()
	{
		bowlsPerOver = Defaults.DEFAULT_BOWLS_PER_OVER;
		OverperInnings = Defaults.DEFAULT_OVERS_PER_INNINGS;
		totalInnings = Defaults.DEFAULT_NUM_INNINGS;
		players = Defaults.DEFAULT_NUM_PLAYERS;
		bowls = 0;
		sides = 0;
		overs = 0;
		completeInnings = 0;
		outs = 0;
		scores = 0;
		sides = 0;
		isPlaying = false;
		inRunning = false;
	}
	
	public CricketGame(int givenBowlsPerOver, int givenOversPerInnings, int givenTotalInnings, int givenNumPlayers)
	{
		bowlsPerOver = givenBowlsPerOver;
		OverperInnings = givenOversPerInnings;
		totalInnings = givenTotalInnings;
		players = givenNumPlayers;
	}
	/*
	 * Bowls the ball and updates the game state depending on the given outcome. Note that after a call to this method with Outcome.HIT, 
	 * the ball will be in play (isInPlay() returns true).
	 * @par - outcome - outcome of this bowl
	 */
	public void bowl(Outcome outcome)
	{
		if(isGameEnded() == false)
		{
			if(outcome == Outcome.WIDE || outcome == Outcome.NO_BALL)
				{
				scores++;
				}
			if(outcome == Outcome.BOUNDARY_SIX)
			{
				if(isPlaying == true)
					bowls++;
				else
				{
					scores = scores + 6;
					bowls++;
				}
			}
			if(outcome == Outcome.BOUNDARY_FOUR)
			{
				scores = scores + 4;
				bowls++;
			}
			if(outcome == Outcome.CAUGHT_FLY || outcome == Outcome.LBW || outcome == Outcome.WICKET)
			{
				if(isPlaying == true)
					bowls++;
				else
				{
					outs++;
					bowls++;
				}
			}
			if(outcome == Outcome.HIT)
			{
				bowls++;
				isPlaying = true;
			}
				if(sides == 0)
					scores1 = scores1 + scores;
				else
					scores2 = scores2 + scores;
				scores = 0;
			if(bowls == bowlsPerOver)
			{
			bowls = 0;
			overs++;
			}
			if(overs == OverperInnings || outs == players - 1)
			{
				completeInnings++;
				bowls = 0;
				outs = 0;
				if(isPlaying == false)
				{
					overs=0;
					if(sides == 0)
						sides = 1;
					else
						sides = 0;
				}
				scores=0;
			}
			if(totalInnings%2 == 1)
				totalInnings++;
		}
		else
			return;
			
	}
	/*
	 * Returns the number of times the bowler has bowled so far during the current over, not counting wides or no-balls.
	 * @return - number of bowls so far in the current over
	 */
	public int getBowlCount()	
	{
		return bowls;
	}
	
	/*
	 * Returns the number of innings that have been completed.
	 * @return - number of completed innings
	 */
	public int getCompletedInnings()	
	{
		return completeInnings;
	}
	/*
	 * Returns the number of players out in the current innings.
	 * @return - number of players out
	 */
	
	public int getOuts()	
	{
		return outs;
	}
	/*
	 * Returns the number of completed overs for the current innings.
	 * @return - number of overs for the current innings
	 */
	public int getOverCount()	
	{
		return overs;
	}
	
	/*
	 * Returns the score for one of the two sides.
	 * @par - battingSide - if true, returns the score for the side currently at bat; otherwise returns the score for the other side
	 * @return - score for one of the two sides
	 */
	public int getScore(boolean battingSide)
	{
		if((battingSide == true && sides == 0)||(battingSide == false && sides == 1))
			return scores1;
		else
			return scores2;
	}
	
	/*
	 * Returns true if the game has ended, false otherwise.
	 * @return - true if the game has ended, false otherwise
	 */
	public boolean isGameEnded()	
	{
		
		if((completeInnings >= totalInnings) || ((totalInnings - 1 == completeInnings) && (scores1 < scores2)))
			return true;
		else
			return false;
	}
	
	/*
	 * Returns true if the ball is currently in play. The ball is in play directly following a call to bowl(Outcome.HIT)
	 *  and is taken out of play by a subsequent call to safe or runOut.
	 * @return - true if the ball is currently in play, false otherwise
	 */
	public boolean isInPlay()
	{
		if(isPlaying == true)
			return true;
		else
			return false;
	}
	/*
	 * Returns true if batsmen are currently running. Batsmen are running directly following a call to tryRun and 
	 * remain in a running state until a subsequent call to safe or runOut.
	 * @return - true if batsmen are running, false otherwise
	 */
	public boolean isRunning() //
	{
		if(inRunning == true)
			return true;
		else
			return false;
	}
	
	/*
	 * Runs the batsman out (i.e., fielders knock over wicket while batsmen are running). Does not count as a run. After this method is called,
	 *  isRunning() returns false and isInPlay() returns false. Does nothing if game is already over or if batsmen are not running.
	 */
	public void runOut()  
	{
		if(inRunning == true)
			outs++;	
		inRunning = false;
		isPlaying = false;
		countRun = 0;
		if(overs == OverperInnings || outs == players - 1)
		{
			overs=0;
			if(sides == 1)
				sides = 0;
			else
				sides = 1;
		}
		return;
	}
	
	/*
	 * Transitions from ball in play to ball not in play, without an out. If batsmen were running, that run is successfully 
	 * completed and a run is added to the score, After this method is called, isRunning() returns false and isInPlay() returns false. 
	 * Method does nothing if game is already over or ball is not in play.
	 */
	public void safe() 
	{
		
		if(inRunning == true)
			{
				if(sides == 0)
					scores1++;
				else
					scores2++;
			}
		isPlaying = false;
		inRunning = false;
		countRun = 0;
		if(overs == OverperInnings || outs == players - 1)
		{
			overs=0;
			if(sides == 1)
				sides = 0;
			else
				sides = 1;
		}
		return;
	}
	
	/*
	 * Starts the batsmen running from one end of the pitch to the other. After this method is called, isRunning() returns true. 
	 * If the batsmen were already running, that run is assumed to have completed successfully and so a run is added to the score for the batting side. 
	 * Method does nothing if game is already over or ball is not in play.
	 */
	public void tryRun()
	{
		if(isPlaying == true)
			inRunning = true;
		else
			inRunning = false;
		countRun++;
		if(countRun == 2)
		{
			if(sides == 0)
				scores1++;
			else
				scores2++;
			countRun=1;
		}
		return;
	}
	
	/*
	 * Returns 0 if side 0 is batting or 1 if side 1 is batting.
	 * return - 0 if side 0 is batting or 1 if side 1 is batting
	 */
	public int whichSideIsBatting()
	{
		if(sides == 1)
			return 1;
		else
			return 0;
	}
}
