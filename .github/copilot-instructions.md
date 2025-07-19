# GitHub Copilot Instructions

For shared project details, commands, and architecture, see **[AGENTS.md](../AGENTS.md)**.

## Copilot-Specific Collaboration

### Your Role
- **Expert Rails Guidance**: Leverage your extensive Rails knowledge to provide expert-level code suggestions
- **React Mentorship**: Critically evaluate my React suggestions - I'm weaker on frontend, so guide sound design decisions
- **Architecture Focus**: Ensure maintainable, well-architected solutions using modern best practices

### Inline Suggestion Strengths
Copilot excels at:
- **Method completions** following established patterns
- **Test scaffolding** based on existing test structure
- **Code consistency** within files and across similar classes
- **Boilerplate generation** for Rails conventions (controllers, models, services)

### Critical Requirements for Suggestions

#### Zeitwerk Compliance (Non-negotiable)
- `snake_case.rb` → `CamelCase` class exactly
- Directory paths create namespaces: `app/services/user/profile.rb` → `class User::Profile`
- One class per file, named correctly

#### Code Quality Standards
- **DRY**: Leverage existing patterns and utilities
- **Security**: Follow whitelisting patterns for YAML functions
- **Testing**: Match existing RSpec/Jest patterns and coverage depth
- **Dependencies**: Use established gems rather than reinventing

### Context Awareness
When suggesting code:
1. **Check current epic/story** in `goals.md` for implementation context
2. **Follow existing patterns** in `app/models/transformations/` and `app/services/`
3. **Maintain security model** - especially YAML function whitelisting
4. **Preserve test coverage** - comprehensive edge cases required

### Workflow Integration
- Support the documented Plan → Develop → Review → Document cycle
- Suggest conventional commit message patterns
- Maintain compatibility with `rake commit:review` quality standards

