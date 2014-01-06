% ch 19, ex 1.
-module(funbase_dets).
-export([open/1, close/0, lookup/2]).

open(File) ->
  Exists = filelib:is_file(File),
  DefParams = [{file, File}, {type, bag}],
  DetsParams =
  if
    Exists ->
      [ {access, read} | DefParams ];
    true ->
      DefParams
  end,
  case dets:open_file(?MODULE, DetsParams) of
    {ok, ?MODULE} ->
      case Exists of
        true -> ok;
        false -> populate()
      end;
    {error, Reason} ->
      io:format("Unable open dets table ~p because of ~p~n", [File, Reason]),
      exit({dets_open_fail, File, Reason})
  end.

close() ->
  dets:close(?MODULE).


populate() ->
  lists:foreach(fun(E) -> dets:insert(?MODULE, E) end, functions()).


functions() ->
  [ {FA, Mod} || Mod <- lib_mods(), FA <- exports(Mod) ].

lib_mods() ->
  MF2 = fun(N, Acc) -> [re:run(N, "ebin/(.+)\\.beam\$", [{capture, [1], list}])| Acc] end,
  [ list_to_atom(Mod) || {match, [Mod]} <- lib_find:files_r(code:lib_dir(), "*.beam", MF2)].

exports(Mod) ->
  try Mod:module_info(exports) of
    List ->
      List
  catch
    _:_ ->
      []
  end.

lookup(Name, Arity) ->
  [Mod || {{_F, _Ar}, Mod} <- dets:lookup(?MODULE, {Name, Arity})].

