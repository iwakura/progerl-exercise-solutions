% pg 259, 260.
-module(lib_find).
-export([files/3, files_r/2, files_r/3]).
-include_lib("kernel/include/file.hrl").

files(Dir, Re, Recursive) ->
  Re1 = xmerl_regexp:sh_to_awk(Re),
  lists:reverse(files(Dir, Re1, Recursive, fun(File, Acc) ->[File|Acc] end, [])).

files(Dir, Reg, Recursive, Fun, Acc) ->
  case file:list_dir(Dir) of
    {ok, Files} -> find_files(Files, Dir, Reg, Recursive, Fun, Acc);
    {error, _} -> Acc
  end.

find_files([File|T], Dir, Reg, Recursive, Fun, Acc0) ->
  FullName = filename:join([Dir,File]),
  case file_type(FullName) of
    regular ->
      case re:run(FullName, Reg, [{capture,none}]) of
        match ->
          Acc = Fun(FullName, Acc0),
          find_files(T, Dir, Reg, Recursive, Fun, Acc);
        nomatch ->
          find_files(T, Dir, Reg, Recursive, Fun, Acc0)
      end;
    directory ->
      case Recursive of
        true ->
          Acc1 = files(FullName, Reg, Recursive, Fun, Acc0),
          find_files(T, Dir, Reg, Recursive, Fun, Acc1);
        false ->
          find_files(T, Dir, Reg, Recursive, Fun, Acc0)
      end;
    error ->
      find_files(T, Dir, Reg, Recursive, Fun, Acc0)
  end;
find_files([], _, _, _, _, A) ->
  A.

file_type(File) ->
  case file:read_file_info(File) of
    {ok, Facts} ->
      case Facts#file_info.type of
        regular -> regular;
        directory -> directory;
        _ -> error
      end;
    _ ->
      error
  end.

files_r(Dir, Re) ->
  files(Dir, Re, true).

files_r(Dir, Re, Fun) ->
  Reg = xmerl_regexp:sh_to_awk(Re),
  files(Dir, Reg, true, Fun, []).


