-module(homework6_app).
-behaviour(application).

- export([
    start/2,
    stop/1
]).

start(_, _) ->
    homework6_sup:start_link().

stop(_) ->
    ok.