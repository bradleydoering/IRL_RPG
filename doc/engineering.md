# Human Skills RPG — Engineering Spec (v1)

## Scope
Local-first iOS app with no backend in v1. Primary concerns are:
- reliable local persistence
- deterministic XP math
- consistent streak/quest scheduling
- transparent audit trail

---

## Tech Stack
- Swift + SwiftUI
- Local persistence:
  - **Core Data** (recommended) OR
  - SQLite via GRDB
- No networking required (v1)
- Optional future integrations:
  - Apple Health (read-only) for sleep/workouts

---

## App Architecture (Suggested)
- MVVM-ish:
  - Views (SwiftUI)
  - ViewModels (state + commands)
  - Services:
    - PersistenceService
    - XPService
    - QuestService
    - StreakService
    - TimeService (date boundaries, week start)
- Deterministic “game rules” should live in pure functions (testable).

---

## Data Model (Conceptual)

### Core entities
- `Skill`
  - id, kind (enum), category, displayName
  - xpTotal (Int)
  - streakCurrentDays (Int)
  - streakLongestDays (Int)
  - lastTrainedDate (Date? normalized to local day)
  - createdAt, updatedAt

- `SessionLog`
  - id, skillId
  - startAt, endAt
  - durationSeconds
  - baseXpAwarded
  - streakMultiplierApplied (Double)
  - bonusXpAwarded (Int) (quests etc.)
  - totalXpAwarded
  - flags: `trainedDespiteResistance` (Bool)
  - source: manual / timer / import
  - createdAt

- `XpEvent` (audit trail)
  - id, dateTime
  - skillId (nullable for meta/global events)
  - type (enum): base, streakBonus, dailyQuestBonus, weeklyQuestBonus, resilience, curiosity, discipline, manualAdjust
  - amount (Int)
  - note (String)

- `DailyQuest`
  - date (LocalDay)
  - skillKindSelected
  - requirementType: minutes / session
  - requirementValue
  - completedAt (Date?)
  - rewardsGranted (Bool)

- `WeeklyQuest`
  - weekStart (LocalDay)
  - templateId (enum)
  - progress counters (stored per template)
  - completedAt (Date?)
  - rewardsGranted (Bool)

- `MetaState` (for resilience/caps)
  - rollingRestartWindow: list of restart timestamps OR counts per 30d window
  - last30dRestartCount (computed)
  - lastSkillUsedDates: skillKind -> LocalDay
  - firstTimeSkillUsed: set

---

## Date / Time Boundaries
All streak, daily quest, and week logic must operate on “local day” boundaries.

- Define `LocalDay` as YYYY-MM-DD in user locale/timezone.
- Normalize any `Date` into a `LocalDay` for comparisons.
- Weekly quests use a consistent week start:
  - Recommended: **Monday** as week start (configurable later).

---

## XP Rules (Deterministic)
Implement XP math as a pure module.

### Base XP
- time-based: 10 XP/minute
- sleep: 2 XP/minute
- session-based: per-skill default 300–500

### Streak multiplier
Applies to **base XP only**:
- 1–2: 1.0
- 3–6: 1.1
- 7–13: 1.25
- 14–29: 1.4
- 30+: 1.5 cap

### Quest bonuses
- Daily quest: +200 skill XP +75 Consistency
- Weekly quest: template-specific bonuses (flat; no multipliers)

### Meta skill bonuses
- Creativity: award **20% of base XP** from Hobby skill sessions (no streak multiplier).

### Level curve
Total XP needed:
- TotalXP(L) = 120 * L^2.2
Level is computed from xpTotal using inverse search (binary search 1..99).

---

## Streak Update Algorithm
When logging a session for a skill:
1. Determine local day `d`.
2. If lastTrainedDate is nil → streakCurrentDays = 1.
3. Else if lastTrainedDate == d → streakCurrentDays unchanged (avoid double-count)
4. Else if lastTrainedDate == d-1 → streakCurrentDays += 1
5. Else → streak break: streakCurrentDays = 1
6. Update longest streak if needed.
7. Update lastTrainedDate = d.

---

## Resilience Detection (Restart)
A restart occurs when:
- a skill is trained on day `d`
- and the previous trained day was <= d-2 (gap of 2+ missed days)
- and the skill had a prior streak (implied by having been trained before)

On restart:
- compute restartCount in rolling 30 days (see below)
- award Resilience XP based on tier:
  - 1: 300
  - 2: 450
  - 3: 600
  - 4: 750
  - 5+: 900 cap
- write an `XpEvent` of type resilience
- increment rolling restart list/state

Rolling 30 days implementation options:
- store timestamps of restarts; keep only those within now-30d

---

## Curiosity Detection
On session for skill K:
- if K has never been trained before → +200 Curiosity
- else if lastUsedDate[K] <= d-30 → +200 Curiosity
Update lastUsedDate[K] = d

---

## Creativity Detection
When logging a **Hobby** skill:
- award Creativity XP = 20% of **base XP**
- write an `XpEvent` of type `creativity`

---

## Discipline
If user toggles “trained despite resistance” on a session:
- award +150 Discipline XP (optional daily cap)

---

## Daily Quest Generation
At start of each local day (or first app open):
- pick a random active skill (excluding meta skills by default)
- set requirement:
  - time-based: 30 minutes default (or 20–45 range)
  - session-based: 1 session
- store DailyQuest(date=d)

Completion:
- if user trains that skill and meets requirement:
  - +200 XP to that skill (bonus)
  - +75 XP to Consistency
  - mark completedAt, rewardsGranted
  - create audit events

---

## Weekly Quest Generation
At start of week (weekStart day, e.g., Monday):
- select 1 template from the V1 set
- initialize progress counters
- store WeeklyQuest(weekStart)

Progress:
- update based on sessions logged throughout the week

Completion:
- on meeting requirements within 7 days:
  - grant template rewards (flat bonuses)
  - mark completedAt, rewardsGranted
  - create audit events

---

## Testing Targets
- XP/level table monotonicity and boundary conditions
- streak transitions (same-day logs, gaps, day+1 increments)
- daily quest deterministic completion conditions
- weekly quest progress logic
- rolling 30-day restart window correctness
- cap enforcement (1 daily quest/day, 1 weekly quest/week, streak cap)

---

## Future Considerations (Not v1)
- Apple Health import service
- iCloud sync (CloudKit) if desired
- friend stats sharing (requires backend or peer-to-peer)
