% ch 19, ex 1.
-module(funbase).
-export([populate/0, lookup/2]).

populate() ->
  Tab = ets:new(?MODULE, [bag, private, named_table]),
  add_functions(Tab).

add_functions(Tab) ->
  [ [ ets:insert(Tab, {{Fn, Arity}, Mod}) || {Fn, Arity} <- exports(Mod)] || Mod <- lib_mods()].

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
  ets:lookup(?MODULE, {Name, Arity}).

