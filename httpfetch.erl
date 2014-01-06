% ch 17, ex 1.
-module(httpfetch).
-export([http_get/1]).


http_get(Link) ->
  {Host, Query} = query_string(Link),
  {ok, Socket} = gen_tcp:connect(Host, 80, [binary, {packet, 0}]),
  ok = gen_tcp:send(Socket, http_get_req(Host, Query)),
  Res = receive_data(Socket, []),
  case location(Res) of
    none ->
      Res;
    Redirect ->
      http_get(Redirect)
  end.

query_string(Link) ->
  case re:run(Link, "(?:http://)?((?i)[-a-z0-9\\._]+)(.*)", [{capture, [1,2], list}]) of
    {match, [Host, []]} ->
      {Host, "/"};
    {match, [Host, Query]} ->
      {Host, Query};
     nomatch ->
       nomatch
  end.

http_get_req(Host, Query) ->
  lists:flatten(["GET ", Query, " HTTP/1.1\r\n", "Host: ", Host, "\r\n\r\n"]).

location(Response) ->
  case re:run(headers(Response), "Location:\s*([^\r\s]+)", [{capture, [1], list}]) of
    nomatch ->
      none;
    {match, [Location]} ->
      Location
  end.


headers(Response) ->
  [Headers, _Body] = headers_body(Response),
  Headers.

headers_body(Res) ->
  binary:split(Res, <<$\r, $\n, $\r, $\n>>).

receive_data(Socket, SoFar) ->
  receive
    {tcp,Socket,Bin} ->
      receive_data(Socket, [Bin|SoFar]);
    {tcp_closed,Socket} ->
      list_to_binary(lists:reverse(SoFar))
  end.
