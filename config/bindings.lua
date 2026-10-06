local wezterm = require('wezterm')
local act = wezterm.action
local backdrops = require('utils.backdrops')

-- stylua: ignore
---@type Key[]
local keys = {
   -- backgrounds
   {
      key = '/',
      mods = 'CMD',
      action = wezterm.action_callback(function(window)
         backdrops:random(window)
      end),
   },
   {
      key = ',',
      mods = 'CMD',
      action = wezterm.action_callback(function(window)
         backdrops:cycle_back(window)
      end),
   },
   {
      key = '.',
      mods = 'CMD',
      action = wezterm.action_callback(function(window)
         backdrops:cycle_forward(window)
      end),
   },
   {
      key = '/',
      mods = 'CMD|CTRL',
      action = act.InputSelector({
         title = 'InputSelector: Select Background',
         choices = backdrops:choices(),
         fuzzy = true,
         fuzzy_description = 'Select Background: ',
         action = wezterm.action_callback(function(window, _pane, idx)
            if not idx then
               return
            end
            backdrops:set_img(window, tonumber(idx))
         end),
      }),
   },
   {
      key = 'b',
      mods = 'CMD',
      action = wezterm.action_callback(function(window)
         backdrops:toggle_focus(window)
      end),
   },

   { key = '1', mods = 'CMD|CTRL', action = act.MoveTab(0) },
   { key = '[', mods = 'CMD|CTRL', action = act.MoveTabRelative(-1) },
   { key = ']', mods = 'CMD|CTRL', action = act.MoveTabRelative(1) },
   {
      key = 'r',
      mods = 'CMD|CTRL',
      action = act.PromptInputLine({
         description = 'Rename tab',
         action = wezterm.action_callback(function(window, _, line)
            if not line or line == '' then
               return
            end

            window:active_tab():set_title(line)
         end),
      }),
   },
}

---@type Config
return {
   send_composed_key_when_left_alt_is_pressed = false,
   send_composed_key_when_right_alt_is_pressed = false,
   keys = keys,
}
