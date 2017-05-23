-module(estado).
-export([start/0]).

start() ->
  Pid = spawn(fun() -> estado(#{}, #{}, #{}) end),
  register(?MODULE, Pid).

geraAvatarJogador() -> %{massa,velocidade,direcao,x,y}
  {20, 20, 120, 100, 100}.


%Online é um map com Username chave e o seu avatar como chave #{Username => {massa,velocidade,direcao,x,y}}
estado(Espera, Online, Planetas) ->
  receive
    {espera, add, Username} ->
      Esp = maps:put(Username, geraAvatarJogador(), Espera),
      estado(Esp, Online, Planetas);
    {online, add, Username, espera} ->
      Avatar = maps:get(Username, Espera),
      On = maps:put(Username, Avatar, Online),
      Esp = maps:remove(Username, Espera),
      estado(Esp, On, Planetas)
      {online, add, Username} ->
On = maps:put(Username, geraAvatorJogador(), Online)

end .

    
