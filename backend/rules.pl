% Compatibility and usage rules

compatible_socket(S, S).

requires_ram_type(lga1700, ddr4).
requires_ram_type(lga1700, ddr5).
requires_ram_type(am4, ddr4).
requires_ram_type(am5, ddr5).

usage_needs_cores(office, 4, 0.9).
usage_needs_cores(gaming, 6, 0.95).
usage_needs_cores(programming, 8, 0.92).
usage_needs_cores(content_creation, 12, 0.98).

usage_needs_ram(gaming, 16, 0.95).
usage_needs_ram(content_creation, 32, 0.98).
usage_needs_ram(office, 8, 0.85).
usage_needs_ram(programming, 16, 0.90).

gaming_needs_gpu('1080p', budget, 0.90).
gaming_needs_gpu('1440p', mid_range, 0.95).
gaming_needs_gpu('4k', high_end, 0.98).

system_power_requirement(GPUTDP, CPUCores, TotalWatts) :-
    CPUPower is CPUCores * 10,
    SystemOverhead is 100,
    TotalWatts is GPUTDP + CPUPower + SystemOverhead.

rgb_affects_component(ram, very_important, 0.98).
rgb_affects_component(ram, nice_to_have, 0.92).
rgb_affects_component(ram, dont_care, 0.85).

rgb_affects_component(case, very_important, 0.98).
rgb_affects_component(case, nice_to_have, 0.92).
rgb_affects_component(case, dont_care, 0.85).

cooling_affects_case(aio, yes, 0.98).
cooling_affects_case(aio, no, 0.70).
cooling_affects_case(air, yes, 0.85).
cooling_affects_case(air, no, 0.90).
cooling_affects_case(either, _, 0.90).
