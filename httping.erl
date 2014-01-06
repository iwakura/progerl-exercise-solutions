% ch 26, ex 1 start.
-module(httping).
-export([ping/2, ping/1]).

% timer doe not work properly
ping(Host, Timeout) ->
  timer:send_after(Timeout, timeout),
  case timer:tc(fun http_head/2, [Host, 80]) of
    {_Time, timeout} ->
      timeout;
    {Time, Headers} ->
      io:format("~p~n", [Headers]),
      {time, Time}
  end.

ping(Host) ->
  {Time, _Value} = timer:tc(fun http_head/2, [Host, 80]),
  {time, Time}.

http_head(Host, Port) ->
  {ok, Socket} = gen_tcp:connect(Host, Port, [binary, {packet, 0}]),
  ok = gen_tcp:send(Socket, head_request(Host, "/")),
  receive_data(Socket, []).

receive_data(Socket, Acc) ->
  receive
    {tcp, Socket, Bin} ->
      receive_data(Socket, [Bin | Acc]);
    {tcp_closed, Socket} ->
      gen_tcp:close(Socket),
      list_to_binary(lists:reverse(Acc));
    timeout ->
      gen_tcp:close(Socket),
      timeout
  end.


head_request(Host, Path) ->
  io_lib:format("HEAD ~s HTTP/1.1\r\nHost: ~s\r\nConnection: close\r\n\r\n", [Path, Host]).

