# Codex Configuration

This repository is configured for OpenAI Codex with persona-specific capabilities.

## Active Personas
<!-- This section is auto-updated by persona_manager.sh -->

## Core Instructions

You are Codex, an AI coding assistant optimized for this repository. Follow these guidelines:

### Code Generation
- Generate code that matches the existing style and patterns in this repository
- Use the same libraries and frameworks already present
- Follow the established directory structure
- Maintain consistent naming conventions

### Safety & Execution
- All code execution happens in sandboxed environments
- Never execute destructive commands without explicit confirmation
- Validate inputs before processing
- Use the sandbox for testing generated code

### Persona-Specific Capabilities
<!-- Auto-populated based on active personas -->

## Repository Context

### Tech Stack
<!-- Auto-detected and populated -->

### Conventions
- Follow existing code style
- Use established patterns
- Maintain test coverage
- Document complex logic

## Available Commands

### General Commands
- `/codex-generate` - Generate code with explanations
- `/codex-refactor` - Refactor with safety checks
- `/codex-test` - Generate comprehensive tests
- `/codex-review` - Code review with suggestions
- `/codex-optimize` - Performance optimization
- `/codex-debug` - Debug with step-by-step analysis

### Persona-Specific Commands
<!-- Commands are loaded based on active personas -->

## Execution Modes

### Safe Mode (Default)
- Read-only analysis
- Suggestions without execution
- Dry-run for destructive operations

### Sandbox Mode
- Execute in isolated container
- No access to production data
- Automatic rollback on errors

### Production Mode
- Requires explicit approval
- Full audit logging
- Backup before changes

## Integration Points

### With Claude
- Share context and patterns
- Consistent command structure
- Unified persona system

### With GitHub Copilot
- Complementary suggestions
- Shared code style rules
- Integrated testing approach

### With Cursor
- Same command interface
- Shared configuration
- Consistent behavior

## Security Guidelines

1. **Never expose secrets** - Mask all sensitive data
2. **Validate inputs** - Sanitize user inputs before use
3. **Audit changes** - Log all modifications
4. **Sandbox first** - Test in isolation before production
5. **Confirm destructive ops** - Always ask before delete/modify

## Performance Optimization

When optimizing code:
1. Profile first to identify bottlenecks
2. Explain the optimization strategy
3. Provide before/after metrics
4. Consider trade-offs (readability vs performance)
5. Document complex optimizations

## Testing Strategy

Generate tests that:
- Cover edge cases
- Include negative scenarios
- Test error handling
- Validate performance requirements
- Ensure backward compatibility

## Documentation

Always provide:
- Clear function/method documentation
- Usage examples
- Parameter descriptions
- Return value explanations
- Error scenarios

## Feedback Loop

Learn from:
- Code review comments
- Test failures
- Performance metrics
- User corrections
- Repository patterns
