-module(homework6).
-behaviour(gen_server).

-export([start_link/0]).
-export([stop/0]).
-export([init/1]).

-export([handle_call/3]).
-export([handle_cast/2]).
-export([create/1]).
-export([insert/3]).
-export([insert/4]).
-export([lookup/2]).
-record(cashe,{value, expire_time}).
start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
    ok.

init([]) ->
    {ok, #{}}.

create(TableName) ->
   gen_server:call(?MODULE, TableName).

insert(TableName, Key, Value) ->
    gen_server:cast(?MODULE, {TableName, Key, Value}).

insert(TableName, Key, Value, Ttl) ->
    gen_server:cast(?MODULE, {TableName, Key, Value, Ttl}).

lookup(TableName, Key) ->
    gen_server:call(?MODULE, {TableName, Key}).

handle_call({TableName, Key}, _From, State) ->
    CurrentTime = erlang:system_time(seconds),
    Value = case ets:lookup(TableName, Key) of
        [{Key, #cashe{value = Value2, expire_time = undefined}}] ->
            Value2;
        [{Key, #cashe{value = Value2, expire_time = ExpireTime}}] when ExpireTime == undefined ->
            Value2;
        [{Key, #cashe{value = Value2, expire_time = ExpireTime}}] when is_integer(ExpireTime), ExpireTime > CurrentTime ->
            Value2;
        _ ->
            undefined
    end,
    {reply, Value, State};

handle_call(TableName, _From, State)->
    ets:new(TableName, [set, public, named_table]),
    {reply, ok, State}.

handle_cast({TableName, Key, Value}, State) ->
    ets:insert(TableName, {Key, #cashe{value = Value, expire_time = undefined}}),
     {noreply, State};

handle_cast({TableName, Key, Value, Ttl}, State) ->
      CurrentTime = erlang:system_time(seconds),
    ExpireAt = add_seconds(CurrentTime, Ttl),
    ets:insert(TableName, {Key, #cashe{value = Value, expire_time = ExpireAt}}),
    {noreply, State}.

add_seconds(Secs, Seconds) ->
    Secs + Seconds.