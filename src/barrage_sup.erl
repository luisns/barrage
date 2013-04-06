
-module(barrage_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    [{_, Type}] = ets:lookup(barrage, type),
    case Type of
        general ->
            {ok, { {one_for_one, 5, 10}, [
                {0, {barrage_general, start_link, []}, permanent, 10000, worker, [barrage_general]}
            ] } };
        commander ->
            {ok, { {one_for_one, 5, 10}, [
                {0, {barrage_commander, start_link, []}, permanent, 10000, worker, [barrage_commander]}
            ] } }
    end. 


