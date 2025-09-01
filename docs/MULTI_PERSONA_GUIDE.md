# 🎭 Multi-Persona Configuration Guide

## Overview

The multi-persona system allows you to combine multiple roles within a single repository. This is perfect for:
- **Data Scientists** who also do backend development
- **Full-stack developers** working on both frontend and backend
- **Architects** who also write code and manage infrastructure
- **ML Engineers** combining data science, backend, and DevOps

## Key Features

### ✅ Repository-Specific Configuration
- Personas are stored in **your project's** `.claude/personas/` directory
- Each repository can have its own unique combination
- No global configuration conflicts

### ✅ Multiple Active Personas
- Combine 2, 3, or more personas simultaneously
- Permissions and commands are merged intelligently
- Switch between preset combinations quickly

### ✅ Quick Switching
- Predefined combinations for common role pairs
- One-command switching between modes
- Save custom combinations for reuse

## Usage

### Interactive Mode

```bash
# Launch the persona manager
./scripts/persona_manager.sh

# You'll see a menu like:
╔══════════════════════════════════════════════════════════════╗
║              🎭 Persona Manager 🎭                          ║
╚══════════════════════════════════════════════════════════════╝

Currently Active Personas:
  • data-scientist ✓
  • backend-developer ✓

Options:
1) Quick switch (preset combinations)
2) Add persona
3) Remove persona
4) Custom combination
5) View available personas
6) Show current configuration
7) Exit
```

### Command Line Usage

```bash
# Add multiple personas
./scripts/persona_manager.sh add data-scientist backend-developer

# Remove a persona
./scripts/persona_manager.sh remove frontend-developer

# Show active personas
./scripts/persona_manager.sh show

# Quick switch to preset combination
./scripts/persona_manager.sh switch

# Clear all personas
./scripts/persona_manager.sh clear
```

## Preset Combinations

### 1. Data Science Mode
**Personas**: Data Scientist + Backend Developer
```bash
./scripts/persona_manager.sh switch
# Select option 1
```
**Use when**: Building ML models and APIs, data pipelines with web services

### 2. Full Stack Mode
**Personas**: Frontend Developer + Backend Developer
```bash
./scripts/persona_manager.sh switch
# Select option 2
```
**Use when**: Building complete web applications, REST APIs with UI

### 3. Platform Mode
**Personas**: Backend Developer + DevOps Engineer + Security Specialist
```bash
./scripts/persona_manager.sh switch
# Select option 3
```
**Use when**: Building secure, scalable platform services

### 4. Architecture Mode
**Personas**: Software Architect + Backend Developer + DevOps Engineer
```bash
./scripts/persona_manager.sh switch
# Select option 4
```
**Use when**: Designing systems while implementing core components

### 5. ML Engineering Mode
**Personas**: Data Scientist + Backend Developer + DevOps Engineer
```bash
./scripts/persona_manager.sh switch
# Select option 5
```
**Use when**: Building production ML systems with proper deployment

## Custom Combinations

### Creating Your Own Mix

```bash
# Interactive selection
./scripts/persona_manager.sh
# Choose option 4 (Custom combination)
# Select personas by number: "1 3 5" for DS + Backend + DevOps
```

### Example: Research & Development Role

Combine Data Scientist + Software Architect for research projects:

```bash
./scripts/persona_manager.sh add data-scientist software-architect
```

This gives you:
- GPU optimization insights (from DS)
- System design capabilities (from Architect)
- Combined command sets from both

## How Personas Combine

### Permission Merging
When multiple personas are active, their permissions are **combined**:

```json
// Data Scientist permissions
{
  "allow": ["Bash(python:*)", "Bash(jupyter:*)", "Bash(nvidia-smi:*)"]
}

// Backend Developer permissions
{
  "allow": ["Bash(npm test:*)", "Bash(curl:*)", "Bash(docker:*)"]
}

// Combined result
{
  "allow": [
    "Bash(python:*)",
    "Bash(jupyter:*)",
    "Bash(nvidia-smi:*)",
    "Bash(npm test:*)",
    "Bash(curl:*)",
    "Bash(docker:*)"
  ]
}
```

### Command Set Merging
Commands from all active personas are available:

```
Active: data-scientist + backend-developer

Available commands:
  From data-scientist:
    - /gpu-optimize
    - /parallel-explain
    - /process-impact

  From backend-developer:
    - /api-design
    - /database-optimize
    - /test-coverage
```

### Focus Area Combination
The AI assistant understands all active focus areas:

```
Combined Focus:
  • GPU optimization (DS)
  • Machine learning (DS)
  • API development (Backend)
  • Database optimization (Backend)
  • Testing strategies (Backend)
```

## Repository Structure

After configuring multiple personas:

```
your-project/
├── .claude/
│   ├── personas/
│   │   ├── active.json           # List of active personas
│   │   ├── data-scientist.json   # DS persona config
│   │   ├── backend-developer.json # Backend config
│   │   └── combined_persona.json  # Merged configuration
│   ├── commands/
│   │   ├── personas/
│   │   │   ├── data-scientist/   # DS-specific commands
│   │   │   └── backend-developer/ # Backend commands
│   │   └── active/                # Currently active commands
│   └── settings.json              # Updated with combined permissions
└── CLAUDE.md                      # AI instructions (auto-updated)
```

## Switching Contexts

### Scenario: Morning Data Science, Afternoon Backend

```bash
# Morning: Focus on model training
./scripts/persona_manager.sh clear
./scripts/persona_manager.sh add data-scientist

# Work with GPU optimization, process monitoring...

# Afternoon: Switch to API development
./scripts/persona_manager.sh clear
./scripts/persona_manager.sh add backend-developer

# Work with REST APIs, database queries...

# Or keep both active all day:
./scripts/persona_manager.sh add data-scientist backend-developer
```

### Scenario: Code Review Requiring Multiple Perspectives

```bash
# Add all relevant personas for comprehensive review
./scripts/persona_manager.sh add software-architect backend-developer security-specialist

# Now your AI can:
# - Review architecture patterns (Architect)
# - Check code quality (Backend)
# - Identify security issues (Security)
```

## Best Practices

### 1. Start Simple
Begin with one or two personas, add more as needed:
```bash
# Start with core role
./scripts/persona_manager.sh add backend-developer

# Add specializations as needed
./scripts/persona_manager.sh add data-scientist  # When working on ML
```

### 2. Use Presets for Common Tasks
The quick switch presets cover most common combinations:
```bash
./scripts/persona_manager.sh switch
# Choose from 5 optimized combinations
```

### 3. Project-Specific Configurations
Each repository maintains its own persona configuration:
```bash
# In ml-project/
./scripts/persona_manager.sh add data-scientist devops-engineer

# In web-app/
./scripts/persona_manager.sh add frontend-developer backend-developer

# Each project keeps its own settings
```

### 4. Regular Cleanup
Clear unused personas to keep configurations clean:
```bash
# Show what's active
./scripts/persona_manager.sh show

# Remove unused
./scripts/persona_manager.sh remove product-manager

# Or start fresh
./scripts/persona_manager.sh clear
```

## Troubleshooting

### Personas Not Applying
```bash
# Check active personas
cat .claude/personas/active.json

# Rebuild combined configuration
./scripts/persona_manager.sh show

# Force recombination
rm .claude/combined_persona.json
./scripts/persona_manager.sh add data-scientist  # Re-add any persona
```

### Commands Not Available
```bash
# Check command directories
ls -la .claude/commands/personas/
ls -la .claude/commands/active/

# Reinstall persona
./scripts/persona_manager.sh remove data-scientist
./scripts/persona_manager.sh add data-scientist
```

### Permission Conflicts
```bash
# View combined permissions
jq '.permissions' .claude/combined_persona.json

# Check main settings
jq '.permissions' .claude/settings.json

# Reset if needed
./scripts/persona_manager.sh clear
# Then re-add desired personas
```

## Advanced Usage

### Creating Custom Personas

Create your own persona configuration:

```bash
# Create new persona file
cat > .claude/personas/ml-engineer.json <<EOF
{
  "persona": "ml-engineer",
  "display_name": "ML Engineer",
  "focus": ["ML pipelines", "Model deployment", "A/B testing"],
  "permissions": {
    "allow": [
      "Bash(mlflow:*)",
      "Bash(dvc:*)",
      "Bash(wandb:*)"
    ]
  },
  "commands": ["ml-pipeline", "model-deploy", "ab-test"]
}
EOF

# Add to active personas
./scripts/persona_manager.sh add ml-engineer
```

### Persona Templates for Teams

Share persona combinations with your team:

```bash
# Export current configuration
cp .claude/personas/active.json team-personas.json

# Team member imports
cp team-personas.json .claude/personas/active.json
./scripts/persona_manager.sh show  # Verify import
```

## Summary

The multi-persona system provides:
- **Flexibility**: Combine any roles as needed
- **Repository-specific**: Each project has its own configuration
- **Quick switching**: Preset combinations for common scenarios
- **Intelligent merging**: Permissions and commands combine seamlessly
- **Easy management**: Simple commands to add/remove/switch

Perfect for modern development where roles overlap and responsibilities shift throughout the day!
