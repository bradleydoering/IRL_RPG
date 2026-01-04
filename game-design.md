# Human Skills RPG — Game Design Spec (v1)

## Concept
An iOS, local-first “skills RPG” where habits are treated like trainable skills. Users earn XP through **observable actions** (timed sessions, simple completions, passive sleep). Progress is intentionally long-term: **Level 99 takes years**.

**Core pillars**
- Consistency beats intensity
- No punishment mechanics
- Restarting is rewarded (Resilience)
- Systems are hard-capped to prevent XP inflation
- Levels represent training time/behavior, not “talent”

---

## Skill List (Locked v1)

### Mind
1. Reading
2. Writing
3. Learning
4. Deep Work
5. Meditation
6. Creativity

### Body
7. Weightlifting
8. Running (bundles cardio)
9. Walking
10. Mobility
11. Sleep

### Craft
12. Woodworking
13. Pottery
14. Cooking
15. DIY / Home Improvement
16. Electronics / Making

### Art
17. Drawing / Painting
18. Music Practice
19. Photography / Video

### Meta (Auto-Leveled)
20. Consistency
21. Discipline
22. Resilience
23. Curiosity

Total: **23 skills**.

---

## XP Earning

### Base XP rates
**Time-based skills**
- **10 XP per minute**
- Example: 30 minutes Reading → 300 XP

**Session-based skills**
- **300–500 XP per session** (tunable per skill)
- Example: Weightlifting workout → 400 XP

**Sleep**
- **2 XP per minute asleep**
- Example: 7.5 hours (450 min) → 900 XP

> Target typical daily XP per trained skill: **300–1200 XP** (before caps/bonuses).

---

## XP → Level Curve (Level 99 takes years)

Use a smooth, non-explosive power curve:

```
TotalXP(level L) = A * (L ^ B)
```

Constants:
- **A = 120**
- **B = 2.2**

Milestone targets (approx):
- Level 10 ≈ 18k XP (~2 months)
- Level 20 ≈ 90k XP (~6 months)
- Level 30 ≈ 230k XP (~1 year of consistency)
- Level 60 ≈ 1.1M XP (~3–4 years)
- Level 80 ≈ 2.4M XP (~6 years)
- Level 99 ≈ 4.5–5.0M XP (~6–10 years)

Assumes:
- ~600–800 XP/day average for that skill
- streak bonuses sometimes
- missed days allowed

---

## Streaks (Multiplier, Hard-Capped)

**Philosophy:** reward consistency without runaway XP.

Multiplier applies to **base XP only**.

| Streak length | Multiplier |
|---|---|
| 1–2 days | 1.0× |
| 3–6 days | 1.1× |
| 7–13 days | 1.25× |
| 14–29 days | 1.4× |
| 30+ days | **1.5× (cap)** |

**Rules**
- Breaking streak returns to **1.0×**
- No multipliers on mini-quest or weekly quest bonuses
- Never exceed **1.5×**

---

## Mini-Quests (Daily)

### Random Daily Mini-Quest (1/day)
Each day, the app randomly selects **one active skill** and nudges the user to train it.

**Template**
- “Train **[Skill]** today”
- Requirement: **20–45 minutes OR 1 session** (skill-specific)

**Rewards**
- **+200 XP** to the selected skill
- **+75 XP** to Consistency
- Daily badge (date-stamped)

**Rules**
- Exactly **1** daily mini-quest per day
- No rerolls; same quest all day

---

## Weekly Combo Quests (1/week, 7 days)

### Rules
- 1 weekly quest is assigned at the start of week (user sees it immediately)
- User has **7 days** to complete it
- Multi-skill combinations
- **All-or-nothing reward**
- Weekly bonus XP is **flat** (no multipliers)

### Weekly Quest Types (v1 set)

#### 1) Balance Quest
Requirement:
- Train **3 different skills** on **4 different days**

Rewards:
- **+500 XP** to each of the 3 skills
- **+400 Consistency XP**
- **+200 Curiosity XP**
- Weekly badge

#### 2) Mind + Body Combo
Requirement:
- **3 Mind sessions** AND **3 Body sessions**

Rewards:
- **+600 XP** split across used skills (implementation: distribute equally to skills used, capped per skill if desired)
- **+500 Consistency XP**
- Weekly badge

#### 3) Focused Grind
Requirement:
- **5 Deep Work sessions**
- **2 nights Sleep ≥ 7h**

Rewards:
- **+800 Deep Work XP**
- **+300 Sleep XP**
- **+500 Discipline XP**
- Weekly badge

#### 4) Creative Burst
Requirement:
- **3 sessions** across Art or Craft skills
- On **3 separate days**

Rewards:
- **+600 XP** to each creative skill used
- **+300 Curiosity XP**
- **+300 Consistency XP**
- Weekly badge

#### 5) Comeback Week (Resilience)
Requirement:
- **Restart 2 skills** (skills with broken streaks)
- Train each at least **twice**

Rewards:
- **+1200 Resilience XP**
- **+300 XP** to each restarted skill
- Weekly badge

---

## Meta Skills (Auto-Leveled)

Meta skills never multiply other XP. They only gain their own XP.

### Consistency
- +75 XP per completed daily mini-quest
- +400–500 XP per completed weekly quest (use the values above)

### Discipline
- Manual toggle on a session: “Trained despite resistance”
- Suggested: **+150 Discipline XP** per flagged session
- (Optional cap) e.g., max 300/day

### Resilience (Stop–Start Reward)
**Restart definition:** logging a skill after **≥2 missed days** where the skill previously had a streak.

Resilience XP scales by restart frequency (rolling 30 days), capped:

| Restart count (rolling 30d) | Resilience XP |
|---|---|
| 1st | +300 |
| 2nd | +450 |
| 3rd | +600 |
| 4th | +750 |
| 5th+ | **+900 cap** |

Rules:
- Rolling 30-day window per user (optionally per skill)
- XP goes to Resilience skill only

### Curiosity
Suggested triggers:
- +200 Curiosity XP when training a skill not used in 30 days
- +200 Curiosity XP for first-time training a skill

---

## XP Economy Safety Rules
- Max 1 daily mini-quest per day
- Max 1 weekly quest per week
- Mini-quest and weekly quest XP are flat (no multipliers)
- Streak multiplier capped at 1.5×
- No negative XP ever

---

## UI Data Requirements (Game-First)
Each skill detail must show:
- Level
- Exact XP: `current / nextLevel`
- Percent to next level
- Streak length and current multiplier
- Recent XP audit trail (events)

---

## Non-Negotiable Tone Rule
**Everything should feel like progress. Nothing should feel like failure.**
