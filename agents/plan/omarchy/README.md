# Omarchy Dotfiles Evolution - Planning Documents

**Created:** December 7, 2025  
**Status:** Planning Phase - Awaiting User Input

---

## 📁 Files in This Directory

### 1. `dotfiles-evolution-plan.md` (1,386 lines)

**Complete implementation plan with actual code** for evolving your dotfiles to work with Omarchy's patching system.

**Contents:**
- Architecture analysis of Omarchy's installation system
- Proposed `scripts/omarchy/` directory structure
- Full shell script implementations for:
  - Helper utilities (logging, detection, symlinks, backups)
  - Main `install.sh` entry point
  - Preflight checks (Omarchy detection, dependencies)
  - Package management (uninstall unwanted, install custom)
  - Configuration patches for ALL your apps:
    - Hyprland
    - Zsh
    - Neovim
    - Alacritty & Ghostty
    - Git
    - Starship
    - Zellij
    - Bat & Delta
  - Theme integration with Omarchy's theme switcher
  - Post-install verification and summary
- Safety procedures and rollback instructions
- Best practices following Omarchy patterns and your AGENTS.md guidelines

**Key Features:**
- ✅ Idempotent (safe to run multiple times)
- ✅ Dry-run mode for testing
- ✅ Automatic backups before changes
- ✅ Comprehensive logging
- ✅ Works alongside your existing stow setup
- ✅ Layers customizations on top of Omarchy defaults

### 2. `implementation-questions.md` (336 lines)

**Detailed questionnaire** to customize the implementation to your specific needs.

**Topics Covered:**
1. **Package Management** - Which packages to remove/install
2. **Configuration Strategy** - Layered vs complete replacement
3. **Application Priority** - Your top 5 apps to focus on first
4. **Theme Integration** - How to handle your custom themes
5. **Stow Integration** - How scripts should work with stow
6. **Installation Timing** - When patches should run
7. **Special Requirements** - Multi-machine, private configs, hardware-specific
8. **Development Workflow** - How you work with dotfiles
9. **Documentation Preferences** - Level and format of docs
10. **Additional Notes** - Anything else needed

---

## 🎯 Quick Start

### View the Plans

```bash
# Main implementation plan (recommended to read first)
bat agents/plan/omarchy/dotfiles-evolution-plan.md

# Or with less
less agents/plan/omarchy/dotfiles-evolution-plan.md

# Questions to customize implementation
bat agents/plan/omarchy/implementation-questions.md
```

### Plan Overview

The plan proposes creating this structure:

```
.files/
├── scripts/
│   └── omarchy/
│       ├── README.md
│       ├── install.sh                   # Main entry point
│       │
│       ├── helpers/                     # Utility functions
│       │   ├── all.sh
│       │   ├── logging.sh
│       │   ├── detection.sh
│       │   ├── symlink.sh
│       │   └── backup.sh
│       │
│       ├── preflight/                   # Pre-install checks
│       │   ├── all.sh
│       │   ├── check-omarchy.sh
│       │   ├── check-deps.sh
│       │   └── confirm.sh
│       │
│       ├── packages/                    # Package management
│       │   ├── all.sh
│       │   ├── uninstall-defaults.sh
│       │   ├── install-custom.sh
│       │   ├── unwanted.list
│       │   └── custom.list
│       │
│       ├── config/                      # Config patches
│       │   ├── all.sh
│       │   ├── hypr.sh
│       │   ├── zsh.sh
│       │   ├── nvim.sh
│       │   └── [other apps].sh
│       │
│       ├── themes/                      # Theme integration
│       │   ├── all.sh
│       │   ├── integrate.sh
│       │   └── custom.sh
│       │
│       └── post-install/                # Finalization
│           ├── all.sh
│           ├── verify.sh
│           └── summary.sh
```

---

## 🚀 Next Steps

### 1. Read the Main Plan

Open and read `dotfiles-evolution-plan.md` to understand:
- How Omarchy's system works
- The proposed architecture
- Complete script implementations (ready to use)
- Safety features and rollback procedures

### 2. Answer the Questions

Fill out `implementation-questions.md` to specify:
- Which packages to remove/install
- Your configuration preferences
- Application priorities
- Theme integration approach
- Special requirements

### 3. Start Implementation

Once you've reviewed and answered questions, we can:
- Implement the helper scripts
- Create configuration patches for your top priority apps
- Set up package management
- Integrate with Omarchy's theme system
- Test with dry-run mode

---

## 📊 Implementation Approach

**Recommended Order:**

1. **Phase 1: Foundation** (Universal)
   - Create helper scripts (logging, detection, symlinks, backups)
   - Create main `install.sh` entry point
   - Set up preflight checks

2. **Phase 2: Test with Top App** (Validate approach)
   - Pick your #1 priority app
   - Implement its config patch
   - Test with `--dry-run`
   - Verify it works

3. **Phase 3: Roll Out** (Expand coverage)
   - Implement remaining app patches
   - Set up package management
   - Integrate themes

4. **Phase 4: Polish** (Make it production-ready)
   - Add comprehensive documentation
   - Test rollback procedures
   - Fine-tune based on usage

---

## 🔍 Key Decisions Needed

Before implementation, you need to decide:

- [ ] **Configuration Strategy:** Layer on Omarchy or replace completely?
- [ ] **Package Management:** Which default packages to remove?
- [ ] **Theme Integration:** Use Omarchy's theme switcher or separate?
- [ ] **Stow Integration:** Work alongside or replace?
- [ ] **Installation Trigger:** Manual, automatic, or on-demand?

These are covered in detail in `implementation-questions.md`.

---

## 📝 Notes

- All scripts follow Omarchy's patterns (phase-based, idempotent, logged)
- Scripts follow your AGENTS.md guidelines (bash, lowercase variables, quoted)
- Everything is designed to be safe with backups and dry-run mode
- Scripts work WITH your existing stow setup, not against it

---

## 🤔 Questions?

If you have questions about the plan or need clarification:

1. Read the detailed plan first
2. Check the questions document
3. Ask for specific clarifications

---

**Files:**
- `dotfiles-evolution-plan.md` - Complete implementation plan with code
- `implementation-questions.md` - Questionnaire to customize implementation
- `README.md` - This file (navigation guide)

**Location:** `/home/mombe090/.files/agents/plan/omarchy/`
