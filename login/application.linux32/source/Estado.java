//Classe que vai armazenar o estado do jogo, memoria partilhada entre a classe Message e login
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.locks.*;

public class Estado{
    private Map<Jogador, AvatarJogador> online;
    private Map<Jogador, AvatarJogador> espera;
    private Map<Integer,AvatarPlaneta> planetas;
    private Lock l = new ReentrantLock();
    
    Estado(){
      online = new HashMap();
      espera = new HashMap();
      planetas = new HashMap();
    }
    
    
    public void addPlayer(Jogador j,AvatarJogador aj){
      l.lock();
      try{
        online.put(j,aj);  
      }finally{
        l.unlock();
      }
    }
    
    public void addPlaneta(int N,AvatarPlaneta ap){
      l.lock();
      try{
        planetas.put(N,ap);  
      }finally{
        l.unlock();
      }
    
    }
    
    public String[] getNome(){
      l.lock();  
      String[] nomes = new String[4];
      int i=0; 
        try{
         for(Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
             nomes[i] = entry.getKey().getUsername();
             i++;
         }
        }finally{
          l.unlock();
          return nomes;
        }
        
    }
    
    public float[][] getPlanetas(){
      l.lock();
      float[][] plan = new float[3][3];
      int i = 0;
      try{
        for(Map.Entry<Integer,AvatarPlaneta> entry : planetas.entrySet()){
             plan[i] = entry.getValue().getAtributos();
             i++;
         }
      }finally{
        l.unlock();
        return plan;
      }
    }
    
    
    public double[][] atributosJogador(){
      l.lock();
      
      double[][] elementos = new double[4][5];
      int i = 0;
      try{
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          double[] atr = entry.getValue().getAtributos();
          //System.out.println(entry.getKey().toString() + entry.getValue().toString());
          elementos[i][0] = atr[0]; elementos[i][1] = atr[1];
          elementos[i][2] = atr[2]; elementos[i][3] = atr[3];
          elementos[i][4] = atr[4];
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
    
    public void updateDirecao(String username,double dir){
      l.lock();
      
      try{
        Jogador j = null;
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          if(entry.getKey().getUsername().equals(username)) entry.getValue().updateDir(dir);
        }
      }finally{
        l.unlock();
      }
    }
    
    public void logout(String username){
      l.lock();
      Jogador j = null;
      try{
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          if(entry.getKey().getUsername().equals(username)) {j = entry.getKey();online.remove(j);break;}
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