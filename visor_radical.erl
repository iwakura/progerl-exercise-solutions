% ch 13, ex 6.
-module(visor_radical).
-export([start/0, start/1, work/0]).


start() ->
  spawn(?MODULE, start, [2]).

start(Num) when Num > 0 ->
  PidRefs = start_all(Num),
  supervise(PidRefs).

supervise(PidRefs) ->
  receive
    {'DOWN', Ref, process, Pid, Reason} ->
      case lists:member({Pid, Ref}, PidRefs) of
        true ->
          demonitor(Ref),
          io:format("Process ~p died because of: ~p~n", [Pid, Reason]),
          stop_all(lists:delete(Pid, PidRefs)),
          NewPidRefs = start_all(length(PidRefs));
        false ->
          NewPidRefs = PidRefs
    end
  end,
  supervise(NewPidRefs).

stop_all([]) ->
  ok;
stop_all([{Pid, Ref} | Rest]) ->
  demonitor(Ref),
  exit(Pid, restart),
  stop_all(Rest).

start_all(Num) ->
  [spawn_monitor(?MODULE, work, []) || _Idx <- lists:seq(1, Num)].

work() ->
  receive
    stop ->
      stop
  after infinity ->
    true
  end.
