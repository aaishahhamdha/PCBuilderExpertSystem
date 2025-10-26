% Conflict resolution and scoring helpers

resolve_conflicts(_, [], none) :- !.
resolve_conflicts(Component, Candidates, Best) :-
    score_candidates(Component, Candidates, ScoredCandidates),
    ScoredCandidates \= [],
    sort(2, @>=, ScoredCandidates, [Best-_|_]).

score_candidates(_, [], []).
score_candidates(Component, [Candidate|Rest], [Candidate-Score|Scored]) :-
    calculate_candidate_score(Component, Candidate, Score),
    score_candidates(Component, Rest, Scored).

calculate_candidate_score(cpu, [_Name, Brand, _Socket, _Price, _Cores, _Threads, Tier, BaseScore], FinalScore) :-
    calculate_confidence(cpu, BaseScore, ConfScore),
    user_choice(budget, BudgetTier),
    (can_afford(BudgetTier, Tier) -> TierBonus = 10 ; TierBonus = 0),
    (user_choice(cpu_preference, Brand) -> BrandBonus = 15 ; BrandBonus = 0),
    FinalScore is ConfScore * 100 + TierBonus + BrandBonus.

calculate_candidate_score(gpu, [_Name, _Brand, _Price, Tier, _TDP, BaseScore], FinalScore) :-
    calculate_confidence(gpu, BaseScore, ConfScore),
    user_choice(budget, BudgetTier),
    (can_afford(BudgetTier, Tier) -> TierBonus = 10 ; TierBonus = 0),
    FinalScore is ConfScore * 100 + TierBonus.

calculate_candidate_score(motherboard, [_Name, _Socket, _Chipset, _Price, Tier, _RamType, BaseScore], FinalScore) :-
    user_choice(budget, BudgetTier),
    (can_afford(BudgetTier, Tier) -> TierBonus = 10 ; TierBonus = 0),
    FinalScore is BaseScore + TierBonus.

calculate_candidate_score(ram, [_Name, _Capacity, _Type, _Speed, _Price, Tier, BaseScore, HasRGB], FinalScore) :-
    calculate_confidence(ram, BaseScore, ConfScore),
    user_choice(budget, BudgetTier),
    (can_afford(BudgetTier, Tier) -> TierBonus = 10 ; TierBonus = 0),
    (user_choice(rgb_importance, RGBPref) -> true ; RGBPref = dont_care),
    (   RGBPref = very_important, HasRGB = yes -> RGBBonus = 20
    ;   RGBPref = nice_to_have, HasRGB = yes -> RGBBonus = 10
    ;   RGBPref = dont_care -> RGBBonus = 0
    ;   RGBBonus = 0
    ),
    FinalScore is ConfScore * 100 + TierBonus + RGBBonus.

calculate_candidate_score(storage, [_Name, _Type, _Capacity, _Price, Tier, BaseScore], FinalScore) :-
    user_choice(budget, BudgetTier),
    (can_afford(BudgetTier, Tier) -> TierBonus = 10 ; TierBonus = 0),
    FinalScore is BaseScore + TierBonus.

calculate_candidate_score(psu, [_Name, _Wattage, _Efficiency, _Price, Tier, BaseScore], FinalScore) :-
    user_choice(budget, BudgetTier),
    (can_afford(BudgetTier, Tier) -> TierBonus = 10 ; TierBonus = 0),
    FinalScore is BaseScore + TierBonus.

calculate_candidate_score(case, [_Name, _FormFactor, _Price, Tier, BaseScore, HasRGB, AIOSupport], FinalScore) :-
    user_choice(budget, BudgetTier),
    (can_afford(BudgetTier, Tier) -> TierBonus = 10 ; TierBonus = 0),
    (user_choice(rgb_importance, RGBPref) -> true ; RGBPref = dont_care),
    (   RGBPref = very_important, HasRGB = yes -> RGBBonus = 20
    ;   RGBPref = nice_to_have, HasRGB = yes -> RGBBonus = 10
    ;   RGBPref = dont_care -> RGBBonus = 0
    ;   RGBBonus = 0
    ),
    (user_choice(cooling_preference, CoolingPref) -> true ; CoolingPref = either),
    (   CoolingPref = aio, AIOSupport = yes -> CoolingBonus = 25
    ;   CoolingPref = aio, AIOSupport = no -> CoolingBonus = -15
    ;   CoolingPref = air, AIOSupport = no -> CoolingBonus = 5
    ;   CoolingPref = either -> CoolingBonus = 0
    ;   CoolingBonus = 0
    ),
    FinalScore is BaseScore + TierBonus + RGBBonus + CoolingBonus.

calculate_candidate_score(_, _Candidate, 50).
