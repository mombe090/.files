---
name: taskfile-creator
description: Create and manage Taskfiles (task automation files) using best practices from taskfile.dev. Use when the user asks to create a Taskfile, add tasks to an existing Taskfile, configure task automation. Supports creating tasks with dependencies, variables, loops ...
---

# Taskfile Creator

## Overview

This skill helps create production-ready Taskfiles following official best practices from taskfile.dev. Taskfiles provide a simpler, more maintainable alternative to Makefiles for task automation, build pipelines, and development workflows.

## When to Use This Skill

- User asks to "create a Taskfile" or "add tasks"
- Creating development workflow commands
- Migrating from Makefiles or npm scripts
- Configuring CI/CD task definitions

## Core Principles

### 1. Prefer Parameters Over Vars

**IMPORTANT**: Use CLI parameters instead of `vars` whenever users need to provide input.

**NAMING CONVENTION**: Always use lowercase Unix-style names for user-defined parameters and variables (e.g., `region`, `env`, `image_name`) for consistency with modern CLI tools. Built-in Task variables like `{{OS}}`, `{{ARCH}}`, `{{.USER_WORKING_DIR}}` remain uppercase as they are system-provided.

**Good** (Parameters with lowercase):

```yaml
version: '3'

tasks:
  deploy:
    desc: Deploy application (Usage: task deploy env=prod region=us-east-1)
    cmds:
      - echo "Deploying to {{.env}} in {{.region}}"
      - ./deploy.sh {{.env}} {{.region}}
```

**Avoid** (Hardcoded vars):

```yaml
tasks:
  deploy:
    vars:
      env: prod # Bad: Forces specific environment
      region: us-east-1
    cmds:
      - ./deploy.sh {{.env}} {{.region}}
```

**When to use vars**:

- Computed/dynamic values (`sh:` commands)
- Constants that don't change
- Default values with override capability using `default` function

**Good use of vars**:

```yaml
tasks:
  build:
    vars:
      timestamp:
        sh: date -u +"%Y%m%d%H%M%S"
      version: '{{.version | default "1.0.0"}}' # Allows override
    cmds:
      - go build -ldflags="-X main.Version={{.version}}-{{.timestamp}}"
```

### 2. Always Add Descriptions

Add `desc:` to all user-facing tasks (shows in `task --list`):

```yaml
tasks:
  test:
    desc: Run unit tests with coverage
    cmds:
      - go test -v -cover ./...
```

### 3. Use Modern Features

- **Loops** instead of shell scripts for iteration
- **Preconditions** for validation
- **Sources/Generates** for incremental builds
- **Platforms** for OS-specific tasks

## Quick Start Templates

### Basic Taskfile Structure

```yaml
version: "3"

# Global variables (use sparingly)
vars:
  app_name: myapp

# Global environment variables
env:
  GO111MODULE: on

# Load .env files
dotenv: [".env"]

tasks:
  default:
    desc: Show available tasks
    cmds:
      - task --list

  build:
    desc: Build the application
    cmds:
      - go build -o {{.app_name}} .
    sources:
      - "**/*.go"
      - go.mod
      - go.sum
    generates:
      - "{{.app_name}}"
```

### Task with CLI Parameters

```yaml
tasks:
  docker:build:
    desc: Build Docker image (Usage: task docker:build tag=v1.0.0)
    cmds:
      - docker build -t {{.image}}:{{.tag | default "latest"}} .
    vars:
      image: '{{.image | default "myapp"}}'
```

### Task with Dependencies

```yaml
tasks:
  deploy:
    desc: Deploy application
    deps: [test, build] # Run in parallel
    cmds:
      - ./deploy.sh

  test:
    desc: Run tests
    cmds:
      - go test ./...

  build:
    desc: Build binary
    cmds:
      - go build .
```

### Sequential Task Execution

```yaml
tasks:
  release:
    desc: Create a release
    cmds:
      - task: test # Run sequentially
      - task: build
      - task: tag
      - echo "Release complete"
```

## Common Patterns

### 1. Looping Over Values

**Loop over list**:

```yaml
tasks:
  lint:
    desc: Lint multiple directories
    cmds:
      - for: [api, web, services]
        cmd: golangci-lint run ./{{.ITEM}}/...
```

**Loop over matrix** (e.g., multi-platform builds):

```yaml
tasks:
  build:all:
    desc: Build for all platforms
    cmds:
      - for:
          matrix:
            os: [linux, darwin, windows]
            arch: [amd64, arm64]
        cmd: GOOS={{.ITEM.os}} GOARCH={{.ITEM.arch}} go build -o dist/app-{{.ITEM.os}}-{{.ITEM.arch}}
```

**Loop over CLI parameter**:

```yaml
tasks:
  process:
    desc: Process files (Usage: task process files="file1.txt file2.txt")
    cmds:
      - for: { var: files }
        cmd: cat {{.ITEM}}
```

### 2. Incremental Builds with Sources/Generates

```yaml
tasks:
  compile:
    desc: Compile only if sources changed
    sources:
      - "src/**/*.ts"
      - exclude: "src/**/*.test.ts"
    generates:
      - "dist/bundle.js"
    cmds:
      - tsc --build
```

### 3. Validation with Preconditions

```yaml
tasks:
  deploy:
    desc: Deploy to environment (requires env parameter)
    preconditions:
      - sh: test -n "{{.env}}"
        msg: "env parameter required. Usage: task deploy env=prod"
      - sh: test -f .env.{{.env}}
        msg: "Environment file .env.{{.env}} not found"
    cmds:
      - ./deploy.sh {{.env}}
```

### 4. Required Variables with Enum Validation

```yaml
tasks:
  deploy:
    desc: Deploy to environment (Usage: task deploy env=dev|staging|prod)
    requires:
      vars:
        - name: env
          enum: [dev, staging, prod]
    cmds:
      - echo "Deploying to {{.env}}"
      - ./deploy.sh {{.env}}
```

### 5. Platform-Specific Tasks

```yaml
tasks:
  install:
    desc: Install dependencies
    platforms: [darwin, linux]
    cmds:
      - brew install go

  install:windows:
    desc: Install dependencies (Windows)
    platforms: [windows]
    cmds:
      - choco install golang
```

### 6. Cleanup with Defer

```yaml
tasks:
  test:integration:
    desc: Run integration tests with cleanup
    cmds:
      - docker-compose up -d
      - defer: docker-compose down
      - sleep 5
      - go test -tags=integration ./...
```

### 7. Dynamic Variables

```yaml
tasks:
  build:
    desc: Build with version from git
    vars:
      version:
        sh: git describe --tags --always
      timestamp:
        sh: date -u +"%Y-%m-%dT%H:%M:%SZ"
    cmds:
      - go build -ldflags="-X main.Version={{.version}} -X main.BuildTime={{.timestamp}}"
```

### 8. Internal Tasks (Helper Tasks)

```yaml
tasks:
  build:frontend:
    desc: Build frontend application
    cmds:
      - task: install-deps
      - npm run build

  install-deps:
    internal: true # Hidden from --list
    cmds:
      - npm ci
```

### 9. Including External Taskfiles

```yaml
version: "3"

includes:
  docker:
    taskfile: ./taskfiles/Docker.yml
    dir: ./docker
    vars:
      image_name: myapp

  terraform:
    taskfile: ./iac/terraform
    optional: true
    aliases: [tf, infra]

tasks:
  deploy:
    desc: Deploy everything
    cmds:
      - task: docker:build
      - task: terraform:apply
```

### 10. Task with Status Checks

```yaml
tasks:
  install:deps:
    desc: Install dependencies if needed
    status:
      - test -d node_modules
      - test -f node_modules/.installed
    cmds:
      - npm ci
      - touch node_modules/.installed
```

## Best Practices Checklist

When creating a Taskfile, ensure:

- [ ] Version specified: `version: '3'`
- [ ] User-facing tasks have `desc:`
- [ ] Descriptions are concise (under 80 chars) - avoid over-engineering
- [ ] No unnecessary comments - let code speak for itself
- [ ] Use lowercase Unix-style names for all user-defined parameters and variables
- [ ] Use parameters instead of hardcoded `vars` for user input
- [ ] Add `default` task that shows help or common workflow
- [ ] Use `preconditions` for validation instead of inline checks
- [ ] Use `sources`/`generates` for incremental builds
- [ ] Add `platforms` for OS-specific commands
- [ ] Use `internal: true` for helper tasks
- [ ] Use `deps` for parallel execution, sequential `task:` calls for serial
- [ ] Add usage examples in descriptions when parameters are needed
- [ ] Use `defer` for cleanup operations
- [ ] Group related tasks with namespaces (e.g., `docker:build`, `docker:push`)

## Common Use Cases

### Development Workflow

```yaml
version: '3'

tasks:
  default:
    desc: Start development environment
    cmds:
      - task: deps
      - task: dev

  deps:
    desc: Install dependencies
    status:
      - test -d node_modules
    cmds:
      - npm ci

  dev:
    desc: Start dev server with watch
    cmds:
      - npm run dev

  test:
    desc: Run tests (Usage: task test args="--watch")
    cmds:
      - npm test {{.args}}

  lint:
    desc: Lint and format code
    cmds:
      - npm run lint
      - npm run format
```

### Docker Build Pipeline

```yaml
version: '3'

tasks:
  docker:build:
    desc: Build Docker image (Usage: task docker:build tag=v1.0.0)
    cmds:
      - docker build -t {{.image}}:{{.tag | default "latest"}} .
    vars:
      image: '{{.image | default "myapp"}}'

  docker:push:
    desc: Push Docker image (Usage: task docker:push tag=v1.0.0)
    deps: [docker:build]
    cmds:
      - docker push {{.image}}:{{.tag | default "latest"}}
    vars:
      image: '{{.image | default "myapp"}}'

  docker:run:
    desc: Run Docker container (Usage: task docker:run port=8080)
    cmds:
      - docker run -p {{.port | default "3000"}}:3000 {{.image}}:latest
    vars:
      image: '{{.image | default "myapp"}}'
```

### Multi-Language Monorepo

```yaml
version: "3"

includes:
  backend:
    taskfile: ./backend/Taskfile.yml
    dir: ./backend
  frontend:
    taskfile: ./frontend/Taskfile.yml
    dir: ./frontend

tasks:
  build:all:
    desc: Build all services
    deps:
      - backend:build
      - frontend:build

  test:all:
    desc: Run all tests
    cmds:
      - task: backend:test
      - task: frontend:test
```

## Advanced Features

### Watch Mode

```yaml
tasks:
  watch:
    desc: Auto-rebuild on changes
    watch: true
    sources:
      - "**/*.go"
    cmds:
      - task: build
```

### Matrix with Variable References

```yaml
version: "3"

vars:
  supported_os: [linux, darwin, windows]
  supported_arch: [amd64, arm64]

tasks:
  build:matrix:
    desc: Build for all OS/Arch combinations
    cmds:
      - for:
          matrix:
            os: { ref: .supported_os }
            arch: { ref: .supported_arch }
        cmd: GOOS={{.ITEM.os}} GOARCH={{.ITEM.arch}} go build -o bin/app-{{.ITEM.os}}-{{.ITEM.arch}}
```

### Complex Preconditions

```yaml
tasks:
  deploy:prod:
    desc: Deploy to production
    prompt: "Deploy to PRODUCTION?"
    preconditions:
      - sh: git diff-index --quiet HEAD --
        msg: "Working directory not clean. Commit changes first."
      - sh: test -n "$DEPLOY_KEY"
        msg: "DEPLOY_KEY environment variable required"
      - sh: test "$(git rev-parse --abbrev-ref HEAD)" = "main"
        msg: "Must be on main branch for production deployment"
    cmds:
      - ./deploy.sh production
```

## Templating Functions

Useful functions available in task templates:

- `{{.var | default "value"}}` - Default value if var not set
- `{{OS}}` - Current OS (linux, darwin, windows) - built-in, uppercase
- `{{ARCH}}` - Current architecture (amd64, arm64) - built-in, uppercase
- `{{.USER_WORKING_DIR}}` - Directory where task was invoked - built-in, uppercase
- `{{.TASK}}` - Current task name - built-in, uppercase
- `{{.CLI_ARGS}}` - Arguments after `--` - built-in, uppercase
- `{{joinPath .dir .file}}` - Join paths

## References

For complete documentation, see:

- Official docs: https://taskfile.dev/docs/guide
- Schema reference: https://taskfile.dev/docs/reference/schema
- Templating guide: https://taskfile.dev/docs/reference/templating
