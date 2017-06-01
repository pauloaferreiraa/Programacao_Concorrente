-module(estado).
-export([start/0]).

start() ->
  Pid = spawn(fun() -> estado(#{}, #{}, queue:new()) end),
  register(?MODULE, Pid).

geraAvatarJogador() -> %{massa,velocidade,direcao,x,y}
  {1, 20, 120, rand:uniform(500), 50, 50, 50}.

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
estado(Online, Planetas, EsperaQ) ->
  receive
    {Socket} ->      %<--------
		  login_estado(Online,Socket),
		  estado(Online,Planetas,EsperaQ);
    {online, add, Username,Socks} ->
      {Massa, Velo, Dir, X, Y, H, W} = geraAvatarJogador(),
      Dados = "online " ++ Username ++ " 0.0 " ++ integer_to_list(Massa) ++ " " ++ integer_to_list(Velo) ++ " " ++ integer_to_list(Dir) 
                ++ " " ++ integer_to_list(X) ++ " " ++ integer_to_list(Y) ++ " " ++ integer_to_list(H) ++ " " ++ integer_to_list(W) ++ "\n",
      [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks], %enviar os dados do jogador
      On = maps:put(Username, {Massa, Velo, Dir, X, Y, H, W}, Online),
      estado(On,Planetas,EsperaQ);
    {espera, add, Username} ->
      Q = queue:in(Username,EsperaQ),
      io:format("~p~n",[Q]),
      estado(Online, Planetas,Q);
    {walk,Username,Socks} ->
      case maps:is_key(Username,Online) of
        false ->
          estado(Online,Planetas,EsperaQ);
        true ->
          maps:get(Username,Online),
          io:format("~p~n",[Username]),
	        {Massa,Velo,Dir,X,Y,H,W} = maps:get(Username,Online),
          NewX = X + (math:cos(Dir*math:pi()/180)*Velo),%converter graus em radianos
          NewY = Y + (math:sin(Dir*math:pi()/180)*Velo),
	        On = maps:update(Username,{Massa,Velo,Dir,NewX,NewY,H,W},Online),
	        Dados = "online_upd_pos " ++ Username ++ " " ++ float_to_list(NewX) ++ " " ++ float_to_list(NewY) ++ "\n",
	        [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks], 
          estado(On,Planetas,EsperaQ)
      end;
    {left,Username,Socks} ->
      case maps:is_key(Username,Online) of
        false ->
          estado(Online,Planetas,EsperaQ);
        true ->
          maps:get(Username,Online),
          io:format("~p~n",[Username]),
	        {Massa,Velo,Dir,X,Y,H,W} = maps:get(Username,Online),
	        On = maps:update(Username,{Massa,Velo,Dir-10,X,Y,H,W},Online),
	        Dados = "online_upd_left " ++ Username ++ " " ++ integer_to_list(Dir-10) ++ "\n",
	        [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks], 
          estado(On,Planetas,EsperaQ)
      end;
    {right,Username,Socks} ->
      case maps:is_key(Username,Online) of
        false ->
          estado(Online,Planetas,EsperaQ);
        true ->
          maps:get(Username,Online),
          io:format("~p~n",[Username]),
	        {Massa,Velo,Dir,X,Y,H,W} = maps:get(Username,Online),
	        On = maps:update(Username,{Massa,Velo,Dir+10,X,Y,H,W},Online),
	        Dados = "online_upd_right " ++ Username ++ " " ++ integer_to_list(Dir+10) ++ "\n",
	        [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks], 
          estado(On,Planetas,EsperaQ)
      end;
    {logout,Username,Socks} ->
      case queue:out(EsperaQ) of
        {empty,_Q1} ->
          On = maps:remove(Username,Online),
          Dados = "logout " ++ Username ++ "\n",
          [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
          estado(On,Planetas,EsperaQ);
        {{value,Item},Q1} -> %o Item é o Username que esta na queue
          case Item of
            Username -> estado(Online,Planetas,Q1);
            _ ->
              On = maps:remove(Username,Online),
              Dados = "logout " ++ Username ++ "\n",
              [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
              estado ! {online,add,Item,Socks},
              estado(On,Planetas,Q1)
          end
      end      
  end.

    
