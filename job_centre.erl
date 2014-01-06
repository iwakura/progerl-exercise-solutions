% ch 22, ex 1-3.
-module(job_centre).
-behavior(gen_server).
-export([start_link/0, stop/0, add_job/1, work_wanted/0, job_done/1, statistics/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-include_lib("job_centre.hrl").

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

stop() ->
  gen_server:call(?MODULE, stop).

add_job(Fun) ->
  gen_server:call(?MODULE, {add, Fun}).

work_wanted() ->
  gen_server:call(?MODULE, get).

job_done(JobNumber) ->
  gen_server:call(?MODULE, {done, JobNumber}).

statistics() ->
  gen_server:call(?MODULE, stats).

init([]) ->
  {ok, #jobs{}}.

handle_call({add, Fun}, _From, #jobs{num=Num, queue=Queue, progress=_Progress, done=_Done} = Jobs) ->
  NewQueue = lists:reverse([{Num+1, Fun} | lists:reverse(Queue)]),
  {reply, Num+1, Jobs#jobs{num=Num+1, queue=NewQueue}};

handle_call(get, _From, #jobs{num=_Num, queue=[], progress=_Progress, done=_Done} = Jobs) ->
  {reply, no, Jobs};

handle_call(get, {Pid, _Ref}, #jobs{num=_Num, queue=[{Num, Fun} | Rest], progress=Progress, done=_Done} = Jobs) ->
  Job = {Num, Fun},
  PJob = {Num, Fun, Pid},
  monitor(process, Pid),
  {reply, Job, Jobs#jobs{queue=Rest, progress=[PJob | Progress]}};

handle_call({done, JobNumber}, _From, #jobs{num=_Num, progress=Progress, done=Done} = Jobs) ->
  NewProgress = lists:filter(fun({Num, _Fun, _Worker}) -> Num =/= JobNumber end, Progress),
  {reply, ok, Jobs#jobs{done=[JobNumber | Done], progress=NewProgress}};

handle_call(stats, _From, #jobs{num=Num, queue=Queue, progress=Progress, done=Done} = Jobs) ->
  Stats = #jobs_stats{num=Num, queue=length(Queue), progress=length(Progress), done=length(Done)},
  {reply, Stats, Jobs};

handle_call(stop, _From, Jobs) ->
  {stop, normal, stopped, Jobs}.

handle_cast(_Msg, Jobs) ->
  {noreply, Jobs}.

handle_info({'DOWN', Ref, process, Pid, _}, #jobs{num=_Num, queue=Queue, progress=Progress, done=_Done} = Jobs) ->
  demonitor(Ref),
  {NewProgress, Failed} = lists:partition(fun({_N, _Fun, Worker}) -> Pid =/= Worker end, Progress),
  Return = [{N, F} || {N, F, _Pid} <- Failed],
  NewQueue = lists:append(lists:reverse(Return), Queue),
  {noreply, Jobs#jobs{progress=NewProgress, queue=NewQueue}};

handle_info(_Msg, Jobs) ->
  {noreply, Jobs}.

terminate(_Reason, _Jobs) ->
  ok.

code_change(_Ver, Jobs, _Extra) ->
  {ok, Jobs}.

