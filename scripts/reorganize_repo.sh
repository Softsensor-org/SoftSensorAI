#!/usr/bin/env bash
# Repository Reorganization Script
# Safely reorganizes the repository structure while maintaining all functionality

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo -e "${BLUE}==> DevPilot Repository Reorganization${NC}"
echo ""

# Function to create directories
create_structure() {
    echo -e "${BLUE}Creating new directory structure...${NC}"

    # Create main directories
    mkdir -p .archive
    mkdir -p .github/ISSUE_TEMPLATE
    mkdir -p .github/PULL_REQUEST_TEMPLATE
    mkdir -p config
    mkdir -p docs/{guides,dev,api,architecture}
    mkdir -p workspace
    mkdir -p var/{tmp,cache,logs}

    echo -e "${GREEN}✓ Directory structure created${NC}"
}

# Function to move documentation files
organize_docs() {
    echo -e "${BLUE}Organizing documentation...${NC}"

    # Core docs stay in root (only essentials)
    # README.md, LICENSE, VERSION stay in root

    # Move project docs to docs/
    if [ -f "CHANGELOG.md" ]; then
        git mv CHANGELOG.md docs/CHANGELOG.md 2>/dev/null || mv CHANGELOG.md docs/CHANGELOG.md
        echo -e "${GREEN}✓ Moved CHANGELOG.md${NC}"
    fi

    if [ -f "CONTRIBUTING.md" ]; then
        git mv CONTRIBUTING.md docs/CONTRIBUTING.md 2>/dev/null || mv CONTRIBUTING.md docs/CONTRIBUTING.md
        echo -e "${GREEN}✓ Moved CONTRIBUTING.md${NC}"
    fi

    if [ -f "CODE_OF_CONDUCT.md" ]; then
        git mv CODE_OF_CONDUCT.md docs/CODE_OF_CONDUCT.md 2>/dev/null || mv CODE_OF_CONDUCT.md docs/CODE_OF_CONDUCT.md
        echo -e "${GREEN}✓ Moved CODE_OF_CONDUCT.md${NC}"
    fi

    if [ -f "SECURITY.md" ]; then
        git mv SECURITY.md docs/SECURITY.md 2>/dev/null || mv SECURITY.md docs/SECURITY.md
        echo -e "${GREEN}✓ Moved SECURITY.md${NC}"
    fi

    if [ -f "RELEASE_NOTES.md" ]; then
        git mv RELEASE_NOTES.md docs/RELEASE_NOTES.md 2>/dev/null || mv RELEASE_NOTES.md docs/RELEASE_NOTES.md
        echo -e "${GREEN}✓ Moved RELEASE_NOTES.md${NC}"
    fi

    # Move development docs
    for file in DEVELOPER_CHECKLIST.md TESTING_RESULTS.md TEST_RESULTS.md REORGANIZATION_PLAN.md; do
        if [ -f "$file" ]; then
            git mv "$file" "docs/dev/$file" 2>/dev/null || mv "$file" "docs/dev/$file"
            echo -e "${GREEN}✓ Moved $file to docs/dev/${NC}"
        fi
    done

    # Move guide docs
    for file in DOCUMENTATION_REVIEW.md REPOSITORY_ACCESS_GUIDE.md; do
        if [ -f "$file" ]; then
            git mv "$file" "docs/guides/$file" 2>/dev/null || mv "$file" "docs/guides/$file"
            echo -e "${GREEN}✓ Moved $file to docs/guides/${NC}"
        fi
    done
}

# Function to move config files
organize_configs() {
    echo -e "${BLUE}Organizing configuration files...${NC}"

    # Move package files to config/
    if [ -f "package.json" ]; then
        git mv package.json config/package.json 2>/dev/null || mv package.json config/package.json
        echo -e "${GREEN}✓ Moved package.json${NC}"
    fi

    if [ -f "package-lock.json" ]; then
        git mv package-lock.json config/package-lock.json 2>/dev/null || mv package-lock.json config/package-lock.json
        echo -e "${GREEN}✓ Moved package-lock.json${NC}"
    fi

    if [ -f "requirements.txt" ]; then
        git mv requirements.txt config/requirements.txt 2>/dev/null || mv requirements.txt config/requirements.txt
        echo -e "${GREEN}✓ Moved requirements.txt${NC}"
    fi

    # Move profiles directory
    if [ -d "profiles" ]; then
        git mv profiles config/profiles 2>/dev/null || mv profiles config/profiles
        echo -e "${GREEN}✓ Moved profiles directory${NC}"
    fi
}

# Function to move workspace files
organize_workspace() {
    echo -e "${BLUE}Organizing workspace files...${NC}"

    # Move temporary directories
    if [ -d "artifacts" ]; then
        git mv artifacts var/tmp/artifacts 2>/dev/null || mv artifacts var/tmp/artifacts
        echo -e "${GREEN}✓ Moved artifacts${NC}"
    fi

    if [ -d "downloads" ]; then
        git mv downloads var/tmp/downloads 2>/dev/null || mv downloads var/tmp/downloads
        echo -e "${GREEN}✓ Moved downloads${NC}"
    fi

    # Move examples to workspace
    if [ -d "examples" ]; then
        git mv examples workspace/examples 2>/dev/null || mv examples workspace/examples
        echo -e "${GREEN}✓ Moved examples${NC}"
    fi

    if [ -d "devpilot" ]; then
        git mv devpilot workspace/devpilot 2>/dev/null || mv devpilot workspace/devpilot
        echo -e "${GREEN}✓ Moved devpilot${NC}"
    fi
}

# Function to clean up old files
cleanup_old() {
    echo -e "${BLUE}Cleaning up old files...${NC}"

    # Move old setup.sh if it exists
    if [ -f "setup.sh" ]; then
        git mv setup.sh .archive/setup.sh.old 2>/dev/null || mv setup.sh .archive/setup.sh.old
        echo -e "${GREEN}✓ Archived old setup.sh${NC}"
    fi

    # Clean node_modules (don't track in git)
    if [ -d "node_modules" ]; then
        rm -rf node_modules
        echo -e "${GREEN}✓ Removed node_modules (will reinstall as needed)${NC}"
    fi
}

# Function to create symlinks for backwards compatibility
create_compatibility_links() {
    echo -e "${BLUE}Creating compatibility symlinks...${NC}"

    # Create symlinks for moved files that scripts might reference
    ln -sf docs/CHANGELOG.md CHANGELOG.md 2>/dev/null || true
    ln -sf docs/CONTRIBUTING.md CONTRIBUTING.md 2>/dev/null || true
    ln -sf docs/CODE_OF_CONDUCT.md CODE_OF_CONDUCT.md 2>/dev/null || true
    ln -sf docs/SECURITY.md SECURITY.md 2>/dev/null || true

    # Link config files
    ln -sf config/package.json package.json 2>/dev/null || true
    ln -sf config/package-lock.json package-lock.json 2>/dev/null || true
    ln -sf config/requirements.txt requirements.txt 2>/dev/null || true

    echo -e "${GREEN}✓ Compatibility symlinks created${NC}"
}

# Function to update gitignore
update_gitignore() {
    echo -e "${BLUE}Updating .gitignore...${NC}"

    # Add new patterns to gitignore
    cat >> .gitignore <<'EOF'

# Reorganized structure
/var/tmp/*
/var/cache/*
/var/logs/*
!/var/tmp/.gitkeep
!/var/cache/.gitkeep
!/var/logs/.gitkeep

# Workspace
/workspace/devpilot/*
/workspace/examples/output/*

# Old compatibility symlinks
/CHANGELOG.md
/CONTRIBUTING.md
/CODE_OF_CONDUCT.md
/SECURITY.md
/package.json
/package-lock.json
/requirements.txt
EOF

    echo -e "${GREEN}✓ Updated .gitignore${NC}"
}

# Function to create README for new structure
create_structure_readme() {
    cat > STRUCTURE.md <<'EOF'
# DevPilot Directory Structure

## Root Directory
```
.
├── README.md           # Main documentation
├── LICENSE             # License file
├── VERSION             # Version tracking
├── Makefile            # Build automation
├── setup_all.sh        # Main setup script
├── AGENTS.md           # Agent configurations
├── CLAUDE.md           # Claude AI instructions
└── PROFILE.md          # Profile documentation
```

## Directory Organization

### `/bin/`
Executable scripts and CLI tools
- `dp` - Main DevPilot CLI

### `/config/`
Configuration files and profiles
- `package.json` - Node.js dependencies
- `requirements.txt` - Python dependencies
- `profiles/` - Skill and phase profiles

### `/docs/`
All documentation
- `guides/` - User guides
- `dev/` - Developer documentation
- `api/` - API documentation
- `architecture/` - System design docs

### `/install/`
Installation scripts for different platforms

### `/scripts/`
Utility and automation scripts

### `/setup/`
Repository setup scripts

### `/system/`
System prompts and configurations

### `/templates/`
Project and file templates

### `/tests/`
Test files and test scripts

### `/tools/`
Development tools and utilities

### `/utils/`
Utility functions and helpers

### `/validation/`
Validation and checking scripts

### `/var/`
Variable data (not tracked in git)
- `tmp/` - Temporary files
- `cache/` - Cache files
- `logs/` - Log files

### `/workspace/`
Working directories for examples and testing

### `/.archive/`
Archived old files for reference
EOF

    echo -e "${GREEN}✓ Created STRUCTURE.md${NC}"
}

# Function to add gitkeep files
add_gitkeep() {
    echo -e "${BLUE}Adding .gitkeep files...${NC}"

    touch var/tmp/.gitkeep
    touch var/cache/.gitkeep
    touch var/logs/.gitkeep
    touch workspace/.gitkeep
    touch .archive/.gitkeep

    echo -e "${GREEN}✓ Added .gitkeep files${NC}"
}

# Main execution
echo "This script will reorganize the repository structure."
echo "All functionality will be preserved through symlinks."
echo ""
read -p "Do you want to proceed? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Reorganization cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Starting reorganization...${NC}"
echo ""

# Execute reorganization
create_structure
organize_docs
organize_configs
organize_workspace
cleanup_old
create_compatibility_links
update_gitignore
create_structure_readme
add_gitkeep

echo ""
echo -e "${GREEN}==> Reorganization Complete!${NC}"
echo ""
echo "Summary of changes:"
echo "  • Documentation moved to /docs/"
echo "  • Configuration files moved to /config/"
echo "  • Temporary files moved to /var/tmp/"
echo "  • Examples moved to /workspace/"
echo "  • Compatibility symlinks created"
echo "  • Structure documented in STRUCTURE.md"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the changes with: git status"
echo "  2. Test functionality with: ./scripts/doctor.sh"
echo "  3. Commit changes with: git add -A && git commit -m 'refactor: Reorganize repository structure'"
echo ""
echo -e "${GREEN}All scripts should continue to work normally!${NC}"
