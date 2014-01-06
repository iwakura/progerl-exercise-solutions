% ch 12, ex 3.
-module(ringb).
-export([bm/2, start/2]).



bm(N, M) ->
  ProcsBefore = length(erlang:processes()),
  Pid = start(N),
  {Pid, T1, T2} = rpc(Pid, {self(), M}),
  io:format("With ~p processes and ~p loops: ~p (~p) microseconds~n", [N, M, T1/1000, T2/1000]),
  ProcsAfter = length(erlang:processes()),
  stop(Pid),
  ProcsAfterStop = length(erlang:processes()),
  io:format("Procs delta: ~p -> ~p~n", [ProcsAfter - ProcsBefore, ProcsAfterStop - ProcsAfter]).

stop(Pid) ->
  Pid ! stop.

start(N) ->
  spawn(?MODULE, start, [N, undefined]).

start(N, undefined) when N > 1 ->
  Next = spawn(?MODULE, start, [N-1, self()]),
  loop(Next, self());
start(1, Start) ->
  loop(Start, Start);
start(N, Start) when N > 1 ->
  Next = spawn(?MODULE, start, [N-1, Start]),
  loop(Next, Start).


loop(Next, Start) ->
  receive
    {Pid, M} ->
      put(caller, Pid),
      start_bm(),
      Next ! M,
      loop(Next, Start);
    stop ->
      Next ! stop;
    1 ->
      case self() of
        Start ->
          send_report();
        _ ->
          Next ! 1
      end,
      loop(Next, Start);
    M ->
      case self() of
        Start ->
          Next ! M - 1;
        _ ->
          Next ! M
      end,
      loop(Next, Start)
  end.


start_bm() ->
  statistics(runtime),
  statistics(wall_clock).

send_report() ->
  {_, Time1} = statistics(runtime),
  {_, Time2} = statistics(wall_clock),
  Pid = get(caller),
  Pid ! {self(), Time1, Time2}.

rpc(Pid, Msg) ->
  Pid ! Msg,
  receive
    Res  ->
      Res
  end.
