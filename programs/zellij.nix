{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = false; # We handle this manually for better control
    # settings = {
    #   # Theme - matching dracula style
    #   theme = "dracula";
    #   themes.dracula = {
    #     fg = "#F8F8F2";
    #     bg = "#282A36";
    #     black = "#21222C";
    #     red = "#FF5555";
    #     green = "#50FA7B";
    #     yellow = "#F1FA8C";
    #     blue = "#BD93F9";
    #     magenta = "#FF79C6";
    #     cyan = "#8BE9FD";
    #     white = "#F8F8F2";
    #     orange = "#FFB86C";
    #   };
    #
    #   # Keybindings - similar to your tmux setup
    #   keybinds = {
    #     # Unbind defaults and set vi mode style
    #     unbind = [ "Ctrl b" ];
    #
    #     # Normal mode keybindings
    #     normal = {
    #       # Prefix-like behavior with Ctrl-a (similar to your tmux)
    #       "bind Ctrl a" = {
    #         SwitchToMode = "Tmux";
    #       };
    #
    #       # Window navigation (similar to j/k in tmux)
    #       "bind Alt h" = {
    #         GoToPreviousTab = { };
    #       };
    #       "bind Alt l" = {
    #         GoToNextTab = { };
    #       };
    #
    #       # Pane navigation with vim keys (matches your H/J/K/L)
    #       # Alt h/l are handled by tab navigation above;
    #       # Alt h/j/k/l for pane focus is covered by the shared mode section below
    #       "bind Alt k" = {
    #         MoveFocus = "Up";
    #       };
    #       "bind Alt j" = {
    #         MoveFocus = "Down";
    #       };
    #
    #       # Resize panes (matches your C-h/C-j/C-k/C-l)
    #       "bind Ctrl k" = {
    #         Resize = "Increase Up";
    #       };
    #       "bind Ctrl j" = {
    #         Resize = "Increase Down";
    #       };
    #       "bind Ctrl h" = {
    #         Resize = "Increase Left";
    #       };
    #       "bind Ctrl l" = {
    #         Resize = "Increase Right";
    #       };
    #     };
    #
    #     # Tmux mode - activated with Ctrl+a
    #     tmux = {
    #       "bind Esc" = {
    #         SwitchToMode = "Normal";
    #       };
    #       "bind Ctrl c" = {
    #         SwitchToMode = "Normal";
    #       };
    #
    #       # Splits - similar to your | and - bindings
    #       "bind |" = {
    #         NewPane = "Right";
    #         SwitchToMode = "Normal";
    #       };
    #       "bind -" = {
    #         NewPane = "Down";
    #         SwitchToMode = "Normal";
    #       };
    #
    #       # New tab (similar to new window)
    #       "bind c" = {
    #         NewTab = { };
    #         SwitchToMode = "Normal";
    #       };
    #
    #       # Rename tab
    #       "bind ," = {
    #         SwitchToMode = "RenameTab";
    #         TabNameInput = 0;
    #       };
    #
    #       # Close pane
    #       "bind x" = {
    #         CloseFocus = { };
    #         SwitchToMode = "Normal";
    #       };
    #
    #       # Detach
    #       "bind d" = {
    #         Detach = { };
    #       };
    #
    #       # Next/Previous tab (similar to j/k)
    #       "bind n" = {
    #         GoToNextTab = { };
    #       };
    #       "bind p" = {
    #         GoToPreviousTab = { };
    #       };
    #
    #       # Select tab by number
    #       "bind 1" = {
    #         GoToTab = 1;
    #         SwitchToMode = "Normal";
    #       };
    #       "bind 2" = {
    #         GoToTab = 2;
    #         SwitchToMode = "Normal";
    #       };
    #       "bind 3" = {
    #         GoToTab = 3;
    #         SwitchToMode = "Normal";
    #       };
    #       "bind 4" = {
    #         GoToTab = 4;
    #         SwitchToMode = "Normal";
    #       };
    #       "bind 5" = {
    #         GoToTab = 5;
    #         SwitchToMode = "Normal";
    #       };
    #       "bind 6" = {
    #         GoToTab = 6;
    #         SwitchToMode = "Normal";
    #       };
    #       "bind 7" = {
    #         GoToTab = 7;
    #         SwitchToMode = "Normal";
    #       };
    #       "bind 8" = {
    #         GoToTab = 8;
    #         SwitchToMode = "Normal";
    #       };
    #       "bind 9" = {
    #         GoToTab = 9;
    #         SwitchToMode = "Normal";
    #       };
    #
    #       # Toggle fullscreen
    #       "bind z" = {
    #         ToggleFocusFullscreen = { };
    #         SwitchToMode = "Normal";
    #       };
    #
    #       # Toggle floating panes
    #       "bind w" = {
    #         ToggleFloatingPanes = { };
    #         SwitchToMode = "Normal";
    #       };
    #     };
    #
    #     # Shared navigation across modes
    #     shared = {
    #       # Vim-style pane navigation (matches your setup)
    #       "bind Alt k" = {
    #         MoveFocus = "Up";
    #       };
    #       "bind Alt j" = {
    #         MoveFocus = "Down";
    #       };
    #       "bind Alt h" = {
    #         MoveFocus = "Left";
    #       };
    #       "bind Alt l" = {
    #         MoveFocus = "Right";
    #       };
    #     };
    #   };
    #
    #   # UI settings
    #   ui = {
    #     pane_frames = {
    #       rounded_corners = true;
    #       hide_session_name = false;
    #     };
    #   };
    #
    #   # Behavior settings
    #   pane_viewport_serialization = true;
    #   scrollback_lines_to_serialize = 10000;
    #   session_serialization = true;
    #
    #   # Default shell
    #   default_shell = "zsh";
    #
    #   # Layout directory
    #   layout_dir = null;
    #
    #   # Copy to clipboard on selection (similar to yank)
    #   copy_command = "wl-copy";
    #   copy_on_select = true;
    #
    #   # Mouse support (matches your setup)
    #   mouse_mode = true;
    # };
  };
}
