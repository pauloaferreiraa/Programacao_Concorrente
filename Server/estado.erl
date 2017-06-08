-module(estado).
-export([start/0]).
-import(avatar,[geraAvatarJogador/0,geraAvatarPlaneta/1,check_edges_planet/2,check_colision/2]).


start() ->
  Pid = spawn(fun() -> estado(#{}, #{}, queue:new(),[]) end),
  register(?MODULE, Pid).


%funcao que recebe socket do user que acabou de fazer login e map dos Online e envia mensagem
login_estado(Online,Planetas,Socket) ->
  case maps:to_list(Online) of
    [] -> skip;
    L ->
  [gen_tcp:send(Socket,list_to_binary("online " ++ U ++ " 0.0 " ++ integer_to_list(Massa) ++ " " ++ integer_to_list(Velo) ++ " " ++ float_to_list(Dir) 
                ++ " " ++ float_to_list(X) ++ " " ++ float_to_list(Y) ++ " " ++ integer_to_list(H) ++ " " ++ integer_to_list(W) ++ "\n"))
                 || {U,{Massa, Velo, Dir, X, Y, H, W}} <- L]    
  end,
  case maps:to_list(Planetas) of
    [] -> skip;
    Pla ->
      [gen_tcp:send(Socket,list_to_binary("planeta " ++ integer_to_list(N) ++ " " ++ integer_to_list(Massa) ++ " " ++ integer_to_list(Velo) ++ " " ++ float_to_list(X) 
                ++ " " ++ float_to_list(Y) ++ "\n"))
                 || {N,{Massa, Velo, X, Y,_S}} <- Pla]
  end.


    
%Online é um map com Username chave e o seu avatar como chave #{Username => {massa,velocidade,direcao,x,y,height,width}}
estado(Online, Planetas, EsperaQ,Socks) ->
  receive
    {gera_planetas} ->
      P = maps:put(0,geraAvatarPlaneta(1),Planetas),
      P1 = maps:put(1,geraAvatarPlaneta(2),P),
      P2 = maps:put(2,geraAvatarPlaneta(3),P1),
      estado(Online,P2,EsperaQ,Socks);
    {planetas, From} ->
      case lists:flatlength(Socks) of
        0 ->
          From ! {back},
          estado(Online,Planetas,EsperaQ,Socks);
        _ ->
          %{M0,V0,X0,Y0} = maps:get(0,Planetas),
          %{M1,V1,X1,Y1} = maps:get(1,Planetas),
          %{M2,V2,X2,Y2} = maps:get(2,Planetas),
          %P = maps:update(0,{M0,V0,X0+V0,Y0},Planetas),
          %P1 = maps:update(1,{M1,V1,X1+V1,Y1},P),
          %P2 = maps:update(2,{M2,V2,X2+V2,Y2},P1),
          P = check_edges_planet(Planetas,0),
          Pla = maps:to_list(P),
          [gen_tcp:send(Socket,list_to_binary("planeta_upd " ++ integer_to_list(N) ++ " " ++ float_to_list(X) ++ " " 
              ++ float_to_list(Y) ++ "\n")) || Socket <- Socks, {N,{_Massa, _Velo, X, Y,_S}} <- Pla],
          From ! {back},
          estado(Online,P,EsperaQ,Socks)
      end;  
    {Socket} ->      %<--------
		  login_estado(Online,Planetas,Socket),
		  estado(Online,Planetas,EsperaQ,Socks++[Socket]);
    {online, add, Username} ->
      {Massa, Velo, Dir, X, Y, H, W} = geraAvatarJogador(),
      Dados = "online " ++ Username ++ " 0.0 " ++ integer_to_list(Massa) ++ " " ++ integer_to_list(Velo) ++ " " ++ float_to_list(Dir) 
                ++ " " ++ float_to_list(X) ++ " " ++ float_to_list(Y) ++ " " ++ integer_to_list(H) ++ " " ++ integer_to_list(W) ++ "\n",
      [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks], %enviar os dados do jogador
      On = maps:put(Username, {Massa, Velo, Dir, X, Y, H, W}, Online),
      estado(On,Planetas,EsperaQ,Socks);
    {espera, add, Username} ->
      Q = queue:in(Username,EsperaQ),
      %io:format("~p~n",[Q]),
      estado(Online, Planetas,Q,Socks);
    {walk,Username} ->
      case maps:is_key(Username,Online) of
        false ->
          estado(Online,Planetas,EsperaQ,Socks);
        true ->
          case check_colision(Username,Online) of
            {error, Dados} ->
              case queue:out(EsperaQ) of
                {empty,_Q1} ->
                  [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
                  estado(maps:remove(Username,Online),Planetas,EsperaQ,Socks);
                {{value,Item},Q1} -> %o Item é o Username que esta na queue
                    [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
                    estado ! {online,add,Item},
                    estado(maps:remove(Username,Online),Planetas,Q1,Socks)
              end;              
            {On,Dados} ->
	            [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks],
              estado(On,Planetas,EsperaQ,Socks)
          end
      end;
    {left,Username} ->
      case maps:is_key(Username,Online) of
        false ->
          estado(Online,Planetas,EsperaQ,Socks);
        true ->
          maps:get(Username,Online),
          %io:format("~p~n",[Username]),
	        {Massa,Velo,Dir,X,Y,H,W} = maps:get(Username,Online),
	        On = maps:update(Username,{Massa,Velo,Dir-10,X,Y,H,W},Online),
	        Dados = "online_upd_left " ++ Username ++ " " ++ float_to_list(Dir-10) ++ "\n",
	        [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks], 
          estado(On,Planetas,EsperaQ,Socks)
      end;
    {right,Username} ->
      case maps:is_key(Username,Online) of
        false ->
          estado(Online,Planetas,EsperaQ,Socks);
        true ->
          maps:get(Username,Online),
          %io:format("~p~n",[Username]),
	        {Massa,Velo,Dir,X,Y,H,W} = maps:get(Username,Online),
	        On = maps:update(Username,{Massa,Velo,Dir+10,X,Y,H,W},Online),
	        Dados = "online_upd_right " ++ Username ++ " " ++ float_to_list(Dir+10) ++ "\n",
	        [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks], 
          estado(On,Planetas,EsperaQ,Socks)
      end;
    {logout,Username,Sock} ->
      case queue:out(EsperaQ) of
        {empty,_Q1} ->
          On = maps:remove(Username,Online),
          Dados = "logout " ++ Username ++ "\n",
          [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
          estado(On,Planetas,EsperaQ,Socks--[Sock]);
        {{value,Item},Q1} -> %o Item é o Username que esta na queue
          case Item of
            Username -> estado(Online,Planetas,Q1,Socks--[Sock]);
            _ ->
              On = maps:remove(Username,Online),
              Dados = "logout " ++ Username ++ "\n",
              [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
              estado ! {online,add,Item},
              estado(On,Planetas,Q1,Socks--[Sock])
          end
      end    
  end.

    
