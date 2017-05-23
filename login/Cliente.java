import java.net.*;
import java.io.*;
import java.util.Scanner;


public class Cliente{
    private Socket pingSocket = null;

    public void connect() throws ConnectException{

        Scanner st = new Scanner(System.in);

        try {
            pingSocket = new Socket("localhost", 1234);
        }catch (ConnectException e) {
            throw e;
        } catch(Exception e){
            e.printStackTrace();
        }
    }


    public void disconnect()throws IOException{


        pingSocket.close();


    }

    public void login(String user, String pass){
        try{
            PrintWriter out = new PrintWriter(pingSocket.getOutputStream());
            out.println("\\login " + user + " " + pass);
            out.flush();
        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void create_account(String user, String pass){
        try{
            PrintWriter out = new PrintWriter(pingSocket.getOutputStream());
            out.println("\\create_account " + user + " " + pass);
            out.flush();
        }catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public Socket getPingSocket(){return pingSocket;}


}