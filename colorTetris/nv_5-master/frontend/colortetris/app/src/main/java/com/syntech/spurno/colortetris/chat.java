package com.syntech.spurno.colortetris;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.WebSocket;
import okhttp3.WebSocketListener;
import okio.ByteString;

public class chat extends AppCompatActivity {
    private WebSocket webSocket;
    private MessageAdapter adapter;
    String url = "coms-309-nv-5.cs.iastate.edu:8181/websocket/" + login.getUsername();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);

        ListView messageList = findViewById(R.id.messageList);
        final EditText messagebox = findViewById(R.id.message);
        Button send = (Button)findViewById(R.id.sendText);
        
        instantiateWebSocket();
        final MessageAdapter adapter = new MessageAdapter();
        messageList.setAdapter(adapter);

        send.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view) {
                String message = messagebox.getText().toString();
                if (!isEmpty(messagebox)) {
                    webSocket.send(message);
                    messagebox.setText("");

                    JSONObject jsonObject = new JSONObject();
                    try {
                        jsonObject.put("message", message);
                        jsonObject.put("byServer", false);

                        adapter.addItem(jsonObject);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }
            });
        }

    /**
     * websocket set up
     */
    private void instantiateWebSocket() {
        OkHttpClient client = new OkHttpClient();
        Request request = new Request.Builder().url(url).build();
        webSocketListener socketListener = new webSocketListener();
        WebSocket websocket = client.newWebSocket(request,socketListener);
    }
    public class webSocketListener extends WebSocketListener{
        public Activity activity;
        public webSocketListener(){
            this.activity = activity;
        }
        @Override
        public void onOpen(WebSocket webSocket, Response response) {
            super.onOpen(webSocket, response);
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(activity, "connected",Toast.LENGTH_LONG).show();
                }
            });
        }

        @Override
        /**
         * add message to jsonobject
         */
        public void onMessage(WebSocket webSocket, final String text) {
            super.onMessage(webSocket, text);
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    JSONObject jsonObject = new JSONObject();
                    try{
                        jsonObject.put("message",text);
                        jsonObject.put("byserver", true);
                        adapter.addItem(jsonObject);
                }
                    catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            });
            }

        @Override
        public void onClosing(WebSocket webSocket, int code, String reason) {
            super.onClosing(webSocket, code, reason);

        }

        @Override
        public void onClosed(WebSocket webSocket, int code, String reason) {
            super.onClosed(webSocket, code, reason);
        }

        @Override
        public void onFailure(WebSocket webSocket, Throwable t, @Nullable Response response) {
            super.onFailure(webSocket, t, response);
        }
    }

    public class MessageAdapter extends BaseAdapter{

        List<JSONObject> messageList = new ArrayList<>();
        @Override
        public int getCount() {
            return messageList.size();
        }

        @Override
        public Object getItem(int position) {
            return messageList.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        /**
         * check if the message is recieved or sent
         */
        public View getView(int position, View convertView, ViewGroup parent) {
            if(convertView == null){
                convertView = getLayoutInflater().inflate(R.layout.message_list_item,parent, false);
                TextView sentMessage = convertView.findViewById(R.id.sentmessage);
                TextView recievedMessage = convertView.findViewById(R.id.recievedMessage);
                JSONObject message = messageList.get(position);
                try{
                    if(message.getBoolean("byServer")){
                        recievedMessage.setVisibility((View.VISIBLE));
                        recievedMessage.setText(message.getString("message"));
                        sentMessage.setVisibility(View.INVISIBLE);
                    }
                    else{
                        recievedMessage.setVisibility((View.INVISIBLE));
                        sentMessage.setText(message.getString("message"));
                        sentMessage.setVisibility(View.VISIBLE);
                    }
                } catch (JSONException e){
                    e.printStackTrace();
                }
            }
            return convertView;
        }
        void addItem(JSONObject item){
            messageList.add(item);
            notifyDataSetChanged();
        }
    }

    /**
     * check if editable text is empty
     * @param Text
     * @return
     */
    public boolean isEmpty(EditText Text) {
        if (Text.getText().toString().trim().length() > 0)
            return false;

        return true;
    }
}
