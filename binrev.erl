% ch 7, ex 5.
-module(binrev).
-export([reverse/1, reverse2/1,reverse3/1]).

-include_lib("eunit/include/eunit.hrl").

reverse(<<>>) ->
  <<>>;
reverse(Bin) ->
  list_to_binary(lists:reverse([rev_bits(<<B/integer>>) || B <- binary:bin_to_list(Bin)])).


rev_bits(<<A:1, B:1, C:1, D:1, E:1, F:1, G:1, H:1>>) ->
  <<H:1, G:1, F:1, E:1, D:1, C:1, B:1, A:1>>.

reverse2(Bin) ->
  reverse2(Bin, []).

reverse2(<<>>, Bits) ->
  join_bits(Bits);

reverse2(Bin, Bits) ->
  <<Bit:1/bits, Rest/bits>> = Bin,
  reverse2(Rest, [Bit | Bits]).

join_bits(Bits) ->
  << <<B/bits>> || B <- Bits >>.

reverse3(Bin) ->
  reverse3(Bin, <<>>).

reverse3(<<>>, Acc) ->
  Acc;
reverse3(<<H:1/bits, Rest/bits>>, Acc) ->
  reverse3(<<Rest/bits>>, <<H/bits, Acc/bits>>).



reverse_empty_binary_test() ->
  ?assertEqual(<<>>, reverse(<<>>)).
reverse_byte1_test() ->
  ?assertEqual(<<128>>, reverse(<<1>>)).
reverse_byte2_test() ->
  ?assertEqual(<<1>>, reverse(<<128>>)).
reverse_byte3_test() ->
  ?assertEqual(<<144>>, reverse(<<9>>)).
reverse_byte4_test() ->
  ?assertEqual(<<9>>, reverse(<<144>>)).
reverse_binary_test() ->
  ?assertEqual(<<2,1,0>>, reverse(<<0,128,64>>)).


