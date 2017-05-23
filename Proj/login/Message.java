import java.io.PrintWriter;
import java.net.Socket;

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
            PrintWriter out = new PrintWriter(pingSocket.getOutputStream());
            out.println("Ola");
            out.flush();
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
