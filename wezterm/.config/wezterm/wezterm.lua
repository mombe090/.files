-- WezTerm Configuration
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Window Config
config.initial_cols = 160
config.initial_rows = 40

-- =============================================================================
-- Appearance
-- =============================================================================

-- Color scheme
config.color_scheme = 'Catppuccin Mocha'

-- Font configuration
config.font = wezterm.font('CaskaydiaMono Nerd Font', { weight = 'Regular' })
config.font_size = 16.0

-- Frontend Rendering
config.front_end = 'WebGpu'
config.freetype_load_target = 'Normal'
config.freetype_render_target = 'Normal'

-- Window appearance
config.window_background_opacity = 1.0
config.window_decorations = 'RESIZE'

-- Tab bar appearance
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = true

-- Window padding
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- =============================================================================
-- Behavior
-- =============================================================================

-- Scrollback
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- Shell
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  -- Windows: Use PowerShell 7
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
elseif wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then
  -- macOS: Use zsh
  config.default_prog = { '/bin/zsh', '-l' }
else
  -- Linux: Use zsh
  config.default_prog = { '/bin/zsh', '-l' }
end

-- =============================================================================
-- Launch Menu
-- =============================================================================

config.launch_menu = {}

-- Add PowerShell on all platforms
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  table.insert(config.launch_menu, {
    label = 'PowerShell',
    args = { 'pwsh.exe', '-NoLogo' },
  })
else
  -- pwsh on Unix systems
  table.insert(config.launch_menu, {
    label = 'PowerShell',
    args = { 'pwsh', '-NoLogo' },
  })
end

-- Add Nushell on all platforms
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  table.insert(config.launch_menu, {
    label = 'Nushell',
    args = { 'nu.exe' },
  })
else
  table.insert(config.launch_menu, {
    label = 'Nushell',
    args = { 'nu' },
  })
end

-- Add WSL (Windows only)
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  table.insert(config.launch_menu, {
    label = 'WSL',
    args = { 'wsl.exe' },
  })

  -- Add specific WSL distributions if available
  table.insert(config.launch_menu, {
    label = 'WSL - Ubuntu',
    args = { 'wsl.exe', '-d', 'Ubuntu' },
  })

  table.insert(config.launch_menu, {
    label = 'WSL - Debian',
    args = { 'wsl.exe', '-d', 'Debian' },
  })
end

-- =============================================================================
-- Hyperlink Rules
-- =============================================================================

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Add custom hyperlink rules
table.insert(config.hyperlink_rules, {
  -- Match GitHub issue references like #123
  regex = [[\b[a-zA-Z0-9._-]+#\d+\b]],
  format = 'https://github.com/$0',
})

table.insert(config.hyperlink_rules, {
  -- Match file paths (Unix-style)
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/[-\w\d.]+)+["]?]],
  format = '$0',
})

table.insert(config.hyperlink_rules, {
  -- Match Git commit hashes (7-40 hex chars)
  regex = [[\b[0-9a-f]{7,40}\b]],
  format = 'https://github.com/search?q=$0&type=commits',
})

table.insert(config.hyperlink_rules, {
  -- Match localhost URLs with ports
  regex = [[\blocalhost:\d+\b]],
  format = 'http://$0',
})

table.insert(config.hyperlink_rules, {
  -- Match IP addresses with ports
  regex = [[\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+\b]],
  format = 'http://$0',
})

table.insert(config.hyperlink_rules, {
  -- Match npm package names
  regex = [[\bnpm:[@a-zA-Z0-9-_/]+\b]],
  format = 'https://www.npmjs.com/package/$0',
})

-- Make URLs clickable without needing ctrl/cmd
config.mouse_bindings = {
  -- Open URLs on single click (no modifier needed)
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  -- Paste on right click
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  -- Middle click to paste primary selection (Unix-style)
  {
    event = { Up = { streak = 1, button = 'Middle' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'PrimarySelection',
  },
  -- Extend selection on shift-click
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'SHIFT',
    action = wezterm.action.ExtendSelectionToMouseCursor 'Cell',
  },
  -- Select word on double-click
  {
    event = { Up = { streak = 2, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.SelectTextAtMouseCursor 'Word',
  },
  -- Select line on triple-click
  {
    event = { Up = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.SelectTextAtMouseCursor 'Line',
  },
  -- Ctrl+Click to open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  -- Ctrl+Scroll to adjust font size
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'CTRL',
    action = wezterm.action.IncreaseFontSize,
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'CTRL',
    action = wezterm.action.DecreaseFontSize,
  },
}

-- =============================================================================
-- Key Bindings
-- =============================================================================

config.keys = {
  -- Launch Menu
  { key = 'l', mods = 'CTRL|ALT', action = wezterm.action.ShowLauncher },

  -- Tabs
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },

  -- Panes
  { key = 'd', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'D', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'x', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = true } },

  -- Font size
  { key = '+', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = wezterm.action.ResetFontSize },

  -- Copy/Paste
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },

  -- Search
  { key = 'f', mods = 'CTRL|SHIFT', action = wezterm.action.Search 'CurrentSelectionOrEmptyString' },
}

-- =============================================================================
-- Return Configuration
-- =============================================================================

return config
