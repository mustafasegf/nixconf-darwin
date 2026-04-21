{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  zjstatusWasm = "${
    inputs.zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default
  }/bin/zjstatus.wasm";
in
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      pane_frames = false;
      session_serialization = true;
      scrollback_lines_to_serialize = 10000;
      mouse_mode = true;
      copy_on_select = true;
    };
  };

  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
        default_tab_template {
            children
            pane size=1 borderless=true {
                plugin location="file:${zjstatusWasm}" {
                    format_left   "{mode} #[fg=#89b4fa,bold]{session}"
                    format_center "{tabs}"
                    format_right  "{datetime}"
                    format_space  ""

                    border_enabled  "false"
                    border_char     "─"
                    border_format   "#[fg=#313244]{char}"
                    border_position "top"

                    hide_frame_for_single_pane "true"

                    mode_normal        "#[bg=#a6e3a1,fg=#1e1e2e,bold] NORMAL "
                    mode_locked        "#[bg=#f38ba8,fg=#1e1e2e,bold] LOCKED "
                    mode_tmux          "#[bg=#fab387,fg=#1e1e2e,bold] TMUX "
                    mode_resize        "#[bg=#f9e2af,fg=#1e1e2e,bold] RESIZE "
                    mode_pane          "#[bg=#89b4fa,fg=#1e1e2e,bold] PANE "
                    mode_tab           "#[bg=#cba6f7,fg=#1e1e2e,bold] TAB "
                    mode_scroll        "#[bg=#a6e3a1,fg=#1e1e2e,bold] SCROLL "
                    mode_enter_search  "#[bg=#f9e2af,fg=#1e1e2e,bold] SEARCH "
                    mode_search        "#[bg=#f9e2af,fg=#1e1e2e,bold] SEARCH "
                    mode_rename_tab    "#[bg=#cba6f7,fg=#1e1e2e,bold] RENAME "
                    mode_rename_pane   "#[bg=#cba6f7,fg=#1e1e2e,bold] RENAME "
                    mode_session       "#[bg=#89b4fa,fg=#1e1e2e,bold] SESSION "
                    mode_move          "#[bg=#fab387,fg=#1e1e2e,bold] MOVE "
                    mode_prompt        "#[bg=#89b4fa,fg=#1e1e2e,bold] PROMPT "
                    mode_default_to_mode "normal"

                    tab_normal              "#[fg=#6c7086] {index} {name} "
                    tab_normal_fullscreen   "#[fg=#6c7086] {index} {name} [] "
                    tab_normal_sync         "#[fg=#6c7086] {index} {name} <> "
                    tab_active              "#[fg=#89b4fa,bold] {index} {name} "
                    tab_active_fullscreen   "#[fg=#89b4fa,bold] {index} {name} [] "
                    tab_active_sync         "#[fg=#89b4fa,bold] {index} {name} <> "
                    tab_separator           "#[fg=#313244]|"

                    datetime          "#[fg=#6c7086]{format}"
                    datetime_format   "%H:%M %d-%b"
                    datetime_timezone "Auto"
                }
            }
        }
    }
  '';
}
