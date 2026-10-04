local disable_hyperlinks = true

local hyperlink_rules = {
   -- Matches: a URL in parens: (URL)
   {
      regex = '\\((\\w+://\\S+)\\)',
      format = '$1',
      highlight = 1,
   },
   -- Matches: a URL in brackets: [URL]
   {
      regex = '\\[(\\w+://\\S+)\\]',
      format = '$1',
      highlight = 1,
   },
   -- Matches: a URL in curly braces: {URL}
   {
      regex = '\\{(\\w+://\\S+)\\}',
      format = '$1',
      highlight = 1,
   },
   -- Matches: a URL in angle brackets: <URL>
   {
      regex = '<(\\w+://\\S+)>',
      format = '$1',
      highlight = 1,
   },
   -- Then handle URLs not wrapped in brackets
   {
      regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
      format = '$0',
   },
   -- implicit mailto link
   {
      regex = '\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b',
      format = 'mailto:$0',
   },
}

---@type Config
return {
   -- behaviours
   automatically_reload_config = true,
   exit_behavior = 'CloseOnCleanExit', -- if the shell program exited with a successful status
   clean_exit_codes = { 130 },
   exit_behavior_messaging = 'Verbose',
   status_update_interval = 5000,
   audible_bell = 'Disabled',

   scrollback_lines = 20000,

   quick_select_patterns = {
      [[\b(?:localhost|127\.0\.0\.1|0\.0\.0\.0)(?::\d{2,5})?(?:/[^\s"'`<>]*)?\b]],
      [[\b[\w][\w.-]+/[A-Za-z0-9_.-]+#\d+\b]],
      [[\b[\w][\w.-]+/[A-Za-z0-9_.-]+@[0-9a-fA-F]{7,40}\b]],
      [[\b[A-Z][A-Z0-9]+-\d+\b]],
      [[\bPR-\d+\b]],
      [[\b(?:feat|feature|fix|bugfix|chore|docs|refactor|test|perf|ci|build|release|hotfix)/[A-Za-z0-9._/-]+\b]],
      '\\b(?:request|req|trace|span)[-_ ]?id[=:]\\s*[0-9a-fA-F-]{8,}\\b',
      [[\b[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}\b]],
      [[\b\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?\b]],
      [[\b\d{4}-\d{2}-\d{2}\b]],
      [[\b\d{2}:\d{2}:\d{2}\b]],
      [[(?:~|/)[^\s:]+(?::\d+){1,2}\b]],
      [[(?:\./|\../)[^\s:]+(?::\d+){1,2}\b]],
   },

   hyperlink_rules = disable_hyperlinks and {} or hyperlink_rules,
}
