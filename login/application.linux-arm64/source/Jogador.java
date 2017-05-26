/**
 * Created by paulo on 23-05-2017.
 */
public class Jogador {
    private String username;
    private double pontuacao;
    
    Jogador(String user,double pontuacao){
      username = user;
      this.pontuacao = pontuacao;
    }
    public String getUsername(){return username;}
}