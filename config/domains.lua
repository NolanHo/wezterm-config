local wezterm = require('wezterm')
local platform = require('utils.platform')

local remote_shell_fallback_prog = {
   'sh',
   '-lc',
   'if command -v zsh >/dev/null 2>&1; then exec zsh -l; '
      .. 'elif command -v bash >/dev/null 2>&1; then exec bash -l; '
      .. 'else exec sh -l; fi',
}

---@type Config
local options = {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   ssh_domains = wezterm.default_ssh_domains(),

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = {},
}

for _, dom in ipairs(options.ssh_domains) do
   if dom.multiplexing == 'None' then
      dom.assume_shell = 'Posix'
      dom.default_prog = remote_shell_fallback_prog
   end
end

if platform.is_win then
   options.ssh_domains = {
      {
         name = 'ssh:wsl',
         username = 'kevin',
         remote_address = 'localhost',
         multiplexing = 'None',
         default_prog = { 'fish', '-l' },
         assume_shell = 'Posix',
      },
   }

   options.wsl_domains = {
      {
         name = 'wsl:ubuntu-fish',
         distribution = 'Ubuntu',
         username = 'kevin',
         default_cwd = '/home/kevin',
         default_prog = { 'fish', '-l' },
      },
      {
         name = 'wsl:ubuntu-bash',
         distribution = 'Ubuntu',
         username = 'kevin',
         default_cwd = '/home/kevin',
         default_prog = { 'bash', '-l' },
      },
   }
end

return options
