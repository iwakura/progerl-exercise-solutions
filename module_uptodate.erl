% ch 16, ex 1.
-module(module_uptodate).
-export([check/1]).


check(Mod) ->
  M = atom_to_list(Mod),
  SrcFile = lists:append([M, ".erl"]),
  BeamFile = lists:append([M, ".beam"]),
  SrcMt = filelib:last_modified(SrcFile),
  BeamMt = filelib:last_modified(BeamFile),
  case is_tuple(SrcMt) and is_tuple(BeamMt) of
    true ->
      calendar:datetime_to_gregorian_seconds(BeamMt) >= calendar:datetime_to_gregorian_seconds(SrcMt);
    _ ->
      error
  end.


