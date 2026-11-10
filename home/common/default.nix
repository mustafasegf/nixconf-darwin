{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ../../modules/common/sops.nix
    ../../programs/btop.nix
    ../../programs/kitty.nix
    ../../programs/nvim.nix
    ../../programs/tmux.nix
    ../../programs/zellij.nix
    ../../programs/zsh.nix
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
  };

  programs = {
    bash.enable = true;
    zsh.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.hide_env_diff = true;
    };
    bat = {
      enable = true;
      config = {
        tabs = "2";
        style = "plain";
        paging = "never";
      };
    };
    fzf =
      let
        cmd = "fd --hidden --follow --ignore-file=$HOME/.gitignore --exclude .git";
      in
      {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        defaultOptions = [ "--layout=reverse --inline-info --height=90%" ];
        defaultCommand = cmd;
        fileWidget.command = "${cmd} --type f";
        changeDirWidget.command = "${cmd} --type d";
        historyWidget.command = "";
      };
    starship = {
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
    git = {
      enable = true;
      signing.format = "ssh";
      settings = {
        user = {
          name = "Mustafa Zaki Assagaf";
          email = "mustafa.segf@gmail.com";
          signingKey = "~/.ssh/id_ed25519";
        };
        commit = {
          gpgSign = true;
          verbose = true;
        };
        tag.gpgSign = true;
        gpg.format = "ssh";
        column.ui = "auto";
        branch.sort = "-committerdate";
        tag.sort = "version:refname";
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        rerere = {
          enabled = true;
          autoUpdate = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        help.autocorrect = "prompt";
        core.editor = "nvim";
        init.defaultBranch = "master";
        merge.conflictStyle = "zdiff3";
        pull.rebase = true;
        pull.ff = true;
        url."ssh://git@source.golabs.io/".insteadOf = "https://source.golabs.io/";
      };
      includes = [
        # {
        #   condition = "gitdir:~/work/aiand/";
        #   contents = {
        #     user.email = "mustafa@aiand.com";
        #     user.signingKey = "~/.ssh/id_ed25519_aiand";
        #     url."git@github.com-aiand:".insteadOf = "git@github.com:";
        #   };
        # }
      ];
    };
    lsd = {
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
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "nvim";
        prompt = "enable";
        pager = "nvim";
      };
    };
    ghostty = {
      enable = true;
      package = null;
      systemd.enable = false;
      settings = {
        macos-option-as-alt = true;
        theme = "catppuccin-mocha";
        font-size = 16;
      };
    };
    lazygit.enable = true;
    yazi = {
      enable = true;
      shellWrapperName = "yy";
    };
    k9s.enable = true;
    eza = {
      enable = true;
      enableZshIntegration = false;
    };
    atuin = {
      enable = true;
      enableZshIntegration = false; # handled via zinit for zsh-vi-mode compat
    };
  };

  home.packages = with pkgs; [ ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.activation.herdrIntegrations =
    let
      herdr = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      [ -d "$HOME/.pi/agent" ] && run mkdir -p "$HOME/.pi/agent/extensions"
      for agent in pi omp codex claude; do
        run ${herdr}/bin/herdr integration install "$agent" || true
      done
      run ${herdr}/bin/herdr plugin install qu8n/herdr-automatic-rename --yes || true
    '';
}
