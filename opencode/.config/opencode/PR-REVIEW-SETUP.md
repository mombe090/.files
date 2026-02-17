# PR Review System - Complete Setup

## ✅ What Was Created

A comprehensive PR review system with proper separation of concerns following OpenCode best practices.

### File Structure

```text
opencode/.config/opencode/
├── agents/
│   ├── reviewer.md                 # Tech Lead reviewer agent (205 lines) ✨ NEW
│   └── 3.1-beast.md               # Existing beast mode agent
├── commands/
│   └── review.md                   # /review command (30 lines)
├── skills/
│   └── pr-reviewer/
│       ├── SKILL.md                # Review workflow (342 lines)
│       └── references/
│           ├── best-practices.md       # General practices (227 lines)
│           └── language-specific.md    # Language patterns (462 lines)
└── PR-REVIEWER.md                  # Documentation
```

## 🎯 Components

### 1. Reviewer Agent (`agents/reviewer.md`) ✨ NEW

**Purpose**: Tech Lead persona that uses the pr-reviewer skill

**Key Features**:

- Senior tech lead identity (10+ years experience)
- **Always loads the pr-reviewer skill** for reviews
- Constructive, educational, pragmatic style
- Mentor mindset (not gatekeeper)
- 7-dimension review focus
- Issue categorization (Critical/Major/Minor)

**Usage**:

```bash
@reviewer    # Switch to reviewer agent
/review      # Perform review
```

### 2. Review Command (`commands/review.md`)

**Purpose**: Simple wrapper to trigger reviews

**Features**:

- Loads pr-reviewer skill
- Passes user context via $ARGUMENTS
- Delegates all logic to the skill

**Usage**:

```bash
/review                                           # Basic review
/review Implement JWT auth for API (JIRA-1234)  # With context
```

### 3. PR Reviewer Skill (`skills/pr-reviewer/`)

**Purpose**: Complete review methodology and references

**Includes**:

- **SKILL.md**: 6-step review process
  1. Gather context
  2. Analyze changes
  3. Detect technologies
  4. Fetch best practices
  5. Perform deep review (7 dimensions)
  6. Generate report

- **references/best-practices.md**:
  - Code quality guidelines
  - Security best practices
  - Performance optimization
  - Architecture patterns (SOLID, design patterns)
  - Testing strategies
  - Error handling

- **references/language-specific.md**:
  - Python: Type hints, context managers, async/await
  - TypeScript: Type safety, discriminated unions
  - Go: Error handling, goroutines, channels
  - Rust: Ownership, borrowing, Result types
  - JavaScript: Async/await, destructuring
  - Java: Streams, Optional, try-with-resources
  - SQL: Query optimization, N+1 prevention

## 🔄 How It Works

```text
User: /review
    ↓
Command: Loads pr-reviewer skill
    ↓
Agent: Applies tech lead persona + skill methodology
    ↓
Process:
    1. Git analysis (diff, branches, commits)
    2. Technology detection
    3. Multi-dimensional review (7 areas)
    4. Issue categorization (Critical/Major/Minor)
    ↓
Output: local_stuff/reviews/review-<branch>-<timestamp>.md
```

## 📊 Review Dimensions

1. **Code Quality** - Readability, complexity, duplication, naming
2. **Best Practices** - Language idioms, framework patterns, error handling
3. **Security** - Input validation, auth/authz, injection vulnerabilities
4. **Performance** - Algorithm efficiency, database optimization, caching
5. **Architecture** - SOLID principles, design patterns, coupling/cohesion
6. **Language-Specific** - Idiomatic patterns for each language
7. **Documentation** - Comments, API docs, README updates

## 🎨 Review Style

The reviewer agent acts as a mentor:

- **Constructive**: Highlights strengths before issues
- **Specific**: Always includes `file.ext:line` references
- **Educational**: Explains *why* (not just *what*)
- **Actionable**: Provides solutions with code examples
- **Pragmatic**: Prioritizes by severity and impact
- **Respectful**: Assumes positive intent
- **Thorough**: Covers all 7 dimensions

## 📝 Issue Format

```markdown
**[CRITICAL]** SQL injection vulnerability

- **Location**: `auth/login.py:45`
- **Problem**: User input concatenated into SQL
- **Impact**: Authentication bypass possible
- **Solution**: Use parameterized queries
  ```python
  # Fix:
  cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
  ```

## 🚀 Usage Examples

### Basic Review

```bash
/review
```

### With Story Context

```bash
/review Implement JWT authentication (JIRA-1234)
```

### Using Reviewer Agent

```bash
@reviewer
/review Feature adds user permissions system
```

## 📦 Output

Reviews saved to: `local_stuff/reviews/review-<branch>-<timestamp>.md`

**Report includes**:

- Executive Summary
- Story Context
- Changes Overview (files + commits)
- Detailed Analysis (Strengths + Issues)
- Code Quality Metrics (scores /10)
- Best Practices Compliance
- Security Assessment
- Performance Considerations
- Architecture Review
- Recommendations (Must Fix / Should Fix / Nice to Have)
- Overall Assessment (APPROVE / REQUEST CHANGES / NEEDS MAJOR REVISION)

## 🔧 Customization

### Agent Personality

Edit `agents/reviewer.md`:

- Change tone and communication style
- Adjust review focus areas
- Modify persona identity

### Review Process

Edit `skills/pr-reviewer/SKILL.md`:

- Change review steps
- Update report template
- Modify workflow logic

### Best Practices

Edit `skills/pr-reviewer/references/*.md`:

- Add new language patterns
- Update security guidelines
- Expand performance tips

### Command Behavior

Edit `commands/review.md`:

- Change trigger conditions
- Modify argument handling

## 🌐 MCP Server Integration

The reviewer can query MCP servers (if available) for:

- Latest language standards
- Framework best practices
- Security vulnerability databases
- Performance optimization techniques

Falls back to built-in references if unavailable.

## ✅ Benefits

### Separation of Concerns

- **Agent**: Persona and style
- **Command**: Trigger and context
- **Skill**: Methodology and knowledge
- **References**: Deep domain knowledge

### Maintainability

- Update persona → Edit agent
- Update workflow → Edit skill
- Update practices → Edit references
- No duplication across files

### Reusability

- Skill can be used by any agent
- References can be loaded independently
- Command can invoke different agents

### Token Efficiency

- Progressive disclosure pattern
- References loaded only when needed
- Skill loaded only during reviews

## 🎉 Ready to Use

Everything is set up and ready:

1. ✅ Reviewer agent created
2. ✅ Command simplified to use skill
3. ✅ Skill contains full methodology
4. ✅ References include 7+ languages
5. ✅ Documentation updated
6. ✅ Follows OpenCode best practices

Start reviewing:

```bash
/review
```

Or use the dedicated reviewer agent:

```bash
@reviewer
/review
```
