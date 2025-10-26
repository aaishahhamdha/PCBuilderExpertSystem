% Reasoning trace utilities

trace_reasoning(Type, Subject, Message) :-
    get_time(Timestamp),
    assertz(reasoning_trace(Type, Subject, Message-Timestamp)).

get_reasoning_trace(Trace) :-
    findall(_{type: Type, subject: Subject, message: Msg, timestamp: Time},
        reasoning_trace(Type, Subject, Msg-Time),
        Trace).
