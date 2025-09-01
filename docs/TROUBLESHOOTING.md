# 🔧 Troubleshooting Guide

Complete solutions for common issues with DevPilot.

## Table of Contents
- [Installation Issues](#installation-issues)
- [Profile & Persona Problems](#profile--persona-problems)
- [Data Science Specific](#data-science-specific)
- [Existing Project Setup](#existing-project-setup)
- [AI Command Issues](#ai-command-issues)
- [Platform-Specific Issues](#platform-specific-issues)

---

## Installation Issues

### Issue: "bash: ./setup.sh: Permission denied"

**Solution**:
```bash
# Make all scripts executable
chmod +x setup.sh
chmod +x setup/*.sh
chmod +x scripts/*.sh

# Alternative: Run with bash directly
bash setup.sh
```

### Issue: "setup.sh: line X: syntax error"

**Cause**: Wrong shell or old bash version

**Solution**:
```bash
# Check bash version (need 4.0+)
bash --version

# If old, update bash
# Ubuntu/Debian:
sudo apt-get update && sudo apt-get install bash

# macOS:
brew install bash

# Run explicitly with bash
/usr/bin/env bash setup.sh
```

### Issue: Scripts not found after installation

**Solution**:
```bash
# Check installation location
ls -la ~/setup-scripts/

# If missing, clone again
git clone https://github.com/yourusername/setup-scripts.git ~/setup-scripts

# Add to PATH (optional)
echo 'export PATH="$HOME/setup-scripts/scripts:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Profile & Persona Problems

### Issue: "Profile not applying" or "Permissions not working"

**Diagnosis**:
```bash
# Check current directory
pwd  # Must be in project root

# Verify files exist
ls -la .claude/
ls -la CLAUDE.md

# Check current profile
cat .claude/settings.json | grep skill
cat .claude/persona.json | grep persona
```

**Solutions**:

1. **Reapply profile**:
```bash
cd /your/project
~/setup-scripts/scripts/apply_profile.sh --skill beginner --phase mvp
```

2. **Reset and reapply**:
```bash
# Remove existing configs
rm -rf .claude/ CLAUDE.md PROFILE.md

# Rerun setup
~/setup-scripts/setup/existing_repo_setup.sh
```

3. **Manual fix**:
```bash
# Copy templates manually
cp -r ~/setup-scripts/templates/.claude .
cp ~/setup-scripts/templates/CLAUDE.md .
```

### Issue: "Persona commands not available"

**Solution**:
```bash
# Check persona installation
ls .claude/commands/sets/

# For data scientist
~/setup-scripts/scripts/apply_persona.sh data-scientist

# For architect
~/setup-scripts/scripts/apply_persona.sh software-architect

# Verify commands installed
ls .claude/commands/sets/data-science/  # Should see gpu-optimize.md etc
```

### Issue: "Wrong skill level applied"

**Solution**:
```bash
# View current level
grep "Skill Level" PROFILE.md

# Change level
~/setup-scripts/scripts/profile_menu.sh
# OR
~/setup-scripts/scripts/apply_profile.sh --skill l2 --phase beta
```

---

## Data Science Specific

### Issue: "GPU monitoring not working"

**Diagnosis**:
```bash
# Check NVIDIA drivers
nvidia-smi

# If "command not found":
# You need NVIDIA drivers installed
```

**Solutions**:

1. **Install NVIDIA drivers** (Ubuntu):
```bash
# Check for GPU
lspci | grep -i nvidia

# Install drivers
sudo apt update
sudo apt install nvidia-driver-535  # or latest version

# Reboot
sudo reboot
```

2. **For WSL2**:
```bash
# Ensure WSL2 has GPU support
wsl --version  # Need WSL 2

# In Windows, install NVIDIA GPU driver for WSL
# Download from: https://developer.nvidia.com/cuda/wsl
```

3. **For cloud instances**:
```bash
# AWS/GCP/Azure typically pre-install drivers
# Just verify:
nvidia-smi
```

### Issue: "Process impact analyzer shows wrong information"

**Solution**:
```bash
# Update process analyzer
cd ~/setup-scripts
git pull origin main

# Reinstall scripts
cd /your/project
~/setup-scripts/scripts/apply_persona.sh data-scientist

# Test with a dummy process
python -c "import time; time.sleep(100)" &
PID=$!
scripts/analyze_process_impact.sh $PID
kill $PID
```

### Issue: "Mixed precision training not working"

**Diagnosis**:
```bash
# Check PyTorch CUDA support
python -c "import torch; print(torch.cuda.is_available())"
python -c "import torch; print(torch.cuda.get_device_capability())"
```

**Solution**:
```python
# Ensure compatible GPU (compute capability >= 7.0 for automatic mixed precision)
# For older GPUs, use manual mixed precision:

# Instead of automatic:
# with torch.cuda.amp.autocast():

# Use manual:
model = model.half()  # Convert to FP16
# ... training code ...
```

---

## Existing Project Setup

### Issue: "Setup detects wrong project type"

**Solution**:
```bash
# Manually specify during setup
~/setup-scripts/setup/existing_repo_setup.sh

# When it detects wrong type, choose "Continue anyway"
# Then manually configure
```

### Issue: "Setup overwrites my existing files"

**Prevention**:
```bash
# Backup first
cp CLAUDE.md CLAUDE.md.backup
cp -r .claude .claude.backup

# Run setup
~/setup-scripts/setup/existing_repo_setup.sh

# When prompted "Update/overwrite?", choose "No"
```

**Recovery**:
```bash
# Restore from backup
mv CLAUDE.md.backup CLAUDE.md
mv .claude.backup .claude
```

### Issue: "Can't find my repository in browser"

**Solution**:
```bash
# Directly specify path
~/setup-scripts/setup/existing_repo_setup.sh

# When prompted for path, enter full path:
/home/username/path/to/your/repo

# Or navigate there first
cd /your/repo
~/setup-scripts/setup/existing_repo_setup.sh
# Choose "Setup configurations here"
```

---

## AI Command Issues

### Issue: "Commands not working in Claude/Cursor"

**Diagnosis**:
```bash
# Check command files exist
ls .claude/commands/
ls .claude/commands/sets/

# Check permissions file
cat .claude/settings.json
```

**Solutions**:

1. **For Claude Desktop**:
```bash
# Ensure project is open in Claude
# Commands only work in project context
```

2. **For Cursor**:
```bash
# Install Cursor AI extension
# Open command palette (Cmd/Ctrl + Shift + P)
# Run: "Reload Window"
```

3. **Manual command usage**:
```bash
# Read command content
cat .claude/commands/gpu-optimize.md

# Copy content to AI chat manually
```

### Issue: "Permission denied when AI tries to run commands"

**Solution**:
```bash
# Check allowed commands
cat .claude/settings.json | grep -A 20 '"allow"'

# Add missing permissions
# Edit .claude/settings.json
# Add to "allow" array:
"Bash(python:*)",
"Bash(npm:*)",
"Read",
"Write"
```

---

## Platform-Specific Issues

### macOS Issues

#### Issue: "realpath: command not found"

**Solution**:
```bash
# Install coreutils
brew install coreutils

# Or add this to ~/.bashrc
realpath() {
  python3 -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$1"
}
```

#### Issue: "sed: illegal option"

**Solution**:
```bash
# macOS uses BSD sed, not GNU sed
# Install GNU sed
brew install gnu-sed

# Use gsed instead of sed
alias sed=gsed
```

### Windows (WSL2) Issues

#### Issue: "Line ending problems"

**Solution**:
```bash
# Configure git for Unix line endings
git config --global core.autocrlf false

# Convert existing files
dos2unix scripts/*.sh
# Or
sed -i 's/\r$//' scripts/*.sh
```

#### Issue: "Cannot execute binary file"

**Solution**:
```bash
# Ensure running in WSL2, not PowerShell
wsl

# Then run commands inside WSL
```

### Linux Issues

#### Issue: "sudo: command not found" (in containers)

**Solution**:
```bash
# In Docker/containers, run as root
docker exec -it --user root container_name bash

# Or install sudo
apt-get update && apt-get install sudo
```

---

## Advanced Debugging

### Enable Debug Mode

```bash
# Run any script with debug output
bash -x ~/setup-scripts/setup.sh

# Or enable in script
set -x  # Add to top of script
```

### Check All Configurations

```bash
# Complete diagnostic
cat <<'EOF' > diagnose.sh
#!/bin/bash
echo "=== Diagnostic Report ==="
echo "Current Directory: $(pwd)"
echo "User: $(whoami)"
echo "Shell: $SHELL"
echo "Bash Version: $BASH_VERSION"
echo ""
echo "=== Project Files ==="
ls -la CLAUDE.md .claude/ 2>/dev/null || echo "No AI configs found"
echo ""
echo "=== Persona ==="
cat .claude/persona.json 2>/dev/null | grep persona || echo "No persona set"
echo ""
echo "=== Commands Available ==="
ls .claude/commands/sets/ 2>/dev/null || echo "No command sets"
echo ""
echo "=== Git Status ==="
git status --short
echo ""
echo "=== Process Check ==="
ps aux | grep -E "python|node|java" | head -5
EOF

chmod +x diagnose.sh
./diagnose.sh > diagnostic.txt
cat diagnostic.txt
```

### Reset Everything

```bash
# Complete reset (saves backups)
cd /your/project

# Backup current configs
tar czf ai-config-backup.tar.gz .claude/ CLAUDE.md PROFILE.md 2>/dev/null

# Remove all configs
rm -rf .claude/ CLAUDE.md PROFILE.md system/

# Fresh setup
~/setup-scripts/setup/existing_repo_setup.sh
```

---

## Getting Help

### Collect Debug Information

When reporting issues, include:

```bash
# System info
uname -a
bash --version
git --version

# Project structure
ls -la

# Config files
head -20 CLAUDE.md
cat .claude/persona.json

# Error messages (full output)
bash -x problematic_script.sh 2>&1 | tee error.log
```

### Report Issues

1. Check existing issues: [GitHub Issues](https://github.com/yourusername/setup-scripts/issues)
2. Include debug information
3. Describe what you expected vs what happened
4. Include steps to reproduce

### Quick Fixes Checklist

- [ ] Scripts executable? (`chmod +x`)
- [ ] In correct directory? (`pwd`)
- [ ] Latest version? (`git pull`)
- [ ] Files exist? (`ls -la`)
- [ ] Correct persona? (`cat .claude/persona.json`)
- [ ] Permissions correct? (`cat .claude/settings.json`)

---

## FAQ

**Q: Can I use this without git?**
A: Yes, but you'll miss git hooks and some features. The core AI configurations still work.

**Q: Can I share configs between projects?**
A: Yes, copy `.claude/` directory and `CLAUDE.md` between projects.

**Q: How do I completely uninstall?**
A:
```bash
rm -rf ~/setup-scripts
rm -rf ~/.claude ~/.gemini
# Remove from projects:
rm -rf .claude/ CLAUDE.md PROFILE.md
```

**Q: Can I customize personas?**
A: Yes! See [PERSONAS_GUIDE.md](PERSONAS_GUIDE.md#customizing-personas)

**Q: Will this work with other AI assistants?**
A: Yes, the configurations work with Claude, Cursor, Copilot, and similar AI coding assistants.

---

**Still stuck?** Open an issue with your diagnostic output! 🚀
