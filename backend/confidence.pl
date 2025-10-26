% Confidence calculation helper

calculate_confidence(Component, BaseScore, FinalConfidence) :-
    user_choice(usage, Usage),
    (   Component = cpu ->
        (usage_needs_cores(Usage, _, UsageConf) -> true ; UsageConf = 0.85),
        FinalConfidence is (BaseScore / 100) * UsageConf
    ;   Component = gpu ->
        (   Usage = gaming, user_choice(gaming_level, Level),
            gaming_needs_gpu(Level, _, GamingConf) ->
            FinalConfidence is (BaseScore / 100) * GamingConf
        ;   FinalConfidence is BaseScore / 100
        )
    ;   Component = ram ->
        (usage_needs_ram(Usage, _, RamConf) -> true ; RamConf = 0.85),
        FinalConfidence is (BaseScore / 100) * RamConf
    ;   FinalConfidence is BaseScore / 100
    ).
