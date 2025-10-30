% Explanation generators

generate_detailed_explanation(cpu, Explanation) :-
    recommended(cpu, [Name, Brand, _Socket, Price, Cores, Threads]),
    confidence_factor(cpu, Confidence),
    user_choice(usage, Usage),
    user_choice(budget, BudgetTier),
    user_choice(cpu_preference, Pref),
    (requirement(cores, MinCores) -> true ; MinCores = 4),
    (usage_needs_cores(Usage, _, UsageConf) -> true ; UsageConf = 0.85),
    
    cpu(Name, _, _, _, _, _, CPUTier, BaseScore),
    (can_afford(BudgetTier, CPUTier) -> TierBonus = 10 ; TierBonus = 0),
    (Pref \= none, Pref \= build, Brand = Pref -> BrandBonus = 15 ; BrandBonus = 0),
    FinalScore is (BaseScore / 100) * UsageConf * 100 + TierBonus + BrandBonus,
    
    format(atom(Explanation), 
        'CPU Selection: ~w\n\n1. Filtering Phase:\n   • Required minimum cores for ~w usage: ~w cores\n   • CPU preference: ~w\n   • Budget tier: ~w (allows ~w tier components)\n   • Selected CPU has ~w cores, ~w threads\n\n2. Scoring Calculation:\n   • Base quality score: ~w/100\n   • Usage confidence multiplier: ~2f (from ~w requirements)\n   • Tier bonus: +~w points (component tier ~w fits budget)\n   • Brand preference bonus: +~w points\n   • Final score: ~2f\n\n3. Selection Rationale:\n   This CPU was chosen because it meets the core count requirement (~w >= ~w), matches your ~w preference, and achieved the highest score among compatible candidates at $~w.\n\n✓ Confidence: ~2f (~w%)',
        [Name, Usage, MinCores, Pref, BudgetTier, BudgetTier, Cores, Threads, 
         BaseScore, UsageConf, Usage, TierBonus, CPUTier, BrandBonus, FinalScore,
         Cores, MinCores, Brand, Price, Confidence, round(Confidence*100)]).

generate_detailed_explanation(gpu, Explanation) :-
    recommended(gpu, [Name, Brand, Price, TDP]),
    confidence_factor(gpu, Confidence),
    user_choice(usage, Usage),
    user_choice(budget, BudgetTier),
    
    gpu(Name, _, _, GPUTier, _, BaseScore),
    (can_afford(BudgetTier, GPUTier) -> TierBonus = 10 ; TierBonus = 0),
    
    (   Usage = gaming,
        user_choice(gaming_level, Level),
        gaming_needs_gpu(Level, RequiredTier, GamingConf) ->
        format(atom(GamingReq), '   • Gaming at ~w requires ~w tier GPU\n   • Gaming confidence factor: ~2f\n', [Level, RequiredTier, GamingConf]),
        FinalScore is (BaseScore / 100) * GamingConf * 100 + TierBonus
    ;   
        GamingReq = '   • No specific gaming requirements\n',
        FinalScore is BaseScore + TierBonus
    ),
    
    format(atom(Explanation),
        'GPU Selection: ~w (~w)\n\n1. Requirements Analysis:\n~w   • Budget tier: ~w\n   • Selected GPU tier: ~w\n   • Power consumption (TDP): ~wW\n\n2. Scoring Calculation:\n   • Base quality score: ~w/100\n   • Tier bonus: +~w points (fits ~w budget)\n   • Final score: ~2f\n\n3. Selection Rationale:\n   This GPU provides the best performance-to-value ratio for your ~w workload within the ~w budget tier at $~w. The ~wW TDP will be accounted for in PSU selection.\n\n✓ Confidence: ~2f (~w%)',
        [Name, Brand, GamingReq, BudgetTier, GPUTier, TDP, BaseScore, TierBonus, 
         BudgetTier, FinalScore, Usage, BudgetTier, Price, TDP, Confidence, round(Confidence*100)]).

generate_detailed_explanation(motherboard, Explanation) :-
    recommended(motherboard, [Name, Socket, Chipset, Price, RamType]),
    confidence_factor(motherboard, Confidence),
    recommended(cpu, [CPUName, _, CPUSocket, _, _, _]),
    user_choice(budget, BudgetTier),
    
    motherboard(Name, _, _, _, MoboTier, _, BaseScore),
    (can_afford(BudgetTier, MoboTier) -> TierBonus = 10 ; TierBonus = 0),
    FinalScore is BaseScore + TierBonus,
    
    format(atom(Explanation),
        'Motherboard Selection: ~w\n\n1. Compatibility Requirements:\n   • CPU socket: ~w (from ~w)\n   • Motherboard socket: ~w ✓ Match\n   • Supported RAM type: ~w\n   • Chipset: ~w\n\n2. Scoring Calculation:\n   • Base quality score: ~w/100\n   • Tier bonus: +~w points (~w tier fits ~w budget)\n   • Final score: ~2f\n\n3. Selection Rationale:\n   This motherboard ensures socket compatibility with your CPU, supports the appropriate RAM type (~w), and provides the best quality-to-price ratio within your budget at $~w.\n\n✓ Confidence: ~2f (~w%)',
        [Name, CPUSocket, CPUName, Socket, RamType, Chipset, BaseScore, 
         TierBonus, MoboTier, BudgetTier, FinalScore, RamType, Price, Confidence, round(Confidence*100)]).

generate_detailed_explanation(ram, Explanation) :-
    recommended(ram, [Name, Capacity, _Type, Speed, Price, HasRGB]),
    confidence_factor(ram, Confidence),
    recommended(motherboard, [MoboName, _, _, _, RamType]),
    user_choice(usage, Usage),
    (user_choice(rgb_importance, RGBPref) -> true ; RGBPref = dont_care),
    (requirement(ram, MinCapacity) -> true ; MinCapacity = 8),
    
    (HasRGB = yes, RGBPref \= dont_care -> 
        RGBBonus = ' The RGB lighting is a nice bonus for aesthetics.'
    ; 
        RGBBonus = ''
    ),
    
    format(atom(Explanation),
        'RAM Selection: ~w\n\nWhy this choice:\nThis RAM meets your ~wGB requirement for ~w and is fully compatible with your ~w motherboard (~w type). With ~w MT/s speed and ~wGB capacity, it delivers excellent performance for your needs at $~w.~w\n\n✓ Confidence: ~2f (~w%)',
        [Name, MinCapacity, Usage, MoboName, RamType, Speed, Capacity, Price, RGBBonus, Confidence, round(Confidence*100)]).

generate_detailed_explanation(storage, Explanation) :-
    recommended(storage, [Name, Type, Capacity, Price]),
    confidence_factor(storage, Confidence),
    user_choice(usage, Usage),
    user_choice(budget, BudgetTier),
    
    storage(Name, _, _, _, StorageTier, BaseScore),
    (can_afford(BudgetTier, StorageTier) -> TierBonus = 10 ; TierBonus = 0),
    FinalScore is BaseScore + TierBonus,
    
    format(atom(Explanation),
        'Storage Selection: ~w\n\n1. Filtering Phase:\n   • Storage type: ~w (NVMe for optimal performance)\n   • Capacity: ~wGB\n   • Budget tier: ~w (allows ~w tier components)\n\n2. Scoring Calculation:\n   • Base quality score: ~w/100\n   • Tier bonus: +~w points (component tier ~w fits budget)\n   • Final score: ~2f\n\n3. Selection Rationale:\n   This NVMe drive was selected for its high quality score (~w) and appropriate capacity (~wGB) for ~w usage. No specific capacity requirement exists for ~w, so the selection prioritizes performance and value within the ~w budget tier at $~w.\n\n✓ Confidence: ~2f (~w%)\n\nNote: The confidence reflects component quality rather than requirement fulfillment, as ~w usage doesn''t mandate specific storage capacity.',
        [Name, Type, Capacity, BudgetTier, BudgetTier, BaseScore, TierBonus, 
         StorageTier, FinalScore, BaseScore, Capacity, Usage, Usage, BudgetTier, 
         Price, Confidence, round(Confidence*100), Usage]).

generate_detailed_explanation(psu, Explanation) :-
    recommended(psu, [Name, Wattage, Efficiency, Price]),
    confidence_factor(psu, Confidence),
    recommended(gpu, [GPUName, _, _, GPUTDP]),
    recommended(cpu, [CPUName, _, _, _, Cores, _]),
    user_choice(budget, BudgetTier),
    
    system_power_requirement(GPUTDP, Cores, RequiredWattage),
    SafeWattage is RequiredWattage + 100,
    
    psu(Name, _, _, _, PSUTier, BaseScore),
    (can_afford(BudgetTier, PSUTier) -> TierBonus = 10 ; TierBonus = 0),
    FinalScore is BaseScore + TierBonus,
    
    CPUPower is Cores * 10,
    SystemOverhead is 100,
    PowerMargin is Wattage - RequiredWattage,
    
    format(atom(Explanation),
        'PSU Selection: ~w\n\n1. Dynamic Power Calculation:\n   • GPU (~w): ~wW TDP\n   • CPU (~w with ~w cores): ~wW (cores × 10W)\n   • System overhead: ~wW\n   • Total required: ~wW\n   • Safe minimum (with 100W buffer): ~wW\n   • Selected PSU: ~wW ✓\n   • Power margin: ~wW\n\n2. Scoring Calculation:\n   • Base quality score: ~w/100\n   • Tier bonus: +~w points (~w tier fits ~w budget)\n   • Final score: ~2f\n   • Efficiency rating: ~w\n\n3. Selection Rationale:\n   This PSU was chosen because it meets the calculated ~wW requirement with a comfortable ~wW safety margin. The ~w efficiency rating ensures stable power delivery and energy efficiency. At $~w, it provides the best quality-to-price ratio within the ~w budget tier.\n\n✓ Confidence: ~2f (~w%)\n\nFormula: Required = GPU_TDP + (CPU_Cores × 10) + 100W',
        [Name, GPUName, GPUTDP, CPUName, Cores, CPUPower, SystemOverhead, 
         RequiredWattage, SafeWattage, Wattage, PowerMargin, BaseScore, TierBonus,
         PSUTier, BudgetTier, FinalScore, Efficiency, SafeWattage, PowerMargin,
         Efficiency, Price, BudgetTier, Confidence, round(Confidence*100)]).

generate_detailed_explanation(case, Explanation) :-
    recommended(case, [Name, FormFactor, Price, HasRGB, AIOSupport]),
    confidence_factor(case, Confidence),
    user_choice(budget, BudgetTier),
    (user_choice(rgb_importance, RGBPref) -> true ; RGBPref = dont_care),
    (user_choice(cooling_preference, CoolingPref) -> true ; CoolingPref = either),
    
    (HasRGB = yes -> RGBText = 'RGB lighting included' ; RGBText = 'No RGB lighting'),
    (AIOSupport = yes -> AIOText = 'Supports liquid cooling' ; AIOText = 'Air cooling only'),
    
    (HasRGB = yes, RGBPref \= dont_care -> 
        RGBBonus = ' The RGB lighting adds a nice aesthetic touch to your build'
    ; 
        RGBBonus = ''
    ),
    
    (AIOSupport = yes, CoolingPref = aio -> 
        CoolingBonus = ' You''ll have flexibility for liquid cooling if you want it later'
    ; 
        CoolingBonus = ''
    ),
    
    format(atom(Explanation),
        'Case Selection: ~w\n\nWhy this choice:\nThis ~w case fits all your components perfectly and offers great build quality. ~w and ~w.~w~w It''s an excellent match for your ~w budget at $~w.\n\n✓ Confidence: ~2f (~w%)',
        [Name, FormFactor, RGBText, AIOText, RGBBonus, CoolingBonus, BudgetTier, Price, Confidence, round(Confidence*100)]).

generate_detailed_explanation(Component, Explanation) :-
    format(atom(Explanation), 'No detailed explanation available for ~w', [Component]).
