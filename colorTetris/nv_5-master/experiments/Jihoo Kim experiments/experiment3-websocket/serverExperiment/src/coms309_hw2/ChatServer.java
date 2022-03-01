package coms309_hw2;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class ChatServer 
{
	public static void main(String args[]) throws IOException
	{
		if(args.length!=1)
			throw new IllegalArgumentException("Syntax:ChatServer<port>");
		int port = Integer.parseInt(args[0]);
		ServerSocket server = new ServerSocket(port);
		System.out.println("ChatServer started");
		while(true)
		{
			Socket client = server.accept();
			//new ChatHandler(client).start();
			System.out.println("Accepted from"+ client.getInetAddress());
			ChatHandler handler = new ChatHandler(client);
			handler.start();
		}
	}

}
