-module(estado).
-export([start/0]).

start() ->
  Pid = spawn(fun() -> estado(#{}, #{}, #{}, []) end),
  register(?MODULE, Pid).

geraAvatarJogador() -> %{massa,velocidade,direcao,x,y}
  {20, 20, 120, rand:uniform(500), 50, 50, 50}.

%funcao que recebe socket do user que acabou de fazer login e map dos Online
login_estado(Online,Socket) ->
  case maps:to_list(Online) of
    [] -> skip;
    L ->
  [gen_tcp:send(Socket,list_to_binary("online " ++ U ++ " 0.0 " ++ integer_to_list(Massa) ++ " " ++ integer_to_list(Velo) ++ " " ++ integer_to_list(Dir) 
                ++ " " ++ integer_to_list(X) ++ " " ++ integer_to_list(Y) ++ " " ++ integer_to_list(H) ++ " " ++ integer_to_list(W) ++ "\n"))
                 || {U,{Massa, Velo, Dir, X, Y, H, W}} <- L]
    
  end.

%Online é um map com Username chave e o seu avatar como chave #{Username => {massa,velocidade,direcao,x,y,height,width}}
estado(Espera, Online, Planetas, Mensagens) ->
  receive
    {Socket} ->      %<--------
		  login_estado(Online,Socket),
		  estado(Espera,Online,Planetas,Mensagens);
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
    {walk,Username,Socks} ->
      io:format("~p~n",[Username]),
	    {Massa,Velo,Dir,X,Y,H,W} = maps:get(Username,Online),
	    On = maps:update(Username,{Massa,Velo,Dir,X,Y+3,H,W},Online),
	    Dados = "online_upd " ++ Username ++ " " ++ integer_to_list(X) ++ " " ++ integer_to_list(Y+3) ++ "\n",
	    [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks], 
      estado(Espera,On,Planetas,Mensagens ++ [Dados]);
    {logout,Username,Socks} ->
      On = maps:remove(Username,Online),
      Dados = "logout " ++ Username ++ "\n",
      [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
      estado(Espera,On,Planetas,Mensagens)
  end.

    
