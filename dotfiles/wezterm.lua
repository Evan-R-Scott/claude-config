local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Only on Windows: use the default WSL distro (see: wsl --set-default <name>).
-- If detection fails, nothing is set and WezTerm uses its normal default shell.
if wezterm.target_triple:find('windows') then
  local ok, success, stdout = pcall(wezterm.run_child_process, { 'wsl.exe', '-l', '-q' })
  if ok and success then
    -- wsl.exe prints UTF-16, which arrives with NUL bytes
    local distro = stdout:gsub('\0', ''):match('[^\r\n]+')
    if distro then
      config.default_domain = 'WSL:' .. distro
    end
  end
end

config.color_scheme = 'Tokyo Night'

config.window_background_opacity = 0.9
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.use_fancy_tab_bar = true

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  { key = 'w', mods = 'CTRL', action = wezterm.action.CloseCurrentTab { confirm = false } },
  { key = '=', mods = 'LEADER', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }, },
  { key = '-', mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }, },
  { mods = 'ALT', key = 'LeftArrow', action = wezterm.action.ActivatePaneDirection 'Left' },
  { mods = 'ALT', key = 'RightArrow', action = wezterm.action.ActivatePaneDirection 'Right' },
  { mods = 'ALT', key = 'UpArrow', action = wezterm.action.ActivatePaneDirection 'Up' },
  { mods = 'ALT', key = 'DownArrow', action = wezterm.action.ActivatePaneDirection 'Down' },

  { mods = 'CTRL|SHIFT', key = 'R', action = wezterm.action.ReloadConfiguration },
  { mods = 'CTRL|SHIFT', key = 'C', action = wezterm.action.CopyTo 'Clipboard' },
  { mods = 'CTRL|SHIFT', key = 'V', action = wezterm.action.PasteFrom 'Clipboard' },
}

return config