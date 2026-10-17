local gpu_adapters = require('utils.gpu-adapter')
local backdrops = require('utils.backdrops')
local colors = require('colors.custom')

---@type Config
return {
   -- 60 fps: fluid on the 120Hz panel, and measured on this machine the cap is
   -- nearly free (heavy-output CPU was ~identical at 30/60/120; cost is text
   -- ingestion; idle = 0). Raise to 120 for extra smoothness, 30 for battery.
   max_fps = 60,
   front_end = 'WebGpu', ---@type 'WebGpu' | 'OpenGL' | 'Software'
   webgpu_power_preference = 'HighPerformance',
   webgpu_preferred_adapter = gpu_adapters:pick_best(),
   -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Dx12', 'IntegratedGpu'),
   -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Gl', 'Other'),

   -- Larger per-line render caches keep rapid scrollback scrolling smooth instead
   -- of re-shaping lines. Defaults are 1024; memory scales with unique lines seen.
   -- ref: https://github.com/wezterm/wezterm/discussions/3664
   shape_cache_size = 2048,
   line_state_cache_size = 4096,
   line_quad_cache_size = 4096,
   line_to_ele_shape_cache_size = 4096,
   underline_thickness = '1.5pt',

   -- cursor
   animation_fps = 30,
   cursor_blink_ease_in = 'EaseOut',
   cursor_blink_ease_out = 'EaseOut',
   default_cursor_style = 'BlinkingBlock',
   cursor_blink_rate = 650,

   -- color scheme
   colors = colors,

   -- background: pass in `true` if you want wezterm to start with focus mode on (no bg images)
   background = backdrops:initial_options({ no_img = false }),

   -- scrollbar
   enable_scroll_bar = true,

   -- tab bar
   enable_tab_bar = true,
   hide_tab_bar_if_only_one_tab = false,
   use_fancy_tab_bar = false,
   tab_max_width = 23,
   show_tab_index_in_tab_bar = false,
   switch_to_last_active_tab_when_closing_tab = true,

   -- command palette
   command_palette_fg_color = '#bb9af7',
   command_palette_bg_color = '#16161e',
   command_palette_font_size = 12,
   command_palette_rows = 25,

   -- window
   window_padding = {
      left = 6,
      right = 6,
      top = 10,
      bottom = 7.5,
   },
   adjust_window_size_when_changing_font_size = false,
   window_close_confirmation = 'NeverPrompt',
   -- No window-level glass. macOS runs the background blur inside WindowServer,
   -- and each frame the window redraws it re-samples whatever is behind it; with
   -- a 5K/120Hz display plus live content underneath this dominated GPU time
   -- (WindowServer ~26% of wall clock in a 20s sample). Keep the frame styling
   -- in-app instead: border, titlebar colors and padding cost nothing.
   window_background_opacity = 1.0,
   text_background_opacity = 1.0,
   macos_window_background_blur = 0,
   window_decorations = 'INTEGRATED_BUTTONS|RESIZE|MACOS_FORCE_DISABLE_SHADOW',
   integrated_title_button_alignment = 'Left',
   integrated_title_button_color = '#7fdbca',
   -- Outer frame: titlebar/border/button colors from the Tokyo Night palette.
   -- Border widths are a hairline, brightening the window edge against busy
   -- wallpapers. See `window_frame` in the docs for the full field list.
   window_frame = {
      active_titlebar_bg = '#071923',
      inactive_titlebar_bg = '#05131c',
      active_titlebar_fg = '#c0caf5',
      inactive_titlebar_fg = '#565f89',
      active_titlebar_border_bottom = '#7aa2f7',
      inactive_titlebar_border_bottom = '#1f2335',
      -- `button_*` only applies once integrated_title_button_style is switched
      -- away from the default 'MacosNative' (which draws the system traffic
      -- lights and ignores these colors).
      button_bg = '#071923',
      button_fg = '#7fdbca',
      button_hover_bg = '#7aa2f7',
      button_hover_fg = '#1a1b26',
      border_left_width = '1px',
      border_right_width = '1px',
      border_top_height = '1px',
      border_bottom_height = '1px',
      border_left_color = '#2f3b5c',
      border_right_color = '#2f3b5c',
      border_top_color = '#2f3b5c',
      border_bottom_color = '#2f3b5c',
      -- font = fonts.font,
      -- font_size = fonts.font_size,
   },
   -- Dim panes that don't have focus so the active split reads at a glance.
   inactive_pane_hsb = {
      saturation = 0.9,
      brightness = 0.75,
   },

   visual_bell = {
      fade_in_function = 'EaseIn',
      fade_in_duration_ms = 250,
      fade_out_function = 'EaseOut',
      fade_out_duration_ms = 250,
      target = 'CursorColor',
   },
}
