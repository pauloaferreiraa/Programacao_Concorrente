-module(avatar).
-export([geraAvatarJogador/0,geraAvatarPlaneta/1,check_edges_planet/2,check_colision/2]).


geraAvatarJogador() -> %{massa,velocidade,direcao,x,y,largura,altura, prop frente, prop esq, prop dir}
  {1, 20, 120.0, rand:uniform(500)+0.0, 50.0, 50, 50, 100, 100, 100}.


geraAvatarPlaneta(P) -> %{massa,velocidade,x,y}
  Massa = 150 + rand:uniform(50),
  Velocidade = 10 + rand:uniform(20),
  if
    P == 1 ->
      {Massa,Velocidade,200.0,200.0,1};
    P == 2 -> %{massa,velocidade,x,y}
      {Massa,Velocidade,200.0,500.0,1};
    P == 3 -> %{massa,velocidade,x,y}
      {Massa,Velocidade,200.0,800.0,1};
    true -> error
end.

check_edges_planet(Planetas,P) ->
  if
    P == 3 -> Planetas;
    true ->
      {M,V,X,Y,S} = maps:get(P,Planetas),
      if
        X > 1200-(M/2) ->
          check_edges_planet(maps:update(P, {M,V,X+(V*-S),Y,-S},Planetas),P+1);      
        X < (M/2) -> check_edges_planet(maps:update(P,{M,V,X+(V*-S),Y,-S},Planetas),P+1); 
        true -> check_edges_planet(maps:update(P,{M,V,X+(V*S),Y,S},Planetas),P+1)  
      end
  end.

check_colision(Username,Avatares) ->
  {Massa,Velo,Dir,X,Y,H,W, Pf, Pe, Pd} = maps:get(Username,Avatares),
  if 
    (X < 0) or (X > 1200) or (Y < 0) or (Y > 1200) -> {error,"dead " ++ Username ++ "\n"};
    true -> 
      NewX = X + (math:cos(Dir*math:pi()/180)*Velo),%converter graus em radianos
      NewY = Y + (math:sin(Dir*math:pi()/180)*Velo),
      {maps:update(Username,{Massa,Velo,Dir,NewX,NewY,H,W,Pf,Pe,Pd},Avatares),"online_upd_pos " ++ Username ++ " " ++ float_to_list(NewX) ++ " " ++ float_to_list(NewY) ++ "\n",
        "online_upd_energy " ++ Username ++ " " ++ integer_to_list(Pf) ++" "++integer_to_list(Pe)++" "++ integer_to_list(Pd) ++ "\n"}
  end.