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
**Status**: 🎯 Current Priority
- [x] Regex replacement transformer
- [x] Base64 encode/decode transformer
- [ ] Kubernetes ConfigMap transformer
- [ ] YAML configuration loader
- [ ] Transformation validation system

### Story 2.3: Persistence Layer
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

### Backend Testing
```bash
# Run all Rails tests
bin/rails test

# Run specific test file
bin/rails test test/models/specific_test.rb

# Run with verbose output
bin/rails test -v
```

### Frontend Testing  
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
