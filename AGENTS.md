# AGENTS.md - AI Agent Guidelines

This file provides unified guidance for AI agents working with the Transformer codebase.

## Project Overview

**Transformer** - A Ruby on Rails 8.0.2 string manipulation web application with modular transformation engine, YAML-based configuration, and secure Liquid templating.

## Essential Commands

### Development
```bash
bin/dev                             # Start development server
bin/setup                          # Initial project setup
```

### Testing
```bash
bundle exec rspec                   # Backend tests (comprehensive: 75+ examples)
npm test                           # Frontend tests (Jest)
```

### Code Quality
```bash
bin/rubocop                        # Linting (Rails Omakase style)
bin/brakeman                       # Security scan
bundle exec rake commit:review     # Analyze changes vs project goals
bundle exec rake commit:message    # Generate conventional commit
```

### Transformation System
```bash
bundle exec rake transformer:list     # Show available transformations
bundle exec rake transformer:validate # Validate YAML files
```

## Architecture & Patterns

### Core Design
- **Transformation Engine**: Modular with `Transformable` interface
- **Security-First**: Function whitelisting prevents code injection
- **Zeitwerk Compliance**: File structure = class namespaces exactly

### Key Directories
```
app/models/transformations/         # Built-in classes (Base64, Regex)
app/models/yaml_transformations/    # YAML system components
app/services/                      # Business logic (commit validation, analysis)
config/transformations/            # Sample YAML files
```

### Data Flow
```
Input → Selection → Processing Engine → Output
              ↓
      YAML Config ← → Built-in Library
```

## Development Workflow

1. **Plan**: Update `goals.md` story status before implementing
2. **Test-First**: Write RSpec/Jest tests before code
3. **Implement**: Follow Zeitwerk naming strictly
4. **Quality**: Run `rake commit:review` before committing
5. **Document**: Update relevant docs and history logs

## Critical Requirements

### Zeitwerk Autoloading (Non-negotiable)
- `snake_case.rb` → `CamelCase` class
- `app/services/user_profile.rb` → `class UserProfile`
- `app/services/user/profile_updater.rb` → `class User::ProfileUpdater`
- One class per file, named correctly

### Security
- YAML functions must be whitelisted in `YamlFunctionRegistry`
- Use Liquid templating for safe variable interpolation
- Validate all inputs before processing

### Testing Standards
- BDD approach: tests first, then implementation
- Comprehensive coverage required (edge cases, security validation)
- Use factories and test helpers in `spec/support/`

## Project Tracking

- **Single Source of Truth**: `goals.md` (Epic → Story → Task structure)
- **Current Status**: Epic 2 complete (Core Data Model), Epic 3 in progress (API Interface)
- **Documentation**: Keep `README.md` current with architecture changes

## Dependencies & Libraries

### Backend
- **Rails 8.0.2** with Zeitwerk
- **Liquid** for secure templating
- **RSpec** testing framework
- **SQLite** with Solid adapters

### Frontend
- **Hotwire** (Stimulus + Turbo)
- **React 18** for complex components
- **Jest** with Testing Library