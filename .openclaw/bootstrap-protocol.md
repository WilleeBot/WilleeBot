# Bootstrap Protocol - Automatic Continuity

## Trigger Conditions

System interruption triggers full continue bootstrap:
- Model change detection
- Session interruption/timeout
- Gateway restart
- New session initialization with existing workspace

## Bootstrap Procedure

1. Load identity and operational framework
2. Load evolutionary lessons (FEEDBACK.md patterns)
3. Load task state (TASKS.md, active work)
4. Load technical state (system constraints, current config)
5. Load latest session context
6. Present bootstrap summary with "FULL CONTINUE" flag

## Handoff Verification

After bootstrap, agent confirms identity + latest state + awaits steering.