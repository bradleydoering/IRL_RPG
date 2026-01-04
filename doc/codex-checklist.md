# Codex Implementation Checklist (Recommended Order)

This checklist is designed for a local-first MVP that feels like a game immediately.

## Phase 0 — Project Setup
- [ ] Create SwiftUI iOS project
- [ ] Add Core Data stack (or SQLite via GRDB)
- [ ] Establish app-wide `TimeService` (LocalDay, weekStart)
- [ ] Add basic app theming and icons (placeholder ok)

## Phase 1 — Core Domain (No UI polish yet)
- [ ] Define SkillKind enum (23 skills)
- [ ] Implement XPService:
  - [ ] Base XP rates (10 XP/min, sleep 2 XP/min, per-skill session defaults)
  - [ ] Streak multiplier tiers (cap 1.5×)
  - [ ] Level curve TotalXP(L)=120*L^2.2
  - [ ] Level-from-XP function (binary search 1..99)
- [ ] Implement StreakService:
  - [ ] Update streak rules on session log
- [ ] Implement Audit Trail:
  - [ ] XpEvent entity + creation helpers

## Phase 2 — Logging (The “game loop”)
- [ ] Implement Session logging:
  - [ ] Start/stop timer sessions (time-based)
  - [ ] Quick add session (duration/session)
  - [ ] Apply base XP + streak multiplier
  - [ ] Write XpEvent lines (base, streak bonus if represented, etc.)
- [ ] Implement Discipline toggle:
  - [ ] +150 Discipline XP when toggled
- [ ] Implement Curiosity triggers:
  - [ ] First-time skill trained → +200 Curiosity
  - [ ] Skill not trained in 30 days → +200 Curiosity
- [ ] Implement Resilience triggers:
  - [ ] Restart detection (gap >=2 days)
  - [ ] Rolling 30-day restart window count
  - [ ] Award Resilience XP tiers (300,450,600,750,900 cap)

## Phase 3 — Daily Quest (Random Mini-Quest)
- [ ] DailyQuest entity + persistence
- [ ] QuestService daily generation:
  - [ ] On first app open each day: pick random active non-meta skill
  - [ ] Choose requirement: 30 min (time-based) OR 1 session (session-based)
- [ ] Daily quest completion:
  - [ ] Detect requirement met
  - [ ] Award +200 skill XP and +75 Consistency XP
  - [ ] Write XpEvents
  - [ ] Mark completed + badge

## Phase 4 — Weekly Quest (Combo Quest)
- [ ] WeeklyQuest entity + persistence
- [ ] Define WeeklyQuestTemplate enum:
  - [ ] Balance
  - [ ] MindBody
  - [ ] FocusedGrind
  - [ ] CreativeBurst
  - [ ] ComebackWeek
- [ ] QuestService weekly generation (weekStart Monday):
  - [ ] Pick a template at week start
  - [ ] Initialize progress tracking
- [ ] Progress tracking:
  - [ ] Update counters based on sessions logged each day
- [ ] Completion + rewards:
  - [ ] Award flat bonuses (per template)
  - [ ] Award Consistency/Curiosity/Discipline/Resilience bonuses as specified
  - [ ] Mark completed + badge

## Phase 5 — UI (5-tab MVP)
- [ ] Tab bar scaffolding:
  - [ ] Home
  - [ ] Skills
  - [ ] Log
  - [ ] Quests
  - [ ] Profile
- [ ] Home screen:
  - [ ] Today’s mini-quest card + progress
  - [ ] Quick actions
  - [ ] Momentum snippet (streak)
- [ ] Skills list:
  - [ ] Group by category
  - [ ] Level + XP bar + exact XP + %
- [ ] Skill detail:
  - [ ] Start session / quick add
  - [ ] Streak + multiplier shown
  - [ ] XP audit trail list
- [ ] Quests screen:
  - [ ] Weekly quest card + countdown
  - [ ] Progress checklist
  - [ ] History (completed only)
- [ ] Profile:
  - [ ] Meta skills as normal skills
  - [ ] Badges grid (daily + weekly)

## Phase 6 — Polish + Guardrails
- [ ] Enforce caps:
  - [ ] 1 daily quest/day
  - [ ] 1 weekly quest/week
  - [ ] no multipliers on quest XP
- [ ] Add haptics/animations for:
  - [ ] quest completion
  - [ ] level up
  - [ ] badge unlock
- [ ] Add lightweight settings:
  - [ ] week start day (optional)
  - [ ] enable/disable skills (active list)

## Phase 7 — Optional (Future)
- [ ] Apple Health import (sleep + workouts)
- [ ] iCloud/CloudKit sync
- [ ] Friend sharing (requires backend)
