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
    
    public void loginSuc(String user) throws InvalidLoginException{
      l.lock();
      boolean log = false;
      try{
        for(Map.Entry<Jogador,AvatarJogador> entry:online.entrySet()){
          if(user.equals(entry.getKey().getUsername())) {log = true;break;}
        }
      }finally{
        l.unlock();
        if(!log) throw new InvalidLoginException("Login nao validado!");
      }
      
    }
    
    public void addPlayer(String user, double pontuacao){
      l.lock();
      try{
        online.put(new Jogador(user,pontuacao),new AvatarJogador());  
      }finally{
        l.unlock();
      }
    }
}