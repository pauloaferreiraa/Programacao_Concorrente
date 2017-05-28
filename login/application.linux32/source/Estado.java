//Classe que vai armazenar o estado do jogo, memoria partilhada entre a classe Message e login
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.locks.*;

public class Estado{
    private Map<Jogador, AvatarJogador> online;
    private Map<Jogador, AvatarJogador> espera;
    private List<AvatarPlaneta> planetas;
    private Lock l = new ReentrantLock();
    
    Estado(){
      online = new HashMap();
      espera = new HashMap();
      planetas = new ArrayList();
    }
    
    
    public void addPlayer(Jogador j,AvatarJogador aj){
      l.lock();
      try{
        online.put(j,aj);  
      }finally{
        l.unlock();
      }
    }
    
    public double[][] atributosJogador(){
      l.lock();
      
      double[][] elementos = new double[4][4];
      int i = 0;
      try{
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          //System.out.println(entry.getKey().toString() + entry.getValue().toString());
          elementos[i][0] = entry.getValue().getAtributos()[0]; elementos[i][1] = entry.getValue().getAtributos()[1];
          elementos[i][2] = entry.getValue().getAtributos()[2]; elementos[i][3] = entry.getValue().getAtributos()[3];
          i++;
        }
      }finally{
        l.unlock();
        return elementos;
      }
    }
    
    public void updatePosicao(String username,double x, double y){
      l.lock();
      
      try{
        Jogador j = null;
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          if(entry.getKey().getUsername().equals(username)) entry.getValue().updatePos(x,y);
        }
      }finally{
        l.unlock();
      }
    }
    
    public String toString(){
      String s = "";
      for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
        s += entry.getKey().toString() + entry.getValue().toString();
      }
      
      return s;
    }
}