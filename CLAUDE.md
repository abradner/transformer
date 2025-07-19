# CLAUDE.md

This file provides Claude Code-specific guidance. For shared project information, see **[AGENTS.md](AGENTS.md)**.

## Claude Code Specific Features

### Advanced Command Usage
```bash
# Specific file testing (Claude Code excels at targeted work)
bundle exec rspec spec/adapters/file_transformation_adapter_spec.rb
bundle exec rspec spec/services/transformation_registry_service_spec.rb
bundle exec rspec --format documentation  # Detailed output

# Architecture-specific testing
bundle exec rspec spec/controllers/transformations_controller_spec.rb  # With mocking
bundle exec rspec spec/models/domain/transformation_definition_spec.rb  # Domain logic

# Watch mode for iterative development
npm run test:watch                  # Frontend test watch mode
npm run test:coverage              # Generate coverage reports
```

### Task Planning & Execution
**TodoWrite Integration with goals.md**:
- When working on a specific story, TodoWrite tasks should mirror the story's checklist items
- Break down story tasks into granular, trackable todo items
- Maintain alignment between TodoWrite progress and goals.md story status
- Use TodoWrite for dynamic task management during implementation
- Update goals.md story status when TodoWrite tasks are completed

**Best Practices**:
- Start each story by creating TodoWrite tasks from goals.md checklist
- Add implementation-specific subtasks as discovered during development
- Mark story as complete in goals.md only when all TodoWrite tasks are done
- **Essential for architectural refactoring** (as demonstrated in the adapter pattern implementation)

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

## Key Architectural Insights

### Clean Architecture Implementation
This project demonstrates **Clean Architecture** principles with Rails:

```
Domain Layer (app/models/domain/)
├── TransformationDefinition  # Core business entity
├── Pure Ruby objects         # No Rails dependencies
└── Business rules and logic

Application Layer (app/services/)  
├── TransformationRegistryService  # Coordinates business operations
├── Orchestrates adapters         # Infrastructure coordination
└── Domain service contracts

Infrastructure Layer (app/adapters/)
├── FileTransformationAdapter     # YAML file persistence
├── DatabaseTransformationAdapter # Database persistence  
└── External system integration

Presentation Layer (app/controllers/)
├── HTTP concerns only
├── JSON serialization
└── Request/response handling
```

### Adapter Pattern Benefits
- **Source Agnostic**: Business logic doesn't know about storage mechanism
- **Conflict Resolution**: Database transformations override file-based ones
- **Testability**: Easy mocking with `allow_any_instance_of(FileTransformationAdapter)`
- **Extensibility**: Add new sources (Redis, API, etc.) without changing domain logic

### Domain-Driven Design Principles
1. **Ubiquitous Language**: `TransformationDefinition`, `source_type`, `file_based?`
2. **Bounded Context**: Transformation management is clearly separated
3. **Aggregate Root**: `TransformationDefinition` encapsulates transformation behavior
4. **Repository Pattern**: Adapters provide collection-like interfaces

## Integration Points

### With Project Workflow
- Always check `goals.md` for current story status before major changes
- Use `rake commit:review` for goal alignment validation
- Follow the documented BDD approach from AGENTS.md
- **Critical**: Plan architectural changes with TodoWrite tool before implementation

### With Other Tools
- Respect Zeitwerk naming conventions (critical for Rails 8)
- Maintain compatibility with Copilot's inline suggestions
- Preserve existing documentation structure and history logs
- **New**: Use mocking in controller tests to isolate from file system dependencies

### Architecture Decision Records
When making significant architectural changes:
1. Document the problem and constraints
2. List alternative solutions considered  
3. Explain the chosen approach and tradeoffs
4. Update both README.md and CLAUDE.md with insights
5. Ensure tests demonstrate the architectural benefits
6. **CRITICAL**: Update goals.md with completed story and add to history log

### Essential Workflow Checkpoints
- **Before Major Changes**: Check goals.md for current story status
- **Story Start**: Create TodoWrite tasks mirroring goals.md story checklist items
- **During Implementation**: Use TodoWrite for dynamic task tracking and discovery
- **Task Completion**: Mark TodoWrite tasks complete as work progresses
- **Story Completion**: Update goals.md story status only when all TodoWrite tasks done
- **After Completion**: Update goals.md history log with key accomplishments
- **Before Commit**: Run `bundle exec rake commit:review` for validation

### TodoWrite ↔ goals.md Integration Example
```
goals.md Story 2.8: Advanced Persistence Features
- [ ] Soft deletion support for database transformations
- [ ] Transformation versioning and rollback functionality
- [ ] Import/export functionality for transformation definitions

↓ Becomes TodoWrite tasks ↓

1. [pending] Research soft deletion patterns in Rails (high)
2. [pending] Implement soft deletion for Transformation model (high) 
3. [pending] Update adapters to handle soft deleted records (medium)
4. [pending] Design versioning schema for transformations (medium)
5. [pending] Implement version creation on transformation updates (medium)
6. [pending] Create rollback functionality (low)
```