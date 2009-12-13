%%%-------------------------------------------------------------------
%%% File    : statistics.erl
%%% Author  :  whoppix <jwringstad@gmail.com>
%%% Description : 
%%%
%%% Created : 26 Jul 2009 by  <jwringstad@gmail.com>
%%%-------------------------------------------------------------------
-module(statistics).
-export([start/0, start_link/0, init/0, loop/0]).

-define(OUTFILE, "stats.jsn").
-define(INTERVAL, 10*1000). % in milliseconds



start_link() -> 
    proc_lib:start_link(?MODULE, init, []).
 
start() ->
    spawn(statistics, init, []).
 
init() ->
    io:format("Statistics: Statistic generator started.~n"),
    {ok, _} = timer:send_after(?INTERVAL, make_statistics),
    catch register(statistics, self()),
    proc_lib:init_ack({ok, self()}),
    loop().
 
loop() ->
    receive
	make_statistics ->
        io:format("Making stats...~n"),
        {ok, _ } = timer:send_after(?INTERVAL, make_statistics),
        {Date, MemoryUsage, ContextSwitches, GarbageCollections, IO, RunningQueue, KernelPoll, ProcessCount, ProcessLimit}
        = get_statistics(),
        String = encode_statistics_json(Date, MemoryUsage, ContextSwitches, GarbageCollections, IO,
            RunningQueue, KernelPoll, ProcessCount, ProcessLimit),
        write_line(String), 
        proc_lib:hibernate(?MODULE, loop, [])
    end.
 
 
get_statistics() ->
    {MegaSecs, Secs, _} = now(),
    Epoch = MegaSecs * 1000000 + Secs,
    MemoryUsage = erlang:memory(),
    {ContextSwitches, 0} = statistics(context_switches),
    {GarbageCollections, _, 0} = statistics(garbage_collection),
    {{input, Input}, {output, Output}} = statistics(io),
    RunningQueue = statistics(run_queue),
    KernelPoll = erlang:system_info(kernel_poll),
    ProcessCount = erlang:system_info(process_count),
    ProcessLimit = erlang:system_info(process_limit),
    {Epoch, MemoryUsage, ContextSwitches, GarbageCollections, 
        {Input, Output}, RunningQueue, KernelPoll, ProcessCount, ProcessLimit}.
 
write_line(String) ->
    {ok, IoDevice} = file:open(?OUTFILE, [append]),
    ok = file:write(IoDevice, list_to_binary(lists:flatten(String) ++ "\n")),
    ok = file:close(IoDevice).
 
encode_statistics_json(Epoch, MemoryUsage, ContextSwitches, GarbageCollections, {Input, Output},
    RunningQueue, KernelPoll, ProcessCount, ProcessLimit) ->
    
    JsonObjMemoryUsage = {struct, lists:map(
            fun({A, B}) -> 
                    {list_to_binary(atom_to_list(A)), B} 
            end, 
            MemoryUsage)},
 
    JsonObj = {struct, [
        {<<"date">>, Epoch}, 
        {<<"memory_usage">>, JsonObjMemoryUsage}, 
        {<<"context_switches">>, ContextSwitches},
        {<<"garbage_collections">>, GarbageCollections},
        {<<"input">>, Input},
        {<<"output">>, Output},
        {<<"running_queue">>, RunningQueue},
        {<<"kernel_poll">>, KernelPoll},
        {<<"process_count">>, ProcessCount},
        {<<"process_limit">>, ProcessLimit}
    ]},
    json(JsonObj).

json(Param) -> (mochijson2:encoder([{utf8, true}]))(Param).
