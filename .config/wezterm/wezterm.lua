local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- config.dpi = 96

------------------------------------------------------------------------
-- Appearance
------------------------------------------------------------------------

config.color_scheme = "Tokyo Night"
-- config.colors = {
--   foreground = "#ffffff",
--   background = "#000000",
-- }

config.font = wezterm.font("JetBrains Mono")
config.font_size = 11.0
config.line_height = 1.0
config.cell_width = 1.0

config.bold_brightens_ansi_colors = true

------------------------------------------------------------------------
-- Window
------------------------------------------------------------------------

config.initial_cols = 120
config.initial_rows = 35

-- config.window_decorations = "RESIZE"
-- config.window_close_confirmation = "AlwaysPrompt"

config.window_background_opacity = 1.0
config.text_background_opacity = 1.0

-- config.macos_window_background_blur = 20

config.enable_scroll_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false

------------------------------------------------------------------------
-- Cursor
------------------------------------------------------------------------

config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 800

------------------------------------------------------------------------
-- Scrolling
------------------------------------------------------------------------

config.scrollback_lines = 10000
config.enable_scroll_bar = false

------------------------------------------------------------------------
-- Performance
------------------------------------------------------------------------

config.front_end = "WebGpu"
config.max_fps = 120
config.animation_fps = 60

------------------------------------------------------------------------
-- Clipboard
------------------------------------------------------------------------

config.selection_word_boundary = " \t\n{}[]()\"'`,;:"

------------------------------------------------------------------------
-- Shell
------------------------------------------------------------------------

-- Linux example:
-- config.default_prog = { "/bin/bash", "-l" }

-- Windows example:
-- config.default_prog = { "pwsh.exe", "-NoLogo" }

------------------------------------------------------------------------
-- Key bindings
------------------------------------------------------------------------
local wezterm = require 'wezterm'
local act = wezterm.action

config.disable_default_key_bindings = false

config.leader = {
  key = "q",
  mods = "CTRL",
  timeout_milliseconds = 1000,
}

config.keys = {
  {
    key = "p",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ActivateCommandPalette
  },
  -- Split horizontally (left/right panes)
  {
    key = "\\",
    mods = "LEADER",
    action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
  },

  -- Split vertically (top/bottom panes)
  {
    key = "-",
    mods = "LEADER",
    action = act.SplitVertical { domain = "CurrentPaneDomain" },
  },

  {
    key = "t",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnTab "CurrentPaneDomain",
  },

  {
    key = "w",
    mods = "CTRL|SHIFT",
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },

  {
    key = "Enter",
    mods = "ALT",
    action = wezterm.action.ToggleFullScreen,
  },

  {
    key = "c",
    mods = "CTRL|SHIFT",
    action = wezterm.action.CopyTo "Clipboard",
  },

  {
    key = "v",
    mods = "CTRL|SHIFT",
    action = wezterm.action.PasteFrom "Clipboard",
  },
}

------------------------------------------------------------------------
-- Mouse
------------------------------------------------------------------------

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelectionOrOpenLinkAtMouseCursor "ClipboardAndPrimarySelection",
  },
}

------------------------------------------------------------------------
-- Hyperlinks
------------------------------------------------------------------------

config.hyperlink_rules = wezterm.default_hyperlink_rules()

------------------------------------------------------------------------
-- Launch Menu
------------------------------------------------------------------------

config.launch_menu = {
  -- {
  --   label = "Bash",
  --   args = { "/bin/bash", "-l" },
  -- },
}

------------------------------------------------------------------------
-- SSH Domains
------------------------------------------------------------------------

config.ssh_domains = {
  -- {
  --   name = "myserver",
  --   remote_address = "example.com",
  --   username = "me",
  -- },
}

------------------------------------------------------------------------
-- WSL Domains
------------------------------------------------------------------------

-- config.wsl_domains = {
--   {
--     name = "WSL:Ubuntu",
--     distribution = "Ubuntu",
--   },
-- }

------------------------------------------------------------------------
-- Multiplexer
------------------------------------------------------------------------

config.unix_domains = {
  -- {
  --   name = "local",
  -- },
}

------------------------------------------------------------------------
-- Pane splitting
------------------------------------------------------------------------

config.default_workspace = "default"

------------------------------------------------------------------------
-- Window padding
------------------------------------------------------------------------

config.window_padding = {
  left = 4,
  right = 4,
  top = 2,
  bottom = 2,
}

------------------------------------------------------------------------
-- Bell
------------------------------------------------------------------------

config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 100,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 100,
}

------------------------------------------------------------------------
-- Misc
------------------------------------------------------------------------

config.check_for_updates = true
config.automatically_reload_config = true
config.warn_about_missing_glyphs = true

------------------------------------------------------------------------
-- Events (examples)
------------------------------------------------------------------------

-- wezterm.on("gui-startup", function(cmd)
-- end)

-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
--   return tab.active_pane.title
-- end)

------------------------------------------------------------------------

return config

