package coms309_hw2;

import java.awt.BorderLayout;
import java.awt.Button;
import java.awt.Frame;
import java.awt.GridLayout;
import java.awt.Label;
import java.awt.Panel;
import java.awt.TextArea;
import java.awt.TextField;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;

public class ChatClient implements Runnable, ActionListener
{
	private Frame frame;
	private Button button1;
	private TextArea textArea1;
	private Label label1;
	private TextField textField1;
	private Panel panel2;
	private Button button2;
	private Panel panel1;
	private TextField textField2;
	private Label label2;
	private TextField textField3;
	private Label label3;
	private TextField textField4;
	protected String host;
	protected int port;
	protected int rightPortNumber = 8000;
	protected String id;
	
	public ChatClient()
	{
		frame = new Frame();
		panel1 = new Panel();
		label1 = new Label();
		textField1 = new TextField();
		label2 = new Label();
		textField2 = new TextField();
		label3 = new Label();
		textField3 = new TextField();
		button1 = new Button();
		button2 = new Button();
		panel2 = new Panel();
		textArea1 = new TextArea();
		textField4 = new TextField();
		
		frame.addWindowListener(new WindowAdapter() 
		{
			public void windowClosing(WindowEvent e)
			{
				try
				{
					stop();
				}
				catch(IOException ex)
				{
				}
				frame.dispose();
				System.exit(0);
			}
		});
		
		frame.addWindowListener(new WindowAdapter()
		{
			public void windowOpended(WindowEvent e)
			{
				label1.requestFocus();
			}
		});
		
		panel1.setLayout(new GridLayout(4,2));
		label1.setText("Server IP");
		panel1.add(label1);
		textField1.setColumns(20);
		panel1.add(textField1);
		label2.setText("Access code");
		panel1.add(label2);
		textField2.setColumns(8);
		panel1.add(textField2);
		label3.setText("Name");
		panel1.add(label3);
		textField3.setColumns(20);
		panel1.add(textField3);
		button1.setLabel("Connect");
		button1.addActionListener(this);
		panel1.add(button1);
		button2.setLabel("Disconnect");
		button2.addActionListener(this);
		panel1.add(button2);
		textField4.setText("input");
		textField4.setColumns(40);
		textField4.setEditable(false);
		textField4.addActionListener(this);
		
		frame.add(panel1,BorderLayout.NORTH);
		panel2.setLayout(new BorderLayout());
		panel2.add(textArea1,BorderLayout.CENTER);
		panel2.add(textField4, BorderLayout.SOUTH);
		frame.add(panel2,BorderLayout.CENTER);
		frame.pack();
		frame.setVisible(true);
	}
	
	protected DataInputStream dataIn;
	protected DataOutputStream dataOut;
	protected Thread listener;
	
	public synchronized void start() throws IOException
	{
		if(listener == null)
		{
			Socket socket = new Socket(host, port);
			try
			{
				dataIn = new DataInputStream(new BufferedInputStream(socket.getInputStream()));
				dataOut = new DataOutputStream(new BufferedOutputStream(socket.getOutputStream()));
				dataOut.writeUTF("##name##"+id);
				dataOut.flush();
			}
			catch(IOException ie)
			{
				socket.close();
				throw ie;
			}
			listener = new Thread(this);
			listener.start();
		}
	}
	
	public synchronized void stop() throws IOException
	{
		if(listener != null)
		{
			listener.interrupt();
			listener = null;
			dataOut.close();
		}
	}
	
	public void run()
	{
		try
		{
			while(!Thread.interrupted())
			{
				String line = dataIn.readUTF();
				textArea1.append(line+"\n");
			}
		}
		catch(IOException ie)
		{
			handleIOException(ie);
		}
		finally
		{
			connectok=false;
		}
	}
	
	protected synchronized void handleIOException(IOException ex)
	{
		if(listener!=null)
		{
			textArea1.append(ex+"\n");
			frame.validate();
			if(listener != Thread.currentThread())
				listener.interrupt();
			listener = null;
			try
			{
				dataOut.close();
			}
			catch(IOException ignored)
			{
			}
		}
	}
	
	protected boolean connectok = false;
	
	public void actionPerformed(ActionEvent event)
	{
		try
		{
			if(!connectok&&event.getActionCommand().equals("Connect"))
			{
				host = textField1.getText();
				port = Integer.parseInt(textField2.getText());
				id=textField3.getText();
				if(port==rightPortNumber)
					textArea1.append("you are connected\n");
				else
					textArea1.append("incorrect access code\n");
				start();
				textField4.setEditable(true);
				textField4.setText("");
				connectok=true;
			}
			else if(connectok && event.getActionCommand().equals(textField4.getText()))
			{
				textField4.selectAll();
				dataOut.writeUTF("<"+id+">:"+event.getActionCommand());
				dataOut.flush();
				textField4.setText("");
			}
			else if(connectok && event.getActionCommand().equals("Disconnect"))
			{
				textArea1.append("Press Disconnect button\n");
				stop();
				connectok = false;
			}
		}
		catch(IOException ex)
		{
			handleIOException(ex);
		}
	}
	
	public static void main(String args[])
	{
		ChatClient chat = new ChatClient();
	}
}
