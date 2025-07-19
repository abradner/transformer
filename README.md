# Transformer

A modern string manipulation web application built with Ruby on Rails 8.0.2 for complex text transformations with both browser and API interfaces.

## 🏗️ Application Overview

Transformer provides a powerful, secure system for text processing with a modern **clean architecture** approach:
- **Regex replacements** for log/payload readability  
- **Base64 encoding/decoding** for strings and Kubernetes config maps
- **Unified transformation system** with file-based YAML + database persistence
- **Domain-driven design** with adapters for different storage sources
- **Live editor interface** for crafting and testing transformations (planned)
- **CLI tool** for batch processing (planned)

## 🚀 Tech Stack

### Backend
- **Ruby on Rails**: 8.0.2 with modern Zeitwerk autoloading
- **Database**: SQLite with Solid adapters
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **Real-time**: Solid Cable + ActionCable
- **Template Engine**: Liquid for secure YAML transformations
- **Testing**: RSpec with comprehensive coverage
- **Deployment**: Docker + Kamal

### Frontend
- **Asset Pipeline**: Propshaft + Importmap
- **JavaScript**: Stimulus + Turbo (Hotwire)
- **React**: Modern JS/TS components (planned)
- **Styling**: CSS with modern approaches
- **Testing**: Jest (when configured)

### Architecture - Clean Architecture with Adapters

```mermaid
graph TB
    subgraph "Presentation Layer"
        A[Controllers] --> B[JSON API]
        A --> C[Web Interface]
        B --> D[Domain Services]
        C --> D
    end
    
    subgraph "Domain Layer"
        D --> E[TransformationRegistryService]
        E --> F[TransformationDefinition]
        F --> G[Transformation Engine]
    end
    
    subgraph "Infrastructure Adapters"
        H[FileTransformationAdapter] --> E
        I[DatabaseTransformationAdapter] --> E
        J[YAML Files] --> H
        K[SQLite Database] --> I
    end
    
    subgraph "Conflict Resolution"
        E --> L[Database Wins Over Files]
        L --> M[Unified Interface]
    end
```

## 🛠️ Development Setup

### Prerequisites
- Ruby 3.2+
- Node.js 18+
- Docker (optional)

### Local Development
```bash
# Clone and setup
git clone <repository>
cd transformer
bin/setup

# Run development server
bin/dev

# Run tests
bundle exec rspec          # Backend tests
npm test                   # Frontend tests (when configured)
```

### Docker Development
```bash
# Build and run
docker build -t transformer .
docker run -p 3000:3000 transformer
```

## 🚀 Current Features

### ✅ Core Transformation Engine
- **Modular Architecture**: Each transformation type as separate, composable module
- **Interface-based Design**: Common `Transformable` contract for all transformations
- **Built-in Transformations**: Regex replacement, Base64 encode/decode
- **Validation Framework**: Comprehensive input validation and error handling

### ✅ YAML Configuration System
- **Liquid Template Engine**: Secure templating with function whitelisting
- **Schema Validation**: Comprehensive YAML structure validation
- **Multi-step Transformations**: Chain multiple transformations sequentially
- **File-based Discovery**: Auto-load transformations from `config/transformations/`

### ✅ Advanced Features
- **Line Range Filtering**: Target specific sections of input using start/stop patterns
- **Function Security**: Whitelisted function calls prevent code injection
- **Sample Library**: Real-world transformation examples including K8s Secret decoding

## 📁 Project Structure - Clean Architecture

### Core Components
```
app/
├── controllers/         # Presentation layer - HTTP concerns only
│   └── transformations_controller.rb  # Orchestrates domain services
├── models/             # Domain & persistence models
│   ├── domain/         # Pure domain objects (no Rails dependencies)
│   │   └── transformation_definition.rb  # Core domain model
│   ├── transformation.rb              # Database persistence model  
│   ├── concerns/       # Transformable interface
│   └── transformations/ # Built-in transformation classes
├── adapters/           # Infrastructure adapters (Hexagonal Architecture)
│   ├── file_transformation_adapter.rb     # YAML file source
│   └── database_transformation_adapter.rb # Database source
├── services/           # Domain services & business logic
│   ├── transformation_registry_service.rb # Unified transformation management
│   └── transformation_loader_service.rb   # Legacy loader (refactored)
├── views/              # ERB templates
├── javascript/         # Stimulus + React components
└── jobs/               # Background jobs

config/transformations/          # File-based transformation definitions
├── k8s_secret_decoder.yml      # Kubernetes Secret base64 decoder
├── log_timestamp_normalizer.yml # ISO timestamp converter
└── log_level_highlighter.yml   # Log level emoji highlighter

spec/                   # Comprehensive test coverage
├── adapters/           # Adapter layer tests
├── controllers/        # Controller integration tests (with mocking)
├── services/           # Domain service tests
├── models/             # Model and engine specs
└── support/            # Test helpers and matchers
```

### Key Architectural Decisions

#### 1. **Clean Architecture Implementation**
- **Domain Layer**: `TransformationDefinition` as core business entity
- **Application Layer**: `TransformationRegistryService` coordinates business logic
- **Infrastructure Layer**: Adapters for file and database sources
- **Presentation Layer**: Controllers handle HTTP concerns only

#### 2. **Adapter Pattern for Data Sources**
```ruby
# Unified interface for both file and database transformations
class TransformationRegistryService
  def initialize
    @file_adapter = FileTransformationAdapter.new
    @database_adapter = DatabaseTransformationAdapter.new
  end
  
  def load_all
    # Combines both sources with conflict resolution
  end
end
```

#### 3. **Domain-First Design**
- **Single Source of Truth**: `TransformationDefinition` represents all transformations
- **Source Agnostic**: Business logic doesn't care about storage mechanism
- **Conflict Resolution**: Database transformations override file-based ones

#### 4. **Database Schema Design**
```sql
-- Simplified, focused schema based on YAML structure
CREATE TABLE transformations (
  name VARCHAR NOT NULL,           -- Unique identifier
  description TEXT,                -- Human-readable description  
  transformations_yaml TEXT NOT NULL, -- Just the transformations array
  transformation_type VARCHAR NOT NULL,   -- Type indicator
  version VARCHAR DEFAULT '1.0.0',        -- Semantic versioning
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## 🧪 Testing Strategy

```mermaid
graph LR
    A[RSpec Specs] --> B[Model Tests]
    B --> C[Integration Tests]
    C --> D[System Tests]

    E[Jest Tests] --> F[Component Tests]
    F --> G[Integration Tests]

    H[BDD Workflow] --> A
    H --> E
```

### Backend Testing (RSpec)
```bash
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/models/sample_yaml_transformations_spec.rb
```

### Commit Validation & Review
```bash
# Review current changes against project goals and code quality
bundle exec rake commit:review

# Generate conventional commit message based on changes
bundle exec rake commit:message
```

### Current Test Coverage
- **75+ test examples** across transformation engine, YAML system, and sample transformations
- **100% passing tests** with comprehensive edge case coverage
- **Security validation** tests for function whitelisting and input sanitization

### Sample Transformations

#### K8s Secret Decoder
```yaml
name: "k8s_secret_decoder"
description: "Decode base64 secrets from Kubernetes Secret data section"
version: "1.0"

transformations:
  - type: "function_based"
    config:
      template: |
        {{ input 
           | split_lines 
           | map_values(base64_decode) 
           | join_lines }}
      
      allowed_functions:
        - split_lines
        - map_values
        - base64_decode
        - join_lines
      
      line_range:
        start_pattern: "^data:"
        stop_pattern: "^(metadata|spec|status|kind):"
        include_boundaries: false
```

#### Log Processing
```yaml
# ISO timestamp normalizer
transformations:
  - type: "regex_replace"
    config:
      pattern: '(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})\.?\d*Z?'
      replacement: '\1 \2'

# Log level highlighter with emoji
transformations:
  - type: "regex_replace"
    config:
      pattern: '(?i)\b(ERROR|FATAL)\b'
      replacement: '🔴 [\1]'
```

## 🔒 Security Features

### Function Whitelisting
- **Principle**: Only pre-approved Ruby methods can be called from YAML
- **Implementation**: Whitelist maintained in Ruby code, not YAML configuration
- **Validation**: Function calls validated at parse time and runtime

### Template Safety
- **Liquid Engine**: Safe variable interpolation without arbitrary code execution
- **Input Sanitization**: All inputs validated before template processing
- **Error Handling**: Clear, secure error messages for invalid configurations

## 🚢 Deployment

This application is configured for deployment using:
- **Kamal**: Modern Rails deployment
- **Docker**: Containerized deployment
- **Thruster**: HTTP caching and compression

## 📋 Project Status

See [goals.md](./goals.md) for detailed project tracking and current priorities.

**Current Epic**: Core Data Model & Transformations  
**Recently Completed**: Story 2.5 - Sample YAML Transformations & K8s ConfigMap with line_range filtering  
**Next Steps**: Story 2.6 - Transformation Validation & Tooling

## 📚 Documentation

- **[YAML Schemas](docs/yaml-schemas.md)**: Complete transformation configuration reference
- **[Goals Tracker](goals.md)**: Project roadmap and development progress
- **[Copilot Instructions](.github/copilot-instructions.md)**: Development workflow guidance

## 🎯 Next Steps

### Planned Features
- **REST API**: Transformation endpoints for programmatic access
- **Live Editor Interface**: Browser-based transformation playground with real-time preview
- **Pipeline Orchestration**: Chain multiple transformations with conditional logic
- **CLI Tool**: Command-line interface for batch processing

## 🤝 Contributing

1. Follow BDD approach: tests first, then implementation
2. Update goals.md with intended changes
3. Maintain documentation currency
4. Use conventional commit messages

### License
This project is licensed under the Mozilla Public License 2.0 (MPL-2.0). See the [LICENSE](LICENSE) file for details.