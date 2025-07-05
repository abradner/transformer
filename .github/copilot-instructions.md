# GitHub Copilot Instructions

### About This Project

This is a Ruby on Rails (8.0.2) and React (JS/TS) application for string transformations. 

## Collaboration Style
- Provide expert guidance and critical evaluation
- Don't assume human suggestions are correct (especially React)
- Leverage extensive Rails experience, strengthen React knowledge
- Focus on modern best practices and maintainable architecture

## Background from the User
I am an experienced Rails developer, but my React skills are weaker, so critically evaluate my suggestions, especially on the front end.
Your role is to provide expert guidance, ensuring we follow modern best practices for a maintainable, well-architected system.

### Our Workflow

We follow a documentation-driven, test-first process.

1.  **Plan**: Before coding, we'll update `goals.md` to 
    *   Define the story and tasks were there isn't enough detail
    *   Update the status of the story we are about to implement to 'In Progress'
2.  **Develop**:
    *   Write tests first (RSpec/Jest).
    *   Implement clean, well-factored code
    *   Make use of appropriate libraries 
    *   Incorporate additional gems where a significant piece of functionality has already been implemented in a well-maintained gem
3.  **Review & Commit**:
    *   Explain the Why, What, and How of the changeset to the user and invite them to do a first-parse review
    *   Use `rake commit:review` to analyze changes.
    *   Use `rake commit:message` to generate a conventional commit message
    *   Use the generated message and the "Why/What/How" to write a suitable PR description summarizing the story completion
4.  **Document**: After implementation, update all relevant documentation (`README.md`, `goals.md`, etc.) and their history logs.

### Key Principles & Standards

#### **Code & Architecture**
*   **Rails**: Write expert-level, modern Rails code.
*   **React**: Guide me in making sound design decisions for JS/TS components.
*   **General**: Code should be DRY, functional, and leverage well-maintained libraries.
*   **Testing**: Adhere strictly to a BDD approach with comprehensive test coverage.

#### **Zeitwerk Autoloading (Rails 8)**
The file and directory structure *must* map directly to module and class names.
*   **Files**: `snake_case.rb` maps to `CamelCase` class.
    *   `app/services/user_profile.rb` -> `class UserProfile`
*   **Directories**: Directory paths create namespaces.
    *   `app/services/user/profile_updater.rb` -> `class User::ProfileUpdater`
*   **Rule**: One class per file, named correctly.

#### **Documentation**
*   **`goals.md`**: Our single source of truth for project tracking.  Jira-style tracker with Epics → Stories → Tasks, maintain history
*   **`README.md`**: Must be kept current with project status, architecture, and usage. Use Mermaid diagrams for clarity.
*   **History Logs**: All significant documentation changes should be noted in the history log section of the respective file.

