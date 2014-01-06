% ch 16, exs. 2,3.
-module(checksum).
-export([md5/1, md5b/1]).

-define(READ_PORTION, 1024000).

md5(File) ->
  {ok, Data} = file:read_file(File),
  Digest = erlang:md5(Data),
  cs_to_hex(Digest).


md5b(File) ->
  Digest = md5fp(File),
  cs_to_hex(Digest).

md5fp(File) ->
  {ok, Fd} = file:open(File, [read, binary, raw]),
  Context = erlang:md5_init(),
  Digest = md5fp(Fd, Context, 0),
  ok = file:close(Fd),
  Digest.

md5fp(Fd, Context, Offset) ->
  case file:pread(Fd, Offset, ?READ_PORTION) of
    {ok, Data} ->
      NewContext = erlang:md5_update(Context, Data),
      NewOffset = Offset + ?READ_PORTION,
      md5fp(Fd, NewContext, NewOffset);
    eof ->
      erlang:md5_final(Context)
  end.

cs_to_hex(Bin) when is_binary(Bin) ->
  integer_to_list(binary:decode_unsigned(Bin), 16).

