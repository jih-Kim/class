package coms309_hw2;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;
import java.util.Enumeration;
import java.util.Vector;

public class ChatHandler implements Runnable
{
	protected Socket socket;
	
	public ChatHandler(Socket socket)
	{
		this.socket = socket;
	}
	
	protected DataInputStream dataIn;
	protected DataOutputStream dataOut;
	protected Thread listener;
	
	public synchronized void start()
	{
		if(listener==null)
		{
			try
			{
				dataIn = new DataInputStream(new BufferedInputStream(socket.getInputStream()));
				dataOut = new DataOutputStream(new BufferedOutputStream(socket.getOutputStream()));
				listener = new Thread(this);
				listener.start();
			}
			catch(IOException ignored)
			{
				
			}
		}
	}
	
	public synchronized void stop()
	{
		if(listener!=null)
		{
			try
			{
				if(listener!=Thread.currentThread())
					listener.interrupt();
				listener=null;
				dataOut.close();
			}
			catch(IOException ignored)
			{
				
			}
		}
	}
	
	protected static Vector<ChatHandler> handlers = new Vector<ChatHandler>();
	protected String myname;
	public void run()
	{
		try
		{
			handlers.addElement(this);
			while(!Thread.interrupted())
			{
				String message = dataIn.readUTF();
				if(message.startsWith("##name##"))
				{
					myname = message.substring(8);
					message = myname + " enter the chatroom";
				}
				System.out.println("Client message: "+message);
				broadcast(message);
			}
		}
		catch(EOFException ignored)
		{
			
		}
		catch(IOException ie)
		{
			if(listener == Thread.currentThread())
				ie.printStackTrace();
		}
		finally
		{
			handlers.removeElement(this);
			broadcast(myname + "leaving the chatroom");
		}
		stop();
	}
	
	protected void broadcast(String message)
	{
		synchronized(handlers)
		{
			Enumeration<ChatHandler> e = handlers.elements();
			while(e.hasMoreElements())
			{
				ChatHandler handler = e.nextElement();
				try
				{
					handler.dataOut.writeUTF(message);
					handler.dataOut.flush();
				}
				catch(IOException ex)
				{
					handler.stop();
				}
			}
		}
	}
}
