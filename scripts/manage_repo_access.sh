#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Manage repository access for Softsensor org members
# This script helps configure appropriate access levels

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO="Softsensor-org/DevPilot"

echo -e "${BLUE}==> Repository Access Management for $REPO${NC}"
echo ""

# Function to check if gh CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
        echo "Install with: brew install gh (macOS) or apt install gh (Linux)"
        exit 1
    fi

    # Check if authenticated
    if ! gh auth status &>/dev/null; then
        echo -e "${RED}Error: Not authenticated with GitHub${NC}"
        echo "Run: gh auth login"
        exit 1
    fi
}

# Function to list current access
list_current_access() {
    echo -e "${BLUE}Current Repository Access:${NC}"
    echo ""

    # Check if repo has teams
    echo -e "${YELLOW}Teams with access:${NC}"
    gh api "repos/$REPO/teams" --jq '.[] | "\(.name): \(.permission)"' 2>/dev/null || echo "  No team access configured"
    echo ""

    # List collaborators
    echo -e "${YELLOW}Direct collaborators:${NC}"
    gh api "repos/$REPO/collaborators" --jq '.[] | "\(.login): \(.permissions | if .admin then "admin" elif .push then "write" elif .pull then "read" else "none" end)"' 2>/dev/null | head -20
    echo ""

    # Count total collaborators
    TOTAL=$(gh api "repos/$REPO/collaborators" --jq '. | length' 2>/dev/null || echo 0)
    echo -e "${GREEN}Total collaborators: $TOTAL${NC}"
}

# Function to add team access
setup_team_access() {
    echo -e "${BLUE}Setting up team-based access...${NC}"
    echo ""

    # Check if organization teams exist
    echo "Checking organization teams..."
    TEAMS=$(gh api "orgs/Softsensor-org/teams" --jq '.[].slug' 2>/dev/null || echo "")

    if [ -z "$TEAMS" ]; then
        echo -e "${YELLOW}No teams found in organization.${NC}"
        echo ""
        echo "Would you like to create teams? (Recommended structure)"
        echo "  1. developers - Write access for all developers"
        echo "  2. contributors - Read access for external contributors"
        echo "  3. admins - Admin access for maintainers"
        echo ""
        read -p "Create recommended teams? (y/n): " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Create teams
            echo "Creating teams..."

            # Create developers team
            gh api --method POST "orgs/Softsensor-org/teams" \
                -f name="developers" \
                -f description="Core development team with write access" \
                -f privacy="closed" \
                -f permission="push" 2>/dev/null && echo -e "${GREEN}✓ Created 'developers' team${NC}"

            # Create contributors team
            gh api --method POST "orgs/Softsensor-org/teams" \
                -f name="contributors" \
                -f description="External contributors with read access" \
                -f privacy="closed" \
                -f permission="pull" 2>/dev/null && echo -e "${GREEN}✓ Created 'contributors' team${NC}"

            # Create admins team
            gh api --method POST "orgs/Softsensor-org/teams" \
                -f name="admins" \
                -f description="Repository administrators" \
                -f privacy="closed" \
                -f permission="admin" 2>/dev/null && echo -e "${GREEN}✓ Created 'admins' team${NC}"
        fi
    else
        echo -e "${GREEN}Found existing teams:${NC}"
        echo "$TEAMS"
    fi

    echo ""
    echo -e "${BLUE}Adding repository to team access:${NC}"

    # Add repo to teams
    for team in developers contributors admins; do
        if gh api "orgs/Softsensor-org/teams/$team" &>/dev/null; then
            PERMISSION="push"
            [ "$team" = "contributors" ] && PERMISSION="pull"
            [ "$team" = "admins" ] && PERMISSION="admin"

            gh api --method PUT "orgs/Softsensor-org/teams/$team/repos/$REPO" \
                -f permission="$PERMISSION" 2>/dev/null && \
                echo -e "${GREEN}✓ Added $team team with $PERMISSION access${NC}" || \
                echo -e "${YELLOW}⚠ Could not add $team team${NC}"
        fi
    done
}

# Function to enable issues for everyone
enable_public_issues() {
    echo ""
    echo -e "${BLUE}Configuring issue permissions...${NC}"

    # Update repository settings
    gh api --method PATCH "repos/$REPO" \
        -f has_issues=true \
        -f has_discussions=true 2>/dev/null && \
        echo -e "${GREEN}✓ Issues and discussions enabled${NC}" || \
        echo -e "${YELLOW}⚠ Could not update issue settings${NC}"

    echo ""
    echo -e "${GREEN}Note: For a private repository:${NC}"
    echo "  • Organization members can create issues"
    echo "  • External users need explicit collaborator access"
    echo "  • Consider making repo public for open issue submission"
}

# Function to add all org members
add_all_org_members() {
    echo ""
    echo -e "${BLUE}Adding all organization members...${NC}"

    # Get all org members
    MEMBERS=$(gh api "orgs/Softsensor-org/members" --jq '.[].login' 2>/dev/null)

    if [ -z "$MEMBERS" ]; then
        echo -e "${RED}Could not fetch organization members${NC}"
        return
    fi

    echo "Found $(echo "$MEMBERS" | wc -l) organization members"
    echo ""

    read -p "Add all members with READ access? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for member in $MEMBERS; do
            gh api --method PUT "repos/$REPO/collaborators/$member" \
                -f permission="pull" 2>/dev/null && \
                echo -e "${GREEN}✓ Added $member${NC}" || \
                echo -e "${YELLOW}⚠ Skipped $member (may already have access)${NC}"
        done
    fi
}

# Main menu
show_menu() {
    echo ""
    echo -e "${BLUE}What would you like to do?${NC}"
    echo "  1) View current access levels"
    echo "  2) Set up team-based access (recommended)"
    echo "  3) Add all org members with read access"
    echo "  4) Enable issues for everyone"
    echo "  5) Make repository public (allows external issues)"
    echo "  6) Run recommended setup (2+3+4)"
    echo "  0) Exit"
    echo ""
    read -p "Choose an option: " choice

    case $choice in
        1) list_current_access ;;
        2) setup_team_access ;;
        3) add_all_org_members ;;
        4) enable_public_issues ;;
        5)
            echo ""
            echo -e "${YELLOW}Warning: This will make the repository PUBLIC${NC}"
            read -p "Are you sure? (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                gh api --method PATCH "repos/$REPO" -f private=false 2>/dev/null && \
                    echo -e "${GREEN}✓ Repository is now public${NC}" || \
                    echo -e "${RED}✗ Could not make repository public${NC}"
            fi
            ;;
        6)
            setup_team_access
            add_all_org_members
            enable_public_issues
            echo ""
            echo -e "${GREEN}✓ Recommended setup complete!${NC}"
            ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac

    # Show menu again
    show_menu
}

# Main execution
check_gh_cli

echo -e "${GREEN}Repository: $REPO${NC}"
echo -e "${GREEN}Organization: Softsensor-org${NC}"
echo ""

# Check admin access
if gh api "repos/$REPO" --jq '.permissions.admin' | grep -q true; then
    echo -e "${GREEN}✓ You have admin access${NC}"
else
    echo -e "${RED}✗ You need admin access to manage permissions${NC}"
    echo "Contact a repository admin to run this script"
    exit 1
fi

show_menu
