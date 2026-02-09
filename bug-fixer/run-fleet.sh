#!/bin/bash

# Fleet Orchestration - Complete Workflow
# Architect → Bootstrap → Interactive Builder + Background Tester + Background Bug Fixer

set -e

PROJECT_DIR="$(pwd)"
COORDINATION_DIR="${PROJECT_DIR}/_coordination"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ $1"
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }

# Create directories
mkdir -p "$COORDINATION_DIR"/{test-results,locks}

# ═══════════════════════════════════════
# PHASE 1: ARCHITECT (One-time)
# ═══════════════════════════════════════

if [ ! -f "$COORDINATION_DIR/ARCHITECTURE.md" ]; then
    print_header "PHASE 1: Architect"
    
    claude <<EOF
Read ~/.claude/skills/architect-lean/SKILL.md

Create the architecture for this project.
Ask the user what they want to build.
Create ARCHITECTURE.md and NEXT_ACTIONS.md in _coordination/
EOF
    
    print_success "Architecture created"
    echo ""
    read -p "Press Enter to continue..."
fi

# ═══════════════════════════════════════
# PHASE 2: BOOTSTRAP (One-time)
# ═══════════════════════════════════════

if [ ! -f "$COORDINATION_DIR/.bootstrap_complete" ]; then
    print_header "PHASE 2: Bootstrap Builder"
    
    claude <<EOF
Read ~/.claude/skills/builder-bootstrap/SKILL.md
Read _coordination/ARCHITECTURE.md

Create minimal deployable skeleton.
Get the app running with zero features.
Update _coordination/BUILD_LOG.md
EOF
    
    print_success "Bootstrap complete"
    
    echo ""
    echo -e "${YELLOW}Start the app in a separate terminal if needed.${NC}"
    read -p "Is app running? (y/n): " app_running
    
    if [[ $app_running != "y" ]]; then
        print_error "Start app before continuing"
        exit 1
    fi
    
    touch "$COORDINATION_DIR/.bootstrap_complete"
    echo ""
    read -p "Press Enter to start interactive development..."
fi

# ═══════════════════════════════════════
# PHASE 3: BACKGROUND TEST + FIX LOOP
# ═══════════════════════════════════════

print_header "Starting Background Test & Fix Loop"

# Initialize files
touch "$COORDINATION_DIR/test-results/bugs-found.md"
touch "$COORDINATION_DIR/test-results/history.log"
echo "Status: Idle" > "$COORDINATION_DIR/status-dashboard.md"

# Single background process - Test → Fix → Test loop
{
    LAST_MOD=0
    while true; do
        # Check for changes in BUILD_LOG
        if [ -f "$COORDINATION_DIR/BUILD_LOG.md" ]; then
            CURRENT_MOD=$(stat -f %m "$COORDINATION_DIR/BUILD_LOG.md" 2>/dev/null || stat -c %Y "$COORDINATION_DIR/BUILD_LOG.md" 2>/dev/null || echo 0)
            
            if [ "$CURRENT_MOD" != "$LAST_MOD" ] && [ "$LAST_MOD" != "0" ]; then
                # === TESTER: Run tests ===
                claude <<EOF
Read ~/.claude/skills/tester-background/SKILL.md

BUILD_LOG.md changed. Run tests:
1. Execute: npm test (or pytest, etc)
2. Update test-results/latest.md (5 lines max)
3. If bugs found, update bugs-found.md (brief)
4. Append to history.log (one line)

Keep it minimal.
EOF
                
                # === BUG FIXER: Fix any critical bugs found ===
                if grep -q "🔴 CRITICAL" "$COORDINATION_DIR/test-results/bugs-found.md" 2>/dev/null; then
                    claude <<EOF
Read ~/.claude/skills/bugfixer/SKILL.md

Critical bugs found in bugs-found.md.

For each 🔴 CRITICAL bug:
1. Update status-dashboard.md (show working on bug)
2. Update locks/files.lock
3. Fix the bug
4. Update BUGFIX_LOG.md (brief)
5. Mark as FIXED in bugs-found.md
6. Release locks

Keep it minimal.
EOF
                    
                    # === TESTER: Re-test after fixes ===
                    claude <<EOF
Read ~/.claude/skills/tester-background/SKILL.md

Bug fixes applied. Re-run tests:
1. Execute: npm test
2. Update test-results/latest.md (5 lines)
3. Update bugs-found.md (mark verified)
4. Append to history.log

Keep it minimal.
EOF
                fi
                
                LAST_MOD=$CURRENT_MOD
            fi
        fi
        sleep 10
    done
} &> /dev/null &
TEST_FIX_LOOP_PID=$!

print_success "Background Test & Fix Loop started (PID: $TEST_FIX_LOOP_PID)"

# Cleanup on exit
trap "kill $TEST_FIX_LOOP_PID 2>/dev/null" EXIT

# ═══════════════════════════════════════
# PHASE 4: INTERACTIVE BUILDER
# ═══════════════════════════════════════

print_header "Interactive Builder"

FEATURE_NUM=1
MAX_ROUNDS=20

while [ $FEATURE_NUM -le $MAX_ROUNDS ]; do
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  Feature Round #$FEATURE_NUM${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Show status
    if [ -f "$COORDINATION_DIR/status-dashboard.md" ]; then
        echo -e "${YELLOW}Fleet Status:${NC}"
        cat "$COORDINATION_DIR/status-dashboard.md"
        echo ""
    fi
    
    # Check for critical bugs
    if [ -f "$COORDINATION_DIR/test-results/bugs-found.md" ] && grep -q "🔴 CRITICAL" "$COORDINATION_DIR/test-results/bugs-found.md"; then
        echo -e "${RED}⚠️  Critical bugs detected!${NC}"
        grep "🔴 CRITICAL" "$COORDINATION_DIR/test-results/bugs-found.md" | head -n 3
        echo ""
        echo "Bug Fixer is working on these automatically."
        echo ""
        read -p "Continue building or wait? (c/w): " choice
        if [[ $choice == "w" ]]; then
            echo "Waiting 30 seconds for bug fixes..."
            sleep 30
            continue
        fi
    fi
    
    # Propose feature
    claude <<EOF
Read ~/.claude/skills/builder-interactive/SKILL.md

Check _coordination/status-dashboard.md (what's locked?)
Read _coordination/NEXT_ACTIONS.md (what's planned?)

Propose next feature that avoids locked files.

Format:
Fleet Status Check:
- Bug Fixer working on: [files if any]
- Safe to work on: [available areas]

Feature Proposal #$FEATURE_NUM: [Name]
- What it does: [brief]
- Why safe: [no conflicts]
- Files: [list with ✓]

Wait for user decision.
EOF
    
    echo ""
    echo -e "${YELLOW}╔════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  What do you want to do?          ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════╝${NC}"
    echo ""
    echo "  1) Build this feature"
    echo "  2) Modify the feature"
    echo "  3) Skip to different feature"
    echo "  4) Add manual test"
    echo "  5) View logs"
    echo "  6) Stop"
    echo ""
    read -p "Choice [1-6]: " choice
    
    case $choice in
        1)
            echo ""
            claude <<EOF
Build the proposed feature.
Keep app running.
Update _coordination/BUILD_LOG.md (brief).
EOF
            print_success "Feature #$FEATURE_NUM built!"
            FEATURE_NUM=$((FEATURE_NUM + 1))
            ;;
        2)
            echo ""
            read -p "How to modify?: " modification
            claude <<EOF
User wants: $modification
Build the modified feature.
Update _coordination/BUILD_LOG.md (brief).
EOF
            print_success "Modified feature #$FEATURE_NUM built!"
            FEATURE_NUM=$((FEATURE_NUM + 1))
            ;;
        3)
            echo ""
            read -p "Which feature?: " different_feature
            claude <<EOF
Build: $different_feature
Update _coordination/BUILD_LOG.md (brief).
EOF
            print_success "Custom feature #$FEATURE_NUM built!"
            FEATURE_NUM=$((FEATURE_NUM + 1))
            ;;
        4)
            echo ""
            read -p "Test description: " test_desc
            # Add to tester queue for manual test
            echo "- [ ] $test_desc" >> "$COORDINATION_DIR/test-queue.md"
            echo "Manual test queued. Background tester will handle it."
            ;;
        5)
            echo ""
            echo "=== BUILD LOG ==="
            cat "$COORDINATION_DIR/BUILD_LOG.md" 2>/dev/null || echo "None"
            echo ""
            echo "=== TEST RESULTS ==="
            cat "$COORDINATION_DIR/test-results/latest.md" 2>/dev/null || echo "None"
            echo ""
            echo "=== BUGS ==="
            cat "$COORDINATION_DIR/test-results/bugs-found.md" 2>/dev/null || echo "None"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        6)
            break
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
done

# ═══════════════════════════════════════
# CLEANUP
# ═══════════════════════════════════════

print_header "Session Complete"

kill $TEST_FIX_LOOP_PID 2>/dev/null || true

echo "Summary:"
echo "  • Features built: $((FEATURE_NUM - 1))"
echo "  • Files: $COORDINATION_DIR"
echo ""

if [ -f "$COORDINATION_DIR/test-results/latest.md" ]; then
    echo "Final test status:"
    head -n 5 "$COORDINATION_DIR/test-results/latest.md"
fi

echo ""
print_success "Done!"