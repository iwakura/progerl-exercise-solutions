% ch 7, exs 1,2,3.
-module(bincho).
-export([rev_bytes/1, term_to_packet/1, packet_to_term/1]).

rev_bytes(Bin) when is_binary(Bin) ->
  list_to_binary(lists:reverse(binary_to_list(Bin))).

term_to_packet(Term) ->
  Data = term_to_binary(Term),
  Size = byte_size(Data),
  <<Size:4, Data/binary>>.

packet_to_term(<<Size:4, Data:Size/binary>>) ->
  binary_to_term(Data).



