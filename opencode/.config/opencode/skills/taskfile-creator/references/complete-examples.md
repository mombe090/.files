# Complete Taskfile Examples

This reference contains full, production-ready Taskfile examples for common scenarios.

## Go Project Taskfile

```yaml
version: '3'

vars:
  APP_NAME: myapp
  BUILD_DIR: ./bin

env:
  CGO_ENABLED: 0
  GO111MODULE: on

dotenv: ['.env']

tasks:
  default:
    desc: Show available tasks
    cmds:
      - task --list

  deps:
    desc: Download dependencies
    sources:
      - go.mod
      - go.sum
    cmds:
      - go mod download
    status:
      - test -f go.sum

  build:
    desc: Build application
    deps: [deps]
    sources:
      - '**/*.go'
      - go.mod
      - go.sum
    generates:
      - '{{.BUILD_DIR}}/{{.APP_NAME}}'
    cmds:
      - mkdir -p {{.BUILD_DIR}}
      - go build -o {{.BUILD_DIR}}/{{.APP_NAME}} .

  test:
    desc: Run tests
    cmds:
      - go test -v -race -coverprofile=coverage.out ./...

  test:integration:
    desc: Run integration tests
    cmds:
      - docker-compose -f docker-compose.test.yml up -d
      - defer: docker-compose -f docker-compose.test.yml down
      - sleep 3
      - go test -v -tags=integration ./...

  lint:
    desc: Run linters
    cmds:
      - golangci-lint run ./...

  fmt:
    desc: Format code
    cmds:
      - go fmt ./...
      - goimports -w .

  clean:
    desc: Clean build artifacts
    cmds:
      - rm -rf {{.BUILD_DIR}}
      - rm -f coverage.out

  run:
    desc: Run application (Usage: task run ARGS="--port 8080")
    deps: [build]
    cmds:
      - '{{.BUILD_DIR}}/{{.APP_NAME}} {{.ARGS}}'

  watch:
    desc: Watch and rebuild on changes
    watch: true
    sources:
      - '**/*.go'
    cmds:
      - task: build
      - task: run

  release:
    desc: Create release builds for all platforms
    cmds:
      - task: test
      - task: build:all

  build:all:
    desc: Build for all platforms
    cmds:
      - for:
          matrix:
            OS: [linux, darwin, windows]
            ARCH: [amd64, arm64]
        cmd: |
          GOOS={{.ITEM.OS}} GOARCH={{.ITEM.ARCH}} \
          go build -ldflags="-s -w" \
          -o {{.BUILD_DIR}}/{{.APP_NAME}}-{{.ITEM.OS}}-{{.ITEM.ARCH}} .
```

## Node.js/TypeScript Project

```yaml
version: '3'

vars:
  NODE_ENV: development

dotenv: ['.env', '.env.local']

tasks:
  default:
    desc: Start development server
    cmds:
      - task: dev

  install:
    desc: Install dependencies
    sources:
      - package.json
      - package-lock.json
    generates:
      - node_modules/.package-lock.json
    cmds:
      - npm ci

  dev:
    desc: Start development server
    deps: [install]
    cmds:
      - npm run dev

  build:
    desc: Build for production
    deps: [install, lint, test]
    sources:
      - 'src/**/*.ts'
      - 'src/**/*.tsx'
      - tsconfig.json
    generates:
      - 'dist/**/*.js'
    cmds:
      - npm run build

  test:
    desc: Run tests (Usage: task test ARGS="--watch")
    deps: [install]
    cmds:
      - npm test -- {{.ARGS}}

  test:coverage:
    desc: Run tests with coverage
    deps: [install]
    cmds:
      - npm test -- --coverage

  lint:
    desc: Lint code
    deps: [install]
    cmds:
      - npm run lint

  lint:fix:
    desc: Lint and fix code
    deps: [install]
    cmds:
      - npm run lint -- --fix

  format:
    desc: Format code with Prettier
    deps: [install]
    cmds:
      - npm run format

  type-check:
    desc: Type check TypeScript
    deps: [install]
    cmds:
      - tsc --noEmit

  clean:
    desc: Clean build artifacts
    cmds:
      - rm -rf dist
      - rm -rf node_modules
      - rm -rf coverage

  docker:build:
    desc: Build Docker image (Usage: task docker:build TAG=latest)
    cmds:
      - docker build -t {{.IMAGE}}:{{.TAG | default "latest"}} .
    vars:
      IMAGE: '{{.IMAGE | default "myapp"}}'

  docker:run:
    desc: Run Docker container (Usage: task docker:run PORT=3000)
    deps: [docker:build]
    cmds:
      - docker run -p {{.PORT | default "3000"}}:3000 {{.IMAGE}}:latest
    vars:
      IMAGE: '{{.IMAGE | default "myapp"}}'
```

## Terraform Infrastructure

```yaml
version: '3'

vars:
  TF_DIR: ./infrastructure

tasks:
  default:
    desc: Show available tasks
    cmds:
      - task --list

  init:
    desc: Initialize Terraform (Usage: task init ENV=dev)
    dir: '{{.TF_DIR}}'
    preconditions:
      - sh: test -n "{{.ENV}}"
        msg: "ENV parameter required. Usage: task init ENV=dev"
    cmds:
      - terraform init -backend-config=backend-{{.ENV}}.hcl

  plan:
    desc: Plan Terraform changes (Usage: task plan ENV=dev)
    dir: '{{.TF_DIR}}'
    deps: [init]
    requires:
      vars:
        - name: ENV
          enum: [dev, staging, prod]
    cmds:
      - terraform plan -var-file={{.ENV}}.tfvars -out={{.ENV}}.tfplan

  apply:
    desc: Apply Terraform changes (Usage: task apply ENV=dev)
    dir: '{{.TF_DIR}}'
    deps: [plan]
    prompt: "Apply changes to {{.ENV}}?"
    requires:
      vars:
        - name: ENV
          enum: [dev, staging, prod]
    cmds:
      - terraform apply {{.ENV}}.tfplan

  destroy:
    desc: Destroy Terraform resources (Usage: task destroy ENV=dev)
    dir: '{{.TF_DIR}}'
    prompt: "DESTROY all resources in {{.ENV}}?"
    requires:
      vars:
        - name: ENV
          enum: [dev, staging, prod]
    preconditions:
      - sh: test "{{.ENV}}" != "prod"
        msg: "Cannot destroy production environment via task"
    cmds:
      - terraform destroy -var-file={{.ENV}}.tfvars

  fmt:
    desc: Format Terraform files
    dir: '{{.TF_DIR}}'
    cmds:
      - terraform fmt -recursive

  validate:
    desc: Validate Terraform configuration
    dir: '{{.TF_DIR}}'
    deps: [init]
    cmds:
      - terraform validate

  lint:
    desc: Lint Terraform with tflint
    dir: '{{.TF_DIR}}'
    cmds:
      - tflint --recursive
```

## Monorepo with Multiple Services

```yaml
version: '3'

includes:
  api:
    taskfile: ./services/api
    dir: ./services/api
  web:
    taskfile: ./services/web
    dir: ./services/web
  worker:
    taskfile: ./services/worker
    dir: ./services/worker
  infra:
    taskfile: ./infrastructure
    dir: ./infrastructure
    aliases: [tf, terraform]

tasks:
  default:
    desc: Show available tasks
    cmds:
      - task --list-all

  install:
    desc: Install dependencies for all services
    deps:
      - api:install
      - web:install
      - worker:install

  build:
    desc: Build all services
    deps:
      - api:build
      - web:build
      - worker:build

  test:
    desc: Test all services
    cmds:
      - task: api:test
      - task: web:test
      - task: worker:test

  lint:
    desc: Lint all services
    cmds:
      - for: [api, web, worker]
        task: '{{.ITEM}}:lint'

  dev:
    desc: Start all services in development mode
    cmds:
      - docker-compose up

  clean:
    desc: Clean all build artifacts
    cmds:
      - for: [api, web, worker]
        task: '{{.ITEM}}:clean'

  deploy:
    desc: Deploy all services (Usage: task deploy ENV=staging)
    requires:
      vars:
        - name: ENV
          enum: [dev, staging, prod]
    prompt: "Deploy to {{.ENV}}?"
    deps:
      - build
      - test
    cmds:
      - task: infra:apply
        vars: { ENV: '{{.ENV}}' }
      - task: api:deploy
        vars: { ENV: '{{.ENV}}' }
      - task: web:deploy
        vars: { ENV: '{{.ENV}}' }
      - task: worker:deploy
        vars: { ENV: '{{.ENV}}' }
```

## Python Project

```yaml
version: "3"

vars:
  PYTHON: python3
  VENV: .venv

env:
  PYTHONPATH: .

tasks:
  default:
    desc: Show available tasks
    cmds:
      - task --list

  venv:
    desc: Create virtual environment
    status:
      - test -d {{.VENV}}
    cmds:
      - "{{.PYTHON}} -m venv {{.VENV}}"

  install:
    desc: Install dependencies
    deps: [venv]
    sources:
      - requirements.txt
      - requirements-dev.txt
    cmds:
      - "{{.VENV}}/bin/pip install -r requirements.txt"
      - "{{.VENV}}/bin/pip install -r requirements-dev.txt"

  test:
    desc: Run tests
    deps: [install]
    cmds:
      - "{{.VENV}}/bin/pytest {{.ARGS}}"

  test:coverage:
    desc: Run tests with coverage
    deps: [install]
    cmds:
      - "{{.VENV}}/bin/pytest --cov=src --cov-report=html"

  lint:
    desc: Lint code
    deps: [install]
    cmds:
      - "{{.VENV}}/bin/ruff check ."
      - "{{.VENV}}/bin/mypy ."

  lint:fix:
    desc: Lint and fix code
    deps: [install]
    cmds:
      - "{{.VENV}}/bin/ruff check --fix ."

  format:
    desc: Format code
    deps: [install]
    cmds:
      - "{{.VENV}}/bin/black ."
      - "{{.VENV}}/bin/isort ."

  clean:
    desc: Clean build artifacts
    cmds:
      - rm -rf {{.VENV}}
      - rm -rf .pytest_cache
      - rm -rf .coverage
      - rm -rf htmlcov
      - find . -type d -name __pycache__ -exec rm -rf {} +
      - find . -type f -name '*.pyc' -delete
```

## CI/CD Pipeline

```yaml
version: '3'

vars:
  registry: ghcr.io
  image: '{{.registry}}/myorg/myapp'

tasks:
  ci:
    desc: Run full CI pipeline
    cmds:
      - task: lint
      - task: test
      - task: build
      - task: security-scan

  lint:
    desc: Run all linters
    cmds:
      - task: lint:code
      - task: lint:docker
      - task: lint:yaml

  lint:code:
    desc: Lint code
    cmds:
      - golangci-lint run ./...

  lint:docker:
    desc: Lint Dockerfile
    cmds:
      - hadolint Dockerfile

  lint:yaml:
    desc: Lint YAML
    cmds:
      - yamllint .

  test:
    desc: Run all tests
    cmds:
      - task: test:unit
      - task: test:integration

  test:unit:
    desc: Run unit tests
    cmds:
      - go test -v -race ./...

  test:integration:
    desc: Run integration tests
    cmds:
      - docker-compose -f docker-compose.test.yml up -d
      - defer: docker-compose -f docker-compose.test.yml down
      - sleep 3
      - go test -v -tags=integration ./...

  build:
    desc: Build application
    cmds:
      - go build -o app .

  security-scan:
    desc: Run security scans
    cmds:
      - task: security:dependencies
      - task: security:container

  security:dependencies:
    desc: Scan dependencies
    cmds:
      - go list -json -m all | nancy sleuth

  security:container:
    desc: Scan container
    deps: [docker:build]
    cmds:
      - trivy image {{.image}}:{{.tag | default "latest"}}

  docker:build:
    desc: Build image (Usage: task docker:build tag=v1.0.0)
    cmds:
      - docker build -t {{.image}}:{{.tag | default "latest"}} .

  docker:push:
    desc: Push image (Usage: task docker:push tag=v1.0.0)
    deps: [docker:build]
    preconditions:
      - sh: docker info
        msg: "Docker daemon not running"
    cmds:
      - docker push {{.image}}:{{.tag | default "latest"}}

  release:
    desc: Create release (Usage: task release version=v1.0.0)
    requires:
      vars: [version]
    preconditions:
      - sh: git diff-index --quiet HEAD --
        msg: "Working directory not clean"
      - sh: test "$(git rev-parse --abbrev-ref HEAD)" = "main"
        msg: "Must be on main branch"
    cmds:
      - task: ci
      - git tag {{.version}}
      - git push origin {{.version}}
      - task: docker:build
        vars: { tag: '{{.version}}' }
      - task: docker:push
        vars: { tag: '{{.version}}' }
```
