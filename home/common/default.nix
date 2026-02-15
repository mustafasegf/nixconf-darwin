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
      format = "$hostname$username$directory$git_branch$git_commit$git_state$git_status$line_break$shlvl$jobs$time$status$character";
      line_break.disabled = false;
      cmd_duration.disabled = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✖](bold red)";
        vicmd_symbol = "[❮](bold yellow)";
      };
      hostname = {
        ssh_only = false;
        format = "[@$hostname](bold blue) ";
        disabled = false;
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

  # Global environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
