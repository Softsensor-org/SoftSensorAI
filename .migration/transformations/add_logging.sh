#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Logging Transformation - Adds structured logging to scripts
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/scripts/logger.sh"

# Add logging to a script
add_logging_to_file() {
    local file="$1"
    local temp_file="/tmp/$(basename "$file").tmp"
    
    log_info "Adding logging to: $file"
    
    # Check if logging already exists
    if grep -q "source.*logger.sh" "$file"; then
        log_info "Logging already present in: $file"
        return 0
    fi
    
    # Create temp file with logging additions
    {
        # Add shebang and set options if missing
        if ! head -1 "$file" | grep -q "^#!/"; then
            echo "#!/usr/bin/env bash"
            echo "set -euo pipefail"
            echo ""
        fi
        
        # Insert logging source after shebang
        local in_header=true
        while IFS= read -r line; do
            echo "$line"
            
            # After the set statement, add logging
            if $in_header && [[ "$line" =~ ^set\ .*pipefail ]]; then
                echo ""
                echo "# Source logging utilities"
                echo 'SCRIPT_DIR="$(cd "$(dirname "\${BASH_SOURCE[0]}")" && pwd)"'
                echo 'DEVPILOT_ROOT="$(dirname "$SCRIPT_DIR")"'
                echo 'source "$DEVPILOT_ROOT/core/logger.sh"'
                echo ""
                in_header=false
            fi
        done < "$file"
    } > "$temp_file"
    
    # Replace echo statements with log functions
    sed -i 's/echo "ERROR:/log_error "/g' "$temp_file"
    sed -i 's/echo "Warning:/log_warn "/g' "$temp_file"
    sed -i 's/echo "Info:/log_info "/g' "$temp_file"
    sed -i 's/echo "Success:/log_success "/g' "$temp_file"
    sed -i 's/echo "==>/log_step "/g' "$temp_file"
    
    # Replace color code variables with log functions
    sed -i 's/echo -e "\${RED}/log_error "/g' "$temp_file"
    sed -i 's/echo -e "\${YELLOW}/log_warn "/g' "$temp_file"
    sed -i 's/echo -e "\${GREEN}/log_success "/g' "$temp_file"
    sed -i 's/echo -e "\${BLUE}/log_info "/g' "$temp_file"
    
    mv "$temp_file" "$file"
    chmod +x "$file"
    log_success "Logging added to: $file"
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
    
    add_logging_to_file "$target_file"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi