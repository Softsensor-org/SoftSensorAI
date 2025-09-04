# Persona Selection Tutorial

A step-by-step guide to selecting and combining AI personas for optimal development assistance.

## Table of Contents

- [Overview](#overview)
- [Understanding Personas](#understanding-personas)
- [Interactive Selection](#interactive-selection)
- [Command-Line Usage](#command-line-usage)
- [Combining Personas](#combining-personas)
- [Use Cases](#use-cases)
- [Best Practices](#best-practices)

## Overview

SoftSensorAI's persona system allows you to customize AI assistance based on your project needs.
Each persona provides specialized knowledge, tools, and permissions tailored to specific development
domains.

## Understanding Personas

### Available Personas

| Persona                | Focus Area           | Key Features                                                |
| ---------------------- | -------------------- | ----------------------------------------------------------- |
| **Data Scientist**     | ML/AI Development    | GPU optimization, ML frameworks, data analysis tools        |
| **Software Architect** | System Design        | Architecture patterns, scalability analysis, design reviews |
| **Backend Developer**  | Server-Side          | API design, database optimization, microservices            |
| **Frontend Developer** | UI/UX                | React/Vue expertise, responsive design, performance         |
| **DevOps Engineer**    | Infrastructure       | CI/CD, Kubernetes, monitoring, deployment                   |
| **Security Engineer**  | Application Security | Vulnerability scanning, secure coding, threat modeling      |

### Persona Components

Each persona includes:

- **Permissions**: File access patterns and allowed operations
- **Commands**: Specialized AI commands for the domain
- **Tools**: Domain-specific development tools
- **Knowledge**: Focused expertise and best practices

## Interactive Selection

### Initial Setup

When setting up a new project, use the interactive profile selector:

```bash
cd your-project
~/devpilot/scripts/apply_profile.sh
```

You'll see an interactive menu:

```
========================================
        DEVPILOT PROFILE SELECTOR
========================================

Select Organization Type:
1) Work (Professional)
2) Personal (Side Projects)
3) Learning (Tutorials)
4) Open Source (Contributions)

Your choice [1-4]: 1

Select Category:
1) Backend (APIs, services)
2) Frontend (UI, web apps)
3) Mobile (iOS, Android)
4) ML/AI (Machine Learning)
5) Data (Analytics, ETL)
6) Infrastructure (DevOps)

Your choice [1-6]: 4
```

### Adding Personas

After initial setup, add specialized personas:

```bash
# Interactive persona selection
~/devpilot/scripts/persona_manager.sh

# You'll see:
========================================
        PERSONA MANAGER
========================================

1) Add persona
2) Remove persona
3) Show active personas
4) Switch to single persona
5) Exit

Your choice: 1

Available personas:
1) data-scientist
2) software-architect
3) backend-developer
4) frontend-developer
5) devops-engineer
6) security-engineer

Select persona to add: 1
✅ Added data-scientist persona
```

## Command-Line Usage

### Direct Commands

Skip the interactive menu with direct commands:

```bash
# Add a persona
~/devpilot/scripts/persona_manager.sh add data-scientist

# Remove a persona
~/devpilot/scripts/persona_manager.sh remove frontend-developer

# Show active personas
~/devpilot/scripts/persona_manager.sh show

# Switch to single persona (removes others)
~/devpilot/scripts/persona_manager.sh switch software-architect
```

### Batch Operations

Add multiple personas at once:

```bash
# Add multiple personas for full-stack ML project
for persona in data-scientist backend-developer devops-engineer; do
  ~/devpilot/scripts/persona_manager.sh add $persona
done
```

## Combining Personas

### Multi-Persona Benefits

Combining personas gives you:

- **Merged permissions**: Access patterns from all personas
- **Combined commands**: Full command set across domains
- **Broader expertise**: AI assistance across multiple areas

### Common Combinations

#### Full-Stack ML Application

```bash
~/devpilot/scripts/persona_manager.sh add data-scientist
~/devpilot/scripts/persona_manager.sh add backend-developer
~/devpilot/scripts/persona_manager.sh add devops-engineer
```

Benefits:

- ML model development and optimization
- API design for model serving
- Deployment and scaling strategies

#### Secure Web Application

```bash
~/devpilot/scripts/persona_manager.sh add backend-developer
~/devpilot/scripts/persona_manager.sh add frontend-developer
~/devpilot/scripts/persona_manager.sh add security-engineer
```

Benefits:

- Full-stack development support
- Security best practices throughout
- Vulnerability prevention

#### Scalable Microservices

```bash
~/devpilot/scripts/persona_manager.sh add software-architect
~/devpilot/scripts/persona_manager.sh add backend-developer
~/devpilot/scripts/persona_manager.sh add devops-engineer
```

Benefits:

- System design and architecture
- Service implementation
- Container orchestration

## Use Cases

### Data Science Project

```bash
# 1. Initial setup
cd ~/projects/ml-project
~/devpilot/scripts/apply_profile.sh --skill l2 --phase mvp

# 2. Add data science persona
~/devpilot/scripts/persona_manager.sh add data-scientist

# 3. Install AI frameworks
~/devpilot/scripts/setup_ai_frameworks.sh

# 4. Use specialized commands
claude /gpu-optimize "optimize this PyTorch training loop"
claude /explain-parallelization "how would this scale to multiple GPUs"
```

### Microservices Architecture

```bash
# 1. Initial setup
cd ~/projects/microservices
~/devpilot/scripts/apply_profile.sh --skill expert --phase production

# 2. Add relevant personas
~/devpilot/scripts/persona_manager.sh add software-architect
~/devpilot/scripts/persona_manager.sh add backend-developer
~/devpilot/scripts/persona_manager.sh add devops-engineer

# 3. Use architecture commands
claude /design-review "review this service mesh configuration"
claude /scale-analysis "analyze bottlenecks in this architecture"
```

### Security Audit

```bash
# 1. Add security persona to existing project
cd ~/projects/web-app
~/devpilot/scripts/persona_manager.sh add security-engineer

# 2. Run security commands
claude /security-review "audit this authentication flow"
claude /threat-model "identify attack vectors"
codex /generate-security-tests "create security test suite"
```

## Best Practices

### 1. Start Simple

Begin with one or two personas, add more as needed:

```bash
# Start with core persona
~/devpilot/scripts/persona_manager.sh add backend-developer

# Add specialized support later
~/devpilot/scripts/persona_manager.sh add data-scientist  # When adding ML features
```

### 2. Match Project Phase

Adjust personas as your project evolves:

```bash
# MVP phase: Focus on development
~/devpilot/scripts/persona_manager.sh switch backend-developer

# Beta phase: Add operations
~/devpilot/scripts/persona_manager.sh add devops-engineer

# Production: Add security
~/devpilot/scripts/persona_manager.sh add security-engineer
```

### 3. Regular Review

Periodically review active personas:

```bash
# Check current setup
~/devpilot/scripts/persona_manager.sh show

# Remove unused personas
~/devpilot/scripts/persona_manager.sh remove frontend-developer
```

### 4. Project Templates

Create templates for common project types:

```bash
# Save current persona setup
cp -r .claude/personas ~/templates/ml-project-personas

# Apply template to new project
cp -r ~/templates/ml-project-personas .claude/personas
```

### 5. Team Alignment

Ensure team members use consistent personas:

```bash
# Document in README
echo "## Required Personas
- data-scientist
- backend-developer
- devops-engineer

Run: ~/devpilot/scripts/persona_manager.sh add [persona]" >> README.md
```

## Troubleshooting

### Personas Not Loading

```bash
# Verify personas directory exists
ls -la .claude/personas/

# Recreate if missing
mkdir -p .claude/personas
~/devpilot/scripts/persona_manager.sh add data-scientist
```

### Command Conflicts

If commands conflict between personas:

```bash
# Check which personas are active
~/devpilot/scripts/persona_manager.sh show

# Remove conflicting persona
~/devpilot/scripts/persona_manager.sh remove [persona-name]
```

### Performance Issues

Too many personas can slow down AI responses:

```bash
# Limit to 3-4 active personas
~/devpilot/scripts/persona_manager.sh show | wc -l

# Switch to essential personas only
~/devpilot/scripts/persona_manager.sh switch software-architect
~/devpilot/scripts/persona_manager.sh add backend-developer
```

## Examples

### Example 1: New ML Project

```bash
# Create project
mkdir ~/projects/sentiment-analysis
cd ~/projects/sentiment-analysis

# Initialize with repo wizard
~/devpilot/setup/repo_wizard.sh

# Set profile for ML
~/devpilot/scripts/apply_profile.sh --skill l2 --phase mvp

# Add ML personas
~/devpilot/scripts/persona_manager.sh add data-scientist
~/devpilot/scripts/persona_manager.sh add backend-developer

# Install frameworks
~/devpilot/scripts/setup_ai_frameworks.sh

# Start development
claude "create a sentiment analysis pipeline with transformers"
```

### Example 2: Existing Project Enhancement

```bash
# Navigate to existing project
cd ~/projects/existing-api

# Add specialized support
~/devpilot/scripts/persona_manager.sh add software-architect

# Get architecture advice
claude /design-review "suggest improvements for this REST API structure"
claude /scale-analysis "how to handle 10x traffic increase"
```

### Example 3: Full-Stack Application

```bash
# Setup for full-stack
cd ~/projects/dashboard

# Add all relevant personas
for persona in frontend-developer backend-developer devops-engineer security-engineer; do
  ~/devpilot/scripts/persona_manager.sh add $persona
done

# Verify setup
~/devpilot/scripts/persona_manager.sh show

# Use combined expertise
claude "setup React frontend with Express backend and JWT auth"
codex "generate Docker compose for development"
```

## Next Steps

1. **Explore Commands**: Check `.claude/commands/` after adding personas
2. **Read Persona Guides**: See [PERSONAS_GUIDE.md](PERSONAS_GUIDE.md) for details
3. **Try Combinations**: Experiment with [MULTI_PERSONA_GUIDE.md](MULTI_PERSONA_GUIDE.md)
4. **Customize**: Create your own personas in `.claude/personas/custom/`

---

_Personas make AI assistance more focused and effective. Choose wisely based on your project needs._
