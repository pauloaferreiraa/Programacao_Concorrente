import java.net.Socket;
import java.io.*;

/**
 * Created by paulo on 22-05-2017.
 */
public class Message extends Thread{
    private Socket pingSocket;

    Message(Socket pingSocket){
        
        this.pingSocket = pingSocket;
    }

    public void run(){
        try {
            BufferedReader in = new BufferedReader(new InputStreamReader(pingSocket.getInputStream()));
            //if(in.readLine().equals("ok"));{
            System.out.println("Output = " + in.readLine());
            
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}