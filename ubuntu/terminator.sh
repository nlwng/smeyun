#优化terminator
修改config

[global_config]
  enabled_plugins = CustomCommandsMenu, TestPlugin, ActivityWatch, TerminalShot, MavenPluginURLHandler
[keybindings]
[layouts]
  [[default]]
    [[[child1]]]
      parent = window0
      profile = default
      type = Terminal
    [[[window0]]]
      parent = ""
      type = Window
[plugins]
[profiles]
  [[default]]
    background_darkness = 0.86
    background_image = None
    background_type = image
    copy_on_selection = True
    cursor_color = "#eee8d5"
    font = Monospace 12
    foreground_color = "#00ff00"
    scroll_on_output = False
    scrollback_lines = 50000
    use_system_font = False
  [[New Profile]]
    background_image = None

