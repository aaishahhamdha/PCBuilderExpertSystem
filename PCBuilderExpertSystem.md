# PC Builder Expert System: How It Works

This comprehensive guide explains the logic, inference mechanisms, scoring algorithms, and workflow behind the AI-powered expert system that recommends optimized PC builds.

---

## What Makes This an Expert System?

An **expert system** is an AI program that mimics the decision-making ability of a human expert in a specific domain. This PC Builder system qualifies as an expert system because it:

1. **Contains Domain Knowledge:** The system has a knowledge base with 72 PC components, compatibility rules, and performance requirements encoded as Prolog facts and rules.

2. **Uses Inference Engine:** The system uses **forward chaining** to automatically derive new facts from user inputs (e.g., "IF usage=gaming THEN gpu_priority=high").

3. **Applies Production Rules:** The system has IF-THEN rules that encode expert knowledge about PC building (e.g., "IF gaming_level=4k THEN min_psu_wattage=850").

4. **Performs Reasoning:** The system doesn't just look up answers—it reasons through constraints, compatibility requirements, and scoring to make intelligent recommendations.

5. **Provides Explanations:** Like a human expert, the system can explain WHY it chose each component through detailed reasoning traces.

6. **Handles Uncertainty:** The system uses confidence multipliers (0.85-0.98) to represent how well components match requirements, similar to how an expert expresses certainty.

**In summary:** This system captures the knowledge and reasoning process of an experienced PC builder and automates it to provide expert-level recommendations to users of any skill level.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Budget Tiers](#2-budget-tiers)
3. [Component Scoring System](#3-component-scoring-system)
4. [Confidence Calculation Examples](#4-confidence-calculation-examples)
5. [Recommendation Workflow](#5-recommendation-workflow)
6. [Full Build Example](#6-full-build-example)
7. [Constraint Resolution](#7-constraint-resolution)
8. [Alternative Recommendations](#8-alternative-recommendations)
9. [TLDR (Quick Reference)](#9-tldr-quick-reference)

---

## 1. System Overview

### What Does It Do?

The system recommends complete PC builds based on:

- **Budget**: Entry-Level, Mid-Range, High-End, or Enthusiast
- **Usage**: Office, Gaming, Programming, or Content Creation
- **Preferences**: CPU brand (Intel/AMD), Gaming resolution (1080p/1440p/4K), RGB importance, Cooling preference
- **Compatibility**: Socket matching, RAM type, power requirements, form factor

Note on "confidence": throughout this documentation and the UI/API the term "confidence" refers to an estimated build quality or suitability metric — i.e., how well a component (or the assembled build) matches the user's requirements and expected performance/reliability. It is not presented as a probabilistic certainty but as a normalized quality/suitability indicator derived from base scores and usage multipliers.

### How the Expert System Works

The system uses **Forward Chaining** as its primary inference mechanism combined with **Conflict Resolution**:

#### 1. Forward Chaining (Knowledge Inference)

The system starts with user inputs and automatically **infers** additional facts using production rules. This happens before any component selection begins:

**Process:**
- User provides: Budget, Usage, Gaming Level, CPU Preference, RGB Importance, Cooling Preference
- System applies rules to infer: Component priorities, price constraints, power requirements, aesthetic needs
- All inferred facts are stored in the knowledge base as `inferred(Fact, Value)` predicates
- These facts guide all subsequent component recommendations

**Example:**
```prolog
User Input: budget=mid_range, usage=gaming, gaming_level=1440p

Forward Chaining Rules Applied:
IF budget = mid_range THEN infer balanced_performance, max_cpu_price=400, max_gpu_price=600
IF usage = gaming THEN infer gpu_priority=high, cpu_priority=medium
IF gaming_level = 1440p_high THEN infer needs_high_end_gpu, min_psu_wattage=750

Stored Facts:
- inferred(balanced_performance, yes)
- inferred(gpu_priority, high)
- inferred(needs_high_end_gpu, yes)
- inferred(min_psu_wattage, 750)
```

#### 2. Component Matching (Query + Filter)

After inference, the system queries the component database and filters by:
- **Compatibility constraints** (socket matching, RAM type, power requirements)
- **Budget constraints** (tier affordability rules)
- **Usage requirements** (minimum cores, RAM capacity, GPU tier)
- **User preferences** (CPU brand, RGB, cooling)

#### 3. Conflict Resolution (Scoring Algorithm)

When multiple components satisfy all constraints, the system scores each candidate and selects the highest-scoring one:

**Scoring Formula:**
```
Final Score = (Base Score / 100) × Confidence Multiplier × 100 + Tier Bonus + Preference Bonuses
```

**Selection:**
- All candidates are scored
- Highest score wins
- All scored alternatives are stored for user exploration

---

## 2. Budget Tiers

### Tier System

The system supports four budget tiers that determine component quality and price ranges:

| Tier | Description | Target Price Range |
|------|-------------|-------------------|
| **Budget** | Value-focused builds for everyday tasks | $500-$800 |
| **Mid-Range** | Balanced performance for most users | $800-$1500 |
| **High-End** | Premium components for power users | $1500-$2500 |
| **Enthusiast** | Top-tier performance, no compromises | $2500+ |

### Affordability Rules

Each budget tier can afford components from equal or lower tiers. This ensures components are appropriately priced for the user's budget:

- **Budget** tier → Can only use Budget components
- **Mid-Range** tier → Can use Budget + Mid-Range components
- **High-End** tier → Can use Budget + Mid-Range + High-End components
- **Enthusiast** tier → Can use all component tiers

**Implementation:**

```prolog
can_afford(UserBudget, ComponentTier) :-
    tier_level(UserBudget, UserLevel),
    tier_level(ComponentTier, CompLevel),
    UserLevel >= CompLevel.

% Tier hierarchy levels:
tier_level(budget, 1).
tier_level(mid_range, 2).
tier_level(high_end, 3).
tier_level(enthusiast, 4).
```

**Example:**

```prolog
User Budget: Mid-Range (level 2)
Can afford: Budget (level 1) + Mid-Range (level 2) ✅
Cannot afford: High-End (level 3), Enthusiast (level 4) ❌
```

---

## 3. Component Scoring System

### Base Scoring Formula

Each component receives a **final score** based on multiple factors:

```prolog
Final Score = (Base Score / 100) × Confidence Multiplier × 100 + Tier Bonus + Preference Bonus
```

### Scoring Components

#### 1. **Base Score** (0-100)

- Pre-assigned quality rating for each component
- Based on performance benchmarks, reliability, reviews
- Example: Intel i9-14900K = 98, Intel i3-12100F = 75

#### 2. **Confidence Multiplier** (0.85-0.98)

- **CPU**: Based on usage requirements (0.85-0.98)
- **GPU**: Based on gaming level requirements (0.90-0.98) or 1.0 for non-gaming
- **RAM**: Based on capacity requirements (0.85-0.98)
- **Motherboard, Storage, PSU, Case**: 1.0 (no multiplier)

The engine uses predefined confidence multipliers declared as Prolog facts in `backend/match.pl`. These multipliers affect how strongly usage and gaming level influence component confidences. Current values in the codebase:

- CPU usage multipliers (`usage_needs_cores/3`):
  - `office`: 0.90, `gaming`: 0.95, `programming`: 0.92, `content_creation`: 0.98

- RAM usage multipliers (`usage_needs_ram/3`):
  - `gaming`: 0.95
  - `content_creation`: 0.98
  - `office`: 0.85
  - `programming`: 0.90

- GPU multipliers by gaming level (`gaming_needs_gpu/3`):
  - `1080p`: budget, multiplier 0.90
  - `1440p`: mid_range, multiplier 0.95
  - `4k`: high_end, multiplier 0.98

Fallbacks and behavior:

- If a usage multiplier is not found for a given usage, the backend falls back to 0.85 for CPU and RAM calculations (see `calculate_confidence/3` in `backend/confidence.pl`).
- For GPUs, when usage is not `gaming` or `gaming_level` is not set, the engine uses the base score directly (effectively multiplier = 1.0).

Where to change these values:

- Edit `backend/match.pl` and update the `usage_needs_cores/3`, `usage_needs_ram/3`, and `gaming_needs_gpu/3` facts. The explanation generator and scoring functions read those facts directly; changes take effect after restarting the server.

#### 3. **Tier Bonus** (+10 points)

- Added if component tier is affordable within budget tier
- Ensures budget-appropriate selections

#### 4. **Preference Bonus**

- **CPU Brand**: +15 points for matching brand preference (Intel/AMD)
- **RGB Lighting**: +20 points (very important), +10 points (nice to have)
- **Cooling Type**: +25 points (AIO support when preferred), -15 points (AIO preference without support), +5 points (air preference without AIO)

---

## 4. Confidence Calculation Examples

### Example 1: CPU Selection (Gaming Build)

**User Requirements:**

- Budget: Mid-Range
- Usage: Gaming
- CPU Preference: Intel
- Required Cores: 6 (from gaming usage rules)

**Candidate: Intel Core i5-14600K**

``` prolog
cpu('Intel Core i5-14600K', intel, lga1700, 320, 14, 20, mid_range, 90).
```

| Factor | Value | Calculation |
|--------|-------|-------------|
| Base Score | 90 | Pre-defined quality score |
| Usage Confidence | 0.95 | Gaming requires high confidence |
| Tier Match | ✅ Mid-Range | +10 bonus |
| Brand Match | ✅ Intel | +15 bonus |

**Calculation:**

```prolog
Base with Confidence = (90 / 100) × 0.95 × 100 = 85.5
Tier Bonus = +10 (Mid-Range component in Mid-Range budget)
Brand Bonus = +15 (Intel matches preference)

Final Score = 85.5 + 10 + 15 = 110.5
Confidence = 0.95 × (90/100) = 0.855 (85.5%)
```

**Competing Candidate: AMD Ryzen 7 7700X**

``` prolog
cpu('AMD Ryzen 7 7700X', amd, am5, 300, 8, 16, mid_range, 89).
```

| Factor | Value | Calculation |
|--------|-------|-------------|
| Base Score | 89 | Pre-defined quality score |
| Usage Confidence | 0.95 | Gaming requires high confidence |
| Tier Match | ✅ Mid-Range | +10 bonus |
| Brand Match | ❌ AMD | +0 bonus |

**Calculation:**

```prolog
Base with Confidence = (89 / 100) × 0.95 × 100 = 84.55
Tier Bonus = +10
Brand Bonus = +0 (AMD doesn't match Intel preference)

Final Score = 84.55 + 10 + 0 = 94.55
Confidence = 0.95 × (89/100) = 0.846 (84.6%)
```

**Winner:** Intel Core i5-14600K (110.5 > 94.55) ✅

---

### Example 2: GPU Selection (1440p Gaming)

**User Requirements:**

- Budget: High-End
- Usage: Gaming
- Gaming Level: 1440p
- Required GPU Tier: Mid-Range (minimum from gaming rules)

**Candidate: NVIDIA RTX 4070**

``` prolog
gpu('NVIDIA RTX 4070', nvidia, 550, mid_range, 200, 88).
```

| Factor | Value | Calculation |
|--------|-------|-------------|
| Base Score | 88 | Pre-defined quality score |
| Gaming Confidence | 0.95 | 1440p gaming confidence |
| Tier Match | ✅ Mid-Range | +10 bonus |
| TDP | 200W | (for PSU calculation) |

**Calculation:**

```prolog
Base with Confidence = (88 / 100) × 0.95 × 100 = 83.6
Tier Bonus = +10 (Mid-Range GPU in High-End budget)

Final Score = 83.6 + 10 = 93.6
Confidence = 0.95 × (88/100) = 0.836 (83.6%)
```

---

### Example 3: RAM Selection (Content Creation)

**User Requirements:**

- Budget: High-End
- Usage: Content Creation
- Motherboard RAM Type: DDR5
- Required Capacity: 32GB (from content creation rules)

**Candidate: G.Skill Trident Z5 32GB DDR5-6000**

``` prolog
ram('G.Skill Trident Z5 32GB DDR5-6000', 32, ddr5, 6000, 160, high_end, 92).

```

| Factor | Value | Calculation |
|--------|-------|-------------|
| Base Score | 92 | Pre-defined quality score |
| Usage Confidence | 0.98 | Content creation needs high RAM confidence |
| Tier Match | ✅ High-End | +10 bonus |
| Capacity | 32GB | Meets requirement |
| Speed | 6000 MT/s | High performance |

**Calculation:**

```prolog
Base with Confidence = (92 / 100) × 0.98 × 100 = 90.16
Tier Bonus = +10

Final Score = 90.16 + 10 = 100.16
Confidence = 0.98 × (92/100) = 0.902 (90.2%)
```

---

### Example 4: PSU Selection (Dynamic Power Calculation)

**Selected Components:**

- GPU: NVIDIA RTX 4070 (200W TDP)
- CPU: Intel Core i7-14700K (20 cores)

**Power Calculation:**

```prolog
CPU Power = Cores × 10W = 20 × 10 = 200W
GPU Power = 200W (TDP)
System Overhead = 100W

Total Required = 200 + 200 + 100 = 500W
Safe Minimum = Required + 100W buffer = 600W
```

**Candidate: EVGA SuperNOVA 850 GT (850W, Gold)**

```prolog
psu('EVGA SuperNOVA 850 GT', 850, gold, 130, mid_range, 87).
```

| Factor | Value | Calculation |
|--------|-------|-------------|
| Base Score | 87 | Pre-defined quality score |
| Wattage | 850W | 850W ≥ 600W ✅ |
| Power Margin | 350W | 850 - 500 = 350W headroom |
| Tier Match | ✅ Mid-Range | +10 bonus |

**Calculation:**

```prolog
Base Score = 87
Tier Bonus = +10

Final Score = 87 + 10 = 97
Confidence = 87 / 100 = 0.87 (87%)
```

---

### Example 5: Motherboard Selection

**User Requirements:**

- CPU Socket: LGA1700 (from selected Intel CPU)
- Budget: Mid-Range

**Candidate: ASUS TUF Gaming Z690**

```prolog
motherboard('ASUS TUF Gaming Z690', lga1700, z690, 250, mid_range, ddr5, 88).
```

| Factor | Value | Calculation |
|--------|-------|-------------|
| Base Score | 88 | Pre-defined quality score |
| Socket | LGA1700 | Matches CPU ✅ |
| RAM Type | DDR5 | Supported by socket |
| Tier Match | ✅ Mid-Range | +10 bonus |

**Calculation:**

```prolog
Base Score = 88
Tier Bonus = +10

Final Score = 88 + 10 = 98
Confidence = 88 / 100 = 0.88 (88%)
```

**Note:** Motherboards do NOT use confidence multipliers. Only base score + tier bonus.
(In practice this means the per-motherboard "confidence" is the normalized base score — i.e., baseScore / 100 — which should be read as an estimated build-quality / suitability indicator for that motherboard.)

---

### Example 6: Storage Selection

**User Requirements:**

- Budget: Budget
- Usage: Gaming
- Storage Type: NVMe (system always uses NVMe)

**Candidate: Kingston NV2 1TB NVMe**

| Factor | Value | Calculation |
|--------|-------|-------------|
| Base Score | 75 | Pre-defined quality score |
| Type | NVMe | High-speed storage |
| Tier Match | ✅ Budget | +10 bonus |

**Calculation:**

```prolog
Base Score = 75
Tier Bonus = +10

Final Score = 75 + 10 = 85
Confidence = 75 / 100 = 0.75 (75%)
```

**Note:** Storage does NOT use confidence multipliers. Only base score + tier bonus.

---

## 5. Recommendation Workflow

### High-Level Process

The system follows a **sequential, data-driven workflow** to build a complete PC recommendation:

```text
1. Receive User Input
   ↓
2. Forward Chaining (Infer Facts)
   ↓
3. Query Usage Requirements from Knowledge Base
   ↓
4. Recommend CPU (scores all compatible CPUs)
   ↓
5. Recommend Motherboard (must match CPU socket)
   ↓
6. Recommend RAM (must match motherboard RAM type)
   ↓
7. Recommend GPU (scores based on usage/gaming needs)
   ↓
8. Recommend Storage (always NVMe, scores by budget)
   ↓
9. Calculate PSU Requirements (from GPU + CPU power)
   ↓
10. Recommend PSU (must meet power requirements)
   ↓
11. Recommend Case (scores by budget and preferences)
   ↓
12. Calculate Overall Build Confidence
   ↓
13. Return Complete Build + Alternatives
```

---

### Detailed Phase-by-Phase Breakdown

#### Phase 1: Forward Chaining (Fact Inference)

**Purpose:** Derive additional knowledge from user inputs before selecting components.

**Process:**
1. System reads all user choices from `user_choice/2` predicates
2. Applies production rules to infer new facts
3. Stores inferred facts as `inferred(Fact, Value)` predicates
4. These facts guide all component selection decisions

**Example Input:**
```prolog
user_choice(budget, mid_range).
user_choice(usage, gaming).
user_choice(gaming_level, '1440p_high').
user_choice(cpu_preference, intel).
user_choice(rgb_importance, nice_to_have).
user_choice(cooling_preference, aio).
```

**Forward Chaining Rules Applied:**

**From Budget (mid_range):**
```prolog
IF budget = mid_range THEN
    assert(inferred(balanced_performance, yes))
    assert(inferred(max_cpu_price, 400))
    assert(inferred(max_gpu_price, 600))
```

**From Usage (gaming):**
```prolog
IF usage = gaming THEN
    assert(inferred(gpu_priority, high))
    assert(inferred(cpu_priority, medium))
```

**From Gaming Level (1440p_high):**
```prolog
IF gaming_level = '1440p_high' THEN
    assert(inferred(needs_high_end_gpu, yes))
    assert(inferred(min_psu_wattage, 750))
```

**From RGB Importance (nice_to_have):**
```prolog
IF rgb_importance = nice_to_have THEN
    assert(inferred(aesthetics_priority, medium))
```

**From Cooling Preference (aio):**
```prolog
IF cooling_preference = aio THEN
    assert(inferred(needs_aio_support, yes))
    assert(inferred(case_size_preference, larger))
```

**Result:** The knowledge base now contains all inferred facts that will guide component selection.

---

#### Phase 2: Query Usage Requirements

**Purpose:** Look up minimum component specifications from the knowledge base.

**Process:**
1. Query `usage_needs_cores/3` to get minimum CPU cores and confidence multiplier
2. Query `usage_needs_ram/3` to get minimum RAM capacity and confidence multiplier
3. If gaming, query `gaming_needs_gpu/3` to get minimum GPU tier and confidence multiplier
4. Store these as requirements for component filtering

**Example Queries:**
```prolog
?- usage_needs_cores(gaming, MinCores, CpuConfidence).
MinCores = 6,
CpuConfidence = 0.95.

?- usage_needs_ram(gaming, MinRAM, RamConfidence).
MinRAM = 16,
RamConfidence = 0.95.

?- gaming_needs_gpu('1440p_high', MinGPUTier, GpuConfidence).
MinGPUTier = mid_range,
GpuConfidence = 0.95.
```

**Result:** System knows minimum requirements: 6 cores CPU, 16GB RAM, mid-range GPU, all with 0.95 confidence multipliers.

---

#### Phase 3: Component Selection (CPU)

**Purpose:** Find the best CPU that satisfies all constraints.

**Process:**
1. **Query database** for all CPUs matching:
   - Minimum cores ≥ 6
   - Tier affordable by user budget
   - Brand matches preference (if specified)

2. **Score each candidate:**
   ```prolog
   Final Score = (BaseScore / 100) × 0.95 × 100 + TierBonus + BrandBonus
   ```

3. **Select highest score** as recommended CPU

4. **Store all candidates** with scores for alternatives

**Example Query:**
```prolog
cpu(Name, Brand, Socket, Price, Cores, Threads, Tier, BaseScore),
    Cores >= 6,
    can_afford(mid_range, Tier),
    Brand = intel.
```

**Candidates Found:**
- Intel Core i5-14600K: Score = 110.5
- Intel Core i5-13400F: Score = 108.6
- Intel Core i5-12400F: Score = 105.75

**Winner:** Intel Core i5-14600K (highest score)

---

#### Phase 4: Component Selection (Motherboard)

**Purpose:** Find a motherboard compatible with the selected CPU.

**Process:**
1. **Extract CPU socket** from selected CPU (e.g., lga1700)

2. **Query database** for motherboards matching:
   - Socket = CPU socket
   - Tier affordable by user budget

3. **Score each candidate:**
   ```prolog
   Final Score = BaseScore + TierBonus
   ```
   (Motherboards don't use confidence multipliers)

4. **Select highest score**

**Compatibility Enforcement:**
```prolog
Selected CPU Socket: lga1700
Required Motherboard Socket: lga1700

motherboard(Name, lga1700, Chipset, Price, Tier, RamType, BaseScore),
    can_afford(mid_range, Tier).
```

**Side Effect:** Motherboard determines RAM type for next phase (e.g., ddr5)

---

#### Phase 5: Component Selection (RAM)

**Purpose:** Find RAM compatible with the selected motherboard.

**Process:**
1. **Extract RAM type** from selected motherboard (e.g., ddr5)

2. **Query database** for RAM matching:
   - RAM type = motherboard RAM type
   - Capacity ≥ minimum requirement (16GB)
   - Tier affordable by user budget

3. **Score each candidate:**
   ```prolog
   Final Score = (BaseScore / 100) × 0.95 × 100 + TierBonus
   ```

4. **Select highest score**

**Compatibility Enforcement:**
```prolog
Selected Motherboard RAM Type: ddr5
Required RAM Type: ddr5
Minimum Capacity: 16GB

ram(Name, Capacity, ddr5, Speed, Price, Tier, BaseScore),
    Capacity >= 16,
    can_afford(mid_range, Tier).
```

---

#### Phase 6: Component Selection (GPU)

**Purpose:** Find a GPU suitable for gaming or other usage.

**Process:**
1. **Determine GPU requirements:**
   - If usage = gaming: use gaming level to find minimum GPU tier
   - Otherwise: no strict tier requirement

2. **Query database** for GPUs matching:
   - Tier ≥ minimum GPU tier (if gaming)
   - Tier affordable by user budget

3. **Score each candidate:**
   ```prolog
   % For gaming:
   Final Score = (BaseScore / 100) × GamingConfidence × 100 + TierBonus
   
   % For non-gaming:
   Final Score = BaseScore + TierBonus
   ```

4. **Select highest score**

**Example (Gaming at 1440p):**
```prolog
Minimum GPU Tier: mid_range
Gaming Confidence: 0.95

gpu(Name, Brand, Price, Tier, TDP, BaseScore),
    tier_level(Tier, Level),
    Level >= 2,  % mid_range or higher
    can_afford(mid_range, Tier).
```

---

#### Phase 7: Component Selection (Storage)

**Purpose:** Select fast NVMe storage.

**Process:**
1. **Query database** for storage matching:
   - Type = nvme (always NVMe for speed)
   - Tier affordable by user budget

2. **Score each candidate:**
   ```prolog
   Final Score = BaseScore + TierBonus
   ```
   (Storage doesn't use confidence multipliers)

3. **Select highest score**

**Note:** System always prefers NVMe SSDs for optimal performance.

---

#### Phase 8: PSU Power Calculation

**Purpose:** Calculate required PSU wattage based on selected components.

**Dynamic Calculation:**
```prolog
GPU Power = GPU TDP (from selected GPU)
CPU Power = CPU Cores × 10W (from selected CPU)
System Overhead = 100W (constant)

Total Required = GPU Power + CPU Power + System Overhead
Safe Minimum = Total Required + 100W buffer
```

**Example:**
```prolog
Selected GPU: NVIDIA RTX 4070 (200W TDP)
Selected CPU: Intel Core i5-14600K (14 cores)

GPU Power = 200W
CPU Power = 14 × 10 = 140W
System Overhead = 100W

Total Required = 200 + 140 + 100 = 440W
Safe Minimum = 440 + 100 = 540W
```

---

#### Phase 9: Component Selection (PSU)

**Purpose:** Find a PSU with sufficient wattage and efficiency.

**Process:**
1. **Use calculated safe minimum** from Phase 8

2. **Query database** for PSUs matching:
   - Wattage ≥ safe minimum
   - Tier affordable by user budget (may relax if needed for power)

3. **Score each candidate:**
   ```prolog
   Final Score = BaseScore + TierBonus
   ```

4. **Select highest score**

**Safety Check:**
```prolog
psu(Name, Wattage, Efficiency, Price, Tier, BaseScore),
    Wattage >= 540,
    can_afford(mid_range, Tier).
```

**Relaxation:** If no PSU found in budget tier, system allows higher tiers for safety.

---

#### Phase 10: Component Selection (Case)

**Purpose:** Select a case that fits the build and user preferences.

**Process:**
1. **Query database** for cases matching:
   - Tier affordable by user budget
   - Form factor = atx (standard)

2. **Apply preference bonuses:**
   - RGB support: +10 or +20 points
   - AIO support: +25 or -15 points (based on cooling preference)

3. **Score each candidate:**
   ```prolog
   Final Score = BaseScore + TierBonus + RgbBonus + CoolingBonus
   ```

4. **Select highest score**

---

#### Phase 11: Overall Confidence Calculation

**Purpose:** Provide a single metric for build quality.

**Formula:**
```prolog
Overall Confidence = Average of all 7 component confidences

Overall = (CPU_conf + Mobo_conf + RAM_conf + GPU_conf + 
           Storage_conf + PSU_conf + Case_conf) / 7
```

**Example:**
```prolog
CPU: 0.855
Motherboard: 0.880
RAM: 0.836
GPU: 0.836
Storage: 0.880
PSU: 0.850
Case: 0.820

Overall = (0.855 + 0.880 + 0.836 + 0.836 + 0.880 + 0.850 + 0.820) / 7
        = 5.957 / 7
        = 0.851
        = 85.1%
```

**Interpretation:** An 85.1% confidence means the build strongly satisfies user requirements.

---

### Key Workflow Characteristics

**Sequential Dependency:**
- Motherboard depends on CPU socket
- RAM depends on motherboard RAM type
- PSU depends on GPU TDP and CPU cores

**Constraint Satisfaction:**
- Every component must pass compatibility checks
- Tier affordability enforced at every step
- Minimum requirements (cores, RAM, GPU tier) checked

**Conflict Resolution:**
- Multiple candidates → scored using algorithm
- Highest score wins
- All alternatives stored for user exploration

**Graceful Degradation:**
- If no components match strict constraints, system relaxes rules in priority order
- Critical constraints (compatibility, power) never relaxed
- Optional constraints (preferences) relaxed first

---

## 6. Full Build Example

### Scenario: Mid-Range Gaming PC (1440p)

**User Input:**

```json
{
  "budget": "mid_range",
  "usage": "gaming",
  "gamingLevel": "1440p",
  "cpuPreference": "intel"
}
```

### Forward Chaining Results

The system applies production rules to infer facts from user inputs:

```prolog
[forward_chain] Analyzing budget=mid_range: 
  Applied rule: budget(mid_range) → balanced_performance
  Inferred: Balanced performance target, max_cpu_price=400, max_gpu_price=600

[forward_chain] Analyzing usage=gaming: 
  Applied rule: usage(gaming) → gpu_priority(high), cpu_priority(medium)
  Inferred: Gaming use - GPU priority high, CPU priority medium

[forward_chain] Analyzing gaming_level=1440p_high: 
  Applied rule: gaming_level(1440p_high) → needs_high_end_gpu, min_psu_wattage(750)
  Inferred: 1440p high gaming needs high-end GPU and 750W minimum PSU

[forward_chain] Analyzing rgb_importance=nice_to_have: 
  Applied rule: rgb_importance(nice_to_have) → aesthetics_priority(medium)
  Inferred: Aesthetics considered but not critical

[forward_chain] Analyzing cooling_preference=aio: 
  Applied rule: cooling_preference(aio) → needs_aio_support, case_size_preference(larger)
  Inferred: AIO cooling needs case with radiator support

[requirements] Querying usage requirements:
  usage_needs_cores(gaming, 6, 0.95) → Minimum 6 cores, confidence multiplier 0.95
  usage_needs_ram(gaming, 16, 0.95) → Minimum 16GB RAM, confidence multiplier 0.95

[requirements] Querying gaming requirements:
  gaming_needs_gpu(1440p_high, mid_range, 0.95) → Minimum mid_range GPU tier, confidence multiplier 0.95
```

**Knowledge Base State After Forward Chaining:**
- `inferred(balanced_performance, yes)`
- `inferred(max_cpu_price, 400)`
- `inferred(max_gpu_price, 600)`
- `inferred(gpu_priority, high)`
- `inferred(cpu_priority, medium)`
- `inferred(needs_high_end_gpu, yes)`
- `inferred(min_psu_wattage, 750)`
- `inferred(aesthetics_priority, medium)`
- `inferred(needs_aio_support, yes)`
- `inferred(case_size_preference, larger)`

### Component Selection Trace

#### 1. CPU Selection

```prolog
[recommendation] cpu: 
  Searching for CPU: Budget=mid_range, Usage=gaming, MinCores=6, Preference=intel

[recommendation] cpu: 
  Found 3 candidate CPUs, scoring...

[recommendation] cpu: 
  Selected: Intel Core i5-14600K (intel, 14 cores/20 threads, $320, confidence: 0.86)
```

**Calculation:**

- Base: 90, Usage Conf: 0.95, Tier: +10, Brand: +15
- Score: (90/100) × 0.95 × 100 + 10 + 15 = 110.5
- Confidence: 0.95 × 0.90 = 0.855

#### 2. Motherboard Selection

```prolog
[recommendation] motherboard: 
  Searching for motherboard: Socket=lga1700 (from Intel Core i5-14600K), Budget=mid_range

[recommendation] motherboard: 
  Found 4 compatible motherboards

[recommendation] motherboard: 
  Selected: ASUS TUF Gaming Z690 (z690 chipset, ddr5 support, $250, confidence: 0.88)
```

**Calculation:**

- Base: 88, Tier: +10
- Score: 88 + 10 = 98
- Confidence: 88 / 100 = 0.88

#### 3. RAM Selection

```prolog
[recommendation] ram: 
  Searching for RAM: Type=ddr5 (from ASUS TUF Gaming Z690), Usage=gaming, MinCapacity=16GB

[recommendation] ram: 
  Found 4 compatible RAM modules

[recommendation] ram: 
  Selected: Corsair Vengeance 32GB DDR5-5600 (32GB ddr5-5600, $130, confidence: 0.84)
```

**Calculation:**

- Base: 88, Usage Conf: 0.95, Tier: +10
- Score: (88/100) × 0.95 × 100 + 10 = 93.6
- Confidence: 0.95 × 0.88 = 0.836

#### 4. GPU Selection

```prolog
[recommendation] gpu: 
  Searching for GPU: Usage=gaming, Budget=mid_range

[recommendation] gpu: 
  Gaming at 1440p requires mid_range tier GPU

[recommendation] gpu: 
  Found 3 compatible GPUs

[recommendation] gpu: 
  Selected: NVIDIA RTX 4070 (nvidia, 200W TDP, $550, confidence: 0.84)
```

**Calculation:**

- Base: 88, Gaming Conf: 0.95, Tier: +10
- Score: (88/100) × 0.95 × 100 + 10 = 93.6
- Confidence: 0.95 × 0.88 = 0.836

#### 5. Storage Selection

```prolog
[recommendation] storage: 
  Searching for storage: Usage=gaming, Budget=mid_range, Type=NVMe

[recommendation] storage: 
  Found 3 NVMe storage options

[recommendation] storage: 
  Selected: Samsung 980 Pro 1TB NVMe (1000GB nvme, $120, confidence: 0.88)
```

**Calculation:**

- Base: 88, Tier: +10
- Score: 88 + 10 = 98
- Confidence: 88 / 100 = 0.88

#### 6. PSU Selection

```prolog
[recommendation] psu: 
  Searching for PSU: Required=340W (GPU: 200W from NVIDIA RTX 4070, CPU: 14 cores from Intel Core i5-14600K), Safe minimum=440W

[recommendation] psu: 
  Found 3 suitable PSUs

[recommendation] psu: 
  Selected: Corsair RM750e (750W gold, $100, 410W margin, confidence: 0.85)
```

**Power Calculation:**

```prolog
GPU TDP = 200W
CPU Power = 14 cores × 10W = 140W
System Overhead = 100W
Total Required = 200 + 140 + 100 = 340W
Safe Minimum = 340 + 100 = 440W
Selected PSU = 750W
Power Margin = 750 - 340 = 410W ✅
```

#### 7. Case Selection

```prolog
[recommendation] case: 
  Searching for case: Budget=mid_range

[recommendation] case: 
  Found 2 compatible cases

[recommendation] case: 
  Selected: NZXT H510 (atx, $80, confidence: 0.82)
```

**Calculation:**

- Base: 82, Tier: +10
- Score: 82 + 10 = 92
- Confidence: 82 / 100 = 0.82

---

### Final Build Summary

| Component | Selected | Price | Confidence |
|-----------|----------|-------|------------|
| **CPU** | Intel Core i5-14600K | $320 | 85.5% |
| **Motherboard** | ASUS TUF Gaming Z690 | $250 | 88.0% |
| **RAM** | Corsair Vengeance 32GB DDR5-5600 | $130 | 83.6% |
| **GPU** | NVIDIA RTX 4070 | $550 | 83.6% |
| **Storage** | Samsung 980 Pro 1TB NVMe | $120 | 88.0% |
| **PSU** | Corsair RM750e (750W Gold) | $100 | 85.0% |
| **Case** | NZXT H510 | $80 | 82.0% |

**Total Cost:** $1,550

**Overall Build Confidence:**

```prolog
Overall = (0.855 + 0.880 + 0.836 + 0.836 + 0.880 + 0.850 + 0.820) / 7
        = 5.957 / 7
        = 0.851
        = 85.1%
```

**Interpretation:** This build has an **85.1% confidence score**, meaning it strongly satisfies the user's requirements for a mid-range 1440p gaming PC.

---

## 7. Constraint Resolution

### Compatibility Constraints

The system enforces strict compatibility rules that are **never relaxed**:

#### Socket Matching (CPU ↔ Motherboard)

**Rule:** CPU socket must match motherboard socket

```prolog
compatible_socket(CPUSocket, MoboSocket) :- CPUSocket = MoboSocket.
```

**Example:**

```text
Selected CPU: Intel Core i5-14600K
CPU Socket: lga1700

Query: motherboard(Name, lga1700, Chipset, Price, Tier, RamType, Score)

✅ ASUS TUF Gaming Z690 (lga1700) - Compatible
❌ MSI B550 Tomahawk (am4) - Incompatible, filtered out
```

---

#### RAM Type Matching (Motherboard ↔ RAM)

**Rule:** RAM type must match motherboard's supported RAM type

```prolog
requires_ram_type(Socket, RAMType).
```

**Socket-to-RAM Mappings:**

- `lga1700` → `ddr4` OR `ddr5` (board-specific)
- `am4` → `ddr4` only
- `am5` → `ddr5` only

**Example:**

```text
Selected Motherboard: ASUS TUF Gaming Z690
Motherboard RAM Type: ddr5

Query: ram(Name, Capacity, ddr5, Speed, Price, Tier, Score)

✅ Corsair Vengeance 32GB DDR5-5600 - Compatible
❌ Kingston Fury 16GB DDR4-3600 - Incompatible, filtered out
```

---

#### Power Requirements (GPU + CPU → PSU)

**Rule:** PSU wattage must meet or exceed safe minimum power requirement

**Formula:**

```prolog
GPU Power = GPU TDP
CPU Power = CPU Cores × 10W
System Overhead = 100W

Total Required = GPU Power + CPU Power + System Overhead
Safe Minimum = Total Required + 100W buffer
```

**Example:**

```text
Selected GPU: NVIDIA RTX 4070 (200W TDP)
Selected CPU: Intel Core i5-14600K (14 cores)

Calculation:
GPU Power = 200W
CPU Power = 14 × 10 = 140W
System Overhead = 100W
Total Required = 200 + 140 + 100 = 440W
Safe Minimum = 440 + 100 = 540W

Query: psu(Name, Wattage, Efficiency, Price, Tier, Score), Wattage >= 540

✅ Corsair RM750e (750W) - Sufficient power
✅ EVGA 600 BR (600W) - Adequate power
❌ Corsair CV550 (550W) - Insufficient power, filtered out
```

---

### Relaxation Strategy

When no components satisfy all constraints, the system relaxes non-critical rules in priority order:

**Never Relaxed (Critical):**

- Socket compatibility (CPU-Motherboard)
- RAM type compatibility (Motherboard-RAM)
- Power requirements (PSU wattage)

**Relaxed in Priority Order (Optional):**

1. **Core count requirements** (relax from optimal to minimum)
2. **RAM capacity requirements** (relax from optimal to minimum)
3. **Brand preferences** (ignore brand preference)
4. **Budget tier constraints** (allow next tier up for critical components like PSU)

---

### Relaxation Examples

#### CPU Selection - Stage-by-Stage Relaxation

**Initial Constraints:**

- Usage: Gaming
- Budget: Mid-Range
- Brand Preference: Intel
- Minimum Cores: 6

**Stage 1 - Strict Matching:**

```prolog
Query: cpu(Name, intel, Socket, Price, Cores, Threads, mid_range, Score),
       Cores >= 6

Result: Found 3 Intel CPUs with 6+ cores in mid_range tier
Action: Score candidates, select best
```

**Stage 2 - Relax Core Requirement (if Stage 1 fails):**

```prolog
Query: cpu(Name, intel, Socket, Price, Cores, Threads, mid_range, Score)
       % Removed: Cores >= 6 constraint

Result: Found 5 Intel CPUs in mid_range tier (including 4-core options)
Action: Score candidates, select best available
```

**Stage 3 - Relax Brand Preference (if Stage 2 fails):**

```prolog
Query: cpu(Name, Brand, Socket, Price, Cores, Threads, mid_range, Score)
       % Removed: Brand = intel constraint

Result: Found 8 CPUs from Intel and AMD in mid_range tier
Action: Score candidates (Intel gets brand bonus, AMD doesn't), select best
```

**Stage 4 - Relax Budget Tier (if Stage 3 fails):**

```prolog
Query: cpu(Name, Brand, Socket, Price, Cores, Threads, Tier, Score),
       tier_level(Tier, Level),
       Level =< 2  % Allow entry_level (1) and mid_range (2)

Result: Found 12 CPUs including entry_level tier
Action: Score candidates, select best (with tier bonus reduction)
```

---

#### PSU Selection - Power-Critical Relaxation

**Initial Constraints:**

- Safe Minimum: 540W
- Budget: Mid-Range
- Efficiency: Prefer Gold or better

**Stage 1 - Strict Matching:**

```prolog
Query: psu(Name, Wattage, gold, Price, mid_range, Score),
       Wattage >= 540

Result: Found 2 Gold-rated PSUs with 540W+ in mid_range tier
Action: Score candidates, select best
```

**Stage 2 - Relax Efficiency (if Stage 1 fails):**

```prolog
Query: psu(Name, Wattage, Efficiency, Price, mid_range, Score),
       Wattage >= 540
       % Removed: Efficiency = gold constraint

Result: Found 4 PSUs (Gold/Bronze) with 540W+ in mid_range tier
Action: Score candidates, select best (Gold scores higher)
```

**Stage 3 - Relax Budget Tier (if Stage 2 fails):**

```prolog
Query: psu(Name, Wattage, Efficiency, Price, Tier, Score),
       Wattage >= 540,
       can_afford_or_next(mid_range, Tier)
       % Allow mid_range OR high_end tiers for safety

Result: Found 6 PSUs with 540W+ in mid_range and high_end tiers
Action: Score candidates, select best (safety prioritized over budget)
```

**Note:** Power safety is never compromised. System will recommend higher-tier PSU if necessary.

---

### Why This Strategy?

**Critical Constraints = Physical Compatibility:**

- Wrong socket → CPU won't fit motherboard (physically impossible)
- Wrong RAM type → RAM won't fit motherboard slots (physically impossible)
- Insufficient power → System unstable or won't boot (dangerous)

**Optional Constraints = Performance/Preference:**

- Fewer cores → Lower performance but functional
- Less RAM → Limited multitasking but functional
- Different brand → Same performance tier, just preference
- Higher tier → Over budget but better quality

**Priority:** **Physical compatibility and safety > Performance optimization > Budget adherence > User preferences**

---

## 8. Alternative Recommendations

### How Alternatives Work

After building a recommendation, the system stores **ALL scored candidates** for each component in `recommended_candidates/2`. This allows the API to return alternative options.

### Alternative Data Structure

Each alternative includes:

- **Component attributes** (name, brand, price, specs)
- **baseScore** - Pre-defined quality score (0-100)
- **confidence** - Calculated confidence factor
- **selected** - Boolean indicating if this is the currently selected component

**Note:** The internal `finalScore` (used for ranking) is **NOT** exposed in the API response.

### Alternatives by Component

The engine stores all considered candidates for each component in `recommended_candidates/2` during recommendation. Each stored candidate includes attributes and scoring metadata (for internal use), such as base quality score and the computed confidence factor. This enables the system to produce alternative suggestions and explain selection rationale.

Typical candidate fields (internal representation) include: name, brand, socket/formFactor/type, price, tier, baseScore, confidence, and a boolean `selected` flag indicating the chosen item. The internal `finalScore` used for ranking is not persisted to external documentation here.

## 9. TLDR (Quick Reference)

### How the System Works

The PC Builder Expert System uses **Forward Chaining** and **Conflict Resolution** to recommend complete PC builds:

1. **Forward Chaining (Inference Engine):**
   - Takes user inputs (budget, usage, preferences)
   - Applies production rules to infer additional facts
   - Stores inferred facts (component priorities, price limits, power requirements)
   - Example: IF usage=gaming THEN infer gpu_priority=high

2. **Component Matching:**
   - Queries component database with filters
   - Enforces compatibility constraints (socket, RAM type, power)
   - Applies budget affordability rules
   - Checks minimum requirements (cores, RAM capacity, GPU tier)

3. **Conflict Resolution (Scoring):**
   - When multiple components match, calculate score for each
   - Score = (BaseScore/100) × Confidence × 100 + TierBonus + PreferenceBonuses
   - Select highest scoring component
   - Store all alternatives for user exploration

4. **Sequential Dependencies:**
   - CPU selection → determines motherboard socket requirement
   - Motherboard selection → determines RAM type requirement
   - GPU + CPU selection → determines PSU power requirement
   - Each step builds on previous selections

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Forward Chaining** | Start with user inputs → apply rules → infer new facts → use facts to guide decisions |
| **Production Rules** | IF-THEN rules that derive new knowledge (e.g., IF budget=mid_range THEN max_cpu_price=400) |
| **Conflict Resolution** | When multiple components satisfy constraints → score them → select best |
| **Base Score** | Component quality rating (0-100) from knowledge base |
| **Confidence Multiplier** | Usage-specific adjustment (0.85-0.98) for CPU, GPU, RAM only |
| **Tier Bonus** | +10 points for components within budget tier |
| **Preference Bonus** | +15 for CPU brand match, +10/+20 for RGB, +25/-15 for cooling |
| **Overall Confidence** | Average of all 7 component confidences (quality indicator) |

### System Workflow Summary

**Step 1: User Input**
```
User provides: budget, usage, gaming_level, cpu_preference, rgb_importance, cooling_preference
```

**Step 2: Forward Chaining (Inference)**
```
Apply production rules → Infer new facts
Example: IF usage=gaming THEN infer(gpu_priority, high)
Result: Knowledge base populated with inferred facts
```

**Step 3: Query Requirements**
```
Look up minimum specs from knowledge base
Example: usage_needs_cores(gaming, 6, 0.95) → Need 6+ cores with 0.95 multiplier
Result: Know what to filter for in component queries
```

**Step 4-10: Component Selection (Sequential)**
```
For each component type:
  1. Query database with filters (compatibility, budget, requirements)
  2. Score all matching candidates using formula
  3. Select highest scoring component
  4. Store alternatives for user exploration
  5. Move to next component (using previous selections as constraints)

Order: CPU → Motherboard → RAM → GPU → Storage → PSU → Case
```

**Step 11: Calculate Build Confidence**
```
Average all component confidences → Overall build quality score
```

**Step 12: Return Results**
```
Return selected components + all scored alternatives + reasoning trace
```

### Scoring Formula by Component

**CPU:**

```prolog
Final Score = (Base Score / 100) × Usage Confidence × 100 + Tier Bonus + Brand Bonus
Confidence = (Base Score / 100) × Usage Confidence
```

**GPU (Gaming):**

```prolog
Final Score = (Base Score / 100) × Gaming Confidence × 100 + Tier Bonus
Confidence = (Base Score / 100) × Gaming Confidence
```

**GPU (Non-Gaming):**

```prolog
Final Score = Base Score + Tier Bonus
Confidence = Base Score / 100
```

**RAM:**

```prolog
Final Score = (Base Score / 100) × Usage Confidence × 100 + Tier Bonus
Confidence = (Base Score / 100) × Usage Confidence
```

**Motherboard, Storage, PSU, Case:**

```prolog
Final Score = Base Score + Tier Bonus + Preference Bonuses
Confidence = Base Score / 100
```

### Usage Requirements Table

| Usage | Min Cores | Confidence | Min RAM | Confidence |
|-------|-----------|------------|---------|------------|
| **Office** | 4 | 0.90 | 8GB | 0.85 |
| **Gaming** | 6 | 0.95 | 16GB | 0.95 |
| **Programming** | 8 | 0.92 | 16GB | 0.90 |
| **Content Creation** | 12 | 0.98 | 32GB | 0.98 |

### Gaming GPU Requirements Table

| Gaming Level | Min GPU Tier | Confidence |
|--------------|--------------|------------|
| **1080p** | Budget | 0.90 |
| **1440p** | Mid-Range | 0.95 |
| **4K** | High-End | 0.98 |

### PSU Power Calculation

```prolog
Required Power = GPU_TDP + (CPU_Cores × 10W) + 100W
Safe Minimum = Required Power + 100W buffer
```

**Example:**

- GPU: 200W TDP
- CPU: 14 cores
- Required: 200 + 140 + 100 = 440W
- Safe: 440 + 100 = 540W

### Component Selection Order

The system always selects components in this specific order:

1. **CPU** (independent)
2. **Motherboard** (depends on CPU socket)
3. **RAM** (depends on motherboard RAM type)
4. **GPU** (independent)
5. **Storage** (independent, always NVMe)
6. **PSU** (depends on GPU TDP + CPU cores)
7. **Case** (independent)

### Relaxation Priority

When no components match all constraints:

1. **Keep:** Socket compatibility, RAM type, power requirements (critical)
2. **Relax:** Core count, RAM capacity (optional requirements)
3. **Relax:** Budget tier (allow higher tier if needed for power/compatibility)
4. **Relax:** Brand preference (last resort)

### System Strengths

✅ **Deterministic** - Same inputs always produce same output  
✅ **Explainable** - Every decision has a traceable reason via trace API  
✅ **Flexible** - Handles missing preferences gracefully with defaults  
✅ **Constraint-aware** - Never recommends incompatible parts  
✅ **Budget-conscious** - Respects spending limits with tier system  
✅ **API-driven** - Easy integration with web/mobile frontends  
✅ **Alternative-aware** - Stores all candidates for user exploration  

### Knowledge Base Statistics

- **16 CPUs** (Intel LGA1700, AMD AM4/AM5)
- **13 Motherboards** (B660, B760, Z690, Z790, B550, B650, X670E chipsets)
- **9 RAM modules** (DDR4 and DDR5, 8GB to 64GB)
- **11 GPUs** (NVIDIA and AMD, budget to enthusiast)
- **8 Storage** (NVMe SSDs, 500GB to 4TB)
- **8 PSUs** (600W to 1300W, Bronze to Titanium)
- **7 Cases** (Micro-ATX and ATX)

### Component Tier Distribution

| Tier | CPUs | Motherboards | RAM | GPUs | Storage | PSUs | Cases |
|------|------|--------------|-----|------|---------|------|-------|
| Budget | 5 | 3 | 3 | 3 | 3 | 2 | 3 |
| Mid-Range | 4 | 4 | 3 | 3 | 2 | 2 | 1 |
| High-End | 4 | 3 | 2 | 4 | 2 | 2 | 2 |
| Enthusiast | 3 | 3 | 1 | 1 | 1 | 2 | 1 |

---

## Conclusion

This expert system uses **forward chaining inference** to derive knowledge from user inputs, then applies that knowledge through a **sequential component selection workflow** with **conflict resolution scoring** to recommend optimal, compatible PC builds.

**Key Differentiators:**

- **Knowledge-driven:** Decisions based on encoded expert knowledge, not hardcoded logic
- **Inference-based:** Automatically derives requirements and priorities from simple user inputs
- **Constraint-aware:** Enforces physical compatibility and power requirements
- **Conflict-resolving:** Intelligently scores and ranks multiple valid options
- **Explainable:** Full reasoning traces show exactly why each component was chosen
- **Graceful degradation:** Relaxes optional constraints when strict matching fails

The system delivers the expertise of a seasoned PC builder through a RESTful API, making professional-grade build recommendations accessible to users of any technical level.

