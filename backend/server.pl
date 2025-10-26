% ============================================================================
% PC Builder Expert System - Entrypoint
% ============================================================================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_cors)).

:- set_setting(http:cors, [*]).

% Include separated files (keeps original predicates but split by purpose)
:- include('state.pl').
:- include('kb.pl').
:- include('tiers.pl').
:- include('rules.pl').
:- include('confidence.pl').
:- include('trace.pl').
:- include('chaining.pl').
:- include('scoring.pl').
:- include('recommend.pl').
:- include('explanations.pl').
:- include('handlers.pl').

% Server control
start_server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    format('~n=== PC Builder Expert System ===~n', []),
    format('Server running on http://localhost:~w~n', [Port]),
    format('~nReady!~n~n', []).

stop_server(Port) :- http_stop_server(Port, []), format('Server stopped.~n', []).

server :- start_server(8080).