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
**Status**: 🎯 Current Priority - In Progress
- [x] Regex replacement transformer
- [x] Base64 encode/decode transformer
- [x] Migrate test suite from Minitest to RSpec
- [x] Update documentation to reflect current state
- [x] Design YAML configuration schemas
- [ ] Implement YAML transformation loader with Liquid templating
- [ ] Create validation tooling for YAML transformation files
- [ ] Kubernetes ConfigMap transformer (using YAML system)

**Current Task**: Implementing YAML configuration system with Liquid template engine

### Story 2.3: YAML Configuration System
**Status**: 📋 Planning - Ready for Implementation
- [ ] Create YAML transformation schema validation
- [ ] Implement Liquid template engine integration
- [ ] Build function whitelist security system
- [ ] Create YAML transformation loader
- [ ] Add file-based transformation discovery in `config/transformations/`
- [ ] Build rake task for YAML validation tooling

**Technical Details**: 
- **Template Engine**: Liquid for security and flexibility
- **Schema**: Single transformation definitions with sequential `transformations:` array
- **Function System**: Whitelisted Ruby methods for complex operations
- **File Location**: `config/transformations/` for built-ins, database storage for user-created

### Story 2.4: Transformation Validation & Tooling
**Status**: 📋 Planning
- [ ] Create YAML schema validation using JSON Schema
- [ ] Build `rake transformer:validate` task for testing YAML files
- [ ] Add `rake transformer:list` to show available transformations
- [ ] Create development helpers for transformation testing
- [ ] Add YAML syntax error reporting with line numbers

### Story 2.5: Persistence Layer
**Status**: Not Started
- [ ] Transformation model and database design
- [ ] CRUD operations for custom transformations
- [ ] Named transformation management
- [ ] Import/export functionality

---

## Epic 3: API Interface
**Status**: Not Started

### Story 3.1: REST API Foundation
**Status**: Not Started
- [ ] API authentication strategy
- [ ] Transformation endpoints (apply, list, CRUD)
- [ ] Request/response format design
- [ ] Error handling and validation
- [ ] API documentation (OpenAPI/Swagger)

### Story 3.2: Batch Processing
**Status**: Not Started
- [ ] Multiple string processing
- [ ] File upload processing
- [ ] Async job processing for large transformations
- [ ] Progress tracking and status endpoints

---

## Epic 4: Browser Interface
**Status**: Not Started

### Story 4.1: Basic UI Framework
**Status**: Not Started
- [ ] Application layout and navigation
- [ ] Transformation management pages
- [ ] Authentication UI (if needed)
- [ ] Responsive design foundation

### Story 4.2: Live Editor Interface
**Status**: Not Started
- [ ] Pattern crafting component (regex/YAML editor)
- [ ] Input text area component
- [ ] Output text area component
- [ ] Real-time transformation preview
- [ ] Save/load transformation patterns

### Story 4.3: Enhanced UX Features
**Status**: Not Started
- [ ] Syntax highlighting for patterns
- [ ] Error highlighting and validation feedback
- [ ] Transformation history/undo
- [ ] Export/share functionality
- [ ] Keyboard shortcuts and productivity features

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
- **2025-07-01**: Project initialized, documentation framework established
- **2025-07-01**: Application requirements defined, epic structure refined
