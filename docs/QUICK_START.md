# ⚡ Quick Start Guide

Get up and running in 5 minutes with these quick setup paths.

## 🎯 Choose Your Path

### Path 1: "I have an existing project" (Most Common)
```bash
# 1. Clone setup scripts
git clone https://github.com/yourusername/setup-scripts.git ~/setup-scripts
cd ~/setup-scripts

# 2. Go to your project
cd /path/to/your/existing/project

# 3. Add AI configurations
~/setup-scripts/setup/existing_repo_setup.sh

# Done! Your project now has AI superpowers
```

### Path 2: "I want to clone a new project"
```bash
# 1. Clone setup scripts
git clone https://github.com/yourusername/setup-scripts.git ~/setup-scripts
cd ~/setup-scripts

# 2. Run interactive wizard
./setup.sh

# 3. Choose "Clone NEW repository"
# 4. Enter GitHub URL when prompted
# 5. Select organization and category

# Done! Project cloned and configured
```

### Path 3: "I'm a data scientist"
```bash
# 1. Get setup scripts
git clone https://github.com/yourusername/setup-scripts.git ~/setup-scripts

# 2. Go to your ML project
cd ~/my-ml-project

# 3. Apply data science persona
~/setup-scripts/scripts/apply_persona.sh data-scientist

# You now have:
# - GPU optimization commands
# - Process impact analyzer
# - Parallel computing explanations
```

### Path 4: "I'm a software architect"
```bash
# 1. Get setup scripts
git clone https://github.com/yourusername/setup-scripts.git ~/setup-scripts

# 2. Go to your project
cd ~/my-app

# 3. Apply architect persona
~/setup-scripts/scripts/apply_persona.sh software-architect

# You now have:
# - Architecture review tools
# - Performance audit commands
# - Scalability analyzers
```

## 📊 Interactive Mode (Recommended for First Time)

```bash
# Just run this and follow the prompts:
~/setup-scripts/setup.sh
```

You'll see this menu:
```
╔══════════════════════════════════════════════════════════════╗
║          🚀 AI-Powered Development Setup 🚀               ║
╚══════════════════════════════════════════════════════════════╝

What would you like to do?

1) Setup EXISTING project 📁
2) Clone NEW repository 🔄
3) Configure AI Profile 🎯
4) Quick Setup Guide 📖
5) Exit 👋

Enter choice (1-5): _
```

## 🏃 Speed Run Commands

### Fastest Setup for Existing Project
```bash
# One-liner for existing project
cd /your/project && curl -sSL https://raw.githubusercontent.com/yourusername/setup-scripts/main/setup/existing_repo_setup.sh | bash
```

### Quick Profile Changes
```bash
# Change to expert level
~/setup-scripts/scripts/apply_profile.sh --skill expert --phase scale

# Switch to data scientist
~/setup-scripts/scripts/apply_persona.sh data-scientist

# Back to developer
~/setup-scripts/scripts/apply_persona.sh developer
```

### Common Persona Commands

#### For Data Scientists
```bash
# In your AI assistant, type:
/gpu-optimize          # Optimize for GPU execution
/parallel-explain      # Explain parallelization
/process-impact        # Analyze process termination impact
```

#### For Architects
```bash
# In your AI assistant, type:
/architecture-review   # Review system architecture
/performance-audit     # Find bottlenecks
/scale-analysis       # Scalability assessment
```

#### For Developers
```bash
# In your AI assistant, type:
/fix-ci-failures      # Debug CI issues
/test-driven         # TDD workflow
/refactor-safely     # Safe refactoring
```

## 🔍 What Gets Installed Where

### In Your Project
```
your-project/
├── CLAUDE.md            # AI instructions (customize this!)
├── .claude/
│   ├── settings.json   # Permissions
│   ├── persona.json    # Your role config
│   └── commands/       # AI commands
└── scripts/            # Helper scripts
```

### Globally (One Time)
```
~/setup-scripts/         # The tool itself
├── profiles/           # All personas
├── scripts/           # All scripts
└── templates/         # Reusable configs
```

## ✅ Verification Checklist

After setup, verify everything works:

```bash
# 1. Check AI configuration exists
ls -la CLAUDE.md .claude/

# 2. View your current profile
cat .claude/persona.json | grep persona

# 3. Test a command in your AI assistant
# Type: /help

# 4. For data scientists - check GPU tools
which nvidia-smi
scripts/gpu_monitor.sh  # If installed

# 5. View available commands
ls .claude/commands/
```

## 🚨 Troubleshooting Quick Fixes

### "Command not found"
```bash
# Make scripts executable
chmod +x ~/setup-scripts/setup.sh
chmod +x ~/setup-scripts/scripts/*.sh
chmod +x ~/setup-scripts/setup/*.sh
```

### "No such file or directory"
```bash
# Pull latest version
cd ~/setup-scripts
git pull origin main
```

### "Permission denied"
```bash
# Run with proper permissions
sudo chown -R $USER:$USER ~/setup-scripts
```

### AI Commands Not Working
```bash
# Reapply configuration
cd /your/project
~/setup-scripts/scripts/apply_profile.sh --skill beginner --phase mvp
```

## 📚 Next Steps

1. **Customize CLAUDE.md** - Add project-specific instructions
2. **Try AI Commands** - Type `/` in your AI assistant
3. **Adjust Skill Level** - Change as you learn
4. **Switch Personas** - Based on current task

## 🎯 Pro Tips

1. **Use Interactive Mode First** - It guides you through everything
2. **Start as Beginner** - You can always level up
3. **Data Scientists** - Always run gpu_monitor.sh during training
4. **Architects** - Use /architecture-review weekly
5. **Check Impact** - Before killing any process, run analyze_process_impact.sh

## 📞 Get Help

- **See all options**: `~/setup-scripts/setup.sh --help`
- **Check status**: `~/setup-scripts/scripts/profile_show.sh`
- **View commands**: `ls ~/.claude/commands/`
- **Report issues**: GitHub Issues page

---

**Ready?** Start with: `~/setup-scripts/setup.sh` 🚀
