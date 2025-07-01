# YAML Transformation Configuration Schemas

This document defines the YAML configuration schemas for the Transformer application's configuration-based transformations.

## Overview

The Transformer application supports two types of YAML configurations:

1. **Transformation Definitions** - Define atomic transformation units
2. **Pipeline Definitions** - Orchestrate multiple transformations (future feature)

## Transformation Schema

### Basic Structure

```yaml
# Required metadata
name: "transformation_identifier"           # String: Unique identifier for this transformation
description: "Human readable description"   # String: What this transformation does
version: "1.0"                             # String: Semantic version for compatibility

# Transformation steps (always plural, even for single transformations)
transformations:                           # Array: Sequential list of transformation steps
  - type: "transformation_type"            # String: Type of transformation (see Types below)
    config:                               # Object: Configuration specific to transformation type
      # ... type-specific configuration
```

### Transformation Types

#### 1. `regex_replace`
Perform regular expression find and replace operations.

```yaml
transformations:
  - type: "regex_replace"
    config:
      pattern: "regex_pattern"             # String: Regular expression pattern
      replacement: "replacement_string"    # String: Replacement text (supports \1, \2 capture groups)
      flags: ["i", "m", "x"]              # Array[String]: Optional regex flags
                                          #   i = case insensitive
                                          #   m = multiline mode  
                                          #   x = extended mode
```

#### 2. `base64_encode`
Encode text using Base64 encoding.

```yaml
transformations:
  - type: "base64_encode"
    config: {}                            # Object: No configuration required
```

#### 3. `base64_decode`
Decode Base64 encoded text.

```yaml
transformations:
  - type: "base64_decode"
    config: {}                            # Object: No configuration required
```

#### 4. `function_based` (Advanced)
Use Liquid templating with whitelisted functions for complex transformations.

```yaml
transformations:
  - type: "function_based"
    config:
      template: |                         # String: Liquid template with function calls
        {{ input 
           | split_lines 
           | map(parse_key_value)
           | map_values(base64_decode) 
           | join_lines }}
      
      allowed_functions:                  # Array[String]: Whitelist of callable functions
        - split_lines                     # Must be pre-defined in Ruby whitelist
        - map
        - parse_key_value
        - map_values
        - base64_decode
        - join_lines
```

### Complete Examples

#### Simple Transformation
```yaml
name: "iso_timestamp_normalizer"
description: "Convert ISO timestamps to human-readable format"
version: "1.0"

transformations:
  - type: "regex_replace"
    config:
      pattern: '(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})'
      replacement: '\1 \2'
```

#### Multi-Step Transformation
```yaml
name: "log_enhancer"
description: "Clean up and enhance log file readability"
version: "1.0"

transformations:
  - type: "regex_replace"
    config:
      pattern: '(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})'
      replacement: '\1 \2'
  
  - type: "regex_replace"
    config:
      pattern: '\b(ERROR|FATAL)\b'
      replacement: '🚨 \1 🚨'
```

#### Complex Function-Based Transformation
```yaml
name: "k8s_secret_decoder"
description: "Extract and decode base64 secrets from Kubernetes YAML"
version: "1.0"

transformations:
  - type: "regex_replace"
    config:
      pattern: '(?s)^.*?data:\s*\n((?:\s+[^:\s]+:\s+[^\n]+\n?)+)'
      replacement: '\1'
      
  - type: "function_based"
    config:
      template: |
        {{ input 
           | split_lines 
           | map(parse_kv_pair)
           | map_values(base64_decode) 
           | join_lines }}
      
      allowed_functions:
        - split_lines
        - map
        - parse_kv_pair
        - map_values
        - base64_decode
        - join_lines
```

## Pipeline Schema (Future)

### Basic Structure
```yaml
# Required metadata
name: "pipeline_identifier"               # String: Unique identifier for this pipeline
description: "Human readable description" # String: What this pipeline orchestrates
version: "1.0"                           # String: Semantic version

# Pipeline steps reference existing transformations
steps:                                   # Array: Sequential list of transformation references
  - transformation: "transformation_name" # String: Name of existing transformation
  - transformation: "another_transformation"
```

### Advanced Pipeline Features (Future)
```yaml
name: "complex_pipeline"
description: "Pipeline with conditional logic and parallel processing"
version: "1.0"

steps:
  - transformation: "input_validator"
  
  - conditional:                         # Object: Conditional execution
      when: "{{ previous_output | contains('kind: Secret') }}"
      then:
        - transformation: "k8s_secret_decoder"
      else:
        - transformation: "generic_yaml_formatter"
  
  - parallel:                           # Object: Parallel processing
      branches:
        validation_branch:
          - transformation: "schema_validator"
        formatting_branch:
          - transformation: "pretty_formatter"
  
  - transformation: "output_merger"
```

## File Locations

### Built-in Transformations
- **Location**: `config/transformations/`
- **Naming**: `snake_case.yml`
- **Loading**: Automatic on application startup
- **Examples**: 
  - `config/transformations/iso_timestamp_normalizer.yml`
  - `config/transformations/k8s_secret_decoder.yml`

### User-Created Transformations
- **Storage**: Database with YAML export capability
- **Validation**: Against schema before storage
- **Sharing**: Export/import via YAML files

## Validation

### Schema Validation
All YAML files must pass JSON Schema validation:
- **Required fields**: `name`, `description`, `version`, `transformations`
- **Type checking**: Strings, arrays, objects as specified
- **Value constraints**: Valid transformation types, function names in whitelist

### Semantic Validation
- **Unique names**: No duplicate transformation names in system
- **Function whitelist**: Only approved functions in `function_based` transformations
- **Circular references**: No transformation can reference itself
- **Version compatibility**: Semantic version constraints

### Validation Commands
```bash
# Validate all YAML files
rake transformer:validate

# Validate specific file
rake transformer:validate FILE=config/transformations/my_transform.yml

# List all available transformations
rake transformer:list

# Test transformation with sample input
rake transformer:test TRANSFORM=iso_timestamp_normalizer INPUT="2025-07-02T14:30:45"
```

## Security Considerations

### Function Whitelisting
- **Principle**: Only pre-approved Ruby methods can be called from YAML
- **Implementation**: Whitelist maintained in Ruby code, not YAML
- **Validation**: Function calls validated at parse time and runtime
- **Error Handling**: Clear error messages for unauthorized function calls

### Template Safety
- **Engine**: Liquid templating for safe variable interpolation
- **Sandboxing**: No arbitrary Ruby code execution
- **Input Validation**: All inputs sanitized before template processing
- **Resource Limits**: Configurable timeouts and memory limits

## Error Handling

### YAML Syntax Errors
```yaml
# Error: Invalid YAML syntax
name: "bad_transformation
description: "Missing quote above
```
**Result**: Parse error with line number and specific issue

### Schema Validation Errors
```yaml
# Error: Missing required field
name: "incomplete_transformation"
# Missing description, version, transformations
```
**Result**: Validation error listing missing required fields

### Function Security Errors
```yaml
# Error: Unauthorized function call
transformations:
  - type: "function_based"
    config:
      template: "{{ input | system('rm -rf /') }}"  # NOT ALLOWED
```
**Result**: Security error preventing execution

## Best Practices

### Naming Conventions
- **Transformation names**: `snake_case`, descriptive, unique
- **File names**: Match transformation name with `.yml` extension
- **Versions**: Use semantic versioning (major.minor.patch)

### Organization
- **Single purpose**: Each transformation should do one thing well
- **Composition**: Use multiple transformations rather than complex single ones
- **Documentation**: Clear descriptions explaining what and why

### Testing
- **Sample inputs**: Include test cases in transformation documentation
- **Edge cases**: Consider empty strings, special characters, malformed input
- **Performance**: Test with realistic data sizes for your use cases
