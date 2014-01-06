% ch 7, ex 4.
-module(bincho_test).
-export([run/0]).

run() ->
  test_packet_generator().

test_packet_generator() ->
  Terms = [ok, [1,2,3], {ok, 200}, <<"human">>, [123, <<>>]],
  lists:foreach(fun test_packet_generation/1, Terms),
  lists:foreach(fun test_packet_generator/1, Terms).

test_packet_generator(Term) ->
  try bincho:packet_to_term(bincho:term_to_packet(Term)) of
    Term ->
      io:format("."),
      ok;
    Other ->
      io:format("Decoded term (~p) differs from original: ~p~n", [Other, Term]),
      fail
  catch _:_ ->
    io:format("Failed decode packet with term: ~p~n", [Term]),
    fail
  end.

test_packet_generation(Term) ->
  try is_bitstring(bincho:term_to_packet(Term)) of
    true ->
      io:format("."),
      ok;
    Other ->
      io:format("Encoded term (~p) from ~p is not a binary.~n", [Other, Term]),
      fail
  catch _:_ ->
    io:format("Failed encode packet with term: ~p~n", [Term]),
    fail
  end.
