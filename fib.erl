-module(fib).
-export([fib/1, fib2/1]).

fib(1) ->
  1;
fib(2) ->
  1;
fib(N) when N > 2->
  fib(N - 1) + fib(N - 2).

fib2(1) ->
  1;
fib2(2) ->
  1;
fib2(N) when N > 2 ->
  fib2(1, 1, N, 3).

fib2(X, Y, N, N) ->
  X + Y;
fib2(X, Y, N, C) ->
  fib2(Y, X + Y, N, C + 1).


