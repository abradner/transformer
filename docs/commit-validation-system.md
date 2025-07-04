# Commit Validation System Documentation

## Overview

The commit validation system provides automated analysis of git changes to ensure code quality, goal alignment, and conventional commit message generation. It follows a service-oriented architecture with clear separation of concerns.

## Architecture Overview

```mermaid
graph TB
    subgraph "Entry Points"
        A[rake commit:review] --> B[CommitReviewer]
        C[rake commit:message] --> B
    end
    
    subgraph "Core Services"
        B --> D[GitAnalyzer]
        B --> E[GoalAnalyzer] 
        B --> F[CodeQualityAnalyzer]
        B --> G[CommitMessageGenerator]
    end
    
    subgraph "Quality Analysis"
        F --> H[RubocopAnalyzer]
        H --> I[RuboCop JSON Output]
        F --> J[Custom Zeitwerk Checks]
        F --> K[YAML Validation]
    end
    
    subgraph "Data Sources"
        D --> L[Git Worktree]
        E --> M[goals.md]
        I --> N[.rubocop.yml Config]
        J --> O[Ruby Files]
        K --> P[YAML Files]
    end
    
    subgraph "Output Models"
        B --> Q[ReviewResult]
        G --> R[Conventional Commit Message]
    end
    
    subgraph "Supporting Classes"
        D --> S[GitChange]
        E --> T[GoalAlignment]
        F --> U[CodeQualityResult]
    end
```

## Service Architecture

### 1. CommitReviewer (Orchestrator)

The central orchestrator that coordinates all analysis services:

```ruby
class CommitReviewer
  def analyze_changes
    changes = @git_analyzer.get_worktree_diff
    goal_analysis = @goal_analyzer.check_alignment(changes)
    quality_analysis = @code_analyzer.review_changes(changes)
    
    ReviewResult.new(...)
  end
end
```

**Responsibilities:**
- Orchestrate analysis workflow
- Aggregate results from all analyzers
- Build final ReviewResult with recommendations

### 2. GitAnalyzer (Git Interface)

Extracts and parses git diff information:

```mermaid
graph LR
    A[Git Worktree] --> B[git diff --cached HEAD]
    A --> C[git diff HEAD]
    B --> D[Combined Diff]
    C --> D
    D --> E[Parse Diff Lines]
    E --> F[GitChange Objects]
    
    subgraph "GitChange Properties"
        F --> G[file: String]
        F --> H[type: :addition/:deletion]
        F --> I[content: String]
        F --> J[Helper Methods]
    end
```

**Decision Logic:**
- Combines staged and unstaged changes for complete analysis
- Parses diff format to extract file changes and content
- Creates typed GitChange objects with helper methods (`ruby_file?`, `test_file?`, etc.)

### 3. GoalAnalyzer (Goal Alignment)

Checks if changes align with current project goals:

```mermaid
graph TB
    A[goals.md File] --> B[Extract Current Story]
    B --> C{Story Found?}
    C -->|Yes| D[Extract Story Context]
    C -->|No| E[Return No Story Found]
    
    D --> F[Parse Keywords]
    D --> G[Parse Technologies]
    D --> H[Parse File Areas]
    
    I[Git Changes] --> J[Analyze File Patterns]
    J --> K[Check Alignment]
    
    F --> K
    G --> K
    H --> K
    K --> L[GoalAlignment Result]
```

**Decision Process:**

1. **Current Story Detection:**
   ```ruby
   # Finds: ### Story 1.5: Title\n**Status**: 🔄 In Progress
   current_match = content.match(/### (Story \d+\.\d+: .+?)\n\*\*Status\*\*: 🔄 In Progress/m)
   ```

2. **Context Extraction:**
   - **Keywords**: `**bold**` and `code` snippets from story description
   - **Technologies**: rake, git, rspec, yaml based on content analysis
   - **File Areas**: lib/tasks, spec, app/services based on story context

3. **Alignment Check:**
   ```ruby
   def check_files_align_with_story(file_patterns, story_context)
     changed_areas = file_patterns[:directories]
     expected_areas = story_context[:file_areas]
     (changed_areas & expected_areas).any?
   end
   ```

### 4. CodeQualityAnalyzer (Hybrid Analysis)

Integrates RuboCop analysis with custom validation checks for a comprehensive quality review. While RuboCop handles standard Ruby linting, this service adds critical, project-specific validation that RuboCop does not cover by default.

**Key Responsibilities**:
- **RuboCop Integration**: Delegates all standard Ruby file analysis to `RubocopAnalyzer` for professional, configurable linting.
- **Custom Zeitwerk Checks**: Ensures new classes and modules adhere to Rails' autoloading conventions, preventing runtime errors. It validates that file names match class names (`user_profile.rb` -> `UserProfile`) and that nested classes exist within corresponding module namespaces.
- **Custom YAML Validation**: Performs basic structural checks on YAML files, such as flagging the use of hard tabs or excessively long lines, which can indicate formatting issues.
- **Suggestion Engine**: Provides contextual suggestions, such as reminding developers to add tests for new application code.

```mermaid
graph TB
    A[Git Changes] --> B[Extract Ruby Files]
    A --> C[Extract Other Files]
    
    B --> D[RubocopAnalyzer]
    D --> E[Execute RuboCop JSON]
    E --> F[Parse Offenses]
    F --> G[Map to Issues]
    
    C --> H[Custom Analysis]
    H --> I[Zeitwerk Compliance]
    H --> J[YAML Structure]
    
    G --> K[Combine Results]
    I --> K
    J --> K
    K --> L[Generate Suggestions]
    L --> M[CodeQualityResult]
```

**Implementation:**
```ruby
def review_changes(changes)
  ruby_files = extract_changed_ruby_files(changes)
  rubocop_result = @rubocop_analyzer.analyze_files(ruby_files)
  custom_issues = analyze_custom_patterns(changes)
  custom_suggestions = generate_custom_suggestions(changes)
  
  CodeQualityResult.new(
    issues: rubocop_result.issues + custom_issues,
    suggestions: rubocop_result.suggestions + custom_suggestions
  )
end
```

3. **Namespace Validation:**
   - Checks for missing module declarations in nested paths
   - Validates directory structure matches namespace hierarchy

### 5. CommitMessageGenerator (Message Creation)

Generates conventional commit messages based on changes and context:

```mermaid
graph TB
    A[Git Changes] --> C{Determine Type}
    B[Goal Analysis] --> D{Determine Scope}
    
    C --> E[Commit Type]
    D --> F[Commit Scope]
    
    A --> G{Generate Description}
    B --> G
    
    G --> H[Commit Description]
    
    E --> I[Conventional Commit Message]
    F --> I
    H --> I
```

**Message Generation Logic:**

1. **Type Determination:**
   ```ruby
   return 'feat' if files.any? { |f| f.start_with?('app/') && !f.include?('spec/') }
   return 'test' if files.all? { |f| f.include?('spec/') }
   return 'docs' if files.all? { |f| f.end_with?('.md') }
   return 'chore' if files.any? { |f| f.start_with?('lib/tasks/') }
   ```

2. **Scope Detection:**
   ```ruby
   return 'validation' if files.any? { |f| f.include?('commit') }
   return 'yaml' if files.any? { |f| f.include?('transformations') }
   ```

3. **Description Generation:**
   - If current story exists: Extract purpose from story title
   - Otherwise: Generate based on file changes and primary action

## Data Flow

### Review Process Flow

```mermaid
sequenceDiagram
    participant User
    participant Rake as rake commit:review
    participant CR as CommitReviewer
    participant GA as GitAnalyzer
    participant GoA as GoalAnalyzer
    participant CQA as CodeQualityAnalyzer
    participant RR as ReviewResult

    User->>Rake: Execute command
    Rake->>CR: analyze_changes()

    CR->>GA: get_worktree_diff()
    GA->>GA: Parse git diff
    GA-->>CR: GitChange[]

    CR->>GoA: check_alignment(changes)
    GoA->>GoA: Parse goals.md
    GoA->>GoA: Extract current story
    GoA->>GoA: Analyze file patterns
    GoA-->>CR: GoalAlignment

    CR->>CQA: review_changes(changes)
    CQA->>CQA: Analyze Ruby patterns
    CQA->>CQA: Check Zeitwerk compliance
    CQA->>CQA: Generate suggestions
    CQA-->>CR: CodeQualityResult

    CR->>RR: new(changes, goal_alignment, quality_issues, suggestions)
    RR-->>CR: ReviewResult

    CR-->>Rake: ReviewResult
    Rake->>Rake: Display summary
    Rake->>Rake: Display details
    Rake-->>User: Formatted output
```

### Message Generation Flow

```mermaid
sequenceDiagram
    participant User
    participant Rake as rake commit:message
    participant CR as CommitReviewer
    participant CMG as CommitMessageGenerator

    User->>Rake: Execute command
    Rake->>CR: generate_commit_message()

    CR->>CR: Get git changes
    CR->>CR: Get goal analysis
    CR->>CMG: new(changes, goal_analysis)

    CMG->>CMG: determine_commit_type()
    CMG->>CMG: determine_scope()
    CMG->>CMG: generate_description()
    CMG->>CMG: generate_body()

    CMG-->>CR: Formatted message
    CR-->>Rake: Commit message
    Rake-->>User: Display message
```

## Decision Trees

### File Type Classification

```mermaid
graph TB
    A[File Path] --> B{Extension?}
    B -->|.rb| C{Path contains?}
    B -->|.yml/.yaml| D[YAML File]
    B -->|.md| E[Documentation]

    C -->|spec/| F[Test File]
    C -->|app/| G{Subdirectory?}
    C -->|lib/tasks| H[Rake Task]

    G -->|models/| I[Model File]
    G -->|services/| J[Service File]
    G -->|controllers/| K[Controller File]

    D --> L[Configuration Analysis]
    E --> M[Documentation Analysis]
    F --> N[Test Analysis]
    I --> O[Ruby Analysis + Zeitwerk]
    J --> O
    K --> O
    H --> P[Task Analysis]
```


```mermaid
graph TB
    A[Code Issue] --> B{Type?}

    B -->|Zeitwerk Violation| C[❌ CRITICAL]
    B -->|Missing Namespace| C
    B -->|Security Issue| C

    B -->|Long Method| D[⚠️ WARNING]
    B -->|Hardcoded String| D
    B -->|Hard Tabs| D

    B -->|TODO Comment| E[💡 SUGGESTION]
    B -->|Potential Refactor| E
    B -->|Missing Tests| E

    C --> F[Block Commit]
    D --> G[Warn Developer]
    E --> H[Suggest Improvement]
```

### 5. RuboCop Analyzer

Executes RuboCop analysis on Ruby files:

**Output Format:**
```ruby
# RuboCop offense converted to issue format
"💡 Style/StringLiterals: Prefer double-quoted strings (app/services/analyzer.rb:48:71)"
```


```ruby
def generate_suggestions(issues)
  suggestions = []
  suggestions << "💡 Consider using consistent string quote style" if issues.any? { |i| i.include?('StringLiterals') }
  suggestions << "💡 Consider breaking long lines" if issues.any? { |i| i.include?('LineLength') }
  # ... additional pattern matching
end
```

## Configuration and Customization

### Thresholds and Constants


# CodeQualityAnalyzer
LONG_METHOD_THRESHOLD = 120
HARDCODED_STRING_MIN_LENGTH = 50
MAX_METHODS_PER_CLASS = 10

# File Type Detection
RUBY_EXTENSIONS = ['.rb']
YAML_EXTENSIONS = ['.yml', '.yaml']
DOC_EXTENSIONS = ['.md']

# Zeitwerk Patterns
NAMESPACE_MODULES = %w[App Models Services Controllers]
```

### Extending the System

The system is designed for extensibility:

1. **New Analyzers**: Implement the analyzer interface and add to CommitReviewer
2. **Custom Quality Checks**: Add methods to CodeQualityAnalyzer
3. **Additional File Types**: Extend GitChange helper methods
4. **New Commit Types**: Update CommitMessageGenerator type detection

## Error Handling and Edge Cases

### Git Analysis Edge Cases

- **Empty repository**: Returns empty changes array
- **Binary files**: Skipped in diff parsing
- **Merge conflicts**: Conflict markers treated as content
- **Large files**: No size limits currently imposed

### Goal Analysis Edge Cases

- **Missing goals.md**: Returns "no story found"
- **Malformed YAML frontmatter**: Graceful degradation
- **Multiple in-progress stories**: Takes first match
- **No story context**: Defaults to permissive alignment

### Quality Analysis Edge Cases

- **Non-UTF8 files**: Ruby string handling manages encoding
- **Generated files**: No special handling currently
- **Vendored code**: Analyzed like application code

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Services instantiated only when needed
2. **Minimal File Reading**: goals.md read once per analysis
3. **Efficient Parsing**: Single-pass diff parsing
4. **Caching Potential**: Results could be cached by git SHA

### Scalability Limits

- **Large diffs**: Linear time complexity O(n) where n = diff lines
- **Complex regexes**: Some quality checks use expensive patterns
- **File system calls**: Multiple file existence checks

## Testing Strategy

The system uses comprehensive RSpec testing:

```mermaid
graph TB
    A[Integration Tests] --> B[rake task:review]
    A --> C[rake task:message]

    D[Unit Tests] --> E[CommitReviewer]
    D --> F[GitAnalyzer]
    D --> G[GoalAnalyzer]
    D --> H[CodeQualityAnalyzer]
    D --> I[CommitMessageGenerator]

    J[Model Tests] --> K[ReviewResult]
    J --> L[GitChange]
    J --> M[GoalAlignment]
    J --> N[CodeQualityResult]

    O[Edge Case Tests] --> P[Empty Changes]
    O --> Q[Missing Files]
    O --> R[Malformed Input]
```


## Future Enhancements

### Planned Improvements

1. **Configurable Rules**: YAML-based quality rule configuration
2. **Plugin Architecture**: External analyzer plugins
3. **IDE Integration**: VS Code extension for real-time feedback
4. **CI/CD Integration**: Git hooks and GitHub Actions
5. **Metrics Dashboard**: Historical code quality trends
6. **AI Integration**: LLM-powered code review suggestions

### Architectural Extensions

```mermaid
graph TB
    A[Current System] --> B[Plugin Architecture]
    B --> C[External Analyzers]
    B --> D[Custom Rules Engine]

    A --> E[CI/CD Integration]
    E --> F[GitHub Actions]
    E --> G[Git Hooks]

    A --> H[Metrics & Analytics]
    H --> I[Quality Trends]
    H --> J[Team Dashboard]
```

---

## Conclusion

The commit validation system provides a robust, extensible foundation for maintaining code quality and project alignment. Its service-oriented architecture allows for easy testing, maintenance, and future enhancements while providing immediate value through automated analysis and conventional commit generation.

The system successfully implements the three core requirements:
1. **Goal Alignment**: Ensures changes match current project stories
2. **Code Quality**: Automated detection of common issues and anti-patterns
3. **Commit Generation**: Conventional commits following best practices

This documentation serves as both an architectural reference and a guide for future development and maintenance of the system.
