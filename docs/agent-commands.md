# 🤖 AI Agent Commands Registry

Auto-generated index of all available AI assistant commands.

> **Note:** This file is auto-generated. Do not edit manually. Run
> `scripts/generate_command_registry.sh` to update.

## Command Categories

- [🧠 Thinking & Analysis](#-thinking--analysis)
- [🔒 Security](#-security)
- [📋 Ticket Management](#-ticket-management)
- [🔍 Code Auditing](#-code-auditing)
- [🔄 Processing & Workflows](#-processing--workflows)

---

## 🧠 Thinking & Analysis

| Command           | Description                    |
| ----------------- | ------------------------------ |
| `/cot-lite`       | Chain of Thought - Lite        |
| `/cot-structured` | Chain of Thought - Structured  |
| `/think-deep`     | Extended Thinking (controlled) |
| `/think-hard`     | Think Hard                     |

## 🔒 Security

| Command            | Description     |
| ------------------ | --------------- |
| `/secure-fix`      | Goal            |
| `/security-review` | Security Review |

## 📋 Ticket Management

| Command                 | Description                            |
| ----------------------- | -------------------------------------- |
| `/ticket-quality-gates` | Ticket Quality Gates Checklist         |
| `/tickets-from-code`    | Command: tickets-from-code (CLI‑first) |
| `/tickets-from-diff`    | Command: tickets-from-diff (CLI‑first) |
| `/tickets-quick-scan`   | Quick Scan → Tickets (20 minutes)      |

## 🔍 Code Auditing

| Command        | Description                               |
| -------------- | ----------------------------------------- |
| `/audit-full`  | Full Repo Audit (chain-ready, structured) |
| `/audit-quick` | Quick Scan (20 minutes, surgical)         |

## 🔄 Processing & Workflows

| Command                | Description              |
| ---------------------- | ------------------------ |
| `/chain-step-skeleton` | Step <N> of <M> — <TASK> |
| `/parallel-map`        | Parallel Map → Reduce    |

---

## Command Details

### Using Commands

Commands are invoked by typing the slash command in your AI assistant:

```
/command-name
```

Some commands accept parameters or context:

```
/tickets-from-diff HEAD~3
/security-review path/to/file.py
```

### Command Files

Each command is defined in a markdown file under `.claude/commands/`. The file structure:

1. **Description** - First line describes the command
2. **Instructions** - Detailed steps for the AI to follow
3. **Examples** - Usage examples (optional)
4. **Parameters** - Accepted parameters (optional)

### Adding New Commands

1. Create a new `.md` file in `.claude/commands/`
2. Follow the existing command structure
3. Run `scripts/generate_command_registry.sh` to update this registry

### Command Naming Convention

- Use kebab-case: `think-hard`, `security-review`
- Be descriptive but concise
- Group related commands with common prefixes:
  - `tickets-*` for ticket operations
  - `audit-*` for code auditing
  - `think-*` for analysis modes

---

_Generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC")_
