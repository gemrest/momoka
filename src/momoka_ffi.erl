-module(momoka_ffi).
-export([gemini_request/5]).

gemini_request(Host, Port, Request, TimeoutMilliseconds, MaximumBytes) ->
    Deadline = erlang:monotonic_time(millisecond) + TimeoutMilliseconds,
    HostName = binary_to_list(Host),
    % Most capsules use self-signed certificates, so there is no chain of trust
    % to verify against.
    Options = [binary, {active, false}, {verify, verify_none},
               {server_name_indication, HostName}],

    case ssl:connect(HostName, Port, Options, TimeoutMilliseconds) of
        {ok, Socket} ->
            Result = case ssl:send(Socket, Request) of
                ok -> receive_all(Socket, Deadline, MaximumBytes, <<>>);
                {error, Reason} -> {error, Reason}
            end,

            ssl:close(Socket),
            Result;
        {error, Reason} ->
            {error, Reason}
    end.

receive_all(_Socket, _Deadline, MaximumBytes, Received)
  when byte_size(Received) > MaximumBytes ->
    {error, response_too_large};
receive_all(Socket, Deadline, MaximumBytes, Received) ->
    RemainingMilliseconds = max(0, Deadline - erlang:monotonic_time(millisecond)),

    % Gemini servers end a response by closing the connection, often without a
    % TLS close_notify, so a closed socket marks the end of the body.
    case ssl:recv(Socket, 0, RemainingMilliseconds) of
        {ok, Data} ->
            receive_all(Socket, Deadline, MaximumBytes, <<Received/binary, Data/binary>>);
        {error, closed} ->
            {ok, Received};
        {error, Reason} ->
            {error, Reason}
    end.
