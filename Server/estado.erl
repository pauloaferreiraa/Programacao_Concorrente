-module(estado).
-export([start/0]).

start() ->
  Pid = spawn(fun() -> estado(#{}, #{}, #{}, []) end),
  register(?MODULE, Pid).

geraAvatarJogador() -> %{massa,velocidade,direcao,x,y}
  {20, 20, 120, rand:uniform(500), rand:uniform(500), 50, 50}.


%Online é um map com Username chave e o seu avatar como chave #{Username => {massa,velocidade,direcao,x,y,height,width}}
estado(Espera, Online, Planetas, Mensagens) ->
  receive
    {online, add, Username,Socks} ->
      io:format("~p",[Socks]),
      {Massa, Velo, Dir, X, Y, H, W} = geraAvatarJogador(),
      Dados = "online " ++ Username ++ " 0.0 " ++ integer_to_list(Massa) ++ " " ++ integer_to_list(Velo) ++ " " ++ integer_to_list(Dir) 
                ++ " " ++ integer_to_list(X) ++ " " ++ integer_to_list(Y) ++ " " ++ integer_to_list(H) ++ " " ++ integer_to_list(W) ++ "\n",
      M = Mensagens ++ [Dados],
      [gen_tcp:send(Socket,list_to_binary(Msg)) || Socket <- Socks, Msg <- M], %enviar os dados do jogador
      On = maps:put(Username, {Massa, Velo, Dir, X, Y, H, W}, Online),
      estado(Espera,On,Planetas,M);
    {espera, add, Username,Socket} ->
      Esp = maps:put(Username, geraAvatarJogador(), Espera),
      estado(Esp, Online, Planetas,Mensagens);
    {walk,Username} ->
      io:format("Hello ~p",[Username]),
      estado(Espera,Online,Planetas,Mensagens)
  end.

    
