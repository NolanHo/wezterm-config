local wezterm = require('wezterm')
local act = wezterm.action

-- stylua: ignore
---@type Key[]
local keys = {
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
