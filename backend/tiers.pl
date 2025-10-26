% Tier system rules

budget_can_afford([budget]).
mid_range_can_afford([budget, mid_range]).
high_end_can_afford([budget, mid_range, high_end]).
enthusiast_can_afford([budget, mid_range, high_end, enthusiast]).

can_afford(BudgetTier, ComponentTier) :-
    (   BudgetTier = budget -> budget_can_afford(List)
    ;   BudgetTier = mid_range -> mid_range_can_afford(List)
    ;   BudgetTier = high_end -> high_end_can_afford(List)
    ;   BudgetTier = enthusiast -> enthusiast_can_afford(List)
    ),
    member(ComponentTier, List).

tier_meets_requirement(T, T).
tier_meets_requirement(mid_range, budget).
tier_meets_requirement(high_end, budget).
tier_meets_requirement(high_end, mid_range).
tier_meets_requirement(enthusiast, budget).
tier_meets_requirement(enthusiast, mid_range).
tier_meets_requirement(enthusiast, high_end).
