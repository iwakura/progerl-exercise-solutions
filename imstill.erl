% ch 13, ex 4.
-module(imstill).
-export([start/0, keep_alive/1, talk/1]).

start() ->
  spawn(?MODULE, keep_alive, [fun() -> start_talker() end]).

keep_alive(StartFun) ->
  Pid = StartFun(),
  Ref = monitor(process, Pid),
  receive
    {'DOWN', Ref, process, Pid, _Reason} ->
      demonitor(Ref),
      keep_alive(StartFun)
  end.

start_talker() ->
  Pid = spawn(?MODULE, talk, [5000]),
  register(imstillalive, Pid),
  Pid.

talk(Delay) ->
  receive
    stop ->
      stop
  after Delay ->
    io:format("I'm still alive.~n"),
    talk(Delay)
  end.
