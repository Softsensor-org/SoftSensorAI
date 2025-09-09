#!/usr/bin/env bash
set -euo pipefail

# Multi-Repository Review Tool
# Reviews all repos in a project folder and creates GitHub issues for findings

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

say() { echo -e "${CYAN}→${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err() { echo -e "${RED}✗${NC} $*" >&2; }

# Check if we're in a multi-repo project
check_project_context() {
    if [ -f "PROJECT.json" ]; then
        return 0
    fi
    
    # Check if there are multiple repos
    local repo_count=$(find . -maxdepth 2 -name ".git" -type d 2>/dev/null | wc -l)
    if [ "$repo_count" -gt 1 ]; then
        return 0
    fi
    
    return 1
}

# Review all repositories
review_all_repos() {
    local review_type="${1:-comprehensive}"
    local output_file="review_results_$(date +%Y%m%d_%H%M%S).md"
    
    say "Starting multi-repository review..."
    echo "# Multi-Repository Review Report" > "$output_file"
    echo "**Date:** $(date)" >> "$output_file"
    echo "**Type:** $review_type" >> "$output_file"
    echo "" >> "$output_file"
    
    # Find all repos
    local repos=()
    for repo_dir in $(find . -maxdepth 2 -name ".git" -type d 2>/dev/null | xargs -I {} dirname {} | sort); do
        repos+=("$repo_dir")
    done
    
    say "Found ${#repos[@]} repositories to review"
    
    # Review each repo
    for repo in "${repos[@]}"; do
        local repo_name=$(basename "$repo")
        say "Reviewing $repo_name..."
        
        echo "## Repository: $repo_name" >> "$output_file"
        echo "" >> "$output_file"
        
        cd "$repo"
        
        # Different review types
        case "$review_type" in
            security)
                review_security "$repo_name" >> "../$output_file"
                ;;
            performance)
                review_performance "$repo_name" >> "../$output_file"
                ;;
            comprehensive)
                review_comprehensive "$repo_name" >> "../$output_file"
                ;;
            architecture)
                review_architecture "$repo_name" >> "../$output_file"
                ;;
            *)
                review_comprehensive "$repo_name" >> "../$output_file"
                ;;
        esac
        
        cd ..
        echo "" >> "$output_file"
    done
    
    success "Review complete! Results saved to $output_file"
    echo ""
    echo "Summary:"
    grep -E "^### (🔴|🟡|🟢)" "$output_file" | sort | uniq -c
    
    return 0
}

# Security review
review_security() {
    local repo_name="$1"
    
    echo "### Security Review"
    echo ""
    
    # Check for secrets
    echo "#### Checking for exposed secrets..."
    if command -v gitleaks >/dev/null 2>&1; then
        local leaks=$(gitleaks detect --no-git 2>&1 | grep -c "leaks found" || true)
        if [ "$leaks" -gt 0 ]; then
            echo "### 🔴 CRITICAL: Potential secrets found!"
        else
            echo "### 🟢 No secrets detected"
        fi
    else
        echo "### 🟡 Warning: gitleaks not installed, skipping secret scan"
    fi
    
    # Check dependencies
    echo ""
    echo "#### Dependency vulnerabilities..."
    if [ -f "package.json" ]; then
        if command -v npm >/dev/null 2>&1; then
            local vulns=$(npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities.total' 2>/dev/null || echo "0")
            if [ "$vulns" -gt 0 ]; then
                echo "### 🔴 Found $vulns npm vulnerabilities"
                npm audit 2>/dev/null | grep -E "(Critical|High)" | head -5
            else
                echo "### 🟢 No npm vulnerabilities"
            fi
        fi
    fi
    
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        if command -v pip-audit >/dev/null 2>&1; then
            local py_vulns=$(pip-audit --format json 2>/dev/null | jq '. | length' || echo "0")
            if [ "$py_vulns" -gt 0 ]; then
                echo "### 🔴 Found $py_vulns Python vulnerabilities"
            else
                echo "### 🟢 No Python vulnerabilities"
            fi
        else
            echo "### 🟡 pip-audit not installed"
        fi
    fi
}

# Performance review
review_performance() {
    local repo_name="$1"
    
    echo "### Performance Review"
    echo ""
    
    # Check for large files
    echo "#### Large files check..."
    local large_files=$(find . -type f -size +1M ! -path "./.git/*" ! -path "./node_modules/*" ! -path "./.venv/*" 2>/dev/null | wc -l)
    if [ "$large_files" -gt 0 ]; then
        echo "### 🟡 Found $large_files files >1MB"
        find . -type f -size +1M ! -path "./.git/*" ! -path "./node_modules/*" -exec ls -lh {} \; | head -3
    else
        echo "### 🟢 No large files"
    fi
    
    # Check for unoptimized images
    echo ""
    echo "#### Image optimization..."
    local images=$(find . -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) ! -path "./node_modules/*" 2>/dev/null | wc -l)
    if [ "$images" -gt 0 ]; then
        echo "### 🟡 Found $images images that may need optimization"
    fi
}

# Comprehensive review
review_comprehensive() {
    local repo_name="$1"
    
    review_security "$repo_name"
    echo ""
    review_performance "$repo_name"
    echo ""
    
    echo "### Code Quality"
    echo ""
    
    # Check for TODOs
    local todos=$(grep -r "TODO\|FIXME\|HACK" --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.venv . 2>/dev/null | wc -l || echo "0")
    if [ "$todos" -gt 0 ]; then
        echo "### 🟡 Found $todos TODO/FIXME/HACK comments"
    fi
    
    # Check test coverage
    if [ -f "package.json" ]; then
        if grep -q "\"test\"" package.json; then
            echo "### 🟢 Tests configured"
        else
            echo "### 🔴 No test script found"
        fi
    fi
}

# Architecture review
review_architecture() {
    local repo_name="$1"
    
    echo "### Architecture Review"
    echo ""
    
    # Analyze structure
    echo "#### Project Structure"
    tree -L 2 -d -I 'node_modules|.git|.venv|__pycache__|dist|build' 2>/dev/null || ls -la
    
    echo ""
    echo "#### Dependencies"
    if [ -f "package.json" ]; then
        echo "**Node.js Dependencies:**"
        jq '.dependencies | keys | length' package.json 2>/dev/null && echo " production dependencies"
        jq '.devDependencies | keys | length' package.json 2>/dev/null && echo " dev dependencies"
    fi
    
    if [ -f "requirements.txt" ]; then
        echo "**Python Dependencies:**"
        wc -l < requirements.txt && echo " packages"
    fi
}

# Create GitHub issues from findings
create_github_issues() {
    local review_file="${1:-review_results_*.md}"
    
    if ! command -v gh >/dev/null 2>&1; then
        err "GitHub CLI (gh) not installed. Install with: brew install gh"
        return 1
    fi
    
    # Check if authenticated
    if ! gh auth status >/dev/null 2>&1; then
        err "Not authenticated with GitHub. Run: gh auth login"
        return 1
    fi
    
    say "Creating GitHub issues from review findings..."
    
    # Parse critical findings
    local critical_findings=$(grep -E "^### 🔴" "$review_file" | sed 's/### 🔴 //')
    
    if [ -n "$critical_findings" ]; then
        echo "$critical_findings" | while IFS= read -r finding; do
            local repo=$(echo "$finding" | awk -F: '{print $1}')
            local issue=$(echo "$finding" | awk -F: '{print $2}')
            
            say "Creating issue for: $issue"
            
            gh issue create \
                --title "🔴 Critical: $issue" \
                --body "Found during automated multi-repo review.\n\nRepository: $repo\n\nDetails: $finding\n\n---\n*Generated by SoftSensorAI Multi-Repo Review*" \
                --label "bug,critical,automated-review" \
                2>/dev/null || warn "Failed to create issue"
        done
    fi
    
    success "Issues created!"
}

# Main execution
main() {
    local action="${1:-review}"
    shift || true
    
    case "$action" in
        review)
            if ! check_project_context; then
                err "Not in a multi-repo project directory"
                echo "Run this from a directory containing multiple repositories"
                exit 1
            fi
            review_all_repos "$@"
            ;;
            
        create-issues)
            create_github_issues "$@"
            ;;
            
        help|--help|-h)
            echo "Multi-Repository Review Tool"
            echo ""
            echo "Usage:"
            echo "  $0 review [type]        # Review all repos"
            echo "  $0 create-issues [file] # Create GitHub issues from review"
            echo ""
            echo "Review types:"
            echo "  comprehensive  - Full review (default)"
            echo "  security      - Security focused"
            echo "  performance   - Performance focused"
            echo "  architecture  - Architecture analysis"
            echo ""
            echo "Examples:"
            echo "  $0 review security"
            echo "  $0 create-issues review_results_20240101_120000.md"
            ;;
            
        *)
            err "Unknown action: $action"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
}

main "$@"