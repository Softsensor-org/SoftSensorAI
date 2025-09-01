#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Path Update Transformation - Updates old paths to new structure
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/scripts/logger.sh"

# Path mappings
declare -A PATH_MAPPINGS=(
    ["setup/agents_global.sh"]="pilot/agents/setup.sh"
    ["setup/agents_repo.sh"]="pilot/agents/repo.sh"
    ["setup/folders.sh"]="core/folders.sh"
    ["setup/repo_wizard.sh"]="projects/wizard.sh"
    ["setup/claude_permissions.sh"]="skills/permissions.sh"
    ["install/key_software_wsl.sh"]="onboard/platforms/wsl.sh"
    ["install/key_software_linux.sh"]="onboard/platforms/linux.sh"
    ["install/key_software_macos.sh"]="onboard/platforms/macos.sh"
    ["install/ai_clis.sh"]="onboard/tools/ai-clis.sh"
    ["validation/validate_agents.sh"]="insights/audit.sh"
    ["scripts/doctor.sh"]="insights/doctor.sh"
)

# Update paths in a file
update_file_paths() {
    local file="$1"
    local changes_made=false
    
    log_info "Updating paths in: $file"
    
    # Create temp file
    local temp_file="/tmp/$(basename "$file").tmp"
    cp "$file" "$temp_file"
    
    # Update each path mapping
    for old_path in "${!PATH_MAPPINGS[@]}"; do
        local new_path="${PATH_MAPPINGS[$old_path]}"
        
        # Check if old path exists in file
        if grep -q "$old_path" "$temp_file"; then
            # Update path references
            sed -i "s|$old_path|$new_path|g" "$temp_file"
            changes_made=true
            log_success "  Updated: $old_path → $new_path"
        fi
    done
    
    # Also update SCRIPT_DIR references
    if grep -q 'SCRIPT_DIR/setup/' "$temp_file"; then
        sed -i 's|SCRIPT_DIR/setup/|DEVPILOT_ROOT/pilot/|g' "$temp_file"
        changes_made=true
        log_success "  Updated SCRIPT_DIR references"
    fi
    
    if grep -q 'SCRIPT_DIR/install/' "$temp_file"; then
        sed -i 's|SCRIPT_DIR/install/|DEVPILOT_ROOT/onboard/|g' "$temp_file"
        changes_made=true
        log_success "  Updated install path references"
    fi
    
    # Apply changes if any were made
    if $changes_made; then
        mv "$temp_file" "$file"
        log_success "Path updates applied to: $file"
    else
        rm "$temp_file"
        log_info "No path updates needed for: $file"
    fi
}

# Main execution
main() {
    local target_file="${1:-}"
    
    if [[ -z "$target_file" ]]; then
        log_error "Usage: $0 <file>"
        exit 1
    fi
    
    if [[ ! -f "$target_file" ]]; then
        log_error "File not found: $target_file"
        exit 1
    fi
    
    update_file_paths "$target_file"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi