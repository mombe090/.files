# Mombe090 Public dotfiles 💻

This is a collection of my personal dotfiles and configurations to set up quickly a machine ready for my day to day development work.

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Features](#features)
- [Software & Tools](#software--tools)
- [Screenshots](#screenshots)
- [Customization](#customization)
- [License](#license)
- [Contact](#contact)

---

## Overview

These dotfiles aim to provide a **clean, efficient, and customizable development environment** for all OS i am using :

- Linux [debian based, rehat based, arch base and nix os],
- macOS
- Windows with WSL

Includes configurations for:

- Shell (`zsh` and some `bash`, but mainly using `zsh` with `zinit`), next is to pick `nushell`.
- Terminal and multiplexer (`alacritty`, `ghostty` and `zellij`)
- Editor (`Neovim`, `Vscode` and `Intellij`)
- Tiling window manager (`hyprland`)
- Omarchy Customization
- System aliases, environment variables, functions and more.

---

## Structure

```text
├── alacritty
│   └── .config
│       └── alacritty
│           └── themes
├── bat
├── ghostty
│   └── .config
│       └── ghostty
├── hypr
│   └── .config
│       └── hypr
│           └── scripts
├── k9s
├── nvim
│   └── .config
│       └── nvim
│           ├── lua
│           │   ├── config
│           │   └── plugins
│           └── plugin
│               └── after
├── omarchy
│   ├── branding -> .config/omarchy/branding
│   ├── .config
│   │   └── omarchy
│   │       ├── branding
│   │       ├── current
│   │       └── themes
│   ├── current -> .config/omarchy/current
│   └── themes -> .config/omarchy/themes
├── starship
├── walker
│   └── .config
├── waybar
│   └── .config
└── zsh
    └── .config
        └── zsh
```

---

## Dependencies

This dotfiles requires the following software to be installed on your system:

- git
- zsh

<!--  TODO: add othe Dependencies and make sure evrything works well -->

## Installation

> **Warning:** Backup your existing configuration files before installing.
> You can achieve this by running :

```bash
cp ~/.zshrc ~/.zshrc.backup
cp -r ~/.config/ ~/.config.backup
```

Once you have backed up your files, you can proceed with the installation.

> Make sure to fork this repository to your own GitHub account if you want to customize it further.

```bash
# Clone this repository
git clone https://github.com/<your-username>/.files.git ~/.dotfiles

# Enter the directory
cd ~/.dotfiles

# Run the install script
# This is interactive script that will guide you through the installation process
./install.sh
```

## Features

Thos dotfiles include ready features like:

- A fully configured `zsh` shell with `zinit` plugin manager.
- Custom aliases and functions for common tasks.
- Pre-configured `Neovim with lazyVim` setup with plugins for development.
- Configured `alacritty` and `ghostty` as terminal emulator with my favorite theme `catppuccin`.
- `hyprland` configuration for a tiling window manager experience on [omarchy](https://omarchy.org).
- [Nix](https://nixos.org/) as as package manager with :
  - [NixDarwin](https://nix-darwin.github.io/) with `flakes` and `homebrew` on MacOS
  - [home-manager](https://nix-community.github.io/home-manager/) for declarative package management on Linux.

## Software & Tools

Bellow a list my most heavily used software and tools that are configured in this dotfiles:

| Tool    | Purpose                                           |
| ------- | ------------------------------------------------- |
| bat     | Cat replacement with beautifull output with icons |
| eza     | ls replacement                                    |
| fzf     | Fuzzy finder                                      |
| Git     | Version control                                   |
| Neovim  | Editor                                            |
| ripgrep | Fast searching                                    |
| Tmux    | Terminal multiplexer                              |
| Zsh     | Shell                                             |

<!-- TODO:  add more tools or put the redirection here -->

## Inspiration

<!-- TODO: add some inspiration dotfiles  -->
