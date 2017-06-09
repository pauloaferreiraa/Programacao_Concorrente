-module(avatar).
-export([geraAvatarJogador/0,geraAvatarPlaneta/1,check_edges_planet/2,check_colision/2,charge_propulsor/3]).


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
      case Pf of
			  N when N>0 -> 
              NewX = X + (math:cos(Dir*math:pi()/180)*Velo),
						  NewY = Y + (math:sin(Dir*math:pi()/180)*Velo),
	        		On = maps:update(Username,{Massa,Velo,Dir,NewX,NewY,H,W,Pf-5,Pe,Pd},Avatares),
              {On,"online_upd_pos " ++ Username ++ " " ++ float_to_list(NewX) ++ " " ++ float_to_list(NewY) ++ " " ++ integer_to_list(Pf-5) ++ "\n"};
			  0 -> 
          On = maps:update(Username,{Massa,Velo,Dir,X,Y,H,W,Pf,Pe,Pd},Avatares),
          {On,"online_upd_pos " ++ Username ++ " " ++ float_to_list(X) ++ " " ++ float_to_list(Y) ++ " " ++ integer_to_list(Pf) ++ "\n"}         
		  end
  end.

charge_propulsor(Username,Prop,Avatares) ->
  {Massa,Velo,Dir,X,Y,H,W, Pf, Pe, Pd} = maps:get(Username,Avatares),
  case Prop of
    "Pe" ->
      if
        Pe == 100 -> {full};
        Pe < 100 -> 
          On = maps:update(Username,{Massa,Velo,Dir,X,Y,H,W, Pf, Pe + 5, Pd},Avatares),
          Msg = "charge " ++ Username ++ " " ++ integer_to_list(Pf) ++ " " ++integer_to_list(Pe+5) ++ " " ++ integer_to_list(Pd) ++ "\n",
          {On,Msg}
      end;
    "Pd" ->
      if
        Pd == 100 -> {full};
        Pd < 100 ->
          On = maps:update(Username,{Massa,Velo,Dir,X,Y,H,W, Pf, Pe, Pd + 5},Avatares),
          Msg = "charge " ++ Username ++ " " ++ integer_to_list(Pf) ++ " " ++ integer_to_list(Pe) ++ " " ++ integer_to_list(Pd + 5) ++ "\n",
          {On,Msg}
      end;
    "Pf" ->
      if
        Pf == 100 -> {full};
        Pf < 100 ->
          On = maps:update(Username,{Massa,Velo,Dir,X,Y,H,W, Pf + 5, Pe, Pd},Avatares),
          Msg = "charge " ++ Username ++ " " ++ integer_to_list(Pf + 5) ++ " " ++ integer_to_list(Pe) ++ " " ++ integer_to_list(Pd) ++ "\n",
          {On,Msg}
      end
  end.