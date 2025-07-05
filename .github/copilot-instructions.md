# GitHub Copilot Instructions

## Project Context
- **Tech Stack**: Ruby on Rails 8.0.2 + React (JS/TS), modern asset pipeline
- **Development Approach**: BDD with RSpec/Jest, DRY functional code, library usage
- **Documentation**: Maintain README + goals.md (project tracker), include Mermaid diagrams

## Workflow Pattern
1. Update `goals.md` with intended action
2. Write tests (RSpec/Jest) for expected functionality  
3. Implement well-factored code using appropriate libraries
4. **Run `rake commit:review` to validate changes align with goals and check code quality**
5. Update `goals.md` with outcome
6. Update README/documentation
7. Update history log in relevant .md files with date and changes
8. **Run `rake commit:message` to generate conventional commit message**
9. Write a suitable commit message summarizing the story completion

## Code Quality Standards
- **Rails**: Expert-level modern practices, leverage Rails 8 features
- **React**: Provide guidance for JS/TS, evaluate design decisions critically
- **Testing**: BDD approach, comprehensive test coverage
- **Architecture**: DRY, functional, well-factored with common libraries

## Rails 8 Zeitwerk Autoloading Rules
### **Critical**: File structure MUST match constant names exactly

#### File Naming Conventions
- **snake_case** file names → **CamelCase** class names
- `user_profile.rb` → `class UserProfile`
- `yaml_transformation_loader.rb` → `class YamlTransformationLoader`

#### Directory Structure Rules
- **Nested modules** require matching directory structure:
  - `app/models/yaml_transformations/base.rb` → `module YamlTransformations; class Base`
  - `app/models/transformations/regex_replace.rb` → `module Transformations; class RegexReplace`

#### Common Autoloading Mistakes to Avoid
- ❌ `yaml_transformation_classes.rb` containing multiple unrelated classes
- ❌ File names not matching class names (`base64_transformation.rb` for `Base64Encode`)
- ❌ Missing namespace modules (`YamlTransformations::Base` without `module YamlTransformations`)
- ❌ One file containing multiple top-level classes

#### Best Practices
- ✅ **One class per file** with matching names
- ✅ **Module namespaces** in separate files or parent directories
- ✅ **Test autoloading** with `Rails.autoloaders.main.dirs` in console
- ✅ **Restart Rails** after major structural changes

#### Debugging Autoloading Issues
```ruby
# Check autoloader directories
Rails.autoloaders.main.dirs

# Test constant loading
YourClass # Should load without require

# Check zeitwerk expectations
Rails.autoloaders.main.eager_load_all
```

## Documentation Requirements
- **goals.md**: Jira-style tracker with Epics → Stories → Tasks, maintain history
- **README.md**: Clear structure, current state, Mermaid diagrams for flows
- **History logs**: Update with date and key changes in all relevant .md files
- Keep all docs synchronized and up-to-date

## Collaboration Style
- Provide expert guidance and critical evaluation
- Don't assume human suggestions are correct (especially React)
- Leverage extensive Rails experience, strengthen React knowledge
- Focus on modern best practices and maintainable architecture
