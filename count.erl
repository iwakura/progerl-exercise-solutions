% ch 19, ex 2.
-module(count).
-export([init/0, me/2, count/2]).
-export([index/2]).

init() ->
  ets:new(?MODULE, [set, protected, named_table]).

me(Mod, Line) ->
  Idx = index(Mod, Line),
  N = count(Idx),
  ets:insert(?MODULE, {Idx, N + 1}).

count(Mod, Line) ->
  Idx = index(Mod, Line),
  count(Idx).

count(Idx) ->
  case ets:lookup(?MODULE, Idx) of
    [] ->
      0;
    [{Idx, N}] ->
      N
  end.

index(Mod, Line) ->
  term_to_binary({Mod, Line}).
