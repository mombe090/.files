# PR Reviewer Skill & Command

Comprehensive tech lead-level pull request code review system for OpenCode.

## Quick Start

```bash
# In any git repository with changes
/review

# With story/ticket context
/review Implement JWT authentication for API endpoints (JIRA-1234)
```

## Architecture

The PR reviewer system follows OpenCode's best practices with clear separation of concerns:

### Components

- **Agent**: `opencode/.config/opencode/agents/reviewer.md` (~205 lines)
  - Tech Lead persona with review instructions
  - **Always loads and uses the pr-reviewer skill**
  - Defines review style and communication approach

- **Command**: `opencode/.config/opencode/commands/review.md` (~30 lines)
  - Simple wrapper that loads the pr-reviewer skill
  - Passes user context as $ARGUMENTS to the skill
  - Triggers the general agent (which can use the reviewer agent)

- **Skill**: `opencode/.config/opencode/skills/pr-reviewer/` (~1000 lines total)
  - `SKILL.md` - Complete review workflow and methodology (342 lines)
  - `references/best-practices.md` - General best practices (227 lines)
  - `references/language-specific.md` - Language patterns (462 lines)

- **Reviews Output**: `local_stuff/reviews/review-<branch>-<timestamp>.md`

### Flow

```text
User runs /review
    ↓
Command loads pr-reviewer skill
    ↓
Agent applies skill methodology
    ↓
Review report generated
    ↓
Saved to local_stuff/reviews/
```

## Features

### Multi-Dimensional Analysis

1. **Code Quality** - Readability, complexity, duplication, naming conventions
2. **Best Practices** - Language idioms, framework patterns, error handling
3. **Security** - Input validation, auth/authz, injection vulnerabilities, dependency security
4. **Performance** - Algorithm efficiency, database optimization, caching, resource management
5. **Architecture** - SOLID principles, design patterns, coupling/cohesion, scalability
6. **Language-Specific** - Detailed patterns for Python, TypeScript, Go, Rust, Java, JavaScript, SQL
7. **Documentation** - Code comments, API docs, README updates

### Review Output

Issues categorized by severity:

- **[CRITICAL]** - Security issues, bugs, data loss (MUST FIX before merge)
- **[MAJOR]** - Quality, performance, maintainability issues (SHOULD FIX)
- **[MINOR]** - Nice-to-have improvements, style issues

Each issue includes:

- **Location**: `file.ext:line`
- **Problem**: What's wrong
- **Impact**: Why it matters
- **Solution**: How to fix

### Review Report Structure

```markdown
# Pull Request Review: {Branch Name}

## Executive Summary
## Story Context
## Changes Overview
## Detailed Analysis
  - ✅ Strengths
  - ⚠️ Issues Found (Critical/Major/Minor)
## Code Quality Metrics
## Best Practices Compliance
## Security Assessment
## Performance Considerations
## Architecture Review
## Recommendations
## Overall Assessment (APPROVE | REQUEST CHANGES | NEEDS MAJOR REVISION)
## Appendix: Technologies Detected
```

## How It Works

1. **Detects current branch** and base branch (main/master)
2. **Analyzes git diff** between branches
3. **Identifies technologies** used (languages, frameworks, tools)
4. **Queries MCP servers** (if available) for latest best practices
5. **Reviews code** across 7 dimensions
6. **Generates report** with specific file:line references
7. **Saves to** `local_stuff/reviews/` with timestamp

## Language Support

### Python

- Type hints, context managers, list comprehensions
- Async/await patterns
- Generator usage
- Pythonic idioms

### TypeScript

- Type safety and generics
- Discriminated unions
- Null safety with optional chaining
- Proper interface design

### Go

- Error handling patterns
- Goroutines and channels
- Defer usage
- Interface design

### Rust

- Ownership and borrowing
- Result type error handling
- Pattern matching
- Lifetime management

### JavaScript

- Async/await vs Promises
- Destructuring patterns
- Arrow function usage
- Modern ES6+ features

### Java

- Streams API
- Optional usage
- Try-with-resources
- Dependency injection

### SQL

- Query optimization
- N+1 query prevention
- Index usage
- Join optimization

## References

The skill includes comprehensive references:

- `references/best-practices.md` - General software engineering practices
  - SOLID principles
  - Design patterns
  - Security best practices
  - Performance optimization
  - Testing strategies
  - Error handling and logging

- `references/language-specific.md` - Language-specific patterns
  - Code examples for each language
  - Common anti-patterns
  - Idiomatic usage
  - Framework-specific patterns

## Example Output

```bash
✅ PR Review Complete

📄 Review saved to: local_stuff/reviews/review-feature-auth-20260217-143022.md

📊 Assessment: REQUEST CHANGES

Issues Found:
- Critical: 2
- Major: 5
- Minor: 8

Key concerns:
- SQL injection vulnerability in user authentication
- Missing input validation on API endpoints
- Performance issues with N+1 queries

See the full review report for detailed analysis and recommendations.
```

## Review Style

The AI reviewer acts as a **tech lead** with these characteristics:

- **Constructive**: Balances criticism with recognition of good work
- **Specific**: Always references file names and line numbers
- **Educational**: Explains *why* something is an issue, not just *what*
- **Actionable**: Provides clear solutions, not just problems
- **Pragmatic**: Prioritizes issues by severity and impact
- **Respectful**: Assumes positive intent, acknowledges complexity
- **Thorough**: Covers all review dimensions

## Error Handling

- Not in git repository → Error message with instructions
- No changes detected → Error message to check branch
- Directory creation fails → Permission error with guidance

## Installation

The command and skill are already set up in your dotfiles:

```bash
# Command will be available after OpenCode loads
/review

# First run will create local_stuff/reviews/ directory automatically
```

## Customization

### Using the Reviewer Agent

The `reviewer.md` agent is a specialized tech lead persona that always uses the pr-reviewer skill. You can invoke it directly:

```bash
# Switch to reviewer agent mode
@reviewer

# Then use it for reviews
/review
```

The reviewer agent:

- Has a tech lead identity (10+ years experience)
- Always loads the pr-reviewer skill automatically
- Follows the skill's methodology precisely
- Uses constructive, educational review style
- Focuses on mentoring, not gatekeeping

### Modifying Components

To modify the review process:

1. **Agent personality**: Edit `opencode/.config/opencode/agents/reviewer.md`
   - Change tone, style, communication approach
   - Add/remove focus areas

2. **Review workflow**: Edit `opencode/.config/opencode/skills/pr-reviewer/SKILL.md`
   - Modify review steps and process
   - Update report template structure

3. **Best practices**: Edit `opencode/.config/opencode/skills/pr-reviewer/references/*.md`
   - Add language-specific patterns
   - Update security/performance guidelines

4. **Command behavior**: Edit `opencode/.config/opencode/commands/review.md`
   - Change how the command is triggered
   - Modify argument handling

## MCP Server Integration

The reviewer can query MCP servers for latest standards if available:

- Language-specific best practices
- Framework conventions
- Security vulnerability databases
- Performance optimization techniques

Falls back to built-in references if MCP servers aren't available.
