infer_facts :-
    trace_reasoning(recommendation_engine, start, 'Beginning facts inferring'),
    retractall(inferred(_,_)),
    infer_from_budget,
    infer_from_usage,
    infer_from_gaming,
    infer_from_rgb,
    infer_from_cooling.

% Infer facts from budget tier
infer_from_budget :-
    user_choice(budget, Budget),
    (Budget = entry_level ->
        assert(inferred(price_conscious, yes)),
        assert(inferred(max_cpu_price, 200)),
        assert(inferred(max_gpu_price, 300)),
        trace_reasoning(recommendation_engine, budget, 'Inferred: Price conscious, limited component budget')
    ; Budget = mid_range ->
        assert(inferred(balanced_performance, yes)),
        assert(inferred(max_cpu_price, 400)),
        assert(inferred(max_gpu_price, 600)),
        trace_reasoning(recommendation_engine, budget, 'Inferred: Balanced performance target')
    ; Budget = high_end ->
        assert(inferred(performance_priority, yes)),
        assert(inferred(premium_acceptable, yes)),
        trace_reasoning(recommendation_engine, budget, 'Inferred: Performance priority, premium components acceptable')
    ; Budget = enthusiast ->
        assert(inferred(no_compromises, yes)),
        assert(inferred(flagship_tier, yes)),
        trace_reasoning(recommendation_engine, budget, 'Inferred: No compromises, flagship components expected')
    ; true).

% Infer facts from usage
infer_from_usage :-
    user_choice(usage, Usage),
    (Usage = gaming ->
        assert(inferred(gpu_priority, high)),
        assert(inferred(cpu_priority, medium)),
        trace_reasoning(recommendation_engine, usage, 'Inferred: Gaming use - GPU priority high')
    ; Usage = content_creation ->
        assert(inferred(cpu_priority, high)),
        assert(inferred(ram_priority, high)),
        assert(inferred(multicore_needed, yes)),
        trace_reasoning(recommendation_engine, usage, 'Inferred: Content creation - CPU and RAM priority')
    ; Usage = programming ->
        assert(inferred(cpu_priority, medium)),
        assert(inferred(ram_priority, high)),
        assert(inferred(ssd_priority, high)),
        trace_reasoning(recommendation_engine, usage, 'Inferred: Programming - Fast storage and RAM important')
    ; Usage = office ->
        assert(inferred(efficiency_priority, yes)),
        assert(inferred(quiet_operation, preferred)),
        trace_reasoning(recommendation_engine, usage, 'Inferred: Office use - Efficiency and quiet operation')
    ; true).

% Infer facts from gaming preferences
infer_from_gaming :-
    (user_choice(usage, gaming) ->
        (user_choice(gaming_level, Level) ->
            (Level = '4k' ->
                assert(inferred(needs_flagship_gpu, yes)),
                assert(inferred(high_power_consumption, yes)),
                assert(inferred(min_psu_wattage, 850)),
                trace_reasoning(recommendation_engine, gaming, 'Inferred: 4K gaming needs flagship GPU and high wattage PSU')
            ; Level = '1440p_high' ->
                assert(inferred(needs_high_end_gpu, yes)),
                assert(inferred(min_psu_wattage, 750)),
                trace_reasoning(recommendation_engine, gaming, 'Inferred: 1440p high needs high-end GPU')
            ; Level = '1080p' ->
                assert(inferred(needs_mid_range_gpu, yes)),
                assert(inferred(min_psu_wattage, 650)),
                trace_reasoning(recommendation_engine, gaming, 'Inferred: 1080p gaming needs mid-range GPU')
            ; true)
        ; true)
    ; true).

% Infer facts from RGB preferences
infer_from_rgb :-
    (user_choice(rgb_importance, RGBPref) ->
        (RGBPref = very_important ->
            assert(inferred(aesthetics_priority, high)),
            assert(inferred(needs_rgb_components, yes)),
            trace_reasoning(recommendation_engine, rgb, 'Inferred: Aesthetics important, need RGB components')
        ; RGBPref = nice_to_have ->
            assert(inferred(aesthetics_priority, medium)),
            trace_reasoning(recommendation_engine, rgb, 'Inferred: Aesthetics considered but not critical')
        ; true)
    ; true).

% Infer facts from cooling preferences
infer_from_cooling :-
    (user_choice(cooling_preference, CoolingPref) ->
        (CoolingPref = aio ->
            assert(inferred(needs_aio_support, yes)),
            assert(inferred(case_size_preference, larger)),
            trace_reasoning(recommendation_engine, cooling, 'Inferred: AIO cooling needs case with radiator support')
        ; CoolingPref = air ->
            assert(inferred(prefer_simplicity, yes)),
            assert(inferred(lower_maintenance, yes)),
            trace_reasoning(recommendation_engine, cooling, 'Inferred: Air cooling preference - simpler maintenance')
        ; true)
    ; true).

infer_usage_requirements :-
    user_choice(usage, Usage),
    (usage_needs_cores(Usage, MinCores, _) -> true ; MinCores = 4),
    (usage_needs_ram(Usage, MinRAM, _) -> true ; MinRAM = 8),
    format(atom(ReqMsg), 'Usage requirements for ~w (MinCores: ~w, MinRAM: ~wGB)', [Usage, MinCores, MinRAM]),
    trace_reasoning(recommendation_engine, usage_requirements, ReqMsg),
    assert(requirement(cores, MinCores)),
    assert(requirement(ram, MinRAM)).

infer_gaming_requirements :-
    user_choice(usage, gaming),
    (user_choice(gaming_level, Level) -> true ; Level = '1080p'),
    (gaming_needs_gpu(Level, RequiredTier, _) -> true ; RequiredTier = budget),
    format(atom(GamingMsg), 'Gaming requirements for ~w (GPU tier: ~w)', [Level, RequiredTier]),
    trace_reasoning(recommendation_engine, gaming_requirements, GamingMsg),
    assert(requirement(gpu_tier, RequiredTier)).

infer_rgb_requirements :-
    (user_choice(rgb_importance, RGBPref) -> true ; RGBPref = dont_care),
    (RGBPref = very_important -> 
        trace_reasoning(recommendation_engine, rgb_requirements, 'RGB very important: requiring RGB components')
    ; RGBPref = nice_to_have ->
        trace_reasoning(recommendation_engine, rgb_requirements, 'RGB nice to have: preferring RGB components')
    ; 
        trace_reasoning(recommendation_engine, rgb_requirements, 'RGB not important: no RGB requirements')
    ).

infer_cooling_requirements :-
    (user_choice(cooling_preference, CoolingPref) -> true ; CoolingPref = either),
    (CoolingPref = aio ->
        trace_reasoning(recommendation_engine, cooling_requirements, 'AIO cooling preferred: case must support AIO')
    ; CoolingPref = air ->
        trace_reasoning(recommendation_engine, cooling_requirements, 'Air cooling preferred: prioritizing non-AIO cases')
    ;
        trace_reasoning(recommendation_engine, cooling_requirements, 'No cooling preference: any case acceptable')
    ).
