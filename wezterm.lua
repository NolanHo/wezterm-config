local Config = require('config')

-- scan backdrops up-front (`wezterm.glob` only works during the initial config
-- load) and pick the startup image; cycle with CMD+, / CMD+. / CMD+b
require('utils.backdrops'):scan_images_dir():set_img_name('astro-jelly')

require('events.left-status').setup()
require('events.tab-title').setup({
   hide_active_tab_unseen = true,
   unseen_icon = 'none',
   show_progress = false,
   title_refresh_interval_seconds = 60,
})
require('events.new-tab-button').setup()
require('events.gui-startup').setup()

return Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domains'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options
