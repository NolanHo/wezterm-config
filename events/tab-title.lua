------------------------------------------------------------------------------------------
-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614 --
------------------------------------------------------------------------------------------

local wezterm = require('wezterm')
local Cells = require('utils.cells')
local OptsValidator = require('utils.opts-validator')
local ustr = require('utils.str')

local nf = wezterm.nerdfonts
local attr = Cells.attr

---
-- =======================================
-- Defining event setup options and schema
-- =======================================

---@class Event.TabTitleOptionsInput
---@field unseen_icon? 'none' | 'circle' | 'numbered_circle' | 'numbered_box'
---@field hide_active_tab_unseen? boolean
---@field show_progress? boolean
---@field title_refresh_interval_seconds? number

---@class Event.TabTitleOptions
---@field unseen_icon 'none' | 'circle' | 'numbered_circle' | 'numbered_box'
---@field hide_active_tab_unseen boolean
---@field show_progress boolean
---@field title_refresh_interval_seconds number

---Setup options for the tab title
---@type OptsValidator
local EVENT_OPTS = OptsValidator:new({
   {
      name = 'unseen_icon',
      type = 'string',
      enum = { 'none', 'circle', 'numbered_circle', 'numbered_box' },
      default = 'circle',
   },
   {
      name = 'hide_active_tab_unseen',
      type = 'boolean',
      default = true,
   },
   {
      name = 'show_progress',
      type = 'boolean',
      default = true,
   },
   {
      name = 'title_refresh_interval_seconds',
      type = 'number',
      default = 60,
   },
})

---
-- ===================
-- Constants and icons
-- ===================

local M = {}

---Commit date part of release tag `20250209-182623-44866cc1`
local PROGRESS_MIN_VERSION = 20250209
local PROGRESS_STALE_AFTER = 30 -- seconds

local ICON_SCIRCLE_LEFT = nf.ple_left_half_circle_thick --[[  ]]
local ICON_SCIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[  ]]

-- stylua: ignore
---@enum PrefixIcon
local ICON_PREFIX = {
   admin    = nf.md_shield_half_full, --[[ 󰞀 ]]
   wsl      = nf.cod_terminal_linux,  --[[  ]]
   debug    = nf.fa_bug,              --[[  ]]
   select   = nf.md_selection_search, --[[ 󱈅 ]]
   --  search = '🔭',
   launcher = nf.oct_rocket,          --[[  ]]
   edit     = nf.fa_edit,             --[[  ]]
}

---@enum UnseenOutputIcon
local ICON_UNSEEN = {
   cirlce = nf.fa_circle, --[[  ]]

   numbered_box_1 = nf.md_numeric_1_box_multiple, --[[ 󰼏 ]]
   numbered_box_2 = nf.md_numeric_2_box_multiple, --[[ 󰼐 ]]
   numbered_box_3 = nf.md_numeric_3_box_multiple, --[[ 󰼑 ]]
   numbered_box_4 = nf.md_numeric_4_box_multiple, --[[ 󰼒 ]]
   numbered_box_5 = nf.md_numeric_5_box_multiple, --[[ 󰼓 ]]
   numbered_box_6 = nf.md_numeric_6_box_multiple, --[[ 󰼔 ]]
   numbered_box_7 = nf.md_numeric_7_box_multiple, --[[ 󰼕 ]]
   numbered_box_8 = nf.md_numeric_8_box_multiple, --[[ 󰼖 ]]
   numbered_box_9 = nf.md_numeric_9_box_multiple, --[[ 󰼗 ]]
   numbered_box_10 = nf.md_numeric_9_plus_box_multiple, --[[ 󰼘 ]]

   numbered_circle_1 = nf.md_numeric_1_circle, --[[ 󰲠 ]]
   numbered_circle_2 = nf.md_numeric_2_circle, --[[ 󰲢 ]]
   numbered_circle_3 = nf.md_numeric_3_circle, --[[ 󰲤 ]]
   numbered_circle_4 = nf.md_numeric_4_circle, --[[ 󰲦 ]]
   numbered_circle_5 = nf.md_numeric_5_circle, --[[ 󰲨 ]]
   numbered_circle_6 = nf.md_numeric_6_circle, --[[ 󰲪 ]]
   numbered_circle_7 = nf.md_numeric_7_circle, --[[ 󰲬 ]]
   numbered_circle_8 = nf.md_numeric_8_circle, --[[ 󰲮 ]]
   numbered_circle_9 = nf.md_numeric_9_circle, --[[ 󰲰 ]]
   numbered_circle_10 = nf.md_numeric_9_plus_circle, --[[ 󰲲 ]]
}

local ICON_PROGRESS_PCT_FRAMES = {
   [1] = nf.md_circle_slice_1, --[[ 󰪞 ]]
   [2] = nf.md_circle_slice_2, --[[ 󰪟 ]]
   [3] = nf.md_circle_slice_3, --[[ 󰪠 ]]
   [4] = nf.md_circle_slice_4, --[[ 󰪡 ]]
   [5] = nf.md_circle_slice_5, --[[ 󰪢 ]]
   [6] = nf.md_circle_slice_6, --[[ 󰪣 ]]
   [7] = nf.md_circle_slice_7, --[[ 󰪤 ]]
   [8] = nf.md_circle_slice_8, --[[ 󰪥 ]]
}

local ICON_PROGRESS_IND_FRAMES = {
   [1] = '◜',
   [2] = '◠',
   [3] = '◝',
   [4] = '◞',
   [5] = '◡',
   [6] = '◟',
}

local TITLE_INSET = {
   default = 4,
   increment = 2,
}

-- stylua: ignore
---Render Segments
local RS = {
   scircle_left  = 1,
   icon          = 2,
   title         = 3,
   progress      = 4,
   unseen_output = 5,
   padding       = 6,
   scircle_right = 7,
}

-- stylua: ignore
-- luacheck: ignore
---Render Variants
local RV = {
   { RS.scircle_left, RS.padding, RS.title, RS.padding, RS.scircle_right },
   { RS.scircle_left, RS.padding, RS.title, RS.padding, RS.unseen_output, RS.padding, RS.scircle_right },

   { RS.scircle_left, RS.padding, RS.title, RS.padding, RS.progress, RS.padding, RS.scircle_right },
   { RS.scircle_left, RS.padding, RS.title, RS.padding, RS.progress, RS.padding, RS.unseen_output, RS.padding, RS.scircle_right },

   { RS.scircle_left, RS.padding, RS.icon, RS.padding, RS.title, RS.padding, RS.scircle_right },
   { RS.scircle_left, RS.padding, RS.icon, RS.padding, RS.title, RS.padding, RS.unseen_output, RS.padding, RS.scircle_right },

   { RS.scircle_left, RS.padding, RS.icon, RS.padding, RS.title, RS.padding, RS.progress, RS.padding, RS.scircle_right },
   { RS.scircle_left, RS.padding, RS.icon, RS.padding, RS.title, RS.padding, RS.progress, RS.padding, RS.unseen_output, RS.padding, RS.scircle_right },
}


---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
   text_default          = { bg = '#414868', fg = '#1a1b26' },
   text_hover            = { bg = '#545c7e', fg = '#1a1b26' },
   text_active           = { bg = '#7aa2f7', fg = '#16161e' },

   unseen_output_default = { bg = '#414868', fg = '#ff9e64' },
   unseen_output_hover   = { bg = '#545c7e', fg = '#ff9e64' },
   unseen_output_active  = { bg = '#7aa2f7', fg = '#ff9e64' },

   scircle_default       = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#414868' },
   scircle_hover         = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#545c7e' },
   scircle_active        = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#7aa2f7' },

   progress_percentage_default    = { bg = '#414868', fg = '#9ece6a' },
   progress_percentage_hover      = { bg = '#545c7e', fg = '#9ece6a' },
   progress_percentage_active     = { bg = '#7aa2f7', fg = '#9ece6a' },

   progress_error_default         = { bg = '#414868', fg = '#f7768e' },
   progress_error_hover           = { bg = '#545c7e', fg = '#f7768e' },
   progress_error_active          = { bg = '#7aa2f7', fg = '#f7768e' },

   progress_indeterminate_default = { bg = '#414868', fg = '#c0caf5' },
   progress_indeterminate_hover   = { bg = '#545c7e', fg = '#c0caf5' },
   progress_indeterminate_active  = { bg = '#7aa2f7', fg = '#c0caf5' },
}

---
-- ================
-- Helper functions
-- ================

---@param pct number
local function _pct_to_frame(pct)
   local frame = math.floor(pct * #ICON_PROGRESS_PCT_FRAMES / 100)
   return ICON_PROGRESS_PCT_FRAMES[frame]
end

local __indeter_frame = 1
local function _ind_to_frame()
   local frame = __indeter_frame
   __indeter_frame = (__indeter_frame % #ICON_PROGRESS_IND_FRAMES) + 1
   return ICON_PROGRESS_IND_FRAMES[frame]
end

---@param proc string
local function clean_process_name(proc)
   local a = string.gsub(proc, '.*[/\\](.*)', '%1')
   return a:gsub('%.exe$', '')
end

---@generic T
---@param pane_title string
---@param process_name string
---@return string, PrefixIcon?
local function create_base_title(pane_title, process_name)
   ---@type PrefixIcon|nil
   local prefix_icon = nil
   local base_title = pane_title

   -- if Debug-Overlay is active
   if base_title == 'Debug' then
      prefix_icon = ICON_PREFIX.debug
      base_title = base_title:upper()

   -- if built-in Launcher is active
   elseif base_title == 'Launcher' then
      prefix_icon = ICON_PREFIX.launcher
      base_title = base_title:upper()

   -- if shell is elevated to windows administrator
   elseif
      ustr.starts_with(base_title, 'Administrator:') or ustr.ends_with(base_title, '(Admin)')
   then
      prefix_icon = ICON_PREFIX.admin
      base_title = base_title:gsub('Administrator: ', ''):gsub('%(Admin%)', '')

   -- if shell is wsl instance
   elseif ustr.starts_with(process_name, 'wsl') then
      prefix_icon = ICON_PREFIX.wsl

   -- if `PromptInputLine` or `InputSelector` overlay is active
   elseif ustr.starts_with(base_title, 'InputSelector:') then
      prefix_icon = ICON_PREFIX.select
      base_title = base_title:gsub('InputSelector: ', '')
   elseif ustr.starts_with(base_title, 'InputLine:') then
      prefix_icon = ICON_PREFIX.edit
      base_title = base_title:gsub('InputLine: ', '')
   end

   return base_title, prefix_icon
end

---@param process_name string
---@param base_title string
---@param max_width number
---@param inset number
local function create_title(process_name, base_title, max_width, inset)
   local title

   if process_name:len() > 0 then
      title = process_name .. ' ~ ' .. base_title
   else
      title = base_title
   end

   local available_width = max_width - inset
   if available_width < 1 then
      available_width = 1
   end

   return wezterm.truncate_right(title, available_width)
end

local progress_stale = (function()
   -- stylua: ignore
   local status_score = {
      indeterminate = 100,
      error         = 200,
      percentage    = 300,
   }

   ---@type {sum: integer, last_changed: integer}[]
   local entries = {}

   ---Mark progress value as stale if the output hasn't changed in 30 seconds
   ---@param tab_index integer
   ---@param pane_index integer
   ---@param status 'indeterminate'|'error'|'percentage'
   ---@param pct integer
   ---@return boolean `true` if stale
   return function(tab_index, pane_index, status, pct)
      -- shifting by 5 bits, assuming no more than 31 panes will be
      -- spawned in a single tab
      local entry_id = (tab_index << 5) | pane_index

      if not entries[entry_id] then
         entries[entry_id] = {}
         entries[entry_id].sum = status_score[status] + pct
         entries[entry_id].last_changed = os.time()
         return false
      end

      local sum = status_score[status] + pct

      if sum ~= entries[entry_id].sum then
         entries[entry_id].sum = sum
         entries[entry_id].last_changed = os.time()
         return false
      end

      return os.time() - entries[entry_id].last_changed > PROGRESS_STALE_AFTER
   end
end)()

---@param options Event.TabTitleOptions
---@param tab_index integer
---@param panes PaneInformation[]
---@return {icon: string?, status: 'indeterminate'|'percentage'|'error'?}[]
local function check_progress(options, tab_index, panes)
   if not options.show_progress then
      return {}
   end

   local progress = {}
   local limit = 3

   for _, pane in ipairs(panes) do
      if #progress > limit then
         break
      end

      local prog = pane.progress
      local status = nil
      local icon = nil
      local pct = 0

      if not prog then
         goto continue
      elseif prog == 'Indeterminate' then
         status = 'indeterminate'
         icon = _ind_to_frame()
      elseif prog.Percentage ~= nil then
         status = 'percentage'
         icon, pct = _pct_to_frame(prog.Percentage), prog.Percentage
      elseif prog.Error ~= nil then
         status = 'error'
         icon, pct = _pct_to_frame(prog.Error), prog.Error
      end

      if icon and status then
         if not progress_stale(tab_index, pane.pane_index, status, pct) then
            table.insert(progress, { icon = icon, status = status })
         end
      end

      ::continue::
   end

   return progress
end

---@param options Event.TabTitleOptions
---@param is_active boolean
---@param panes PaneInformation[]
---@return UnseenOutputIcon|nil
local function check_unseen_output(options, is_active, panes)
   if options.unseen_icon == 'none' then
      return nil
   end

   if options.hide_active_tab_unseen and is_active then
      return nil
   end

   local icon = nil

   local count = 0
   local limit = 10

   if options.unseen_icon == 'circle' then
      limit = 0
   end

   for _, pane in ipairs(panes) do
      if count > limit then
         break
      end

      if pane.has_unseen_output then
         count = count + 1
      end
   end

   if count > 0 then
      icon = '*'
   end

   return icon
end

---
-- =================
-- Tab class and API
-- =================

local progress_cells = Cells:new():add_segment(RS.progress):add_segment(RS.padding, ' ')
local title_cells = Cells:new()
   :add_segment(RS.scircle_left, ICON_SCIRCLE_LEFT)
   :add_segment(RS.icon)
   :add_segment(RS.title, nil, nil, attr(attr.intensity('Bold')))
   :add_nested_segment(RS.progress)
   :add_segment(RS.unseen_output)
   :add_segment(RS.padding, ' ')
   :add_segment(RS.scircle_right, ICON_SCIRCLE_RIGHT)

---@class Tab
---@field title_locked boolean
---@field locked_title string
---@field has_icon boolean
---@field has_unseen boolean
---@field has_progress boolean
---@field last_rendered FormatItem[]?
---@field last_refresh_time integer
---@field last_tab_state string?
---@field last_max_width number?
local Tab = {}
Tab.__index = Tab

---@return Tab
function Tab:new()
   local tab = {
      title_locked = false,
      locked_title = '',
      has_icon = false,
      has_unseen = false,
      has_progress = false,
      last_rendered = nil,
      last_refresh_time = 0,
      last_tab_state = nil,
      last_max_width = nil,
   }

   return setmetatable(tab, self)
end

---@param tab TabInformation
---@param hover boolean
---@return string
local function get_tab_state(tab, hover)
   if tab.is_active then
      return 'active'
   elseif hover then
      return 'hover'
   end
   return 'default'
end

---@param event_opts Event.TabTitleOptions
---@param tab TabInformation
---@param hover boolean
---@param max_width number
function Tab:update_cells(event_opts, tab, hover, max_width)
   self.has_icon = false
   self.has_unseen = false
   self.has_progress = false

   local tab_state = get_tab_state(tab, hover)

   local process_name = ''
   local base_title, prefix_icon = create_base_title(
      tab.tab_title ~= '' and tab.tab_title or tab.active_pane.title,
      process_name
   )
   local unseen_icon = check_unseen_output(event_opts, tab.is_active, tab.panes)
   local progress = check_progress(event_opts, tab.tab_index, tab.panes)
   local inset = TITLE_INSET.default

   -- Prefix icons
   if prefix_icon then
      inset = inset + TITLE_INSET.increment
      self.has_icon = true
      title_cells:update_segment_text(RS.icon, prefix_icon)
   end

   -- Unseen output icon
   if unseen_icon then
      inset = inset + TITLE_INSET.increment
      self.has_unseen = true
      title_cells:update_segment_text(RS.unseen_output, unseen_icon)
   end

   -- Progress icons - BEGIN
   inset = inset + (TITLE_INSET.increment * #progress)
   self.has_progress = #progress > 0

   ---@type FormatItem[][]
   local nested_items = {}

   if self.has_progress then
      for i, prog in ipairs(progress) do
         local prog_colors = 'progress_' .. prog.status .. '_' .. tab_state
         progress_cells
            :update_segment_text(RS.progress, prog.icon)
            :update_segment_colors(RS.progress, colors[prog_colors])
            :update_segment_colors(RS.padding, colors['text_' .. tab_state])
         if i == #progress then
            table.insert(nested_items, progress_cells:render({ RS.progress }))
         else
            table.insert(nested_items, progress_cells:render({ RS.progress, RS.padding }))
         end
      end
   end

   title_cells:update_nested_segment(RS.progress, nested_items)
   -- Progress icons - END

   if self.title_locked then
      process_name = ''
      base_title = self.locked_title
   end

   local title = create_title(process_name, base_title, max_width, inset)

   title_cells:update_segment_text(RS.title, title)

   -- stylua: ignore
   title_cells
      :update_segment_colors(RS.scircle_left,   colors['scircle_' .. tab_state])
      :update_segment_colors(RS.icon,           colors['text_' .. tab_state])
      :update_segment_colors(RS.title,          colors['text_' .. tab_state])
      :update_segment_colors(RS.unseen_output,  colors['unseen_output_' .. tab_state])
      :update_segment_colors(RS.padding,        colors['text_' .. tab_state])
      :update_segment_colors(RS.scircle_right,  colors['scircle_' .. tab_state])
end

---@param title string
function Tab:update_and_lock_title(title)
   self.locked_title = title
   self.title_locked = true
   self.last_refresh_time = 0
end

---@return FormatItem[]
function Tab:render()
   local variant_idx = self.has_icon and 5 or 1
   if self.has_unseen then
      variant_idx = variant_idx + 1
   end
   if self.has_progress then
      variant_idx = variant_idx + 2
   end
   self.last_rendered = title_cells:render(RV[variant_idx])
   return self.last_rendered
end

---@param event_opts Event.TabTitleOptions
---@param tab TabInformation
---@param hover boolean
---@param max_width number
---@return boolean
function Tab:should_refresh(event_opts, tab, hover, max_width)
   if not self.last_rendered then
      return true
   end

   if event_opts.title_refresh_interval_seconds <= 0 then
      return true
   end

   local tab_state = get_tab_state(tab, hover)
   if self.last_tab_state ~= tab_state or self.last_max_width ~= max_width then
      return true
   end

   return os.time() - self.last_refresh_time >= event_opts.title_refresh_interval_seconds
end

---@type Tab[]
local tab_list = {}

---NOTE:
---Progress indicator is only available for WezTerm nightly versions `20250209-182623-44866cc1` and onwards.
---If an older version is used, the `show_progress` options will be hard-set to `false`.
---@param opts? Event.TabTitleOptionsInput Default: {unseen_icon = 'circle', hide_active_tab_unseen = true, show_progress = true}
M.setup = function(opts)
   local valid_opts, err = EVENT_OPTS:validate(opts or {})

   if err then
      wezterm.log_error(err)
   end

   ---@cast valid_opts Event.TabTitleOptions

   if tonumber(wezterm.version:sub(1, 8)) < PROGRESS_MIN_VERSION then
      valid_opts.show_progress = false
   end

   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   -- Tab name will remain locked until the `reset-tab-title` is triggered
   wezterm.on('tabs.manual-update-tab-title', function(window, pane)
      local title = nil

      if ustr.ends_with(wezterm.version, 'custom-build') then
         title = 'InputLine: Manual Tab Title'
      end

      window:perform_action(
         wezterm.action.PromptInputLine({
            title = title,
            description = wezterm.format({
               { Foreground = { Color = '#FFFFFF' } },
               { Attribute = { Intensity = 'Bold' } },
               { Text = 'Enter new name for tab' },
            }),
            action = wezterm.action_callback(function(_window, _pane, line)
               if line ~= nil then
                  local tab = window:active_tab()
                  local id = tab:tab_id()
                  tab_list[id]:update_and_lock_title(line)
               end
            end),
         }),
         pane
      )
   end)

   -- CUSTOM EVENT
   -- Event listener to unlock manually set tab name
   wezterm.on('tabs.reset-tab-title', function(window, _pane)
      ---@cast window Window
      local tab = window:active_tab()
      local id = tab:tab_id()
      tab_list[id].title_locked = false
      tab_list[id].last_refresh_time = 0
   end)

   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   wezterm.on('tabs.toggle-tab-bar', function(window, _pane)
      ---@cast window Window
      local effective_config = window:effective_config()
      window:set_config_overrides({
         enable_tab_bar = not effective_config.enable_tab_bar,
         background = effective_config.background,
      })
   end)

   -- BUILTIN EVENT
   wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
      if not tab_list[tab.tab_id] then
         tab_list[tab.tab_id] = Tab:new()
      end

      -- `max_width` refers to the `tab_max_width` option set in `config/appearance.lua`
      local tab_info = tab_list[tab.tab_id]
      if tab_info:should_refresh(valid_opts, tab, hover, max_width) then
         tab_info:update_cells(valid_opts, tab, hover, max_width)
         tab_info.last_refresh_time = os.time()
         tab_info.last_tab_state = get_tab_state(tab, hover)
         tab_info.last_max_width = max_width
         return tab_info:render()
      end

      return tab_info.last_rendered
   end)
end

return M
