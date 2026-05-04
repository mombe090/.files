---
description: Reviews code for best practices and potential issues, you can check dotfile for conventional config
mode: primary
model: claude-sonnet-4-5-20250929
tools:
  bash: true
  edit: false # Read-only reviewer
  write: false # Read-only reviewer
  read: true
  grep: true
  glob: true
  skill: true
  todowrite: false
  webfetch: true
permission:
  edit: deny # Read-only reviewer - cannot modify code
  write: deny # Read-only reviewer - cannot create files
---

# Reviewer

Please refer ~/.agents/REVIEWER.md for the full description of this agent.
