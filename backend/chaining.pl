% Forward and backward chaining helpers

forward_chain :-
    trace_reasoning(forward_chain, start, 'Beginning forward chaining'),
    retractall(inferred(_,_)),
    trace_reasoning(forward_chain, complete, 'Forward chaining complete').

prove_usage_requirements :-
    user_choice(usage, Usage),
    (usage_needs_cores(Usage, MinCores, _) -> true ; MinCores = 4),
    (usage_needs_ram(Usage, MinRAM, _) -> true ; MinRAM = 8),
    format(atom(ReqMsg), 'Proven: Usage requirements for ~w (MinCores: ~w, MinRAM: ~wGB)', [Usage, MinCores, MinRAM]),
    trace_reasoning(backward_chain, usage_requirements, ReqMsg),
    assert(requirement(cores, MinCores)),
    assert(requirement(ram, MinRAM)).

prove_gaming_requirements :-
    user_choice(usage, gaming),
    (user_choice(gaming_level, Level) -> true ; Level = '1080p'),
    (gaming_needs_gpu(Level, RequiredTier, _) -> true ; RequiredTier = budget),
    format(atom(GamingMsg), 'Proven: Gaming requirements for ~w (GPU tier: ~w)', [Level, RequiredTier]),
    trace_reasoning(backward_chain, gaming_requirements, GamingMsg),
    assert(requirement(gpu_tier, RequiredTier)).

prove_rgb_requirements :-
    (user_choice(rgb_importance, RGBPref) -> true ; RGBPref = dont_care),
    (RGBPref = very_important -> 
        assert(requirement(rgb_ram, yes)),
        assert(requirement(rgb_case, yes)),
        trace_reasoning(backward_chain, rgb_requirements, 'RGB very important: requiring RGB components')
    ; RGBPref = nice_to_have ->
        assert(requirement(rgb_preference, nice_to_have)),
        trace_reasoning(backward_chain, rgb_requirements, 'RGB nice to have: preferring RGB components')
    ; 
        trace_reasoning(backward_chain, rgb_requirements, 'RGB not important: no RGB requirements')
    ).

prove_cooling_requirements :-
    (user_choice(cooling_preference, CoolingPref) -> true ; CoolingPref = either),
    (CoolingPref = aio ->
        assert(requirement(aio_support, yes)),
        trace_reasoning(backward_chain, cooling_requirements, 'AIO cooling preferred: case must support AIO')
    ; CoolingPref = air ->
        assert(requirement(air_preference, yes)),
        trace_reasoning(backward_chain, cooling_requirements, 'Air cooling preferred: prioritizing non-AIO cases')
    ;
        trace_reasoning(backward_chain, cooling_requirements, 'No cooling preference: any case acceptable')
    ).
