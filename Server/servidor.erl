-module(servidor).
-export([server/1, acceptor/2, room/1, user/2]).
-import(loginManager, [start/0, create_account/3, login/3, online/0, close_account/3, logado/1, logout/3,logout_socket/1]).
-import(estado,[]).


server(Port) ->
  Room = spawn(fun() -> room([]) end),
  {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}, {reuseaddr, true}]),
  spawn(fun()->start()end),
  estado:start(),
  Oper = spawn(fun() -> operation() end),
  register(?MODULE,Oper),
  acceptor(LSock, Room).

acceptor(LSock, Room) ->
  {ok, Sock} = gen_tcp:accept(LSock),
  spawn(fun() -> acceptor(LSock, Room) end),
  Room ! {enter, Sock},
  user(Sock, Room).

%find_by_value(Value, M) ->
 % L = maps:to_list(M),
  %hd(lists:filter(fun({_Key, V1}) -> V1 == Value end, L)).


room(Socks) ->
  receive
    {enter, Socket} ->
      io:format("user_entered ~p~n", [Socket]),
      room(Socks++[Socket]);
    {line, Data, Socket} ->

      StrData = binary:bin_to_list(Data),
      case StrData of
        "\\login " ++ Dados ->
          St = string:tokens(Dados, " "),
          [U | P] = St,
          case login(U, P, Socket) of
            {ok,N} -> %recebe o numero de clientes logados
              gen_tcp:send(Socket,<<"ok_login\n">>),
              if
                N =< 4 -> ?MODULE ! {online,add,U,Socks};
                true -> skip
              end;                                     
            {invalid,_} ->
              gen_tcp:send(Socket,<<"invalid_login\n">>) 
          end;
        "\\create_account " ++ Dados ->
          St = string:tokens(Dados, " "),
          [U | P] = St,
          case create_account(U, P, Socket) of
            {ok,N} -> %recebe o numero de clientes logados
              gen_tcp:send(Socket,<<"ok_create_account\n">>),
              if
                N =< 4 -> ?MODULE ! {online,add,U,Socks};
                true -> skip
              end;   
            {user_exists,_} -> 
              gen_tcp:send(Socket,<<"invalid_create_account\n">>)
          end;
        "\\logout " ++ Dados ->
          St = string:tokens(Dados, " "),
          [U | P] = St,
          logout(U, P, Socket);
        "\\close_account " ++ Dados ->
          St = string:tokens(Dados, " "),
          [U | P] = St,
          close_account(U, P, Socket);
        "\\walk\n" -> %Caso receba mensagem para andar, mandar para si proprio uma mensagem com a instrucao walk
          Username = logado(Socket),
          ?MODULE ! {walk,Username,Socks};            
        _ ->
          skip
      end,

      %[Pid ! {line, Data} || Pid <- maps:keys(Pids)],

      room(Socks);
    {leave, Socket} ->
      io:format("user_left ~p~n", [Socket]),
      logout_socket(Socket),%fazer logout quando o utilizador deixar o servidor
      room(Socks--[Socket])
  end.

user(Sock, Room) ->
  receive
    {line, Data} ->
      gen_tcp:send(Sock, Data),
      user(Sock, Room);
    {tcp, Socket, Data} ->
      Room ! {line, Data, Socket},
      %gen_tcp:send(Sock, Data),
      user(Sock, Room);
    {tcp_closed, Socket} ->
      Room ! {leave, Socket};
    {tcp_error, Socket, _} ->
      Room ! {leave, Socket}
  end.


operation() ->
  receive
    {walk,Username,Socks} ->
      estado ! {walk,Username,Socks},
      operation();
    {online,add,U,Socks} ->
      estado ! {online,add,U,Socks},
      operation()
  end.