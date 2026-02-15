{ pkgs, inputs, ... }:

{
  # Common home-manager configuration shared across all systems

  imports = [
    ../../modules/common/sops.nix
    ../../programs/btop.nix
    ../../programs/kitty.nix
    ../../programs/nvim.nix
    ../../programs/tmux.nix
    ../../programs/zsh.nix
  ];

  # Programs
  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
      tabs = "2";
      style = "plain";
      paging = "never";
    };
  };

  programs.fzf =
    let
      cmd = "fd --hidden --follow --ignore-file=$HOME/.gitignore --exclude .git";
    in
    {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      defaultOptions = [ "--layout=reverse --inline-info --height=90%" ];
      defaultCommand = cmd;
      fileWidgetCommand = "${cmd} --type f";
      changeDirWidgetCommand = "${cmd} --type d";
    };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      format = "[$symbol$version]($style)[$directory]($style)[$git_branch]($style)[$git_commit]($style)[$git_state]($style)[$git_status]($style)[$line_break]($style)[$username]($style)[$hostname]($style)[$shlvl]($style)[$jobs]($style)[$time]($style)[$status]($style)[$character]($style)";
      line_break.disabled = true;
      cmd_duration.disabled = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✖](bold red)";
        vicmd_symbol = "[❮](bold yellow)";
      };
      package.disabled = true;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Mustafa Zaki Assagaf";
        email = "mustafa.segf@gmail.com";
      };
      core.editor = "nvim";
      init.defaultBranch = "master";
      pull.rebase = false;
      pull.ff = true;
      url."ssh://git@source.golabs.io/".insteadOf = "https://source.golabs.io/";
    };
  };

  programs.lsd = {
    enable = true;
    settings = {
      layout = "grid";
      blocks = [
        "permission"
        "user"
        "group"
        "date"
        "size"
        "git"
        "name"
      ];
      color.when = "auto";
      date = "+%d %m(%b) %Y %a";
      recursion = {
        enable = false;
        depth = 7;
      };
      size = "short";
      permission = "rwx";
      no-symlink = false;
      total-size = false;
      hyperlink = "auto";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
      prompt = "enable";
      pager = "nvim";
    };
  };

  home.packages = with pkgs; [ ];
}
