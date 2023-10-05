-module(homework6_sup).
-behaviour(supervisor).

-export([
    start_link/0,
    init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	P = [{homework6, {homework6, start_link, []},
		permanent, 5000, worker, [homework6]}],
	{ok, {{one_for_one, 10, 10}, P}}.