# Project Goals & Tracker

## Project Overview
**Transformer** - A string manipulation web application with both browser and API interfaces for complex text transformations.

### Application Purpose
A tool for common string transformations including:
- Regex replacements for log/payload readability
- Base64 encoding/decoding (strings and k8s config maps)
- Named transformation persistence (built-in YAML + database)
- Live editor interface for crafting and testing transformations

### Tech Stack
- **Backend**: Rails 8.0.2, SQLite, Solid Cache/Queue/Cable
- **Frontend**: Turbo, Stimulus, React components for live editor
- **Testing**: RSpec (Rails), Jest (React)
- **Deployment**: Docker, Kamal
- **Future**: CLI tool (transformation logic modularized)

---

## Epic 1: Project Foundation & Setup
**Status**: In Progress

### Story 1.1: Project Documentation & Workflow Setup
**Status**: ✅ Complete
- [x] Create GitHub Copilot instructions
- [x] Initialize goals.md tracker
- [x] Update README with project structure and diagrams
- [x] Define application requirements and scope

### Story 1.2: Development Environment Setup
**Status**: ✅ Complete
- [x] Configure RSpec for backend testing
- [x] Setup Jest for frontend testing
- [x] Configure linting and formatting
- [ ] Setup CI/CD pipeline basics

### Story 1.3: Testing Framework Validation
**Status**: ✅ Complete
- [x] Create sample RSpec test to validate backend setup
- [x] Create sample Jest test to validate frontend setup
- [x] Verify all testing tools work correctly
- [x] Document testing commands and workflows

### Story 1.4: Testing Documentation & Commands
**Status**: ✅ Complete
- [x] Document test execution commands
- [x] Validate both frontend and backend testing
- [x] Resolve environment compatibility issues
- [x] Establish testing best practices

### Story 1.5: Commit Validation & Review Tooling
**Status**: ✅ Complete
- [x] Create rake task to analyze git diff against main branch
- [x] Implement commit validation checks (atomic commits, goal alignment)
- [x] Add code quality review (factoring, Rails best practices)
- [x] Generate PR description / commit message suggestions
- [x] Update copilot-instructions.md workflow to include validation step
- [x] Create comprehensive test coverage for the validation tooling

**Technical Details**:
- **Git Analysis**: Examine worktree diff including unstaged changes
- **Goal Alignment**: Check changes against current story/epic context
- **Quality Checks**: Identify potential refactoring opportunities
- **Message Generation**: Craft atomic commit messages following conventional commits

**Completed**: Comprehensive commit validation and review tooling with rake tasks `commit:review` and `commit:message`, service-based architecture, goal alignment checking, code quality analysis, and conventional commit message generation.

### Story 1.6: Integrate RuboCop with Commit Validation
**Status**: ✅ Complete
- [x] Replace custom code quality checks with RuboCop integration
- [x] Configure RuboCop to run on changed files only
- [x] Parse RuboCop output into our ReviewResult format
- [x] Remove redundant code quality analysis from CodeQualityAnalyzer
- [x] Update tests to work with RuboCop integration
- [x] Ensure Zeitwerk-specific validations still work (may need custom rules)

**Technical Details**:
- **RuboCop Integration**: Use existing `.rubocop.yml` configuration
- **Selective Analysis**: Run RuboCop only on changed files for performance
- **Output Parsing**: Convert RuboCop JSON output to our quality issue format
- **Performance**: Faster analysis using battle-tested linting rules

**Completed**: Successfully integrated RuboCop with commit validation system, replacing custom quality checks with professional linting while maintaining custom Zeitwerk and YAML analysis. System now provides precise issue locations, cop names, and intelligent suggestions based on detected patterns.

---

## Epic 2: Core Data Model & Transformations
**Status**: Not Started

### Story 2.1: Transformation Engine Architecture
**Status**: ✅ Complete
- [x] Design transformation interface/contract
- [x] Create modular transformation system
- [x] Implement built-in transformations (regex, base64)
- [x] Design YAML-based transformation format
- [x] Plan database schema for custom transformations

**Completed**: Core transformation engine with Transformable interface, Base64 encode/decode, Regex replacement with capture groups, validation framework, and comprehensive test coverage.

### Story 2.2: Built-in Transformations
**Status**: ✅ Complete
- [x] Regex replacement transformer
- [x] Base64 encode/decode transformer
- [x] Migrate test suite from Minitest to RSpec
- [x] Update documentation to reflect current state
- [x] Design YAML configuration schemas
- [x] Document YAML schemas and validation patterns
- [x] Implement YAML transformation loader with Liquid templating
- [x] Create validation tooling for YAML transformation files
- [ ] Kubernetes ConfigMap transformer (using YAML system)

**Completed**: YAML transformation system with Liquid template engine, function whitelisting security, multi-step transformation chains, comprehensive validation, and 14 passing tests.

### Story 2.3: YAML Configuration System
**Status**: ✅ Complete
- [x] Create YAML transformation schema validation
- [x] Implement Liquid template engine integration
- [x] Build function whitelist security system
- [x] Create YAML transformation loader
- [x] Add file-based transformation discovery in `config/transformations/`
- [x] Build comprehensive test coverage for YAML system

**Technical Details**:
- **Template Engine**: Liquid for security and flexibility
- **Schema**: Single transformation definitions with sequential `transformations:` array
- **Function System**: Whitelisted Ruby methods for complex operations
- **File Location**: `config/transformations/` for built-ins, database storage for user-created

**Completed**: Complete YAML configuration system with Zeitwerk-compliant autoloading, security validation, and production-ready functionality.

### Story 2.5: Sample YAML Transformations & K8s ConfigMap
**Status**: ✅ Complete
- [x] Create sample YAML transformation files in `config/transformations/`
- [x] Implement Kubernetes ConfigMap/Secret decoder using YAML system
- [x] Add line_range filtering feature to function_based transformations
- [x] Create comprehensive test coverage for sample transformations
- [x] Update YAML schema documentation with line_range feature

**Technical Details**:
- **Line Range Filtering**: Added "DNA codon" pattern matching to function_based transformations
- **K8s Secret Decoder**: Clean implementation targeting only `data:` section using start/stop patterns
- **Sample Files**: Created log timestamp normalizer, log level highlighter, and K8s decoders
- **Schema Extension**: Minimal, expressive `line_range` config for targeted processing

**Completed**: Complete YAML sample transformations library with practical real-world examples including K8s Secret decoding, log processing, and pattern-based line filtering.

### Story 2.6: Transformation Validation & Tooling
**Status**: ✅ Complete
- [x] Create YAML schema validation using JSON Schema
- [x] Add YAML syntax error reporting with line numbers
- [x] Build `rake transformer:validate` task for testing YAML files
- [x] Add `rake transformer:list` to show available transformations

### Story 2.7: Persistence Layer
**Status**: Deferred until after 4.3
- [ ] Transformation model and database design
- [ ] CRUD operations for custom transformations
- [ ] Named transformation management
- [ ] Import/export functionality
- [ ] Create development helpers for transformation testing

---

## Epic 3: API Interface
**Status**: In Progress

### Story 3.1: REST API Foundation
**Status**: In Progress
- [ ] Design request/response format for API endpoints
- [ ] Implement `GET /api/v1/transformations` to list available YAML-based transformations
- [ ] Implement `POST /api/v1/transform` to apply a named transformation (one-shot)
- [ ] Implement basic error handling and validation
- [ ] Add comprehensive test coverage for API endpoints

### Story 3.2: Real-time Transformation API (WebSocket)
**Status**: Up Next
- [ ] Design WebSocket message format for real-time transformations
- [ ] Implement ActionCable channel for live transformation updates
- [ ] Add WebSocket authentication and connection management
- [ ] Implement real-time error handling and validation
- [ ] Add comprehensive test coverage for WebSocket functionality

### Story 3.3: API Authentication & Security
**Status**: Deferred until after: 4.5
- [ ] Implement API key authentication for REST endpoints
- [ ] Add rate limiting and throttling
- [ ] Implement CORS configuration for browser access
- [ ] Add security headers and validation
- [ ] Create API documentation (OpenAPI/Swagger)

### Story 3.4: CRUD Operations for Custom Transformations
**Status**: Not Started
- [ ] Implement `POST /api/v1/transformations` to create custom transformations
- [ ] Implement `PUT /api/v1/transformations/:id` to update transformations
- [ ] Implement `DELETE /api/v1/transformations/:id` to delete transformations
- [ ] Add validation for custom transformation YAML
- [ ] Implement transformation import/export endpoints

### Story 3.5: Batch Processing
**Status**: Not Started
- [ ] Multiple string processing endpoints
- [ ] File upload processing
- [ ] Async job processing for large transformations
- [ ] Progress tracking and status endpoints

---

## Epic 4: Browser Interface
**Status**: In Progress

### Story 4.1: Basic UI Framework & Layout
**Status**: Up Next after 3.2
- [ ] Create a main controller and root route for the application
- [ ] Implement basic application layout (header, navigation, content area)
- [ ] Set up Turbo and Stimulus integration
- [ ] Create basic CSS structure and styling
- [ ] Add responsive design foundation

### Story 4.2: Transformation Playground (Core UI)
**Status**: Not Started
- [ ] Create playground page with input/output text areas
- [ ] Implement transformation selection dropdown (YAML-based only)
- [ ] Add basic form validation and error display
- [ ] Implement static transformation preview (without real-time)
- [ ] Add sample data loading for testing transformations

### Story 4.3: Real-time Transformation Integration
**Status**: Not Started
- [ ] Integrate ActionCable WebSocket for real-time updates
- [ ] Implement real-time transformation preview as user types
- [ ] Add debouncing to prevent excessive WebSocket calls
- [ ] Implement connection status indicators
- [ ] Add fallback to REST API if WebSocket fails

### Story 4.4: Enhanced Playground Features
**Status**: Not Started
- [ ] Add syntax highlighting for input/output text areas
- [ ] Implement transformation history/undo within session
- [ ] Add export functionality for transformation results
- [ ] Implement keyboard shortcuts for common actions
- [ ] Add mobile/tablet responsive design

### Story 4.5: Transformation Management Interface
**Status**: Not Started
- [ ] Create transformation browsing and management pages
- [ ] Implement transformation creation/editing forms
- [ ] Add transformation testing interface
- [ ] Implement transformation import/export UI
- [ ] Add transformation versioning and comparison views

### Story 4.6: Authentication & User Management UI
**Status**: Not Started
- [ ] Implement user registration and login forms
- [ ] Add user dashboard for managing personal transformations
- [ ] Implement user profile management
- [ ] Add user-specific transformation organization
- [ ] Implement sharing and collaboration features

### Story 4.7: Advanced UX Features
**Status**: Not Started
- [ ] Add drag-and-drop file upload for batch processing
- [ ] Implement advanced error highlighting and validation feedback
- [ ] Add auto-completion for transformation functions
- [ ] Implement transformation result sharing via URLs
- [ ] Add dark mode and theme customization

---

## Epic 5: Advanced Features & Polish
**Status**: Not Started

### Story 5.1: Performance & Scalability
**Status**: Not Started
- [ ] Transformation result caching
- [ ] Large file processing optimization
- [ ] Rate limiting and security measures
- [ ] Monitoring and logging

### Story 5.2: Integration & Extensibility
**Status**: Not Started
- [ ] Plugin system for custom transformations
- [ ] CLI tool foundation (modular architecture)
- [ ] Import from popular transformation tools
- [ ] Export to various formats

---

## Epic 6: Pipeline Orchestration (Future)
**Status**: 📋 Future Planning

### Story 6.1: Pipeline Definition System
**Status**: Not Started
- [ ] Design pipeline YAML schema (separate from transformations)
- [ ] Create pipeline orchestration engine
- [ ] Implement sequential step execution
- [ ] Add pipeline validation and error handling
- [ ] Support for referencing existing transformations by name

**Technical Details**:
- **Pipeline Schema**: References transformations, doesn't define them
- **Orchestration Layer**: Manages transformation flow and error handling
- **Integration**: Pipelines implement `Transformable` for engine compatibility

### Story 6.2: Advanced Pipeline Features
**Status**: Not Started  
- [ ] Conditional pipeline execution (if/then/else logic)
- [ ] Parallel branch processing with merge capabilities
- [ ] Pipeline nesting (pipelines calling other pipelines)
- [ ] Error recovery and retry mechanisms
- [ ] Pipeline performance monitoring and logging

### Story 6.3: Pipeline Management Interface
**Status**: Not Started
- [ ] Pipeline creation and editing UI
- [ ] Visual pipeline designer with drag-and-drop
- [ ] Pipeline testing and debugging tools
- [ ] Pipeline versioning and rollback
- [ ] Pipeline sharing and collaboration features

---

## Epic 7: System Audit & Refinement
**Status**: ✅ Complete
**Goal**: To resolve discrepancies between documentation and implementation, refactor existing code for clarity and correctness, and ensure the project's foundation is solid before building new features.

### Story 7.1: Correct Commit Validation Documentation
**Status**: ✅ Complete
- [ ] Update the Mermaid diagram for `CommitMessageGenerator` in `docs/commit-validation-system.md` to accurately reflect its logic (commit type, scope, and description generation).
- [ ] Verify the responsibilities of `CodeQualityAnalyzer` post-RuboCop integration and update the documentation to clarify what custom checks (e.g., Zeitwerk, YAML) remain.
- [ ] Update the `README.md` to correctly describe the `app/services` directory as implemented.


## Architecture Decisions

### Transformation Engine Design
- **Modular**: Each transformation type as separate module
- **Interface-based**: Common contract for all transformations
- **Composable**: Chain multiple transformations
- **CLI-ready**: Logic separated from web interface

### Data Flow
```
Input → Transformation Selection → Processing Engine → Output
                ↓
        Named Storage ← → Built-in Library
```

### Component Structure (React)
- **PatternEditor**: Regex/YAML crafting with syntax highlighting
- **InputPanel**: Text input with file upload support
- **OutputPanel**: Results display with export options
- **TransformationPicker**: Browse/select saved transformations

---

## Testing Commands Reference

### Backend Testing (RSpec)
```bash
# Run all RSpec tests
bundle exec rspec

# Run specific spec file
bundle exec rspec spec/models/transformation_engine_spec.rb

# Run with documentation format
bundle exec rspec --format documentation

# Run with coverage (when configured)
bundle exec rspec --format documentation --format html --out coverage/index.html
```

### Frontend Testing (Jest)
```bash
# Run all Jest tests
npm test

# Run tests in watch mode
npm run test:watch

# Run with coverage
npm run test:coverage
```

---

## History Log
- **2025-07-05**: Pivoted to API and UI foundation (Epic 3 & 4) to enable early application use, deferring persistence.
- **2025-07-05**: Integrated RuboCop with commit validation system, replacing custom quality checks with professional linting
- **2025-07-05**: Added commit validation and review tooling with rake tasks `commit:review` and `commit:message`
- **2025-07-02**: Added line_range filtering to function_based transformations for targeted line processing
- **2025-07-02**: Implemented K8s Secret decoder using line_range to target only data: section
- **2025-07-02**: Created sample YAML transformations library with real-world examples
- **2025-07-01**: Project initialized, documentation framework established
- **2025-07-01**: Application requirements defined, epic structure refined
