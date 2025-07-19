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

### Core Design - Clean Architecture
- **Domain-Driven Design**: `TransformationDefinition` as core business entity
- **Adapter Pattern**: Unified interface for file and database sources
- **Dependency Inversion**: Business logic independent of storage mechanism
- **Single Responsibility**: Each layer has clear, focused responsibilities
- **Security-First**: Function whitelisting prevents code injection
- **Zeitwerk Compliance**: File structure = class namespaces exactly

### Key Directories - Clean Architecture
```
app/models/domain/                  # Pure domain objects (no Rails dependencies)
app/adapters/                      # Infrastructure adapters (File, Database)
app/services/                      # Domain services & business logic 
app/controllers/                   # Presentation layer (HTTP concerns only)
app/models/                        # ActiveRecord persistence models
config/transformations/            # File-based transformation definitions
```

### Data Flow - Unified Sources
```
Controllers → Registry Service → Domain Objects
                    ↓
           [File Adapter] ← → [Database Adapter]
                    ↓
           Transformation Definition (unified interface)
                    ↓
           Processing Engine → Output
```

### Clean Architecture Layers
```
Presentation    → Controllers (HTTP, JSON)
Application     → Services (Business Logic)
Domain          → Models (Pure Business Objects)  
Infrastructure  → Adapters (File, Database, External APIs)
```

## Development Workflow

1. **Plan**: Update `goals.md` story status before implementing
2. **Architecture**: For complex changes, use Clean Architecture patterns (Domain → Services → Adapters → Controllers)
3. **Test-First**: Write RSpec/Jest tests before code (mock adapters in controller tests)
4. **Implement**: Follow Zeitwerk naming strictly, respect layer boundaries
5. **Quality**: Run `rake commit:review` before committing
6. **Document**: Update relevant docs and history logs

### For Architectural Changes
1. **TodoWrite Planning**: Break complex refactoring into manageable steps (mirror goals.md story tasks)
2. **Domain First**: Start with pure domain objects (no Rails dependencies)
3. **Adapter Pattern**: Create adapters for external dependencies
4. **Service Layer**: Coordinate between adapters and domain logic
5. **Controller Updates**: Minimal changes, delegate to services
6. **Comprehensive Testing**: Test each layer independently with mocking
7. **Story Completion**: Update goals.md only when all TodoWrite tasks complete

### TodoWrite ↔ goals.md Workflow
- **Story Start**: Convert goals.md checklist items into TodoWrite tasks
- **Dynamic Planning**: Add implementation-specific subtasks as discovered
- **Progress Tracking**: TodoWrite provides real-time progress, goals.md provides project context
- **Completion Sync**: Mark goals.md story complete only when TodoWrite shows all tasks done

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