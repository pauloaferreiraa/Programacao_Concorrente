-module(servidor).
-export([server/1, acceptor/2, room/1, user/2]).
-import(loginManager, [start/0, create_account/3, login/3, online/0, close_account/3, logado/1, logout/3]).


server(Port) ->
  Room = spawn(fun() -> room(#{}) end),
  {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}, {reuseaddr, true}]),
  start(),
  Oper = spawn(fun() -> operation() end),
  register(?MODULE,Oper),
  acceptor(LSock, Room).

acceptor(LSock, Room) ->
  {ok, Sock} = gen_tcp:accept(LSock),
  spawn(fun() -> acceptor(LSock, Room) end),
  Room ! {enter, self(), Sock},
  user(Sock, Room).

find_by_value(Value, M) ->
  L = maps:to_list(M),
  hd(lists:filter(fun({_Key, V1}) -> V1 == Value end, L)).


room(Pids) ->
  receive
    {enter, Pid, Sock} ->
      io:format("user_entered ~p~n", [Pid]),
      room(maps:put(Pid, Sock, Pids));
    {line, Data, Sock} ->
      {Pi, _Soc} = find_by_value(Sock, Pids),

      StrData = binary:bin_to_list(Data),
      case StrData of
        "\\login " ++ Dados ->
          St = string:tokens(Dados, " "),
          [U | P] = St,
          case login(U, P, Pi) of
            ok ->
              io:format("Conta existe~n"), 
              gen_tcp:send(Sock,<<"ok\n">>);           
            invalid ->
              io:format("Conta nao existe~n"),
              gen_tcp:send(Sock,<<"invalid\n">>) 
          end;
        "\\create_account " ++ Dados ->
          St = string:tokens(Dados, " "),
          [U | P] = St,
          case create_account(U, P, Pi) of
            ok -> 
              io:format("Conta~n"),
              gen_tcp:send(Sock,<<"ok">>); 
            user_exists -> 
              io:format("Conta ja existe~n"),
              gen_tcp:send(Sock,<<"invalid">>)
          end;
        "\\logout " ++ Dados ->
          St = string:tokens(Dados, " "),
          [U | P] = St,
          logout(U, P, Pi),
          room(Pids);
        "\\close_account " ++ Dados ->
          St = string:tokens(Dados, " "),
          [U | P] = St,
          close_account(U, P, Pi),
          room(Pids);
        "\\walk\n" -> %Caso receba mensagem para andar, mandar para si proprio uma mensagem com a instrucao walk
          ?MODULE ! {walk};
        _ ->
          skip
      end,

      %[Pid ! {line, Data} || Pid <- maps:keys(Pids)],

      room(Pids);
    {leave, Pid} ->
      io:format("user_left ~p~n", [Pid]),
      room(maps:remove(Pid, Pids))
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
    {tcp_closed, _} ->
      Room ! {leave, self()};
    {tcp_error, _, _} ->
      Room ! {leave, self()}
  end.


operation() ->
  receive
    {walk} ->
      io:format("Walk"),
      operation()
  end.
