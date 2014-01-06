% ch 13, ex 5.
-module(visor).
-export([start/0, start/1, sleep/0]).

start() ->
  spawn(?MODULE, start, [2]).

start(Num) when Num > 0 ->
  [start_one() || _Idx <- lists:seq(1, Num)],
  supervise().

supervise() ->
  receive
    {'DOWN', Ref, process, Pid, Reason} ->
      demonitor(Ref),
      io:format("Process ~p died because of: ~p~n", [Pid, Reason]),
      start_one()
  end,
  supervise().


start_one() ->
  spawn_monitor(?MODULE, sleep, []).


sleep() ->
  receive
    stop ->
      stop
  after infinity ->
    true
  end.
