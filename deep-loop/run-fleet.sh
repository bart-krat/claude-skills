#!/bin/bash

# Claude Code Fleet - Complete Orchestration
# Handles both initial setup (Architect) and development cycles (Build → Test → Deploy)

set -e  # Exit on error

# Configuration
PROJECT_DIR="$(pwd)"
COORDINATION_DIR="${PROJECT_DIR}/_coordination"
MAX_ROUNDS=10

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if coordination directory exists
if [ ! -d "$COORDINATION_DIR" ]; then
    mkdir -p "$COORDINATION_DIR"
fi

# ===========================
# INITIAL SETUP CHECK
# ===========================

if [ ! -f "$COORDINATION_DIR/ARCHITECTURE.md" ]; then
    print_header "INITIAL SETUP - Architect Phase"
    
    echo "No architecture found. Running initial setup..."
    echo ""
    
    # Check if architect skill exists
    if [ ! -f "$HOME/.claude/skills/architect/SKILL.md" ]; then
        print_error "Architect skill not found at ~/.claude/skills/architect/SKILL.md"
        echo "Please install the skills first. See README.md for instructions."
        exit 1
    fi
    
    echo "Starting Architect (Claude Code) instance..."
    echo "The Architect will create the initial system architecture."
    echo ""
    
    claude <<EOF
Read the architect skill at ~/.claude/skills/architect/SKILL.md

Your task: Create the initial architecture for this project.

Ask the user what they want to build, then create:
1. _coordination/ARCHITECTURE.md - Complete system design
2. _coordination/NEXT_ACTIONS.md - Initial priorities for Builder

Follow all instructions in the architect skill.
EOF
    
    echo ""
    print_success "Architect phase complete"
    
    # Show created files
    if [ -f "$COORDINATION_DIR/ARCHITECTURE.md" ]; then
        echo ""
        print_success "Created ARCHITECTURE.md"
        echo ""
        echo "Architecture summary:"
        echo "----------------------------------------"
        head -n 30 "$COORDINATION_DIR/ARCHITECTURE.md"
        echo "----------------------------------------"
    fi
    
    if [ -f "$COORDINATION_DIR/NEXT_ACTIONS.md" ]; then
        echo ""
        print_success "Created NEXT_ACTIONS.md"
        echo ""
        echo "Next actions:"
        echo "----------------------------------------"
        head -n 20 "$COORDINATION_DIR/NEXT_ACTIONS.md"
        echo "----------------------------------------"
    fi
    
    echo ""
    echo -e "${CYAN}Initial setup complete! Now starting development cycles...${NC}"
    echo ""
    read -p "Press Enter to begin Round 1..."
else
    print_header "Claude Code Fleet - Development Cycles"
    echo "Architecture already exists. Continuing from where we left off..."
    echo ""
fi

# ===========================
# MAIN ORCHESTRATION LOOP
# ===========================

ROUND=1

while [ $ROUND -le $MAX_ROUNDS ]; do
    print_header "ROUND $ROUND - Build → Test → Deploy Cycle"
    
    # ===========================
    # PHASE 1: BUILD
    # ===========================
    print_header "Phase 1: Builder"
    echo "Starting Builder instance..."
    echo ""
    
    claude <<EOF
Read the builder skill at ~/.claude/skills/builder/SKILL.md
Read _coordination/ARCHITECTURE.md and _coordination/NEXT_ACTIONS.md
Follow the builder skill instructions to implement the next priority tasks.
Update _coordination/BUILD_LOG.md and _coordination/NEXT_ACTIONS.md when complete.
EOF
    
    print_success "Build phase complete"
    
    # ===========================
    # PHASE 2: TEST
    # ===========================
    print_header "Phase 2: Tester"
    echo "Starting Tester instance..."
    echo ""
    
    claude <<EOF
Read the tester skill at ~/.claude/skills/tester/SKILL.md
Read _coordination/BUILD_LOG.md and _coordination/NEXT_ACTIONS.md
Follow the tester skill instructions to test the code.
Update _coordination/TEST_REPORT.md and _coordination/NEXT_ACTIONS.md when complete.
EOF
    
    print_success "Test phase complete"
    
    # ===========================
    # PHASE 3: DEPLOY
    # ===========================
    print_header "Phase 3: Deployer"
    echo "Starting Deployer instance..."
    echo ""
    
    claude <<EOF
Read the deployer skill at ~/.claude/skills/deployer/SKILL.md
Read _coordination/TEST_REPORT.md and _coordination/NEXT_ACTIONS.md
Follow the deployer skill instructions to deploy and verify.
Update _coordination/DEPLOYMENT_LOG.md and _coordination/NEXT_ACTIONS.md when complete.
EOF
    
    print_success "Deploy phase complete"
    
    # ===========================
    # ROUND SUMMARY
    # ===========================
    print_header "Round $ROUND Complete"
    
    echo "Summary of coordination files:"
    ls -lh "$COORDINATION_DIR" 2>/dev/null || echo "No coordination files yet"
    echo ""
    
    # Show current status
    if [ -f "$COORDINATION_DIR/NEXT_ACTIONS.md" ]; then
        echo -e "${BLUE}Current Status:${NC}"
        echo "----------------------------------------"
        # Show first 25 lines of NEXT_ACTIONS.md
        head -n 25 "$COORDINATION_DIR/NEXT_ACTIONS.md"
        echo "----------------------------------------"
        echo ""
        
        # Check for critical bugs
        CRITICAL_COUNT=$(grep -c "🔴" "$COORDINATION_DIR/NEXT_ACTIONS.md" || echo "0")
        if [ "$CRITICAL_COUNT" -gt 0 ]; then
            print_warning "Critical bugs detected: $CRITICAL_COUNT 🔴"
            echo "Next round should prioritize these fixes."
        else
            print_success "No critical bugs detected"
        fi
        
        # Check deployment status
        if [ -f "$COORDINATION_DIR/DEPLOYMENT_LOG.md" ]; then
            echo ""
            if grep -q "DEPLOYMENT SUCCESSFUL" "$COORDINATION_DIR/DEPLOYMENT_LOG.md"; then
                print_success "Deployment successful!"
            else
                print_error "Deployment failed - check DEPLOYMENT_LOG.md for details"
            fi
        fi
    fi
    
    # ===========================
    # USER INPUT
    # ===========================
    echo ""
    echo -e "${YELLOW}╔════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  What would you like to do next?  ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════╝${NC}"
    echo ""
    echo "  1) Continue to Round $((ROUND + 1)) (Build → Test → Deploy)"
    echo "  2) View detailed logs"
    echo "  3) Stop fleet and exit"
    echo ""
    read -p "Enter choice [1-3] (default: 1): " choice
    choice=${choice:-1}
    
    case $choice in
        1)
            ROUND=$((ROUND + 1))
            if [ $ROUND -gt $MAX_ROUNDS ]; then
                print_warning "Maximum rounds ($MAX_ROUNDS) reached"
                break
            fi
            echo ""
            echo -e "${GREEN}➜ Continuing to Round $ROUND...${NC}"
            sleep 1
            ;;
        2)
            echo ""
            echo "Select log to view:"
            echo "  1) ARCHITECTURE.md"
            echo "  2) BUILD_LOG.md"
            echo "  3) TEST_REPORT.md"
            echo "  4) DEPLOYMENT_LOG.md"
            echo "  5) NEXT_ACTIONS.md"
            echo "  6) Go back"
            echo ""
            read -p "Enter choice [1-6]: " log_choice
            
            echo ""
            case $log_choice in
                1) 
                    echo -e "${BLUE}=== ARCHITECTURE.md ===${NC}"
                    cat "$COORDINATION_DIR/ARCHITECTURE.md" 2>/dev/null || echo "File not found"
                    ;;
                2) 
                    echo -e "${BLUE}=== BUILD_LOG.md ===${NC}"
                    cat "$COORDINATION_DIR/BUILD_LOG.md" 2>/dev/null || echo "File not found"
                    ;;
                3) 
                    echo -e "${BLUE}=== TEST_REPORT.md ===${NC}"
                    cat "$COORDINATION_DIR/TEST_REPORT.md" 2>/dev/null || echo "File not found"
                    ;;
                4) 
                    echo -e "${BLUE}=== DEPLOYMENT_LOG.md ===${NC}"
                    cat "$COORDINATION_DIR/DEPLOYMENT_LOG.md" 2>/dev/null || echo "File not found"
                    ;;
                5) 
                    echo -e "${BLUE}=== NEXT_ACTIONS.md ===${NC}"
                    cat "$COORDINATION_DIR/NEXT_ACTIONS.md" 2>/dev/null || echo "File not found"
                    ;;
                6) 
                    echo "Returning to menu..."
                    ;;
                *) 
                    echo "Invalid choice"
                    ;;
            esac
            
            # Ask again what to do
            echo ""
            echo "Options:"
            echo "  1) Continue to next round"
            echo "  2) View another log"
            echo "  3) Stop fleet"
            echo ""
            read -p "Enter choice [1-3]: " continue_choice
            
            case $continue_choice in
                1)
                    ROUND=$((ROUND + 1))
                    if [ $ROUND -gt $MAX_ROUNDS ]; then
                        print_warning "Maximum rounds ($MAX_ROUNDS) reached"
                        break
                    fi
                    ;;
                2)
                    # Loop back to log viewing
                    ROUND=$((ROUND - 1))  # Don't increment round
                    ;;
                3)
                    print_warning "Stopping fleet"
                    break
                    ;;
                *)
                    ROUND=$((ROUND + 1))
                    ;;
            esac
            ;;
        3)
            print_warning "Stopping fleet"
            break
            ;;
        *)
            echo "Invalid choice, continuing to next round..."
            ROUND=$((ROUND + 1))
            ;;
    esac
done

# ===========================
# COMPLETION SUMMARY
# ===========================
print_header "Fleet Orchestration Complete"

echo "📊 Session Summary:"
echo "  • Total rounds completed: $((ROUND - 1))"
echo "  • Coordination files: $COORDINATION_DIR"
echo ""

if [ -f "$COORDINATION_DIR/DEPLOYMENT_LOG.md" ]; then
    if grep -q "DEPLOYMENT SUCCESSFUL" "$COORDINATION_DIR/DEPLOYMENT_LOG.md"; then
        print_success "Final status: Deployment successful! ✨"
    else
        print_warning "Final status: Deployment incomplete"
    fi
fi

echo ""
echo "📁 Generated files:"
ls -lh "$COORDINATION_DIR"

echo ""
print_success "Done! Your AI fleet has finished working."
echo ""
echo "To review the work:"
echo "  • Architecture: cat _coordination/ARCHITECTURE.md"
echo "  • Current status: cat _coordination/NEXT_ACTIONS.md"
echo "  • Test results: cat _coordination/TEST_REPORT.md"
echo "  • Deployment: cat _coordination/DEPLOYMENT_LOG.md"
echo ""