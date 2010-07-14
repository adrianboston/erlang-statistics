%%%-------------------------------------------------------------------
%%% File    : statistics.erl
%%% Author  :  whoppix <jwringstad@gmail.com>
%%% Description : 
%%%
%%% Created : 26 Jul 2009 by  <jwringstad@gmail.com>
%%%-------------------------------------------------------------------
-module(statistics).
-export([start/0, start_link/0, init/0, loop/0]).
-compile([export_all]).
-define(OUTFILE, "stats.jsn").
-define(INTERVAL, 1*1000). % in milliseconds



start_link() -> 
    proc_lib:start_link(?MODULE, init, []).
 
start() ->
    spawn(statistics, init, []).
 
init() ->
    io:format("Statistics: Statistic generator started.~n"),
    {ok, _} = timer:send_after(?INTERVAL, make_statistics),
    catch register(statistics, self()),
    catch proc_lib:init_ack({ok, self()}),
    loop().
 
loop() ->
    receive
	make_statistics ->
        {ok, _ } = timer:send_after(?INTERVAL, make_statistics),
        Mnesia = try get_mnesia_statistics() of
            Val -> Val
        catch
            _:_ -> []
        end,
        StatList = get_basic_statistics()
        ++ get_memory_statistics()
        ++ Mnesia
        ++ get_additional_statistics(),
        String = encode_statistics_json(StatList),
        write_line(String), 
        proc_lib:hibernate(?MODULE, loop, [])
    end,
    io:format("done~n"),
    ?MODULE:loop().
 
 
get_basic_statistics() -> % general statistics.
    {MegaSecs, Secs, _} = now(),
    Epoch = MegaSecs * 1000000 + Secs,
    {ContextSwitches, 0} = statistics(context_switches),
    {{input, Input}, {output, Output}} = statistics(io),
    RunningQueue = statistics(run_queue),
    KernelPoll = erlang:system_info(kernel_poll),
    ProcessCount = erlang:system_info(process_count),
    ProcessLimit = erlang:system_info(process_limit),
    Nodes = length(nodes()) + 1, % other nodes plus our own node
    Ports = length(erlang:ports()),
    ModulesLoaded = length(code:all_loaded()),
    [
        {<<"date">>, Epoch}, {<<"context_switches">>, ContextSwitches}, {<<"input">>, Input}, {<<"output">>, Output},
        {<<"running_queue">>, RunningQueue}, {<<"kernel_poll">>, KernelPoll}, {<<"process_count">>, ProcessCount},
        {<<"process_limit">>, ProcessLimit}, {<<"nodes">>, Nodes}, {<<"ports">>, Ports}, {<<"modules_loaded">>, ModulesLoaded}
    ].

get_memory_statistics() -> % memory statistics.
    MemoryUsage = erlang:memory(),
    JsonObjectMemoryUsage = {struct, lists:map(
            fun({A, B}) ->
                    {list_to_binary(atom_to_list(A)), B}
            end,
            MemoryUsage)},
    {GarbageCollections, _, 0} = statistics(garbage_collection),
    [{<<"memory_usage">>, JsonObjectMemoryUsage}, {<<"garbage_collections">>, GarbageCollections}].

get_mnesia_statistics() -> % mnesia statistics
    RunningNodes = length(mnesia:system_info(running_db_nodes)),
    PersistentNodes = length(mnesia:system_info(db_nodes)),
    HeldLocks = length(mnesia:system_info(held_locks)),
    QueuedLocks = length(mnesia:system_info(lock_queue)),
    KnownTables = length(mnesia:system_info(tables)),
    RunningTransactions = length(mnesia:system_info(transactions)),
    % The rest is cumulative.
    TransactionCommits = mnesia:system_info(transaction_commits),
    TransactionFailures = mnesia:system_info(transaction_failures),
    TransactionLogWrites = mnesia:system_info(transaction_log_writes),
    TransactionRestarts = mnesia:system_info(transaction_restarts),
    [
        {<<"running_nodes">>, RunningNodes}, 
        {<<"persistent_nodes">>, PersistentNodes},
        {<<"held_locks">>, HeldLocks},
        {<<"queued_locks">>, QueuedLocks},
        {<<"known_tables">>, KnownTables},
        {<<"running_transactions">>, RunningTransactions},
        {<<"transaction_commits">>, TransactionCommits},
        {<<"transaction_failures">>, TransactionFailures},
        {<<"transaction_log_writes">>, TransactionLogWrites},
        {<<"transaction_restarts">>, TransactionRestarts}
    ].
%get_additional_statistics() -> [].
get_additional_statistics() -> % To add generic statistics, uncomment and edit this function.
    [
        {<<"generic">>, {struct, [{<<"foo">>, 1}, {<<"bar">>, 2}]}}
    ].

 
write_line(String) ->
    {ok, IoDevice} = file:open(?OUTFILE, [append]),
    ok = file:write(IoDevice, list_to_binary(lists:flatten(String) ++ "\n")),
    ok = file:close(IoDevice).
 
encode_statistics_json(StatList) ->
    JsonObj = {struct, StatList},
    json(JsonObj).

json(Param) -> (mochijson2:encoder([{utf8, true}]))(Param).
