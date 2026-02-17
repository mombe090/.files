# Language-Specific Best Practices

Quick reference for language-specific patterns and idioms to check during code reviews.

## Python

### Type Hints (Python 3.5+)

```python
# ✅ Good - Clear type annotations
def process_user(user_id: int, name: str) -> dict[str, Any]:
    return {"id": user_id, "name": name}

# ❌ Bad - No type hints
def process_user(user_id, name):
    return {"id": user_id, "name": name}
```

### Context Managers

```python
# ✅ Good - Proper resource management
with open("file.txt") as f:
    content = f.read()

# ❌ Bad - Manual close, error-prone
f = open("file.txt")
content = f.read()
f.close()
```

### List Comprehensions

```python
# ✅ Good - Pythonic, readable
squares = [x**2 for x in range(10) if x % 2 == 0]

# ❌ Bad - Verbose
squares = []
for x in range(10):
    if x % 2 == 0:
        squares.append(x**2)
```

### Async/Await

```python
# ✅ Good - Proper async usage
async def fetch_data(url: str) -> dict:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.json()

# ❌ Bad - Blocking in async function
async def fetch_data(url: str) -> dict:
    return requests.get(url).json()  # Blocks event loop!
```

## TypeScript

### Type Safety

```typescript
// ✅ Good - Strict typing
interface User {
  id: number;
  name: string;
  email: string;
}

function getUser(id: number): User {
  // Implementation
}

// ❌ Bad - Using 'any'
function getUser(id: any): any {
  // Implementation
}
```

### Discriminated Unions

```typescript
// ✅ Good - Type-safe state handling
type Result<T> =
  | { success: true; data: T }
  | { success: false; error: string };

function handleResult<T>(result: Result<T>) {
  if (result.success) {
    console.log(result.data); // TypeScript knows 'data' exists
  } else {
    console.error(result.error); // TypeScript knows 'error' exists
  }
}

// ❌ Bad - Loose typing
type Result = {
  success: boolean;
  data?: any;
  error?: string;
};
```

### Null Safety

```typescript
// ✅ Good - Explicit null handling
function getName(user: User | null): string {
  return user?.name ?? "Unknown";
}

// ❌ Bad - No null check
function getName(user: User): string {
  return user.name; // May crash if user is null
}
```

## Go

### Error Handling

```go
// ✅ Good - Explicit error handling
func readFile(path string) ([]byte, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("failed to read %s: %w", path, err)
    }
    return data, nil
}

// ❌ Bad - Ignored errors
func readFile(path string) []byte {
    data, _ := os.ReadFile(path) // Don't ignore errors!
    return data
}
```

### Goroutines and Channels

```go
// ✅ Good - Proper synchronization
func processItems(items []string) []Result {
    results := make(chan Result, len(items))
    var wg sync.WaitGroup

    for _, item := range items {
        wg.Add(1)
        go func(i string) {
            defer wg.Done()
            results <- process(i)
        }(item) // Capture loop variable
    }

    go func() {
        wg.Wait()
        close(results)
    }()

    return collectResults(results)
}

// ❌ Bad - Race condition
func processItems(items []string) []Result {
    results := []Result{}
    for _, item := range items {
        go func() {
            results = append(results, process(item)) // Race!
        }()
    }
    return results
}
```

### Defer

```go
// ✅ Good - Resource cleanup with defer
func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return err
    }
    defer f.Close() // Guaranteed cleanup

    // Process file
    return nil
}
```

## Rust

### Ownership and Borrowing

```rust
// ✅ Good - Clear ownership
fn process_data(data: Vec<String>) -> Vec<String> {
    data.into_iter()
        .map(|s| s.to_uppercase())
        .collect()
}

// Alternative: Borrow if original needed
fn process_data(data: &[String]) -> Vec<String> {
    data.iter()
        .map(|s| s.to_uppercase())
        .collect()
}

// ❌ Bad - Unnecessary cloning
fn process_data(data: &Vec<String>) -> Vec<String> {
    data.clone() // Expensive!
        .into_iter()
        .map(|s| s.to_uppercase())
        .collect()
}
```

### Error Handling with Result

```rust
// ✅ Good - Idiomatic error handling
fn read_config(path: &str) -> Result<Config, ConfigError> {
    let content = fs::read_to_string(path)
        .map_err(|e| ConfigError::IoError(e))?;

    serde_json::from_str(&content)
        .map_err(|e| ConfigError::ParseError(e))
}

// ❌ Bad - Using unwrap in library code
fn read_config(path: &str) -> Config {
    let content = fs::read_to_string(path).unwrap(); // Will panic!
    serde_json::from_str(&content).unwrap()
}
```

### Pattern Matching

```rust
// ✅ Good - Exhaustive pattern matching
match result {
    Ok(value) => process(value),
    Err(Error::NotFound) => handle_not_found(),
    Err(Error::PermissionDenied) => handle_permission(),
    Err(e) => handle_other_error(e),
}

// ❌ Bad - Using if-let when match is clearer
if let Ok(value) = result {
    process(value);
}
// Other errors silently ignored
```

## JavaScript

### Async/Await vs Promises

```javascript
// ✅ Good - Clean async/await
async function fetchUserData(userId) {
  try {
    const user = await fetchUser(userId);
    const posts = await fetchPosts(user.id);
    return { user, posts };
  } catch (error) {
    console.error('Failed to fetch user data:', error);
    throw error;
  }
}

// ❌ Bad - Promise chain when async/await is clearer
function fetchUserData(userId) {
  return fetchUser(userId)
    .then(user => fetchPosts(user.id)
      .then(posts => ({ user, posts })))
    .catch(error => {
      console.error('Failed to fetch user data:', error);
      throw error;
    });
}
```

### Destructuring

```javascript
// ✅ Good - Clean destructuring
const { name, email, age = 18 } = user;

// ❌ Bad - Manual property access
const name = user.name;
const email = user.email;
const age = user.age || 18;
```

### Arrow Functions

```javascript
// ✅ Good - Appropriate use
const double = x => x * 2;
items.map(item => item.id);

// ❌ Bad - Unnecessary arrow function binding issues
class Component {
  handleClick = () => {
    // Arrow function preserves 'this', but creates new function per instance
  }
}
// Better: Use method and bind in constructor if needed
```

## Java

### Streams API

```java
// ✅ Good - Functional style with streams
List<String> names = users.stream()
    .filter(user -> user.isActive())
    .map(User::getName)
    .collect(Collectors.toList());

// ❌ Bad - Imperative style when streams are better
List<String> names = new ArrayList<>();
for (User user : users) {
    if (user.isActive()) {
        names.add(user.getName());
    }
}
```

### Optional

```java
// ✅ Good - Proper Optional usage
public Optional<User> findUser(String id) {
    return userRepository.findById(id);
}

user.flatMap(User::getAddress)
    .map(Address::getCity)
    .orElse("Unknown");

// ❌ Bad - Returning null
public User findUser(String id) {
    return userRepository.findById(id); // May return null
}
```

### Try-with-resources

```java
// ✅ Good - Automatic resource management
try (BufferedReader reader = new BufferedReader(new FileReader("file.txt"))) {
    return reader.readLine();
} catch (IOException e) {
    throw new RuntimeException(e);
}

// ❌ Bad - Manual resource cleanup
BufferedReader reader = null;
try {
    reader = new BufferedReader(new FileReader("file.txt"));
    return reader.readLine();
} finally {
    if (reader != null) {
        reader.close();
    }
}
```

## SQL

### Query Optimization

```sql
-- ✅ Good - Indexed column in WHERE
SELECT * FROM users WHERE user_id = 123;

-- ❌ Bad - Function on indexed column prevents index use
SELECT * FROM users WHERE UPPER(email) = 'USER@EXAMPLE.COM';

-- ✅ Better - Store normalized data or use functional index
SELECT * FROM users WHERE email = 'user@example.com';
```

### N+1 Query Problem

```sql
-- ❌ Bad - N+1 queries (one for users, then one per user for posts)
SELECT * FROM users;
-- Then for each user:
SELECT * FROM posts WHERE user_id = ?;

-- ✅ Good - Single JOIN query
SELECT users.*, posts.*
FROM users
LEFT JOIN posts ON users.id = posts.user_id;
```

## Common Anti-Patterns (All Languages)

### Magic Numbers

```javascript
// ❌ Bad
if (user.status === 3) { // What does 3 mean?
  // ...
}

// ✅ Good
const USER_STATUS_ACTIVE = 3;
if (user.status === USER_STATUS_ACTIVE) {
  // ...
}
```

### Deep Nesting

```python
# ❌ Bad - Arrow anti-pattern
def process(data):
    if data:
        if data.valid:
            if data.user:
                if data.user.active:
                    return process_active_user(data.user)
    return None

# ✅ Good - Early returns
def process(data):
    if not data or not data.valid:
        return None

    if not data.user or not data.user.active:
        return None

    return process_active_user(data.user)
```

### God Objects

```java
// ❌ Bad - Class doing too much
class UserManager {
    void createUser() { }
    void deleteUser() { }
    void sendEmail() { }
    void logActivity() { }
    void generateReport() { }
    void processPayment() { }
}

// ✅ Good - Single responsibility
class UserService { }
class EmailService { }
class ActivityLogger { }
class ReportGenerator { }
class PaymentProcessor { }
```
