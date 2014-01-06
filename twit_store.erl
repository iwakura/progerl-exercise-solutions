% ch 16, ex 5.
-module(twit_store).
-export([init/1, store/2, fetch/1]).
-define(T_LEN, 140).

init(N) ->
  {ok, Storage} = file:open(storage(), [raw, write, binary]),
  Length = N * 8 * ?T_LEN,
  Content = <<0:Length>>,
  file:pwrite(Storage, 0, Content),
  file:close(Storage).

store(N, Buf) when is_list(Buf), is_integer(N), N > 0 ->
  store(N, list_to_binary(Buf));

% read, write to preserve existing data
store(N, Buf) when is_binary(Buf) ->
  NewContent = place_content(storage(), N, Buf),
  {ok, Storage} = file:open(storage(), [raw, write, binary]),
  ok = file:pwrite(Storage, 0, NewContent),
  file:close(Storage).

fetch(N) when is_integer(N), N > 0 ->
  {ok, Storage} = file:open(storage(), [raw, read, binary]),
  {ok, Content} = file:pread(Storage, (N - 1) * ?T_LEN, ?T_LEN),
  file:close(Storage),
  strip_zeros(Content).

strip_zeros(Line) ->
   re:replace(Line, "\\0+", "", [{return,list}, global]).

place_content(File, N, Buf) ->
  {ok, OldContent} = file:read_file(File),
  IntroLen = ?T_LEN * (N - 1),
  <<Intro:IntroLen/binary, _Prev:?T_LEN/binary, Rest/binary>> = OldContent,
  PadLength = (?T_LEN - byte_size(Buf)) * 8,
  <<Intro/binary, Buf/binary, 0:PadLength, Rest/binary>>.


storage() ->
  "/tmp/storage.dat".
