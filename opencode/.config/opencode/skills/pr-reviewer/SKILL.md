---
name: pr-reviewer
description: Perform comprehensive tech lead-level pull request reviews by analyzing git diff between current branch and main/master branch. Use when user requests PR review with commands like "/review", "review this PR", "code review", or similar. Generates detailed reviews covering code quality, best practices, security, performance, architecture, and language-specific patterns. Saves reviews to local_stuff/reviews/ directory with timestamps. Optionally accepts story context for domain-specific analysis.
---

# PR Reviewer Skill

Conduct thorough, tech lead-level pull request reviews by analyzing code changes between the current branch and the base branch (main/master).

## Review Process

The PR review involves these steps:

1. **Gather context** - Identify current branch, base branch, and optional user story
2. **Analyze changes** - Run git diff to get all changes between branches
3. **Detect technologies** - Identify programming languages, frameworks, and tools used
4. **Fetch best practices** - Query MCP servers or documentation for latest standards
5. **Perform deep review** - Analyze code across multiple dimensions
6. **Generate report** - Write comprehensive review to local_stuff/reviews/ directory

## Step 1: Gather Context

### Branch Detection

```bash
# Get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Detect base branch (prefer main, fallback to master)
if git show-ref --verify --quiet refs/heads/main; then
    base_branch="main"
elif git show-ref --verify --quiet refs/remotes/origin/main; then
    base_branch="origin/main"
elif git show-ref --verify --quiet refs/heads/master; then
    base_branch="master"
else
    base_branch="origin/master"
fi
```

### User Story (Optional)

If the user provides a story or context (e.g., Jira ticket, feature description), capture it for domain-specific analysis.

## Step 2: Analyze Changes

### Get Unified Diff

```bash
# Get full diff with context
git diff $base_branch...$current_branch > /tmp/pr_diff.txt

# Get changed files list
git diff --name-status $base_branch...$current_branch > /tmp/changed_files.txt

# Get commit messages for context
git log $base_branch...$current_branch --oneline > /tmp/commits.txt
```

### Get Statistics

```bash
# Get change statistics
git diff --stat $base_branch...$current_branch
```

## Step 3: Detect Technologies

Identify languages, frameworks, and tools from:

- File extensions (`.ts`, `.py`, `.go`, `.rs`, `.java`, etc.)
- Configuration files (`package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, etc.)
- Framework indicators (React, Vue, Django, Flask, Express, etc.)
- Build tools (webpack, vite, cargo, maven, gradle, etc.)

## Step 4: Fetch Best Practices

**If MCP servers are available**, query them for latest standards:

- Language-specific best practices
- Framework conventions and patterns
- Security vulnerabilities and fixes
- Performance optimization techniques

**Fallback**: Use built-in knowledge and reference best practices documented in `references/best-practices.md`.

## Step 5: Perform Deep Review

Analyze the code changes across these dimensions:

### 1. Code Quality

- **Readability**: Clear variable names, proper formatting, logical structure
- **Complexity**: Cyclomatic complexity, nesting depth, function length
- **Duplication**: Repeated code patterns, opportunities for abstraction
- **Naming**: Consistent conventions, descriptive identifiers
- **Comments**: Necessary documentation, removal of obsolete comments

### 2. Best Practices

- **Language idioms**: Pythonic code, Go conventions, Rust patterns, etc.
- **Framework patterns**: React hooks best practices, Django ORM optimization, etc.
- **Code organization**: Proper separation of concerns, module structure
- **Error handling**: Appropriate use of exceptions, error types, recovery strategies
- **Testing**: Test coverage, test quality, edge cases

### 3. Security

- **Input validation**: Sanitization, type checking, bounds validation
- **Authentication/Authorization**: Proper permission checks, token handling
- **Data exposure**: Sensitive data in logs, API responses, error messages
- **Injection vulnerabilities**: SQL injection, XSS, command injection
- **Dependency security**: Known vulnerabilities in dependencies

### 4. Performance

- **Algorithm efficiency**: Time/space complexity analysis
- **Database queries**: N+1 problems, missing indexes, inefficient joins
- **Caching**: Appropriate use of memoization, caching strategies
- **Resource management**: Memory leaks, connection pooling, file handles
- **Lazy loading**: Deferred execution, pagination

### 5. Architecture

- **Design patterns**: Appropriate use of patterns, anti-patterns to avoid
- **SOLID principles**: Single responsibility, open/closed, dependency inversion
- **Coupling**: Component dependencies, interface design
- **Scalability**: Horizontal/vertical scaling considerations
- **Maintainability**: Future extensibility, technical debt

### 6. Language-Specific

Refer to `references/language-specific.md` for detailed patterns per language:

- **Python**: Type hints, context managers, generators, async/await
- **TypeScript**: Type safety, generics, discriminated unions
- **Go**: Error handling, goroutines, channels, defer
- **Rust**: Ownership, borrowing, lifetimes, traits
- **Java**: Streams, optionals, dependency injection
- **JavaScript**: Promises, async/await, closures

### 7. Documentation

- **Code comments**: Explain "why" not "what"
- **API documentation**: Clear function/method signatures and examples
- **README updates**: Reflect new features or changes
- **Migration guides**: Breaking changes documented

## Step 6: Generate Report

### Output Location

Create review in: `local_stuff/reviews/review-{branch}-{timestamp}.md`

- If `local_stuff/` doesn't exist, create it
- If `local_stuff/reviews/` doesn't exist, create it
- Use ISO 8601 timestamp format: `YYYYMMDD-HHMMSS`

### Report Template

Use this structure for the review report:

```markdown
# Pull Request Review: {Branch Name}

**Reviewer**: AI Tech Lead (Claude)
**Date**: {ISO Date}
**Base Branch**: {main/master}
**Current Branch**: {branch-name}
**Total Changes**: {files changed, insertions, deletions}

---

## Executive Summary

{2-3 paragraph overview of the PR: purpose, scope, overall quality assessment}

---

## Story Context

{If provided by user, include the story/ticket information here}

---

## Changes Overview

### Files Modified

{List of changed files with change type: Added, Modified, Deleted, Renamed}

### Commit History

{List of commits in this branch}

---

## Detailed Analysis

### ✅ Strengths

{Highlight what was done well - be specific with file references and line numbers}

- {Strength 1 with file:line reference}
- {Strength 2 with file:line reference}

### ⚠️ Issues Found

#### Critical

{Issues that must be fixed before merge - security, bugs, data loss}

- **[CRITICAL]** {Issue description}
  - **Location**: `file.ext:line`
  - **Problem**: {What's wrong}
  - **Impact**: {Why it matters}
  - **Solution**: {How to fix}

#### Major

{Significant issues affecting quality, performance, or maintainability}

- **[MAJOR]** {Issue description}
  - **Location**: `file.ext:line`
  - **Problem**: {What's wrong}
  - **Impact**: {Why it matters}
  - **Solution**: {How to fix}

#### Minor

{Nice-to-have improvements, style issues, minor optimizations}

- **[MINOR]** {Issue description}
  - **Location**: `file.ext:line`
  - **Suggestion**: {Improvement idea}

---

## Code Quality Metrics

- **Readability**: {Score/10 with justification}
- **Complexity**: {Score/10 with justification}
- **Test Coverage**: {Estimated coverage or comment on testing}
- **Documentation**: {Score/10 with justification}

---

## Best Practices Compliance

### {Language/Framework Name}

- ✅ {Practice followed correctly}
- ❌ {Practice violated - reference specific location}
- ⚠️ {Practice partially followed - needs improvement}

---

## Security Assessment

{List security concerns or confirm none found}

- {Security issue or ✅ No security concerns identified}

---

## Performance Considerations

{List performance impacts or confirm none}

- {Performance concern or ✅ No performance issues identified}

---

## Architecture Review

{Comment on architectural decisions, patterns used, design quality}

---

## Recommendations

### Must Fix Before Merge

1. {Critical item with action}
2. {Critical item with action}

### Should Fix Soon

1. {Important improvement}
2. {Important improvement}

### Nice to Have

1. {Optional enhancement}
2. {Optional enhancement}

---

## Overall Assessment

**Recommendation**: {APPROVE | REQUEST CHANGES | NEEDS MAJOR REVISION}

{Final paragraph with overall assessment and next steps}

---

## Appendix: Technologies Detected

- **Languages**: {List}
- **Frameworks**: {List}
- **Tools**: {List}
- **Dependencies Modified**: {List if applicable}
```

## Review Style Guidelines

Write reviews as a **tech lead** with these characteristics:

- **Constructive**: Balance criticism with recognition of good work
- **Specific**: Always reference file names and line numbers
- **Educational**: Explain *why* something is an issue, not just *what*
- **Actionable**: Provide clear solutions, not just problems
- **Pragmatic**: Prioritize issues by severity and impact
- **Respectful**: Assume positive intent, acknowledge complexity
- **Thorough**: Cover all dimensions (quality, security, performance, architecture)

## Example Usage

**User**: `/review`

**Expected behavior**:

1. Detect current branch and base branch
2. Run `git diff` to get changes
3. Analyze all changes across review dimensions
4. Generate comprehensive review report
5. Save to `local_stuff/reviews/review-{branch}-{timestamp}.md`
6. Inform user of review completion and file location

**User**: `/review` + provides story context

**Expected behavior**:
Same as above, but include story context in the "Story Context" section for domain-specific analysis.
