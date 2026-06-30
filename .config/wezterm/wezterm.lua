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

config.font = wezterm.font('JetBrains Mono', { weight = 'ExtraLight' })

config.font_size = 10.0
config.line_height = 1.0
config.cell_width = 1.0

config.bold_brightens_ansi_colors = 'BrightOnly'

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

-- Split H or V based on pane aspect ratio (wider → side by side, taller → top/bottom)
local function smart_split(window, pane)
  local dim = pane:get_dimensions()
  if dim.pixel_width > dim.pixel_height then
    window:perform_action(act.SplitHorizontal { domain = 'CurrentPaneDomain' }, pane)
  else
    window:perform_action(act.SplitVertical { domain = 'CurrentPaneDomain' }, pane)
  end
end

config.disable_default_key_bindings = false

config.leader = {
  key = "\\",
  mods = "CTRL",
  timeout_milliseconds = 1000,
}

config.keys = {
  {
    key = "p",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ActivateCommandPalette
  },

  -- Smart split: H or V based on pane aspect ratio
  {
    key = "=",
    mods = "ALT",
    action = wezterm.action_callback(smart_split),
  },

  -- Maximize current pane (zoom), hiding others; press again to restore
  {
    key = "Enter",
    mods = "CTRL|SHIFT",
    action = act.TogglePaneZoomState,
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

  {
    key = "l",
    mods = "CTRL|SHIFT",
    action = act.Multiple {
      act.ClearScrollback "ScrollbackAndViewport",
      act.SendKey { key = "l", mods = "CTRL" },
    },
  },

  -- Font size: increase/decrease by 1
  {
    key = "=",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, _)
      local cfg = window:get_config_overrides() or {}
      local size = cfg.font_size or config.font_size
      cfg.font_size = size + 1
      window:set_config_overrides(cfg)
    end),
  },
  {
    key = "-",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, _)
      local cfg = window:get_config_overrides() or {}
      local size = cfg.font_size or config.font_size
      cfg.font_size = math.max(1, size - 1)
      window:set_config_overrides(cfg)
    end),
  },

  -- Font size: reset to config default
  {
    key = "0",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, _)
      local cfg = window:get_config_overrides() or {}
      cfg.font_size = config.font_size
      window:set_config_overrides(cfg)
    end),
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

  -- Font size: Ctrl+scroll wheel
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = "CTRL",
    action = wezterm.action_callback(function(window, _)
      local cfg = window:get_config_overrides() or {}
      local size = cfg.font_size or config.font_size
      cfg.font_size = size + 1
      window:set_config_overrides(cfg)
    end),
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = "CTRL",
    action = wezterm.action_callback(function(window, _)
      local cfg = window:get_config_overrides() or {}
      local size = cfg.font_size or config.font_size
      cfg.font_size = math.max(1, size - 1)
      window:set_config_overrides(cfg)
    end),
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

