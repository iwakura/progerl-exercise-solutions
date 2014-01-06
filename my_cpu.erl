% ch 15, ex 3.
-module(my_cpu).
-export([info/0]).

info() ->
  Name = os:cmd("dmesg | grep CPU: | head -n 1 | cut -d : -f 2"),
  re:replace(Name, "\n|^\s", "", [{return,list}, global]).

