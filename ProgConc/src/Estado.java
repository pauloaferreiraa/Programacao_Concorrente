//Classe que vai armazenar o estado do jogo, memoria partilhada entre a classe Message e login
import java.util.List;
import java.util.Map;

public class Estado{
    private Map<Jogador, AvatarJogador> online;
    private Map<Jogador, AvatarJogador> espera;
    private List<AvatarPlaneta> planetas;
}