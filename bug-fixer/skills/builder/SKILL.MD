---
name: builder-interactive
description: Propose features one at a time. Wait for user approval. Build incrementally.
---

# Interactive Feature Builder

Build features **one at a time** with user approval.

## Workflow

1. **Check status** `_coordination/status-dashboard.md` - what's Bug Fixer working on?
2. **Read** `_coordination/NEXT_ACTIONS.md` - what features are planned?
3. **Propose** the next logical feature that avoids locked files
4. **Wait** for user approval/modification
5. **Build** the approved feature
6. **Deploy** (app should still run after adding feature)
7. **Repeat**

## Feature Proposal Template

```markdown
# Feature Proposal

## Fleet Status Check:
[Read _coordination/status-dashboard.md]

**Bug Fixer currently working on:**
- [List locked files, if any]

**Safe to work on:**
- [List available areas/files]

---

## Next Feature: [Name]

**What it does:**
[1-2 sentence description]

**Why now:**
[Why this is the logical next step]

**Why safe to build:**
[Explain how this avoids any locked files]

**Files to modify/create:**
- [file 1] ✓ (available)
- [file 2] ✓ (available)

**Estimated complexity:** Simple / Medium / Complex

**Do you want to:**
1. Build this feature as-is
2. Modify the feature (tell me how)
3. Skip to different feature
4. Stop for now
```

## After Building

Update `_coordination/BUILD_LOG.md`:
```markdown
# Feature: [Name]

## Added:
- [Brief description]

## Files changed:
- [list files]

## Test it:
[How user can verify it works]

## Status: DEPLOYED ✓
App still running with new feature.
```

## Rules

- **Check status first** - always read status-dashboard.md before proposing
- **Avoid locked files** - propose features that don't conflict with Bug Fixer
- **One feature at a time** - don't build multiple
- **Keep app running** - never break existing features
- **Small increments** - prefer small features over large
- **Always deployable** - after each feature, app should work

## Conflict Avoidance

**Before proposing a feature:**

1. Check `_coordination/status-dashboard.md`
2. See what files Bug Fixer is working on
3. Propose features that use different files
4. If all planned features conflict, suggest:
   - Wait for Bug Fixer to finish (~X minutes)
   - OR work on a different feature from roadmap
   - OR create new feature in new module

**Example:**
```
Status dashboard shows:
- Bug Fixer working on: src/auth/login.js

Good proposal: Feature using features/notifications.js ✓
Bad proposal: Feature using src/auth/login.js ✗
```