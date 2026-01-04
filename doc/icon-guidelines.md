# Skill Icon Guidelines

## Where to put icons
Add icons into `IRL-RPG/Assets.xcassets/SkillIcons` as individual image sets. Each image set name must match the skill raw value exactly.

## Naming (must match skill raw values)
Mind:
- `reading`
- `writing`
- `research`
- `deepWork`
- `meditation`

Body:
- `weightlifting`
- `cardio`
- `walking`
- `sleep`
- `yoga`
- `surfing`
- `basketball`
- `swimming`
- `sauna`
- `iceBaths`

Hobby:
- `woodworking`
- `pottery`
- `cooking`
- `coding`
- `drawing`
- `painting`
- `music`
- `crafting`

Meta:
- `consistency`
- `discipline`
- `resilience`
- `curiosity`
- `creativity`

## Asset format
- Preferred: vector PDF (single scale).
- Acceptable: PNGs at @1x/@2x/@3x.

## Helper script
Use `scripts/import_skill_icons.sh` to create imagesets from a folder of PDFs/PNGs.
