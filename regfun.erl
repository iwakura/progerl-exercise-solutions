% ch 12, ex 1.
-module(regfun).
-export([start/2]).

start(Name, Fun) ->
  case whereis(Name) of
    undefined ->
      Pid = spawn(fun() -> Fun() end),
      register(Name, Pid);
    _ ->
      error
  end.

