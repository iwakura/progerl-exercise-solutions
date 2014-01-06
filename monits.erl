% ch 13, exs 1,2,3.
-module(monits).
-export([my_spawn/3, my_spawn2/3, my_spawn/4, sleep/0]).

my_spawn(Mod, Func, Args) ->
  Caller = self(),
  spawn(fun() ->
          {L1, T1, _} = erlang:now(),
          {Pid, Ref} = spawn_monitor(Mod, Func, Args),
          Caller ! {pid, Pid},
          receive
            {'DOWN', Ref, process, Pid, Reason} ->
              {L2, T2, _} = erlang:now(),
              Runtime = (L2 - L1) * 1000000 + T2 - T1,
              io:format("Process ~p died because of: ~p~nLived: ~p seconds.~n", [Pid, Reason, Runtime])
          end
        end),
  receive
    {pid, Pid} ->
      Pid
  end.

my_spawn2(Mod, Func, Args) ->
  {L1, T1, _} = erlang:now(),
  Pid = spawn(Mod, Func, Args),
  on_exit(Pid, fun(Reason) ->
                  {L2, T2, _} = erlang:now(),
                  Runtime = (L2 - L1) * 1000000 + T2 - T1,
                  io:format("Process ~p died because of: ~p~nLived: ~p seconds.~n", [Pid, Reason, Runtime])
                end),
  Pid.


my_spawn(Mod, Func, Args, Time) ->
  Pid = spawn(Mod, Func, Args),
  spawn(fun() ->
          receive
          after Time * 1000 ->
            io:format("Killing ~p if still alive.~n", [Pid]),
            exit(Pid, timeover)
          end
        end),
  Pid.



on_exit(Pid, Fun) ->
  spawn(fun() ->
          Ref = monitor(process, Pid),
          receive
            {'DOWN', Ref, process, Pid, Why} ->
              Fun(Why)
          end
      end).

sleep() ->
  receive
    stop ->
      stop
  after infinity ->
    true
  end.
