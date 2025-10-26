% Recommendation engine (per-component recommenders)

recommend_build :-
    trace_reasoning(main, start, 'Starting recommendation'),
    forward_chain,
    prove_usage_requirements,
    catch(
        (user_choice(usage, gaming) -> prove_gaming_requirements ; true),
        _,
        true
    ),
    catch(prove_rgb_requirements, _, true),
    catch(prove_cooling_requirements, _, true),
    recommend_cpu_robust,
    recommend_motherboard_robust,
    recommend_ram_robust,
    recommend_gpu_robust,
    recommend_storage_robust,
    recommend_psu_robust,
    recommend_case_robust,
    trace_reasoning(main, complete, 'Build complete').

% CPU
recommend_cpu_robust :-
    user_choice(budget, BudgetTier),
    user_choice(usage, Usage),
    (requirement(cores, MinCores) -> true ; MinCores = 4),
    user_choice(cpu_preference, Pref),
    format(atom(StartMsg), 'Searching for CPU: Budget=~w, Usage=~w, MinCores=~w, Preference=~w', [BudgetTier, Usage, MinCores, Pref]),
    trace_reasoning(recommendation, cpu, StartMsg),
    
    % Stage 1: Try with preference and core requirement
    findall([Name, Brand, Socket, Price, Cores, Threads, CPUTier, Score],
        (   cpu(Name, Brand, Socket, Price, Cores, Threads, CPUTier, Score),
            (Pref = none ; Pref = build ; Brand = Pref),
            Cores >= MinCores,
            can_afford(BudgetTier, CPUTier)
        ), Stage1),
    
    % Stage 2: Relax core requirement
    (   Stage1 = [] ->
        format(atom(RelaxMsg), 'No CPUs found with ~w cores, relaxing requirement', [MinCores]),
        trace_reasoning(recommendation, cpu, RelaxMsg),
        findall([Name, Brand, Socket, Price, Cores, Threads, CPUTier, Score],
            (   cpu(Name, Brand, Socket, Price, Cores, Threads, CPUTier, Score),
                (Pref = none ; Pref = build ; Brand = Pref),
                can_afford(BudgetTier, CPUTier)
            ), Stage2)
    ;   Stage2 = Stage1
    ),
    
    % Stage 3: Try any CPU in budget
    (   Stage2 = [] ->
        trace_reasoning(recommendation, cpu, 'Relaxing brand preference, searching all CPUs in budget'),
        findall([Name, Brand, Socket, Price, Cores, Threads, CPUTier, Score],
            (   cpu(Name, Brand, Socket, Price, Cores, Threads, CPUTier, Score),
                can_afford(BudgetTier, CPUTier)
            ), FinalCandidates)
    ;   FinalCandidates = Stage2
    ),
    
    length(FinalCandidates, NumCandidates),
    format(atom(CandMsg), 'Found ~w candidate CPUs, scoring...', [NumCandidates]),
    trace_reasoning(recommendation, cpu, CandMsg),
    
    FinalCandidates \= [],
    % Score all candidates and sort
    score_candidates(cpu, FinalCandidates, ScoredCandidates),
    sort(2, @>=, ScoredCandidates, SortedCandidates),
    
    retractall(recommended_candidates(cpu, _)),
    SortedCandidates = [BestCandidate-_|_],
    findall(_{name: Name, brand: Brand, socket: Socket, price: Price, cores: Cores, threads: Threads, 
              tier: CPUTier, baseScore: BaseScore, finalScore: FinalScore, confidence: Conf, selected: Selected},
        (member([Name, Brand, Socket, Price, Cores, Threads, CPUTier, BaseScore]-FinalScore, SortedCandidates),
         calculate_confidence(cpu, BaseScore, Conf),
         ([Name, Brand, Socket, Price, Cores, Threads, CPUTier, BaseScore] = BestCandidate -> Selected = true ; Selected = false)),
        CandidatesJSON),
    assert(recommended_candidates(cpu, CandidatesJSON)),
    
    % Select best
    BestCandidate = [BestName, BestBrand, BestSocket, BestPrice, BestCores, BestThreads, _, BestScore],
    calculate_confidence(cpu, BestScore, Confidence),
    assert(recommended(cpu, [BestName, BestBrand, BestSocket, BestPrice, BestCores, BestThreads])),
    assert(confidence_factor(cpu, Confidence)),
    format(atom(SelectedMsg), 'Selected: ~w (~w, ~w cores/~w threads, $~w, confidence: ~2f)', [BestName, BestBrand, BestCores, BestThreads, BestPrice, Confidence]),
    trace_reasoning(recommendation, cpu, SelectedMsg).

% MOTHERBOARD
recommend_motherboard_robust :-
    recommended(cpu, [CPUName, _, Socket, _, _, _]),
    user_choice(budget, BudgetTier),
    format(atom(StartMsg), 'Searching for motherboard: Socket=~w (from ~w), Budget=~w', [Socket, CPUName, BudgetTier]),
    trace_reasoning(recommendation, motherboard, StartMsg),
    
    findall([Name, MoboSocket, Chipset, Price, MoboTier, RamType, Score],
        (   motherboard(Name, MoboSocket, Chipset, Price, MoboTier, RamType, Score),
            compatible_socket(Socket, MoboSocket),
            requires_ram_type(Socket, RamType),
            can_afford(BudgetTier, MoboTier)
        ), Candidates),
    
    length(Candidates, NumCandidates),
    format(atom(CandMsg), 'Found ~w compatible motherboards', [NumCandidates]),
    trace_reasoning(recommendation, motherboard, CandMsg),
    
    Candidates \= [],
    % Score all candidates and sort
    score_candidates(motherboard, Candidates, ScoredCandidates),
    sort(2, @>=, ScoredCandidates, SortedCandidates),
    
    % Store ALL scored candidates
    retractall(recommended_candidates(motherboard, _)),
    SortedCandidates = [BestCandidate-_|_],
    findall(_{name: Name, socket: MoboSocket, chipset: Chipset, price: Price, tier: MoboTier, 
              ramType: RamType, baseScore: BaseScore, finalScore: FinalScore, confidence: Conf, selected: Selected},
        (member([Name, MoboSocket, Chipset, Price, MoboTier, RamType, BaseScore]-FinalScore, SortedCandidates),
         (   [Name, MoboSocket, Chipset, Price, MoboTier, RamType, BaseScore] = BestCandidate -> Selected = true ; Selected = false),
         % Motherboards do not use usage multipliers but we still expose a per-candidate confidence
         % (consistent with other components). Use calculate_confidence helper which falls back to BaseScore/100.
         calculate_confidence(motherboard, BaseScore, Conf)
        ),
        MoboJSON),
    assert(recommended_candidates(motherboard, MoboJSON)),
    
    % Select best
    BestCandidate = [BestName, BestSocket, BestChipset, BestPrice, _, BestRamType, BestScore],
    Confidence is BestScore / 100,
    assert(recommended(motherboard, [BestName, BestSocket, BestChipset, BestPrice, BestRamType])),
    assert(confidence_factor(motherboard, Confidence)),
    format(atom(SelectedMsg), 'Selected: ~w (~w chipset, ~w support, $~w, confidence: ~2f)', [BestName, BestChipset, BestRamType, BestPrice, Confidence]),
    trace_reasoning(recommendation, motherboard, SelectedMsg).

% RAM
recommend_ram_robust :-
    recommended(motherboard, [MoboName, _, _, _, RamType]),
    user_choice(budget, BudgetTier),
    user_choice(usage, Usage),
    (requirement(ram, MinCapacity) -> true ; MinCapacity = 8),
    format(atom(StartMsg), 'Searching for RAM: Type=~w (from ~w), Usage=~w, MinCapacity=~wGB', [RamType, MoboName, Usage, MinCapacity]),
    trace_reasoning(recommendation, ram, StartMsg),
    
    % Try with capacity requirement
    findall([Name, Capacity, Type, Speed, Price, RamTier, Score, HasRGB],
        (   ram(Name, Capacity, Type, Speed, Price, RamTier, Score, HasRGB),
            Type = RamType,
            Capacity >= MinCapacity,
            can_afford(BudgetTier, RamTier)
        ), Stage1),
    
    % Relax capacity if needed
    (   Stage1 = [] ->
        format(atom(RelaxMsg), 'No RAM found with ~wGB, relaxing capacity requirement', [MinCapacity]),
        trace_reasoning(recommendation, ram, RelaxMsg),
        findall([Name, Capacity, Type, Speed, Price, RamTier, Score, HasRGB],
            (   ram(Name, Capacity, Type, Speed, Price, RamTier, Score, HasRGB),
                Type = RamType,
                can_afford(BudgetTier, RamTier)
            ), FinalCandidates)
    ;   FinalCandidates = Stage1
    ),
    
    length(FinalCandidates, NumCandidates),
    format(atom(CandMsg), 'Found ~w compatible RAM modules', [NumCandidates]),
    trace_reasoning(recommendation, ram, CandMsg),
    
    FinalCandidates \= [],
    % Score all candidates and sort
    score_candidates(ram, FinalCandidates, ScoredCandidates),
    sort(2, @>=, ScoredCandidates, SortedCandidates),
    
    % Store ALL scored candidates
    retractall(recommended_candidates(ram, _)),
    SortedCandidates = [BestCandidate-_|_],
    findall(_{name: Name, capacity: Capacity, type: Type, speed: Speed, price: Price, tier: RamTier, 
              baseScore: BaseScore, hasRGB: HasRGB, finalScore: FinalScore, confidence: Conf, selected: Selected},
        (member([Name, Capacity, Type, Speed, Price, RamTier, BaseScore, HasRGB]-FinalScore, SortedCandidates),
         calculate_confidence(ram, BaseScore, Conf),
         ([Name, Capacity, Type, Speed, Price, RamTier, BaseScore, HasRGB] = BestCandidate -> Selected = true ; Selected = false)),
        RAMJSON),
    assert(recommended_candidates(ram, RAMJSON)),
    
    % Select best
    BestCandidate = [BestName, BestCapacity, BestType, BestSpeed, BestPrice, _, BestScore, BestRGB],
    calculate_confidence(ram, BestScore, Confidence),
    assert(recommended(ram, [BestName, BestCapacity, BestType, BestSpeed, BestPrice, BestRGB])),
    assert(confidence_factor(ram, Confidence)),
    format(atom(SelectedMsg), 'Selected: ~w (~wGB ~w-~w, RGB: ~w, $~w, confidence: ~2f)', [BestName, BestCapacity, BestType, BestSpeed, BestRGB, BestPrice, Confidence]),
    trace_reasoning(recommendation, ram, SelectedMsg).

% GPU
recommend_gpu_robust :-
    user_choice(usage, Usage),
    user_choice(budget, BudgetTier),
    format(atom(StartMsg), 'Searching for GPU: Usage=~w, Budget=~w', [Usage, BudgetTier]),
    trace_reasoning(recommendation, gpu, StartMsg),
    
    % Try gaming requirements if applicable
    (   Usage = gaming,
        user_choice(gaming_level, Level),
        gaming_needs_gpu(Level, RequiredTier, _),
        format(atom(GamingMsg), 'Gaming at ~w requires ~w tier GPU', [Level, RequiredTier]),
        trace_reasoning(recommendation, gpu, GamingMsg),
        findall([Name, Brand, Price, GPUTier, TDP, Score],
            (   gpu(Name, Brand, Price, GPUTier, TDP, Score),
                tier_meets_requirement(GPUTier, RequiredTier),
                can_afford(BudgetTier, GPUTier)
            ), Stage1),
        Stage1 \= [] ->
        FinalCandidates = Stage1
    ;   
        % Just use budget
        trace_reasoning(recommendation, gpu, 'Using budget tier for GPU selection'),
        findall([Name, Brand, Price, GPUTier, TDP, Score],
            (   gpu(Name, Brand, Price, GPUTier, TDP, Score),
                can_afford(BudgetTier, GPUTier)
            ), FinalCandidates)
    ),
    
    length(FinalCandidates, NumCandidates),
    format(atom(CandMsg), 'Found ~w compatible GPUs', [NumCandidates]),
    trace_reasoning(recommendation, gpu, CandMsg),
    
    FinalCandidates \= [],
    % Score all candidates and sort
    score_candidates(gpu, FinalCandidates, ScoredCandidates),
    sort(2, @>=, ScoredCandidates, SortedCandidates),
    
    % Store ALL scored candidates
    retractall(recommended_candidates(gpu, _)),
    SortedCandidates = [BestCandidate-_|_],
    findall(_{name: Name, brand: Brand, price: Price, tier: GPUTier, tdp: TDP, 
              baseScore: BaseScore, finalScore: FinalScore, confidence: Conf, selected: Selected},
        (member([Name, Brand, Price, GPUTier, TDP, BaseScore]-FinalScore, SortedCandidates),
         calculate_confidence(gpu, BaseScore, Conf),
         ([Name, Brand, Price, GPUTier, TDP, BaseScore] = BestCandidate -> Selected = true ; Selected = false)),
        GPUJSON),
    assert(recommended_candidates(gpu, GPUJSON)),
    
    % Select best
    BestCandidate = [BestName, BestBrand, BestPrice, _, BestTDP, BestScore],
    calculate_confidence(gpu, BestScore, Confidence),
    assert(recommended(gpu, [BestName, BestBrand, BestPrice, BestTDP])),
    assert(confidence_factor(gpu, Confidence)),
    format(atom(SelectedMsg), 'Selected: ~w (~w, ~wW TDP, $~w, confidence: ~2f)', [BestName, BestBrand, BestTDP, BestPrice, Confidence]),
    trace_reasoning(recommendation, gpu, SelectedMsg).

% STORAGE
recommend_storage_robust :-
    user_choice(budget, BudgetTier),
    user_choice(usage, Usage),
    format(atom(StartMsg), 'Searching for storage: Usage=~w, Budget=~w, Type=NVMe', [Usage, BudgetTier]),
    trace_reasoning(recommendation, storage, StartMsg),
    findall([Name, Type, Capacity, Price, StorageTier, Score],
        (   storage(Name, Type, Capacity, Price, StorageTier, Score),
            Type = nvme,
            can_afford(BudgetTier, StorageTier)
        ), Candidates),
    length(Candidates, NumCandidates),
    format(atom(CandMsg), 'Found ~w NVMe storage options', [NumCandidates]),
    trace_reasoning(recommendation, storage, CandMsg),
    
    Candidates \= [],
    % Score all candidates and sort
    score_candidates(storage, Candidates, ScoredCandidates),
    sort(2, @>=, ScoredCandidates, SortedCandidates),
    
    % Store ALL scored candidates
    retractall(recommended_candidates(storage, _)),
    SortedCandidates = [BestCandidate-_|_],
    findall(_{name: Name, type: Type, capacity: Capacity, price: Price, tier: StorageTier, 
              baseScore: BaseScore, finalScore: FinalScore, confidence: Conf, selected: Selected},
        (member([Name, Type, Capacity, Price, StorageTier, BaseScore]-FinalScore, SortedCandidates),
         Conf is BaseScore / 100,
         ([Name, Type, Capacity, Price, StorageTier, BaseScore] = BestCandidate -> Selected = true ; Selected = false)),
        StorageJSON),
    assert(recommended_candidates(storage, StorageJSON)),
    
    % Select best
    BestCandidate = [BestName, BestType, BestCapacity, BestPrice, _, BestScore],
    Confidence is BestScore / 100,
    assert(recommended(storage, [BestName, BestType, BestCapacity, BestPrice])),
    assert(confidence_factor(storage, Confidence)),
    format(atom(SelectedMsg), 'Selected: ~w (~wGB ~w, $~w, confidence: ~2f)', [BestName, BestCapacity, BestType, BestPrice, Confidence]),
    trace_reasoning(recommendation, storage, SelectedMsg).

% PSU
recommend_psu_robust :-
    recommended(gpu, [GPUName, _, _, TDP]),
    recommended(cpu, [CPUName, _, _, _, Cores, _]),
    system_power_requirement(TDP, Cores, RequiredWattage),
    SafeWattage is RequiredWattage + 100,
    user_choice(budget, BudgetTier),
    format(atom(StartMsg), 'Searching for PSU: Required=~wW (GPU: ~wW from ~w, CPU: ~w cores from ~w), Safe minimum=~wW', 
           [RequiredWattage, TDP, GPUName, Cores, CPUName, SafeWattage]),
    trace_reasoning(recommendation, psu, StartMsg),
    
    % Try with budget constraint
    findall([Name, Wattage, Efficiency, Price, PSUTier, Score],
        (   psu(Name, Wattage, Efficiency, Price, PSUTier, Score),
            Wattage >= SafeWattage,
            can_afford(BudgetTier, PSUTier)
        ), Stage1),
    
    % Relax budget if needed for power
    (   Stage1 = [] ->
        format(atom(RelaxMsg), 'No PSU found in budget tier with ~wW, relaxing budget constraint', [SafeWattage]),
        trace_reasoning(recommendation, psu, RelaxMsg),
        findall([Name, Wattage, Efficiency, Price, PSUTier, Score],
            (   psu(Name, Wattage, Efficiency, Price, PSUTier, Score),
                Wattage >= SafeWattage
            ), FinalCandidates)
    ;   FinalCandidates = Stage1
    ),
    
    length(FinalCandidates, NumCandidates),
    format(atom(CandMsg), 'Found ~w suitable PSUs', [NumCandidates]),
    trace_reasoning(recommendation, psu, CandMsg),
    
    FinalCandidates \= [],
    % Score all candidates and sort
    score_candidates(psu, FinalCandidates, ScoredCandidates),
    sort(2, @>=, ScoredCandidates, SortedCandidates),
    
    % Store ALL scored candidates
    retractall(recommended_candidates(psu, _)),
    SortedCandidates = [BestCandidate-_|_],
    findall(_{name: Name, wattage: Wattage, efficiency: Efficiency, price: Price, tier: PSUTier, 
              baseScore: BaseScore, finalScore: FinalScore, confidence: Conf, selected: Selected},
        (member([Name, Wattage, Efficiency, Price, PSUTier, BaseScore]-FinalScore, SortedCandidates),
         Conf is BaseScore / 100,
         ([Name, Wattage, Efficiency, Price, PSUTier, BaseScore] = BestCandidate -> Selected = true ; Selected = false)),
        PSUJSON),
    assert(recommended_candidates(psu, PSUJSON)),
    
    % Select best
    BestCandidate = [BestName, BestWattage, BestEff, BestPrice, _, BestScore],
    Confidence is BestScore / 100,
    assert(recommended(psu, [BestName, BestWattage, BestEff, BestPrice])),
    assert(confidence_factor(psu, Confidence)),
    PowerMargin is BestWattage - RequiredWattage,
    format(atom(SelectedMsg), 'Selected: ~w (~wW ~w, $~w, ~wW margin, confidence: ~2f)', [BestName, BestWattage, BestEff, BestPrice, PowerMargin, Confidence]),
    trace_reasoning(recommendation, psu, SelectedMsg).

% CASE
recommend_case_robust :-
    user_choice(budget, BudgetTier),
    format(atom(StartMsg), 'Searching for case: Budget=~w', [BudgetTier]),
    trace_reasoning(recommendation, case, StartMsg),
    findall([Name, FormFactor, Price, CaseTier, Score, HasRGB, AIOSupport],
        (   case(Name, FormFactor, Price, CaseTier, Score, HasRGB, AIOSupport),
            can_afford(BudgetTier, CaseTier)
        ), Candidates),
    length(Candidates, NumCandidates),
    format(atom(CandMsg), 'Found ~w compatible cases', [NumCandidates]),
    trace_reasoning(recommendation, case, CandMsg),
    
    Candidates \= [],
    % Score all candidates and sort
    score_candidates(case, Candidates, ScoredCandidates),
    sort(2, @>=, ScoredCandidates, SortedCandidates),
    
    % Store ALL scored candidates
    retractall(recommended_candidates(case, _)),
    SortedCandidates = [BestCandidate-_|_],
    findall(_{name: Name, formFactor: FormFactor, price: Price, tier: CaseTier, 
              baseScore: BaseScore, hasRGB: HasRGB, aioSupport: AIOSupport, finalScore: FinalScore, confidence: Conf, selected: Selected},
        (member([Name, FormFactor, Price, CaseTier, BaseScore, HasRGB, AIOSupport]-FinalScore, SortedCandidates),
         Conf is BaseScore / 100,
         ([Name, FormFactor, Price, CaseTier, BaseScore, HasRGB, AIOSupport] = BestCandidate -> Selected = true ; Selected = false)),
        CaseJSON),
    assert(recommended_candidates(case, CaseJSON)),
    
    % Select best
    BestCandidate = [BestName, BestForm, BestPrice, _, BestScore, BestRGB, BestAIO],
    Confidence is BestScore / 100,
    assert(recommended(case, [BestName, BestForm, BestPrice, BestRGB, BestAIO])),
    assert(confidence_factor(case, Confidence)),
    format(atom(SelectedMsg), 'Selected: ~w (~w, RGB: ~w, AIO: ~w, $~w, confidence: ~2f)', [BestName, BestForm, BestRGB, BestAIO, BestPrice, Confidence]),
    trace_reasoning(recommendation, case, SelectedMsg).
