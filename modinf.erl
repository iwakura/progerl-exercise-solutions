% ch8, ex2.
-module(modinf).
-export([pop_fun_names/0, exclusive_fun_names/0, uniq/1]).

pop_fun_names() ->
  Counters = count_occurences(function_names()),
  lists:reverse(lists:keysort(2, Counters)).

exclusive_fun_names() ->
  Counters = count_mod_occurences(uniq(funmod())),
  [F || {F, Num} <- Counters, Num =:= 1 ].


count_occurences(List) ->
  count_occurences(List, []).

count_occurences([], Acc) ->
  Acc;
count_occurences([H|T], Acc) ->
  NewAcc =
  case lists:keyfind(H, 1, Acc) of
    { H, Cnt } ->
      [ {H, Cnt + 1} | lists:keydelete(H, 1, Acc)];
    false ->
      [ {H, 1} | Acc]
  end,
  count_occurences(T, NewAcc).


count_mod_occurences(List) ->
  count_mod_occurences(List, []).

count_mod_occurences([], Acc) ->
  Acc;
count_mod_occurences([{F, _M}|T], Acc) ->
  NewAcc =
  case lists:keyfind(F, 1, Acc) of
    { F, Cnt } ->
      [ {F, Cnt + 1} | lists:keydelete(F, 1, Acc)];
    false ->
      [ {F, 1} | Acc]
  end,
  count_mod_occurences(T, NewAcc).

function_names() ->
  lists:flatten([ [ F || {F, _Ar} <- Mod:module_info(exports)] || {Mod, _Path} <- code:all_loaded()]).

funmod() ->
  lists:flatten([ [ {F, Mod} || {F, _Ar} <- Mod:module_info(exports)] || {Mod, _Path} <- code:all_loaded()]).

uniq(List) ->
  uniq(List, []).

uniq([], Acc) ->
  Acc;
uniq([H|T], Acc) ->
  case lists:member(H, Acc) of
    true ->
      uniq(T, Acc);
    false ->
      uniq(T, [H | Acc])
  end.
