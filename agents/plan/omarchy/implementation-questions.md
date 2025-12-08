# Implementation Questions

**Please answer these questions to customize the Omarchy dotfiles evolution plan.**

Your answers will guide the implementation of the patch scripts.

---

## 1. Package Management

### Packages to REMOVE

Which Omarchy default packages do you want to remove? Check categories and list specific packages:

**Terminal Emulators:**
- [ ] kitty
- [ ] foot
- [ ] Other: ________________

**Text Editors:**
- [ ] kate
- [ ] gedit
- [ ] Other: ________________

**Browsers:**
- [ ] firefox (if you prefer another)
- [ ] chromium
- [ ] Other: ________________

**File Managers:**
- [ ] (list if any)

**Media Players:**
- [ ] (list if any)

**Development Tools:**
- [ ] (list specific ones you don't use)

**System Utilities:**
- [ ] (list if any)

**Other Applications:**
- [ ] (list any other unwanted packages)

**Your List:**
```
# Add packages to remove (one per line):


```

---

### Packages to INSTALL

Which additional packages do you want installed? (Beyond what Omarchy provides)

**Already detected from your aliases:**
- fzf
- ripgrep
- eza
- bat
- fd
- delta

**Additional packages you want:**
```
# Add packages to install (one per line):


```

---

## 2. Configuration Strategy

For applications where Omarchy already has configurations (Hyprland, Waybar, etc.):

**Select your preferred approach:**

- [ ] **Option A - Layer on Top (Recommended)**
  - Keep Omarchy's defaults
  - Add your customizations on top
  - Benefit from Omarchy updates
  - Example: Keep Omarchy's Hyprland imports, add your overrides

- [ ] **Option B - Complete Replacement**
  - Replace Omarchy configs entirely
  - Full control, no Omarchy defaults
  - Manual maintenance

- [ ] **Option C - Hybrid**
  - Some apps: Omarchy defaults + your tweaks
  - Other apps: Fully custom
  - Specify which apps for each approach:
    ```
    Omarchy + tweaks:
    - 
    
    Fully custom:
    - 
    ```

---

## 3. Application Priority

**Rank your top 5 applications by importance (1 = most important):**

Put numbers 1-5 next to your priorities:

- [ ] Hyprland (window manager)
- [ ] Zsh (shell)
- [ ] Neovim (editor)
- [ ] Ghostty (terminal)
- [ ] Alacritty (terminal)
- [ ] Git
- [ ] Starship (prompt)
- [ ] Zellij (multiplexer)
- [ ] Bat (cat replacement)
- [ ] Delta (git diff)
- [ ] Other: _______________

**Implementation will focus on your top priorities first.**

---

## 4. Theme Integration

You have themes in `omarchy_backup/`. What do you want for themes?

**Select one:**

- [ ] **Option A:** Integrate existing themes with Omarchy's theme switcher
  - Use Omarchy's GUI to switch themes
  - Your custom themes show up in the switcher
  - Best integration with Omarchy

- [ ] **Option B:** Keep themes separate from Omarchy
  - Manage themes manually
  - Don't use Omarchy's theme system
  - More control, less automation

- [ ] **Option C:** Use only Omarchy's default themes
  - Stick with what Omarchy provides
  - No custom themes needed

- [ ] **Option D:** Create new custom themes from scratch
  - Start fresh with new theme system
  - Define exactly what you want

**Additional theme preferences:**

- [ ] Want CLI theme switcher (in addition to or instead of GUI)
- [ ] Want automatic theme switching (time-based, dark/light mode)
- [ ] Want per-application theme control
- [ ] Want to sync theme with wallpaper

---

## 5. Stow Integration

How should the patch scripts work with GNU Stow?

**Select one:**

- [ ] **Option A - Independent (Recommended)**
  - Keep using stow for dotfiles management
  - Scripts create additional patches/symlinks
  - Best of both worlds

- [ ] **Option B - Replace Stow**
  - Scripts handle all symlinking
  - Stop using stow
  - Unified management

- [ ] **Option C - Stow Only**
  - Keep current stow workflow
  - Minimal scripting
  - Manual patches as needed

**Why this matters:** Determines if scripts should:
- Work alongside stow (check for stow symlinks)
- Replace stow functionality
- Avoid conflicting with stow

---

## 6. Installation Timing

When should the Omarchy patches run?

**Select one or more:**

- [ ] **Manual Execution**
  - Run `./scripts/omarchy/install.sh` when you want
  - Full control over timing
  - Good for testing

- [ ] **On Fresh Omarchy Install**
  - Part of initial system setup
  - Automated first-time configuration
  - Modify Omarchy's install process

- [ ] **On Login**
  - Automatic via systemd service or shell rc
  - Keeps configs in sync
  - May slow down login

- [ ] **On Dotfiles Update**
  - Git post-merge hook
  - Automatic after `git pull`
  - Ensures latest configs applied

**Preference:** _______________

---

## 7. Special Requirements

Do you need any of these special features?

**Multi-Machine Support:**
- [ ] Yes, I use different machines with different configs
  - If yes, how should configs differ? _______________
  - (hostname-based, profiles, environment variables?)

**Private Configuration Management:**
- [ ] Yes, I need to handle secrets/private data
  - Approach:
    - [ ] Separate private repo
    - [ ] Encrypted files
    - [ ] Environment variables
    - [ ] Other: _______________

**Hardware-Specific Patches:**
- [ ] Yes, I need hardware-specific configurations
  - Hardware types:
    - [ ] Laptop vs desktop
    - [ ] NVIDIA GPU
    - [ ] AMD GPU
    - [ ] HiDPI displays
    - [ ] Other: _______________

**Migration Scripts:**
- [ ] Yes, I want version-controlled migrations for updates
  - Similar to Omarchy's timestamps: `1234567890.sh`
  - For breaking changes in dotfiles

**Development Mode:**
- [ ] Yes, I want a dev/staging mode for testing configs
  - Test changes before applying system-wide

**Configuration Profiles:**
- [ ] Yes, I want different profiles (work, personal, minimal, etc.)
  - Profile names: _______________

---

## 8. Development Workflow

**How do you currently manage dotfiles?**

- [ ] Edit directly in `~/.files/` repo and commit
- [ ] Edit in-place in `~/.config/`, then copy to repo
- [ ] Test in branches, merge to main when stable
- [ ] Other: _______________

**Git workflow:**
- [ ] Single branch (main/master)
- [ ] Multiple branches (dev, stable, experimental, etc.)
- [ ] Per-machine branches
- [ ] Other: _______________

**Update frequency:**
- [ ] Daily
- [ ] Weekly
- [ ] When something breaks
- [ ] When adding new tools

---

## 9. Documentation Preferences

**What level of documentation do you want?**

- [ ] **Minimal:** Just basic usage instructions
- [ ] **Standard:** Usage + troubleshooting + customization
- [ ] **Comprehensive:** Everything + examples + architecture docs

**Documentation format:**
- [ ] Markdown (README.md)
- [ ] Man pages
- [ ] Inline script comments
- [ ] All of the above

---

## 10. Additional Notes

**Any other requirements, preferences, or concerns?**

```
Add any additional notes here:




```

---

## Summary Checklist

Before proceeding with implementation, ensure you've answered:

- [ ] Package management (remove/install lists)
- [ ] Configuration strategy (layered vs replacement)
- [ ] Application priorities (ranked 1-5)
- [ ] Theme integration approach
- [ ] Stow integration decision
- [ ] Installation timing preference
- [ ] Special requirements (if any)
- [ ] Development workflow description
- [ ] Documentation level preference

---

**Next Steps:**

1. Fill out this questionnaire
2. Review the main plan: `dotfiles-evolution-plan.md`
3. Discuss any questions or concerns
4. Begin implementation starting with helpers and your top priorities

**Questions?** Add them in the Additional Notes section above.
