local wezterm = require('wezterm')
local platform = require('utils.platform')

local font_size = platform.is_mac and 15.0 or 9.75

---@type Config
return {
   font = wezterm.font_with_fallback({
      { family = 'Fira Code', weight = 'Medium' },
      { family = 'LXGW WenKai Mono', weight = 'Medium' },
      { family = 'LXGW WenKai', weight = 'Medium' },
   }),
   font_size = font_size,
   line_height = 1.06,
   harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },

   --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
   freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
   freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
