/**
 * Created by paulo on 23-05-2017.
 */
//Avatares de Jogadores
public class AvatarJogador {
    private static double massa;
    private static double velocidade;
    private double direcao; //angulo em graus
    private double x, y; //coordenadas do jogador
    private double h,w; //altura e largura do avatar
    
    AvatarJogador(double massa,double velocidade, double direcao, double x, double y, double h, double w){
      this.massa = massa;this.velocidade = velocidade; this.direcao = direcao; this.x = x; this.y = y; this.h = h; this.w = w;
    }
    
    public void updatePos(double x, double y){
      this.x = x;this.y = y;
    }
    
    public void updateDir(double dir){
      this.direcao = dir;
    }
    public String toString(){
      return "Massa: " + massa + " Veloc: " + velocidade + " Dir: " + direcao + " x: " + x + " y: " + y + " h: " + h + " w: " + w + "\n";
    }
    
    public double[] getAtributos(){
      double[] feat = {x,y,h,w,direcao};
      
      return feat;
    }
}