# Transformer

A modern Ruby on Rails 8.0.2 application with React integration for building scalable web applications.

## 🏗️ Architecture Overview

```mermaid
graph TB
    subgraph "Frontend Layer"
        A[React Components] --> B[Stimulus Controllers]
        B --> C[Turbo Frames/Streams]
    end
    
    subgraph "Rails Application"
        C --> D[Controllers]
        D --> E[Services]
        E --> F[Models]
        F --> G[(SQLite Database)]
    end
    
    subgraph "Background Processing"
        H[Solid Queue] --> I[Jobs]
        I --> F
    end
    
    subgraph "Caching & Real-time"
        J[Solid Cache] --> D
        K[Solid Cable] --> L[ActionCable]
        L --> A
    end
```

## 🚀 Tech Stack

### Backend
- **Ruby on Rails**: 8.0.2 (latest features)
- **Database**: SQLite with Solid adapters
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **Real-time**: Solid Cable + ActionCable
- **Deployment**: Docker + Kamal

### Frontend
- **Asset Pipeline**: Propshaft + Importmap
- **JavaScript**: Stimulus + Turbo (Hotwire)
- **React**: Modern JS/TS components
- **Styling**: CSS with modern approaches

### Testing & Quality
- **Backend Testing**: RSpec
- **Frontend Testing**: Jest
- **Code Quality**: RuboCop (Rails Omakase), Brakeman
- **Development**: Debug gem, hot reloading

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
bin/rspec                 # Backend tests
npm test                  # Frontend tests (when configured)
```

### Docker Development
```bash
# Build and run
docker build -t transformer .
docker run -p 3000:3000 transformer
```

## 📋 Project Status

See [goals.md](./goals.md) for detailed project tracking and current priorities.

**Current Epic**: Project Foundation & Setup
**Next Steps**: Configure testing frameworks and define application requirements

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
- **Models**: Unit tests for business logic with descriptive contexts
- **Integration**: End-to-end transformation workflows
- **Services**: Business logic isolation and validation
- **Features**: User-facing functionality (planned)

### Frontend Testing (Jest)
- **Components**: React component behavior
- **Integration**: Component interaction
- **E2E**: Critical user paths

## 📁 Project Structure

```
app/
├── controllers/         # Rails controllers
├── models/             # ActiveRecord models & transformation engine
│   ├── concerns/       # Transformable interface
│   └── transformations/ # Built-in transformation classes
├── views/              # ERB templates
├── javascript/         # Stimulus + React components
│   ├── controllers/    # Stimulus controllers
│   └── __tests__/      # Jest test setup
├── jobs/               # Background jobs
└── services/           # Business logic services (planned)

config/
├── routes.rb           # Application routes
├── database.yml        # Database configuration
└── importmap.rb        # JavaScript imports

spec/                   # RSpec test files
├── models/             # Model and engine specs
├── support/            # Test helpers and matchers
└── factories/          # Test data factories
```

## 🚢 Deployment

This application is configured for deployment using:
- **Kamal**: Modern Rails deployment
- **Docker**: Containerized deployment
- **Thruster**: HTTP caching and compression

## 🤝 Contributing

1. Follow BDD approach: tests first, then implementation
2. Update goals.md with intended changes
3. Maintain documentation currency
4. Use conventional commit messages

## 📚 Documentation

- **[Goals & Tracker](./goals.md)**: Project progress and planning
- **[Copilot Instructions](./.github/copilot-instructions.md)**: Development workflow guidance

---

*Built with ❤️ using Ruby on Rails 8.0.2 and modern web technologies*
