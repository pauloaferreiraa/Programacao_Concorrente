import java.net.Socket;
import java.io.*;
import java.util.concurrent.locks.*;

/**
 * Created by paulo on 22-05-2017.
 */
public class Message extends Thread{
    private BufferedReader in;
    private Estado estado;

    Message(BufferedReader in,Estado estado){
        this.in = in;
        this.estado = estado;
    }

    public void run(){
        try {
            
            while(true){
              String s = in.readLine();
              System.out.println(s);
              String[] sp = s.split(" "); //dividir strings por espaços
              //System.out.println("Entrou");
              if(sp[0].equals("online")){
                estado.addPlayer(new Jogador(sp[1],Double.parseDouble(sp[2])),new AvatarJogador(Double.parseDouble(sp[3]),Double.parseDouble(sp[4]),
                                                                                        Double.parseDouble(sp[5]),Double.parseDouble(sp[6]),
                                                                                        Double.parseDouble(sp[7]),Double.parseDouble(sp[8]),
                                                                                        Double.parseDouble(sp[9])));
              }
              if(sp[0].equals("online_upd")){
                estado.updatePosicao(sp[1],Double.parseDouble(sp[2]),Double.parseDouble(sp[3]));
              }
              
              if(sp[0].equals("logout")){
                System.out.println("Recebeu");
                estado.logout(sp[1]);
              }
            }
            
            
            
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}