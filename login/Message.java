import java.net.Socket;
import java.io.*;
import java.util.concurrent.locks.*;

/**
 * Created by paulo on 22-05-2017.
 */
public class Message extends Thread{
    private Socket pingSocket;
    private Estado estado;

    Message(Socket pingSocket,Estado estado){
        this.pingSocket = pingSocket;
        this.estado = estado;
    }

    public void run(){
        try {
            BufferedReader in = new BufferedReader(new InputStreamReader(pingSocket.getInputStream()));
            
            String s = in.readLine();
            String[] sep = s.split(" ");
            if(s.equals("ok_create_account") || s.equals("ok_login")){estado.addPlayer("Paulo",0.0);}
            System.out.println(s);
            
            
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}