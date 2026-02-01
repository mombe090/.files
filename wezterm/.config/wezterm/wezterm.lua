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
config.initial_cols = 144
config.initial_rows = 36

-- =============================================================================
-- Appearance
-- =============================================================================

-- Color scheme
config.color_scheme = 'Catppuccin Mocha'

-- Font configuration
config.font = wezterm.font('CaskaydiaMono Nerd Font', { weight = 'Regular' })
config.font_size = 16.0

-- Window appearance
config.window_background_opacity = 1.0
config.window_decorations = 'RESIZE'
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

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
-- Key Bindings
-- =============================================================================

-- =============================================================================
-- Return Configuration
-- =============================================================================

return config
