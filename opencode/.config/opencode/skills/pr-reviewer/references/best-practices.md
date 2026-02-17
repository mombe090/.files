# Best Practices Reference

General software engineering best practices to check during code reviews.

## Code Quality

### Readability

- **Clear naming**: Variable and function names should clearly express intent
- **Consistent formatting**: Follow language conventions (PEP 8, Standard JS, etc.)
- **Appropriate abstraction**: Functions should do one thing well
- **Self-documenting code**: Code should be understandable without extensive comments

### Complexity Management

- **Cyclomatic complexity**: Aim for functions with complexity < 10
- **Function length**: Keep functions under 50 lines when possible
- **Class size**: Single responsibility - a class should have one reason to change
- **Nesting depth**: Avoid more than 3 levels of nesting

### DRY Principle (Don't Repeat Yourself)

- Extract repeated code into functions
- Use inheritance/composition for shared behavior
- Consider design patterns for common solutions
- Balance DRY with readability - don't over-abstract

## Security Best Practices

### Input Validation

- **Sanitize all user input**: Never trust external data
- **Use allowlists over denylists**: Define what's acceptable, not what's not
- **Validate on server side**: Client-side validation is for UX only
- **Type checking**: Ensure data types match expectations

### Authentication & Authorization

- **Never store passwords in plain text**: Use bcrypt, Argon2, or similar
- **Use established auth libraries**: Don't roll your own crypto
- **Principle of least privilege**: Grant minimum necessary permissions
- **Session management**: Proper timeout, secure tokens, CSRF protection

### Data Protection

- **Sensitive data in logs**: Never log passwords, tokens, or PII
- **Environment variables**: Store secrets in env vars, not code
- **SQL injection**: Use parameterized queries, never string concatenation
- **XSS prevention**: Escape output, use Content Security Policy

### Dependency Security

- **Keep dependencies updated**: Use tools like Dependabot, Snyk
- **Audit dependencies**: Check for known vulnerabilities
- **Minimize dependencies**: Fewer dependencies = smaller attack surface
- **Verify package integrity**: Use lock files, check checksums

## Performance

### Algorithm Efficiency

- **Big O notation**: Be aware of time/space complexity
  - O(1) > O(log n) > O(n) > O(n log n) > O(n²) > O(2ⁿ)
- **Avoid nested loops**: Look for ways to reduce complexity
- **Use appropriate data structures**: HashMap for lookups, Set for uniqueness

### Database Performance

- **N+1 query problem**: Load related data in a single query with JOINs
- **Index frequently queried columns**: WHERE, JOIN, ORDER BY columns
- **Avoid SELECT \***: Only fetch needed columns
- **Connection pooling**: Reuse database connections
- **Pagination**: Don't load all records at once

### Caching

- **Cache expensive operations**: Database queries, API calls, computations
- **Cache invalidation**: Have a clear strategy for updating cached data
- **Appropriate cache duration**: Balance freshness with performance
- **Use caching layers**: Browser cache, CDN, application cache, database cache

### Resource Management

- **Memory leaks**: Ensure resources are freed (close files, clear listeners)
- **Connection limits**: Use connection pooling, set timeouts
- **Lazy loading**: Load data only when needed
- **Async operations**: Don't block the main thread

## Architecture

### SOLID Principles

1. **Single Responsibility**: A class should have one reason to change
2. **Open/Closed**: Open for extension, closed for modification
3. **Liskov Substitution**: Subtypes must be substitutable for base types
4. **Interface Segregation**: Many specific interfaces over one general interface
5. **Dependency Inversion**: Depend on abstractions, not concretions

### Design Patterns

**Creational**:

- Factory: Create objects without specifying exact class
- Singleton: Ensure only one instance exists (use sparingly)
- Builder: Construct complex objects step by step

**Structural**:

- Adapter: Make incompatible interfaces compatible
- Decorator: Add behavior without modifying class
- Facade: Simplify complex subsystem

**Behavioral**:

- Observer: Notify multiple objects of state changes
- Strategy: Define family of algorithms, make them interchangeable
- Command: Encapsulate requests as objects

### Separation of Concerns

- **Layered architecture**: Presentation, business logic, data access
- **MVC/MVVM**: Separate model, view, controller/viewmodel
- **Microservices**: Independent, deployable services
- **API boundaries**: Clear contracts between components

### Coupling and Cohesion

- **Low coupling**: Components should be independent
- **High cohesion**: Related functionality should be together
- **Dependency injection**: Provide dependencies rather than create them
- **Interface-based design**: Program to interfaces, not implementations

## Testing

### Test Coverage

- **Unit tests**: Test individual functions/methods in isolation
- **Integration tests**: Test components working together
- **E2E tests**: Test complete user workflows
- **Aim for 80%+ coverage**: But focus on critical paths

### Test Quality

- **Test behavior, not implementation**: Tests should survive refactoring
- **One assertion per test**: Makes failures clear
- **Arrange-Act-Assert**: Clear test structure
- **Meaningful test names**: Describe what's being tested and expected outcome

### Test-Driven Development (TDD)

- **Red-Green-Refactor**: Write failing test, make it pass, improve code
- **Benefits**: Better design, less debugging, confidence in changes
- **When to use**: Complex logic, bug fixes, new features

### Edge Cases

- **Null/undefined values**: How does code handle missing data?
- **Empty collections**: Arrays, strings, objects with no elements
- **Boundary conditions**: Min/max values, off-by-one errors
- **Concurrent access**: Race conditions, deadlocks

## Documentation

### Code Comments

- **Explain WHY, not WHAT**: Code shows what, comments explain why
- **Complex algorithms**: Explain the approach and reasoning
- **Workarounds**: Document why a hack was necessary
- **TODOs**: Use TODO comments for planned improvements

### API Documentation

- **Function signatures**: Clear parameter types and return values
- **Usage examples**: Show common use cases
- **Error conditions**: Document what exceptions/errors can occur
- **Side effects**: Document any state changes or I/O operations

### README Files

- **Project overview**: What does this project do?
- **Installation**: How to set up the development environment
- **Usage**: How to run/use the application
- **Configuration**: Environment variables, config files
- **Contributing**: How to contribute to the project

## Error Handling

### Exception Handling

- **Catch specific exceptions**: Don't catch generic Exception/Error
- **Fail fast**: Detect and report errors immediately
- **Meaningful error messages**: Help users/developers understand the problem
- **Clean up resources**: Use finally blocks or context managers

### Logging

- **Appropriate log levels**: DEBUG, INFO, WARN, ERROR, FATAL
- **Structured logging**: Use JSON or key-value pairs for parsing
- **Context in logs**: Include request IDs, user IDs, timestamps
- **Don't log sensitive data**: Passwords, tokens, PII

### Graceful Degradation

- **Fallback mechanisms**: Provide alternatives when features fail
- **Circuit breakers**: Stop calling failing services
- **Retry logic**: With exponential backoff and jitter
- **User-friendly errors**: Don't expose stack traces to users

## Code Review Checklist

### Before Submitting

- [ ] Code follows style guide
- [ ] All tests pass
- [ ] New tests added for new functionality
- [ ] Documentation updated
- [ ] No commented-out code
- [ ] No debug statements left in code
- [ ] Dependencies updated and audited

### While Reviewing

- [ ] Code is understandable
- [ ] Logic is correct
- [ ] Edge cases are handled
- [ ] Security vulnerabilities addressed
- [ ] Performance implications considered
- [ ] Error handling is appropriate
- [ ] Tests are comprehensive
- [ ] Documentation is clear
