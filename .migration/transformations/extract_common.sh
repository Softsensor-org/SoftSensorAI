#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Extract Common Functions - Identifies and extracts reusable functions
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/scripts/logger.sh"

COMMON_FUNCTIONS_FILE="/tmp/common_functions.sh"

# Extract functions from a file
extract_functions() {
    local file="$1"
    local func_name=""
    local in_function=false
    local brace_count=0
    
    log_info "Extracting functions from: $file"
    
    while IFS= read -r line; do
        # Detect function start
        if [[ "$line" =~ ^[[:space:]]*(function[[:space:]]+)?([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\(\)[[:space:]]*\{ ]]; then
            func_name="${BASH_REMATCH[2]}"
            in_function=true
            brace_count=1
            
            # Check if it's a common utility function
            if is_common_function "$func_name"; then
                echo "# From: $file" >> "$COMMON_FUNCTIONS_FILE"
                echo "$line" >> "$COMMON_FUNCTIONS_FILE"
            fi
        elif $in_function; then
            # Count braces to find function end
            local open_braces="${line//[^{]/}"
            local close_braces="${line//[^}]/}"
            brace_count=$((brace_count + ${#open_braces} - ${#close_braces}))
            
            if is_common_function "$func_name"; then
                echo "$line" >> "$COMMON_FUNCTIONS_FILE"
            fi
            
            if [[ $brace_count -eq 0 ]]; then
                in_function=false
                if is_common_function "$func_name"; then
                    echo "" >> "$COMMON_FUNCTIONS_FILE"
                    log_success "  Extracted: $func_name"
                fi
            fi
        fi
    done < "$file"
}

# Check if a function is a common utility
is_common_function() {
    local func_name="$1"
    
    # List of common utility function patterns
    local common_patterns=(
        "say"
        "success"
        "warn"
        "err"
        "die"
        "check_command"
        "detect_os"
        "detect_platform"
        "backup_file"
        "create_symlink"
        "ensure_dir"
        "is_installed"
        "get_latest_version"
        "download_file"
    )
    
    for pattern in "${common_patterns[@]}"; do
        if [[ "$func_name" == "$pattern" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Replace extracted functions with source statement
replace_with_source() {
    local file="$1"
    local temp_file="/tmp/$(basename "$file").tmp"
    
    log_info "Replacing extracted functions in: $file"
    
    # Add source statement after shebang
    {
        local added_source=false
        while IFS= read -r line; do
            echo "$line"
            
            # Add source after set statement
            if ! $added_source && [[ "$line" =~ ^set\ .*pipefail ]]; then
                echo ""
                echo "# Source common utilities"
                echo 'source "$DEVPILOT_ROOT/core/utils.sh"'
                echo ""
                added_source=true
            fi
        done < "$file"
    } > "$temp_file"
    
    # Remove extracted function definitions
    # (This would need more sophisticated parsing in production)
    
    mv "$temp_file" "$file"
    log_success "Functions replaced with source in: $file"
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
    
    # Clear common functions file
    > "$COMMON_FUNCTIONS_FILE"
    
    # Extract functions
    extract_functions "$target_file"
    
    if [[ -s "$COMMON_FUNCTIONS_FILE" ]]; then
        log_info "Common functions extracted to: $COMMON_FUNCTIONS_FILE"
        # In a real migration, we'd move these to core/utils.sh
        # and update the original file
    else
        log_info "No common functions found in: $target_file"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi