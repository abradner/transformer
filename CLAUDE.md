# CLAUDE.md

This file provides Claude Code-specific guidance. For shared project information, see **[AGENTS.md](AGENTS.md)**.

## Claude Code Specific Features

### Advanced Command Usage
```bash
# Specific file testing (Claude Code excels at targeted work)
bundle exec rspec spec/models/transformation_engine_spec.rb
bundle exec rspec --format documentation  # Detailed output

# Watch mode for iterative development
npm run test:watch                  # Frontend test watch mode
npm run test:coverage              # Generate coverage reports
```

### Task Planning & Execution
Use TodoWrite tool for complex multi-step tasks:
- Break down large features into manageable chunks
- Track progress across implementation phases
- Maintain context across long development sessions

## Claude Code Workflow Optimizations

### For Large Changes
1. Use `TodoWrite` to plan multi-step implementations
2. Leverage parallel tool execution for comprehensive analysis
3. Use `Task` tool for open-ended searches requiring multiple rounds

### For Code Analysis
- Use `Grep` and `Glob` tools for pattern-based searches
- Batch multiple independent searches in single responses
- Leverage `Task` tool when search scope is uncertain

### For Testing & Quality
- Run quality checks in parallel: `rspec`, `rubocop`, `brakeman`
- Use commit validation tools before any changes
- Generate conventional commit messages automatically

## Integration Points

### With Project Workflow
- Always check `goals.md` for current story status before major changes
- Use `rake commit:review` for goal alignment validation
- Follow the documented BDD approach from AGENTS.md

### With Other Tools
- Respect Zeitwerk naming conventions (critical for Rails 8)
- Maintain compatibility with Copilot's inline suggestions
- Preserve existing documentation structure and history logs