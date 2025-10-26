# PC Builder Expert System: How It Works

This comprehensive guide explains the logic, scoring mechanisms, and workflow behind the AI-powered expert system that recommends optimized PC builds.

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
9. [TLDR](#9-tldr)

---

## 1. System Overview

### What Does It Do?

The system recommends complete PC builds based on:

- **Budget**: Budget, Mid-Range, High-End, or Enthusiast
- **Usage**: Office, Gaming, Programming, or Content Creation
- **Preferences**: CPU brand (Intel/AMD), Gaming resolution (1080p/1440p/4K)
- **Compatibility**: Socket matching, RAM type, power requirements, form factor

Note on "confidence": throughout this documentation and the UI/API the term "confidence" refers to an estimated build quality or suitability metric — i.e., how well a component (or the assembled build) matches the user's requirements and expected performance/reliability. It is not presented as a probabilistic certainty but as a normalized quality/suitability indicator derived from base scores and usage multipliers.

### Expert System Approach

The system uses three AI techniques:

1. **Forward Chaining** – Starts with user requirements and applies rules to infer component needs
2. **Backward Chaining** – Verifies that selected components satisfy all constraints
3. **Conflict Resolution** – When multiple components match, scores them and selects the best

---

## 2. Budget Tiers

### Tier System

| Tier | Description |
|------|-------------|
| **Budget** | Value-focused builds for everyday tasks |
| **Mid-Range** | Balanced performance for most users |
| **High-End** | Premium components for power users |
| **Enthusiast** | Top-tier performance, no compromises |

### Affordability Rules

Each tier can afford components from equal or lower tiers:

- **Budget** tier → Can only use Budget components
- **Mid-Range** tier → Can use Budget + Mid-Range components
- **High-End** tier → Can use Budget + Mid-Range + High-End components
- **Enthusiast** tier → Can use all component tiers

**Example:**

```prolog
User selects: Mid-Range budget
Available CPU tiers: Budget, Mid-Range
Blocked CPU tiers: High-End, Enthusiast
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

The engine uses predefined confidence multipliers declared as Prolog facts in `backend/server.pl`. These multipliers affect how strongly usage and gaming level influence component confidences. Current values in the codebase:

- CPU usage multipliers (`usage_needs_cores/3`):
  - `office`: 0.90, `gaming`: 0.95, `programming`: 0.92, `content_creation`: 0.98`

- RAM usage multipliers (`usage_needs_ram/3`):
  - `gaming`: 0.95
  - `content_creation`: 0.98
  - `office`: 0.85
  - `programming`: 0.90

- GPU multipliers by gaming level (`gaming_needs_gpu/3`):
  - `1080p`: budget, multiplier 0.90, `1440p`: mid_range, multiplier 0.95, `4k`: high_end, multiplier 0.98

Fallbacks and behavior:

- If a usage multiplier is not found for a given usage, the backend falls back to 0.85 for CPU and RAM calculations (see `calculate_confidence/3`).
- For GPUs, when usage is not `gaming` or `gaming_level` is not set, the engine uses the base score directly (effectively multiplier = 1.0).

Where to change these values:

- Edit `backend/server.pl` and update the `usage_needs_cores/3`, `usage_needs_ram/3`, and `gaming_needs_gpu/3` facts. The explanation generator and scoring functions read those facts directly; changes take effect after restarting the server.

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

### Step-by-Step Process

```
User Input
    ↓
Forward Chaining (Initialize inference)
    ↓
Prove Usage Requirements (Backward chaining)
    ↓
Prove Gaming Requirements (if gaming usage)
    ↓
Recommend CPU
    ↓
Recommend Motherboard (depends on CPU socket)
    ↓
Recommend RAM (depends on motherboard RAM type)
    ↓
Recommend GPU
    ↓
Recommend Storage
    ↓
Calculate PSU Requirements (depends on GPU + CPU)
    ↓
Recommend PSU
    ↓
Recommend Case
    ↓
Calculate Overall Confidence
    ↓
Return Build
```

### Detailed Workflow

#### Phase 1: Forward Chaining

```prolog
Input: Budget=Mid-Range, Usage=Gaming, GamingLevel=1440p, CpuPreference=Intel, RgbImportance=nice_to_have, CoolingPreference=aio

Apply Rules:
1. gaming_needs_cores(gaming, 6, 0.95) → MinCores = 6
2. gaming_needs_ram(gaming, 16, 0.95) → MinRAM = 16GB
3. gaming_needs_gpu('1440p', mid_range, 0.95) → MinGPUTier = mid_range
4. rgb_affects_component(ram, nice_to_have, 0.92) → RGB preference for RAM
5. rgb_affects_component(case, nice_to_have, 0.92) → RGB preference for Case
6. cooling_affects_case(aio, yes, 0.98) → AIO support required for Case

Store Requirements:
- requirement(cores, 6)
- requirement(ram, 16)
- requirement(gpu_tier, mid_range)
- requirement(rgb_preference, nice_to_have)
- requirement(aio_support, yes)
```

#### Phase 2: Backward Chaining (CPU)

```prolog
Goal: Find CPU that satisfies all constraints

Constraints:
1. Cores ≥ 6
2. Tier ≤ Mid-Range (can_afford check)
3. Brand = Intel (if preference set)

Stage 1: Try with all constraints
Stage 2: If no results, relax core requirement
Stage 3: If still no results, relax brand preference

Query Database:
cpu(Name, intel, Socket, Price, Cores, Threads, Tier, Score) :-
    Cores >= 6,
    can_afford(mid_range, Tier),
    Brand = intel

Results:
- Intel Core i5-12400F (6 cores, Budget, 85)
- Intel Core i5-13400F (10 cores, Mid-Range, 88)
- Intel Core i5-14600K (14 cores, Mid-Range, 90)
```

#### Phase 3: Conflict Resolution

```prolog
Score Each Candidate:
1. i5-12400F: (85/100) × 0.95 × 100 + 10 + 15 = 105.75
2. i5-13400F: (88/100) × 0.95 × 100 + 10 + 15 = 108.6
3. i5-14600K: (90/100) × 0.95 × 100 + 10 + 15 = 110.5

Winner: Intel Core i5-14600K (highest score)

Store ALL candidates with scores in recommended_candidates(cpu, [...])
```

#### Phase 4: Component Chain

Each component depends on previous selections:

1. **CPU** → Determines socket type
2. **Motherboard** → Must match CPU socket, determines RAM type
3. **RAM** → Must match motherboard RAM type
4. **GPU** → Independent, based on usage/gaming requirements
5. **Storage** → Independent, filtered by budget, always NVMe
6. **PSU** → Calculated from GPU TDP + CPU cores
7. **Case** → Independent, filtered by budget

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

```prolog
[backward_chain] usage_requirements: 
  Proven: Usage requirements for gaming (MinCores: 6, MinRAM: 16GB)

[backward_chain] gaming_requirements: 
  Proven: Gaming requirements for 1440p (GPU tier: mid_range)
```

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

#### Socket Matching (CPU ↔ Motherboard)

```prolog
Rule: compatible_socket(CPUSocket, MoboSocket)

Example:
CPU: Intel Core i5-14600K → Socket: lga1700
Motherboard must have: lga1700
✅ ASUS TUF Gaming Z690 → Socket: lga1700 (Compatible)
❌ MSI B550 Tomahawk → Socket: am4 (Incompatible)
```

#### RAM Type Matching (Motherboard ↔ RAM)

```prolog
Rule: requires_ram_type(Socket, RAMType)

Examples:
- lga1700 → ddr4 OR ddr5
- am4 → ddr4 only
- am5 → ddr5 only

Selected Motherboard: ASUS TUF Gaming Z690 (ddr5)
Required RAM Type: ddr5
✅ Corsair Vengeance 32GB DDR5-5600 (Compatible)
❌ Kingston Fury 16GB DDR4-3600 (Incompatible)
```

#### Power Requirements (GPU + CPU → PSU)

```prolog
Rule: system_power_requirement(GPUTDP, CPUCores, TotalWatts)

Formula:
TotalWatts = GPUTDP + (CPUCores × 10) + 100

Example:
GPU TDP = 200W
CPU Cores = 14
Total = 200 + (14 × 10) + 100 = 340W
Safe Minimum = 340 + 100 = 440W

PSU must have: Wattage ≥ 440W
✅ Corsair RM750e (750W) (Compatible)
✅ EVGA 600 BR (600W) (Adequate)
```

### Relaxation Strategy

When no components satisfy all constraints, the system relaxes rules in priority order:

**Priority 1:** Keep compatibility constraints (socket, RAM type, power)  
**Priority 2:** Relax optional requirements (core count, capacity)  
**Priority 3:** Relax budget constraints (go to next tier up)  
**Priority 4:** Relax preferences (brand)

**Example: CPU Selection Stages**

```prolog
Stage 1: Intel, ≥6 cores, Mid-Range → Try first
Stage 2 (if no results): Intel, any cores, Mid-Range → Relax core requirement
Stage 3 (if no results): Any brand, any cores, Mid-Range → Relax brand preference
```

**Example: PSU Selection Stages**

```prolog
Stage 1: ≥440W, Mid-Range budget → Try first
Stage 2 (if no results): ≥440W, Any budget tier → Relax budget for safety
```

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

## 9. TLDR

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Forward Chaining** | Start with user requirements → infer component needs from rules |
| **Backward Chaining** | Start with goal (complete build) → verify all constraints are satisfied |
| **Conflict Resolution** | Multiple candidates → score them using formula → select best |
| **Base Score** | Component quality rating (0-100) from knowledge base |
| **Confidence Multiplier** | Usage-specific adjustment (0.85-0.98) for CPU, GPU, RAM only |
| **Tier Bonus** | +10 points for components within budget tier |
| **Preference Bonus** | +15 points for matching CPU brand preference (Intel/AMD) |
| **Overall Confidence** | Average of all 7 component confidences |

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
Final Score = Base Score + Tier Bonus
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

This expert system combines rule-based AI with scoring algorithms to deliver intelligent, personalized PC build recommendations through a RESTful API.
