#!/usr/bin/env bash
# Multi-user DevPilot installation script (run as root)
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DEVPILOT_ROOT="/opt/devpilot"
SOFTSENSORAI_REPO="https://github.com/Softsensor-org/SoftSensorAI.git"
DEVPILOT_BRANCH="main"

# Helper functions
say() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*" >&2; }
die() { echo -e "${RED}✗${NC} $*" >&2; exit 1; }

# Check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."

    # Check if running as root
    [[ $EUID -eq 0 ]] || die "This script must be run as root (use sudo)"

    # Check required commands
    for cmd in git bash; do
        command -v "$cmd" >/dev/null 2>&1 || die "$cmd is required but not installed"
    done

    # Check bash version (need 4.0+)
    bash_version=$(bash --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    if [[ "${bash_version%%.*}" -lt 4 ]]; then
        die "Bash 4.0+ required (found $bash_version)"
    fi

    say "Prerequisites satisfied"
}

# Create directory structure
create_directories() {
    echo "Creating directory structure..."

    mkdir -p "$DEVPILOT_ROOT"/{bin,tools,templates,scripts,etc,src}

    say "Created directories under $DEVPILOT_ROOT"
}

# Clone or update repository
install_devpilot() {
    echo "Installing DevPilot..."

    if [[ -d "$DEVPILOT_ROOT/src/.git" ]]; then
        echo "Updating existing installation..."
        cd "$DEVPILOT_ROOT/src"
        git fetch origin
        git checkout "$DEVPILOT_BRANCH"
        git pull origin "$DEVPILOT_BRANCH"
    else
        echo "Cloning DevPilot repository..."
        git clone "$SOFTSENSORAI_REPO" "$DEVPILOT_ROOT/src"
        cd "$DEVPILOT_ROOT/src"
        git checkout "$DEVPILOT_BRANCH"
    fi

    # Copy components
    echo "Installing components..."
    cp -r "$DEVPILOT_ROOT/src/bin/"* "$DEVPILOT_ROOT/bin/" 2>/dev/null || true
    cp -r "$DEVPILOT_ROOT/src/tools/"* "$DEVPILOT_ROOT/tools/" 2>/dev/null || true
    cp -r "$DEVPILOT_ROOT/src/templates/"* "$DEVPILOT_ROOT/templates/" 2>/dev/null || true
    cp -r "$DEVPILOT_ROOT/src/scripts/"* "$DEVPILOT_ROOT/scripts/" 2>/dev/null || true

    # Set permissions
    chmod 755 "$DEVPILOT_ROOT"/bin/* 2>/dev/null || true
    chmod 755 "$DEVPILOT_ROOT"/tools/*.sh 2>/dev/null || true
    chmod 755 "$DEVPILOT_ROOT"/scripts/*.sh 2>/dev/null || true

    say "DevPilot components installed"
}

# Create configuration file
create_config() {
    echo "Creating configuration..."

    local config_file="$DEVPILOT_ROOT/etc/devpilot.conf"

    if [[ -f "$config_file" ]]; then
        warn "Configuration already exists at $config_file"
        echo "Backing up to ${config_file}.bak"
        cp "$config_file" "${config_file}.bak"
    fi

    # Get version from source
    local version="2.0.0"
    if [[ -f "$DEVPILOT_ROOT/src/VERSION" ]]; then
        version=$(cat "$DEVPILOT_ROOT/src/VERSION")
    fi

    cat > "$config_file" <<EOF
# DevPilot Multi-User Configuration
# Generated: $(date -Iseconds)
# Version: $version

# Core paths (required)
DEVPILOT_ROOT=$DEVPILOT_ROOT
DEVPILOT_USER_DIR=\$HOME/.devpilot
DEVPILOT_VERSION=$version

# Component paths (optional, defaults shown)
DEVPILOT_TEMPLATES=$DEVPILOT_ROOT/templates
DEVPILOT_TOOLS=$DEVPILOT_ROOT/tools
DEVPILOT_SCRIPTS=$DEVPILOT_ROOT/scripts

# Team defaults (optional, users can override)
# AI_PROVIDER=anthropic
# AI_MODEL=claude-3-7-sonnet-20250219
# BASE_BRANCH=main

# Audit logging (optional)
# DEVPILOT_AUDIT_LOG=/var/log/devpilot/audit.log
EOF

    chmod 644 "$config_file"
    say "Configuration created at $config_file"
}

# Set up system PATH
setup_path() {
    echo "Setting up system PATH..."

    local profile_file="/etc/profile.d/devpilot.sh"

    cat > "$profile_file" <<'EOF'
# DevPilot system-wide PATH
if [ -d "/opt/devpilot/bin" ]; then
    export PATH="/opt/devpilot/bin:$PATH"
fi
EOF

    chmod 644 "$profile_file"
    say "PATH configuration added to $profile_file"
}

# Create sample user setup script
create_user_setup() {
    echo "Creating user setup helper..."

    cat > "$DEVPILOT_ROOT/scripts/user_setup.sh" <<'EOF'
#!/usr/bin/env bash
# DevPilot user setup helper
set -euo pipefail

echo "Setting up DevPilot for user: $USER"

# Create user directories
mkdir -p ~/.devpilot/{artifacts,cache,logs,config}
mkdir -p ~/.devpilot/artifacts/{agent,review,build}

# Create user config if not exists
if [[ ! -f ~/.devpilot/config/user.conf ]]; then
    cat > ~/.devpilot/config/user.conf <<'CONFIG'
# DevPilot User Configuration
# Override team defaults here

# AI provider settings
# AI_PROVIDER=anthropic
# AI_MODEL=claude-3-7-sonnet-20250219

# Personal preferences
# EDITOR=vim
# PAGER=less
CONFIG
    echo "✓ Created user configuration at ~/.devpilot/config/user.conf"
fi

# Check for API keys
if [[ -z "${ANTHROPIC_API_KEY:-}" && -z "${OPENAI_API_KEY:-}" && -z "${GOOGLE_API_KEY:-}" && -z "${GROK_API_KEY:-}" ]]; then
    echo ""
    echo "⚠ No AI provider API keys found in environment"
    echo "Please set one of the following:"
    echo "  export ANTHROPIC_API_KEY='sk-ant-...'"
    echo "  export OPENAI_API_KEY='sk-...'"
    echo "  export GOOGLE_API_KEY='...'"
    echo "  export GROK_API_KEY='...'"
    echo ""
    echo "Or use secure storage: /opt/devpilot/utils/secure_keys.sh store"
fi

echo ""
echo "✓ DevPilot user setup complete!"
echo ""
echo "Next steps:"
echo "1. Set your API keys (see above)"
echo "2. Navigate to a project directory"
echo "3. Run: dp init"
echo "4. Verify with: dp doctor"
EOF

    chmod 755 "$DEVPILOT_ROOT/scripts/user_setup.sh"
    say "User setup script created"
}

# Create team doctor command
create_team_doctor() {
    echo "Adding team doctor command..."

    # Check if dp already has team-doctor command
    if grep -q "cmd_team_doctor" "$DEVPILOT_ROOT/bin/dp" 2>/dev/null; then
        say "Team doctor command already exists"
        return
    fi

    # We'll add this to dp in the next step
    say "Team doctor command will be added to dp"
}

# Print summary
print_summary() {
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    say "DevPilot Multi-User Installation Complete!"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "Installation details:"
    echo "  Mode         : Multi-user"
    echo "  System root  : $DEVPILOT_ROOT"
    echo "  Config file  : $DEVPILOT_ROOT/etc/devpilot.conf"
    echo "  User data    : ~/.devpilot/ (per user)"
    echo ""
    echo "For users to get started:"
    echo "  1. Source the new PATH: source /etc/profile.d/devpilot.sh"
    echo "  2. Run user setup: $DEVPILOT_ROOT/scripts/user_setup.sh"
    echo "  3. Set API keys and run: dp init"
    echo ""
    echo "For administrators:"
    echo "  - Edit config: $DEVPILOT_ROOT/etc/devpilot.conf"
    echo "  - Update DevPilot: cd $DEVPILOT_ROOT/src && git pull"
    echo "  - Add templates: cp template.md $DEVPILOT_ROOT/templates/"
    echo ""
    echo "Documentation: $DEVPILOT_ROOT/src/docs/MULTI_USER.md"
}

# Main execution
main() {
    echo "════════════════════════════════════════════════════════════════"
    echo "DevPilot Multi-User Installer"
    echo "════════════════════════════════════════════════════════════════"
    echo ""

    check_prerequisites
    create_directories
    install_devpilot
    create_config
    setup_path
    create_user_setup
    create_team_doctor
    print_summary
}

# Run main function
main "$@"
