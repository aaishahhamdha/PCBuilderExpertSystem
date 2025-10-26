% HTTP handlers and build JSON collection

:- http_handler(root(.), http_redirect(moved, '/index.html'), []).
:- http_handler(root('api/build'), handle_build_request, [methods([get,post,options])]).
:- http_handler(root('api/alternatives'), handle_alternatives_request, [methods([get,post,options])]).
:- http_handler(root('api/components'), handle_components_request, [methods([get,post,options])]).
:- http_handler(root('api/explain'), handle_explain_request, [methods([get,post,options])]).
:- http_handler(root('api/trace'), handle_trace_request, [methods([get,post,options])]).
:- http_handler(root('api/confidence'), handle_confidence_request, [methods([get,post,options])]).

handle_build_request(Request) :-
    cors_enable(Request, [methods([get, post, options])]),
    member(method(Method), Request),
    (   Method = options
    ->  format('Status: 204~n~n')
    ;   Method = post
    ->  catch(
        (
            http_read_json_dict(Request, Input),
            atom_string(Budget, Input.budget),
            atom_string(Usage, Input.usage),
            (get_dict(gamingLevel, Input, GLString), GLString \= null -> atom_string(GamingLevel, GLString) ; GamingLevel = null),
            (get_dict(cpuPreference, Input, CPString), CPString \= null, CPString \= "none" -> atom_string(CpuPref, CPString) ; CpuPref = none),
            (get_dict(rgbImportance, Input, RGBString), RGBString \= null -> atom_string(RGBPref, RGBString) ; RGBPref = dont_care),
            (get_dict(coolingPreference, Input, CoolString), CoolString \= null -> atom_string(CoolingPref, CoolString) ; CoolingPref = either),

            retractall(user_choice(_,_)),
            retractall(recommended(_,_)),
            retractall(reasoning_trace(_,_,_)),
            retractall(confidence_factor(_,_)),
            retractall(inferred(_,_)),
            retractall(requirement(_,_)),
            retractall(recommended_candidates(_,_)),

            assert(user_choice(budget, Budget)),
            assert(user_choice(usage, Usage)),
            (GamingLevel \= null -> assert(user_choice(gaming_level, GamingLevel)) ; true),
            assert(user_choice(cpu_preference, CpuPref)),
            assert(user_choice(rgb_importance, RGBPref)),
            assert(user_choice(cooling_preference, CoolingPref)),

            (recommend_build -> 
                collect_build_json(BuildJSON),
                reply_json_dict(BuildJSON)
            ;
                get_reasoning_trace(Trace),
                reply_json_dict(_{
                    error: "Could not generate build", 
                    details: "Component selection failed",
                    trace: Trace
                }, [status(400)])
            )
        ),
        Error,
        (
            format(atom(ErrorMsg), 'Server error: ~w', [Error]),
            reply_json_dict(_{error: ErrorMsg}, [status(500)])
        )
    )).

handle_alternatives_request(Request) :-
    cors_enable(Request, [methods([get, post, options])]),
    member(method(Method), Request),
    (   Method = options
    ->  format('Status: 204~n~n')
    ;   (
    http_parameters(Request, [component(ComponentAtom, [atom, optional(true)])]),
    % If frontend requested a specific component and candidates exist from the last recommendation, return those
    (   nonvar(ComponentAtom), ComponentAtom \= '' , recommended_candidates(ComponentAtom, Candidates) ->
        reply_json_dict(_{component: ComponentAtom, alternatives: Candidates})
    ;   % No specific component requested - return error
        reply_json_dict(_{error: "Please specify a component parameter (cpu, gpu, motherboard, ram, storage, psu, case)"}, [status(400)])
    )
    )).

handle_components_request(Request) :-
    cors_enable(Request, [methods([get, post, options])]),
    member(method(Method), Request),
    (   Method = options
    ->  format('Status: 204~n~n')
    ;   (
        findall(_{name: N, brand: B, price: P, cores: C, score: S}, cpu(N, B, _, P, C, _, _, S), CPUs),
        findall(_{name: N, price: P, socket: So, score: S}, motherboard(N, So, _, P, _, _, S), Motherboards),
        findall(_{name: N, price: P, brand: B, score: S}, gpu(N, B, P, _, _, S), GPUs),
        reply_json_dict(_{cpus: CPUs, motherboards: Motherboards, gpus: GPUs})
    )).

handle_explain_request(Request) :-
    cors_enable(Request, [methods([get, post, options])]),
    member(method(Method), Request),
    (   Method = options
    ->  format('Status: 204~n~n')
    ;   (
        http_read_json_dict(Request, Input),
        atom_string(Component, Input.component),
        atom_string(ExplainType, Input.get('type', 'detailed')),
        (   ExplainType = 'why' ->
            generate_why_explanation(Component, Explanation)
        ;   ExplainType = 'how' ->
            generate_how_explanation(Component, Explanation)
        ;   generate_detailed_explanation(Component, Explanation)
        ),
        reply_json_dict(_{explanation: Explanation})
    )).

handle_trace_request(Request) :-
    cors_enable(Request, [methods([get, options])]),
    member(method(Method), Request),
    (   Method = options
    ->  format('Status: 204~n~n')
    ;   (
        get_reasoning_trace(Trace),
        reply_json_dict(_{trace: Trace})
    )).

handle_confidence_request(Request) :-
    cors_enable(Request, [methods([get, options])]),
    member(method(Method), Request),
    (   Method = options
    ->  format('Status: 204~n~n')
    ;   (
        findall(_{component: Component, confidence: Conf},
            confidence_factor(Component, Conf),
            Confidences),
        reply_json_dict(_{confidences: Confidences})
    )).

% Helper - collect build json
collect_build_json(JSON) :-
    recommended(cpu, [CPUName, CPUBrand, CPUSocket, CPUPrice, CPUCores, CPUThreads]),
    recommended(motherboard, [MoboName, MoboSocket, MoboChipset, MoboPrice, MoboRamType]),
    recommended(ram, [RAMName, RAMCapacity, RAMType, RAMSpeed, RAMPrice, RAMRGB]),
    recommended(gpu, [GPUName, GPUBrand, GPUPrice, GPUTDP]),
    recommended(storage, [StorageName, StorageType, StorageCapacity, StoragePrice]),
    recommended(psu, [PSUName, PSUWattage, PSUEff, PSUPrice]),
    recommended(case, [CaseName, CaseForm, CasePrice, CaseRGB, CaseAIO]),

    confidence_factor(cpu, CPUConf),
    confidence_factor(motherboard, MoboConf),
    confidence_factor(ram, RAMConf),
    confidence_factor(gpu, GPUConf),
    confidence_factor(storage, StorageConf),
    confidence_factor(psu, PSUConf),
    confidence_factor(case, CaseConf),

    TotalCost is CPUPrice + MoboPrice + RAMPrice + GPUPrice + StoragePrice + PSUPrice + CasePrice,
    OverallConfidence is (CPUConf + MoboConf + RAMConf + GPUConf + StorageConf + PSUConf + CaseConf) / 7,

    JSON = _{
        cpu: _{name: CPUName, brand: CPUBrand, socket: CPUSocket, price: CPUPrice, cores: CPUCores, threads: CPUThreads, confidence: CPUConf},
        motherboard: _{name: MoboName, socket: MoboSocket, chipset: MoboChipset, price: MoboPrice, ramType: MoboRamType, confidence: MoboConf},
        ram: _{name: RAMName, capacity: RAMCapacity, type: RAMType, speed: RAMSpeed, price: RAMPrice, hasRGB: RAMRGB, confidence: RAMConf},
        gpu: _{name: GPUName, brand: GPUBrand, price: GPUPrice, tdp: GPUTDP, confidence: GPUConf},
        storage: _{name: StorageName, type: StorageType, capacity: StorageCapacity, price: StoragePrice, confidence: StorageConf},
        psu: _{name: PSUName, wattage: PSUWattage, efficiency: PSUEff, price: PSUPrice, confidence: PSUConf},
        case: _{name: CaseName, formFactor: CaseForm, price: CasePrice, hasRGB: CaseRGB, aioSupport: CaseAIO, confidence: CaseConf},
        totalCost: TotalCost,
        overallConfidence: OverallConfidence,
        compatibility: _{socketMatch: true, ramTypeMatch: true, powerAdequate: true},
        inferenceMethod: 'hybrid_forward_backward_chaining'
    }.
