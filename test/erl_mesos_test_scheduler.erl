-module(erl_mesos_test_scheduler).

-behaviour(erl_mesos_scheduler).

-include_lib("erl_mesos.hrl").

-export([init/1,
         registered/2,
         error/2,
         handle_info/2,
         terminate/2]).

-record(state, {callback,
                test_pid}).

init(Options) ->
    FrameworkInfo = framework_info(Options),
    TestPid = proplists:get_value(test_pid, Options),
    {ok, FrameworkInfo, true, #state{callback = init,
                                     test_pid = TestPid}}.

registered(SubscribedPacket, #state{test_pid = TestPid} = State) ->
    %%reply(TestPid, {subscribed_packet})
    {ok, registered_state}.

error(#error_event{} = ErrorPacket, State) ->
    io:format("Error callback. Error packet: ~p, state: ~p~n",
              [ErrorPacket, State]),
    {ok, error_state}.

handle_info(_Info, State) ->
    {ok, State}.

terminate(_Reason, State) ->
    {ok, State}.

framework_info(Options) ->
    User = proplists:get_value(user, Options, <<>>),
    Name = proplists:get_value(name, Options, <<>>),
    Id = proplists:get_value(id, Options, undefined),
    FailoverTimeout = proplists:get_value(failover_timeout, Options, undefined),
    Checkpoint = proplists:get_value(checkpoint, Options, undefined),
    Role = proplists:get_value(role, Options, undefined),
    Hostname = proplists:get_value(hostname, Options, undefined),
    Principal = proplists:get_value(principal, Options, undefined),
    WebuiUrl = proplists:get_value(webui_url, Options, undefined),
    Capabilities = proplists:get_value(capabilities, Options, undefined),
    Labels = proplists:get_value(labels, Options, undefined),
    #framework_info{user = User,
                    name = Name,
                    id = Id,
                    failover_timeout = FailoverTimeout,
                    checkpoint = Checkpoint,
                    role = Role,
                    hostname = Hostname,
                    principal = Principal,
                    webui_url = WebuiUrl,
                    capabilities = Capabilities,
                    labels = Labels}.

reply(undefined, _Message) ->
    undefined;
reply(TestPid, Message) ->
    TestPid ! Message.
