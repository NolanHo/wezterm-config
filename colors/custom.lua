-- Tokyo Night Storm
-- ref: https://github.com/folke/tokyonight.nvim (storm variant)
-- ansi/brights/cursor/selection values verified against wezterm builtin "Tokyo Night Storm"
-- stylua: ignore
local tn = {
   bg             = '#24283b',
   bg_dark        = '#1f2335',
   bg_highlight   = '#292e42',
   terminal_black = '#414868',
   fg             = '#c0caf5',
   fg_dark        = '#a9b1d6',
   fg_gutter      = '#3b4261',
   dark3          = '#545c7e',
   comment        = '#565f89',
   red            = '#f7768e',
   orange         = '#ff9e64',
   yellow         = '#e0af68',
   green          = '#9ece6a',
   teal           = '#73daca',
   cyan           = '#7dcfff',
   blue           = '#7aa2f7',
   purple         = '#9d7cd8',
   magenta        = '#bb9af7',
}

local colorscheme = {
   foreground = tn.fg,
   background = tn.bg,
   cursor_bg = tn.fg,
   cursor_border = tn.fg,
   cursor_fg = tn.bg,
   selection_bg = '#2e3c64',
   selection_fg = tn.fg,
   ansi = {
      '#1d202f', -- black
      tn.red,
      tn.green,
      tn.yellow,
      tn.blue,
      tn.magenta,
      tn.cyan,
      tn.fg_dark, -- white
   },
   brights = {
      tn.terminal_black, -- black
      tn.red,
      tn.green,
      tn.yellow,
      tn.blue,
      tn.magenta,
      tn.cyan,
      tn.fg, -- white
   },
   tab_bar = {
      background = 'rgba(0, 0, 0, 0.4)',
      active_tab = {
         bg_color = tn.terminal_black,
         fg_color = tn.fg,
      },
      inactive_tab = {
         bg_color = tn.bg_dark,
         fg_color = tn.fg_dark,
      },
      inactive_tab_hover = {
         bg_color = tn.bg_highlight,
         fg_color = tn.fg,
      },
      new_tab = {
         bg_color = tn.bg,
         fg_color = tn.fg,
      },
      new_tab_hover = {
         bg_color = tn.bg_dark,
         fg_color = tn.fg,
         italic = true,
      },
   },
   visual_bell = tn.red,
   indexed = {
      [16] = tn.orange,
      [17] = tn.fg,
   },
   scrollbar_thumb = tn.terminal_black,
   split = tn.dark3,
   compose_cursor = tn.magenta,
}

return colorscheme
