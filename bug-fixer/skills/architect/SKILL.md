---
name: architect-lean
description: Create practical architecture based on user requirements. Balance between rapid deployment and production considerations. Use when starting a new project.
---

# Architect - Lean Version

Create a **practical, deployable architecture** based on what the user actually needs.

## Your Job

1. **Understand the requirements**
   - Ask: "What do you want to build?" 
   - Ask: "Who will use it and how?"
   - Ask: "Any specific technical requirements or constraints?"

2. **Choose appropriate tech stack**
   - Match technology to requirements (not always simplest)
   - Consider: What does this actually need?
   - Consider: What will make development smooth?
   - Consider: What's production-ready but not over-engineered?

3. **Design for incremental delivery**
   - Plan features in priority order
   - First deployment should work and be useful
   - Can add complexity as needed

## Create These Files

### _coordination/ARCHITECTURE.md

```markdown
# Architecture

## What We're Building
[2-3 sentence description]
[Key user needs this solves]

## Tech Stack
**Language:** [choice based on requirements]
**Framework:** [if beneficial for this use case]
**Database:** [appropriate for data needs - SQL, NoSQL, or file-based]
**Deployment:** [realistic target - local, cloud, container]

**Rationale:** [Why these choices make sense for this project]

## System Components

[List 3-5 main components/modules]
- Component 1: [Purpose]
- Component 2: [Purpose]
- Component 3: [Purpose]

## File Structure
```
src/
  [organized by feature/component]
  main.[ext]
  [3-8 files depending on complexity]
tests/
  [mirror src structure]
config/
  [if needed]
```

## Feature Roadmap (Priority Order)

### Phase 1 - Bootstrap (Get it running)
1. [Core feature that demonstrates value]
2. [Essential supporting feature]
3. [Basic deployment capability]

### Phase 2 - Core Functionality (Rounds 2-4)
4. [Next priority feature]
5. [Next priority feature]
6. [Next priority feature]

### Phase 3 - Production Hardening (Rounds 5+)
7. [Security enhancements]
8. [Error handling improvements]
9. [Observability/monitoring]
10. [Performance optimization]

## Production Considerations

**Security:** [Key security measures needed]
**Error Handling:** [Strategy for errors]
**Logging:** [What to log, where]
**Performance:** [Any known concerns to address]

Note: Basic versions implemented early, enhanced as we go.

## Data Model (if applicable)
[Key entities and relationships]

## API Design (if applicable)
[Key endpoints or interfaces]
```

### _coordination/NEXT_ACTIONS.md

```markdown
# Next Actions

## Bootstrap Goal:
Get a working, deployable version with core value proposition.

## Ready for Round 1 (Bootstrap):
- [ ] Build: [Core feature - most important capability]
- [ ] Build: [Essential setup - config, structure]
- [ ] Build: [Basic tests]
- [ ] Deploy: Get it running locally

## Ready for Round 2-4 (Core Features):
- [ ] Build: [Feature from Phase 2]
- [ ] Build: [Feature from Phase 2]
- [ ] Build: [Feature from Phase 2]

## Future Rounds (Production Polish):
- [ ] Add comprehensive error handling
- [ ] Add logging and monitoring
- [ ] Add security hardening
- [ ] Performance optimization
```

## Guidelines

### DO:
✅ Ask clarifying questions about requirements
✅ Choose technology that fits the use case
✅ Plan for production, but implement incrementally
✅ Consider security and observability from start
✅ Design components that can be built independently
✅ Prioritize features based on user value

### DON'T:
❌ Assume simplest is always best
❌ Ignore production needs entirely
❌ Over-engineer for scale not needed yet
❌ Create 50-feature roadmap (keep it focused)
❌ Design components that require everything at once

## Balancing Act

**Not too simple:**
- Don't choose tech that won't scale to production
- Don't skip essential security considerations
- Don't ignore error handling completely

**Not too complex:**
- Don't build for millions of users if you have 10
- Don't add every possible feature upfront
- Don't require perfect architecture before shipping

**Just right:**
- Choose production-ready tech that's also fast to develop with
- Plan for security/logging but implement basic versions first
- Get to deployment quickly, then iterate and improve

## Keep It Practical

Architecture.md should be ~100-150 lines.
Feature roadmap should be ~10-15 features.
Focus on getting to a working, useful deployment quickly.