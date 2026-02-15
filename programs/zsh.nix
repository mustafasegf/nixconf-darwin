{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Auto-detect Rust architecture for toolchain paths
  rustArch =
    if pkgs.stdenv.isLinux then
      if pkgs.stdenv.isAarch64 then "aarch64-unknown-linux-gnu" else "x86_64-unknown-linux-gnu"
    else if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "aarch64-apple-darwin" else "x86_64-apple-darwin"
    else
      throw "Unsupported platform";

  # Platform-specific PATH additions
  platformPaths = lib.optionalString pkgs.stdenv.isDarwin ''
    export PATH=$PATH:/opt/homebrew/bin:~/Library/Python/3.9/bin
    export PATH=$PATH:~/.cache/.bun/bin
    export LIBRARY_PATH=$LIBRARY_PATH:${pkgs.libiconv}/lib
  '';

  # Linux-specific env vars
  linuxEnv = lib.optionalString pkgs.stdenv.isLinux ''
    CARGO_MOMMYS_LITTLE="boy/baby"
  '';

  RUSTC_VERSION = "nightly";
in
{
  programs.zsh = {
    enable = true;
    autocd = true;

    # Disable built-in plugin loading - zinit handles everything (faster with deferred loading)
    autosuggestion.enable = false;
    enableCompletion = false;
    syntaxHighlighting.enable = false;

    defaultKeymap = "viins";

    envExtra = ''
      # XDG directories
      export XDG_DATA_HOME=$HOME/.local/share
      export XDG_CONFIG_HOME=$HOME/.config
      export XDG_STATE_HOME=$HOME/.local/state
      export XDG_CACHE_HOME=$HOME/.cache

      # Home cleaning - move config files to XDG directories
      export ANDROID_HOME="$XDG_DATA_HOME"/android
      export ASDF_DATA_DIR="$XDG_DATA_HOME"/asdf
      export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
      export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
      export HISTFILE="$XDG_STATE_HOME"/zsh/history
      export CARGO_HOME="$XDG_DATA_HOME"/cargo
      export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
      export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
      export ELINKS_CONFDIR="$XDG_CONFIG_HOME"/elinks
      export GEM_HOME="$XDG_DATA_HOME"/gem
      export GEM_SPEC_CACHE="$XDG_CACHE_HOME"/gem
      export GNUPGHOME="$XDG_DATA_HOME"/gnupg
      export GOPATH="$XDG_DATA_HOME"/go
      export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
      export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
      export KDEHOME="$XDG_CONFIG_HOME"/kde
      export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
      export DVDCSS_CACHE="$XDG_DATA_HOME"/dvdcss
      export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
      export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
      export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
      export PSQL_HISTORY="$XDG_DATA_HOME"/psql_history
      export KERAS_HOME="$XDG_STATE_HOME"/keras
      export REDISCLI_HISTFILE="$XDG_DATA_HOME"/redis/rediscli_history
      export VAGRANT_HOME="$XDG_DATA_HOME"/vagrant
      export WINEPREFIX="$XDG_DATA_HOME"/wine
      export _Z_DATA="$XDG_DATA_HOME"/z
      export WAKATIME_HOME="$XDG_CONFIG_HOME/wakatime"
      export ZSH_WAKATIME_BIN="$WAKATIME_HOME/.wakatime/wakatime-cli"

      # PATH - Common
      export PATH=$PATH:$CARGO_HOME/bin
      export PATH=$PATH:$RUSTUP_HOME:~/.rustup/toolchains/${RUSTC_VERSION}-${rustArch}/bin/
      export PATH=$PATH:$GOPATH/bin

      # PATH - Platform-specific
      ${platformPaths}

      # Platform-specific env vars
      ${linuxEnv}

      # Misc settings
      export CHTSH_QUERY_OPTIONS="style=rrt"

      # LF file manager icons
      export LF_ICONS="\
      di=:\
      fi=:\
      ln=:\
      or=:\
      ex=:\
      *.vimrc=:\
      *.viminfo=:\
      *.gitignore=:\
      *.c=:\
      *.cc=:\
      *.clj=:\
      *.coffee=:\
      *.cpp=:\
      *.css=:\
      *.d=:\
      *.dart=:\
      *.erl=:\
      *.exs=:\
      *.fs=:\
      *.go=:\
      *.h=:\
      *.hh=:\
      *.hpp=:\
      *.hs=:\
      *.html=:\
      *.java=:\
      *.jl=:\
      *.js=:\
      *.json=:\
      *.lua=:\
      *.md=:\
      *.php=:\
      *.pl=:\
      *.pro=:\
      *.py=:\
      *.rb=:\
      *.rs=:\
      *.scala=:\
      *.ts=:\
      *.vim=:\
      *.cmd=:\
      *.ps1=:\
      *.sh=:\
      *.bash=:\
      *.zsh=:\
      *.fish=:\
      *.tar=:\
      *.tgz=:\
      *.arc=:\
      *.arj=:\
      *.taz=:\
      *.lha=:\
      *.lz4=:\
      *.lzh=:\
      *.lzma=:\
      *.tlz=:\
      *.txz=:\
      *.tzo=:\
      *.t7z=:\
      *.zip=:\
      *.z=:\
      *.dz=:\
      *.gz=:\
      *.lrz=:\
      *.lz=:\
      *.lzo=:\
      *.xz=:\
      *.zst=:\
      *.tzst=:\
      *.bz2=:\
      *.bz=:\
      *.tbz=:\
      *.tbz2=:\
      *.tz=:\
      *.deb=:\
      *.rpm=:\
      *.jar=:\
      *.war=:\
      *.ear=:\
      *.sar=:\
      *.rar=:\
      *.alz=:\
      *.ace=:\
      *.zoo=:\
      *.cpio=:\
      *.7z=:\
      *.rz=:\
      *.cab=:\
      *.wim=:\
      *.swm=:\
      *.dwm=:\
      *.esd=:\
      *.jpg=:\
      *.jpeg=:\
      *.mjpg=:\
      *.mjpeg=:\
      *.gif=:\
      *.bmp=:\
      *.pbm=:\
      *.pgm=:\
      *.ppm=:\
      *.tga=:\
      *.xbm=:\
      *.xpm=:\
      *.tif=:\
      *.tiff=:\
      *.png=:\
      *.svg=:\
      *.svgz=:\
      *.mng=:\
      *.pcx=:\
      *.mov=:\
      *.mpg=:\
      *.mpeg=:\
      *.m2v=:\
      *.mkv=:\
      *.webm=:\
      *.ogm=:\
      *.mp4=:\
      *.m4v=:\
      *.mp4v=:\
      *.vob=:\
      *.qt=:\
      *.nuv=:\
      *.wmv=:\
      *.asf=:\
      *.rm=:\
      *.rmvb=:\
      *.flc=:\
      *.avi=:\
      *.fli=:\
      *.flv=:\
      *.gl=:\
      *.dl=:\
      *.xcf=:\
      *.xwd=:\
      *.yuv=:\
      *.cgm=:\
      *.emf=:\
      *.ogv=:\
      *.ogx=:\
      *.aac=:\
      *.au=:\
      *.flac=:\
      *.m4a=:\
      *.mid=:\
      *.midi=:\
      *.mka=:\
      *.mp3=:\
      *.mpc=:\
      *.ogg=:\
      *.ra=:\
      *.wav=:\
      *.oga=:\
      *.opus=:\
      *.spx=:\
      *.xspf=:\
      *.pdf=:\
      *.nix=:\
      "
    '';

    initContent = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      unset -v SSH_ASKPASS

      # Tmux configuration
      ZSH_TMUX_AUTOSTART=false
      ZSH_TMUX_AUTOSTART_ONCE=false
      ZSH_TMUX_AUTOCONNECT=true
      ZSH_TMUX_CONFIG=~/.config/tmux/tmux.conf

      # Vi-mode configuration
      VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
      VI_MODE_SET_CURSOR=true
      MODE_INDICATOR="%F{yellow}+%f"
      KEYTIMEOUT=15
      VI_MODE_PROMPT_INFO=true

      # LF file manager integration
      LFCD="$HOME/.config/lf/lfcd.sh"
      if [ -f "$LFCD" ]; then
        source "$LFCD"
      fi

      # Helper function to create and cd into directory
      function mkcdir() {
        mkdir -p -- "$1" && cd -P -- "$1"
      }

      # Jump to git repository root
      function cdg() { cd "$(git rev-parse --show-toplevel)" }

      # Git shortcuts
      function gsts() { git status }
      function gc() { git commit -am "$@" }
      function ga() { git add "$@" }
      function gs() { git switch "$@" }
      function gsc() { git switch -c "$@" }
      function gm() { git merge "$@" }
      function gcb() { git checkout -b "$@" }
      function gca() { git commit --amend --no-edit -m "$@" }
      function gu() { git reset --soft HEAD~1 }
      function gst() { git stash "$@" }
      function gstp() { git stash pop "$@" }
      function grmc() { git rm --cached "$@" }

      function gpo() { git push origin "$@" }
      function gplo() { git pull origin "$@" }
      function gpu() { git push upstream "$@" }
      function gplu() { git pull upstream "$@" }

      # Dynamic main branch detection (works with main/master/etc)
      function gsm() { gs "$(basename `git symbolic-ref refs/remotes/origin/HEAD`)" }
      function gpom() { gpo "$(basename `git symbolic-ref refs/remotes/origin/HEAD`)" }
      function gpum() { gpu "$(basename `git symbolic-ref refs/remotes/origin/HEAD`)" }
      function gplom() { gplo "$(basename `git symbolic-ref refs/remotes/origin/HEAD`)" }
      function gplum() { gplu "$(basename `git symbolic-ref refs/remotes/origin/HEAD`)" }

      function gplob() { gplo "$(git symbolic-ref --short HEAD)" }
      function gplub() { gplu "$(git symbolic-ref --short HEAD)" }
      function gpob() { gpo "$(git symbolic-ref --short HEAD)" }
      function gpub() { gpu "$(git symbolic-ref --short HEAD)" }

      # Generate gitignore from toptal.com
      function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@ }
      function gil() { gi list | tr , '\n' | fzf --multi | xargs echo | tr ' ' , | xargs -I {} curl -sLw "\n" 'https://www.toptal.com/developers/gitignore/api/{}' | tee .gitignore }

      # Nix rebuild helpers
      function update() {
        pushd $HOME/.config/nixpkgs
        sudo nixos-rebuild switch --flake .#
        popd
      }

      function update-test() {
        pushd $HOME/.config/nixpkgs
        sudo nixos-rebuild test --flake .#
        popd
      }

      alias update-flake='nix flake update --commit-lock-file'

      # Memory usage by process
      function tmem() {
        smem -t -k -c pss -P "$@"
      }

      ${lib.optionalString pkgs.stdenv.isLinux ''
        # Linux-only: cargo-mommy wrappers
        function cmw() {
          cargo watch -x "mommy $@"
        }

        function cmwr() {
          cargo watch -x "mommy run $@"
        }
      ''}

      ${lib.optionalString pkgs.stdenv.isDarwin ''
        # Mac-only: Delete current directory and go up
        function frfr() {
          original_dir="$(pwd)"
          original_dir_name="$(basename "$original_dir")"
          cd ..
          if [ "$(basename "$original_dir")" != "$(basename "$(pwd)")" ]
          then
            rm -rf "$original_dir"
            if command -v cowsay > /dev/null
            then
              cowsay "RIP $original_dir_name"
            else
              echo "RIP $original_dir_name"
            fi
          else
            echo "Failed to delete: same directory."
          fi
        }

        # Mac-only: Kubernetes helpers
        function kgrep() {
          kubectl get "$1" | grep "$2" | awk '{print $1}'
        }

        function kpfz() {
          query=$1
          shift
          pod=$(kubectl get pod --no-headers -o custom-columns=":metadata.name" | fzf --filter="$query" --select-1 --exit-0)
          [ -n "$pod" ] && kubectl port-forward "$pod" "$@"
        }
      ''}

      # Tmux auto-attach on supported terminals
      if [ "$TERM" = "xterm-ghostty" ] || [[ "$TERM" == "xterm-256color" ]] || [ "$TERM" = "xterm-kitty" ]; then
        tmux new -As0
      fi

      # Initialize zinit for fast plugin loading with turbo mode
      ZINIT_HOME="''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit/zinit.git"
      if [[ ! -d "$ZINIT_HOME" ]]; then
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
      fi
      source "''${ZINIT_HOME}/zinit.zsh"

      # Essential plugins - load immediately
      zinit light-mode for \
        OMZL::history.zsh \
        OMZL::key-bindings.zsh

      # Vi-mode - load immediately (better than OMZ vi-mode)
      zinit ice depth=1
      zinit light jeffreytse/zsh-vi-mode

      # Deferred plugins - load after prompt (turbo mode)
      zinit wait lucid for \
        OMZP::tmux \
        OMZP::sudo \
        OMZP::copyfile \
        OMZP::copypath \
        OMZP::dirhistory \
        OMZP::history \
        OMZP::colored-man-pages

      # Docker completions - deferred
      zinit wait lucid for \
        OMZP::docker \
        OMZP::docker-compose

      # Cloud tools - heavily deferred (these are slow)
      zinit wait"2" lucid for \
        OMZP::gcloud

      # AWS - deferred, skip slow homebrew check
      zinit wait"2" lucid for \
        atload"unset -f _awscli-homebrew-installed 2>/dev/null" \
        OMZP::aws

      # History substring search - deferred
      zinit wait lucid for \
        zsh-users/zsh-history-substring-search

      # z for directory jumping - deferred
      zinit wait lucid for \
        agkozak/zsh-z

      # Dracula theme - deferred
      zinit wait lucid for \
        dracula/zsh

      # Atuin - deferred
      zinit wait lucid for \
        ellie/atuin

      ${lib.optionalString pkgs.stdenv.isLinux ''
        # Wakatime - Linux only, deferred
        zinit wait lucid for \
          sobolevn/wakatime-zsh-plugin
      ''}

      # Syntax highlighting, autosuggestions, and completions - load last, deferred
      # zicompinit replaces compinit with a faster cached version
      zinit wait lucid for \
        atinit"zicompinit; zicdreplay" \
        zsh-users/zsh-syntax-highlighting \
        zsh-users/zsh-autosuggestions
    '';

    shellAliases = {
      # Common aliases (all platforms)
      rm = "trash put";
      cat = "bat";
      grep = "rg";
      c = "clear";

      l = "ls -Alh";
      lta = "ls -A --tree";

      g = "git";
      lg = "lazygit";
      oc = "opencode";
      wget = ''wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'';
      xbindkeys = ''xbindkeys -f "$XDG_CONFIG_HOME"/xbindkeys/config'';

      mans = ''man -k . | cut -d " " -f 1 | fzf -m --preview "man {1}" | xargs man'';

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      # Linux-only: cargo-mommy aliases
      car = "cargo";
      cm = "cargo mommy";
      cmr = "cargo mommy run";
      cmrr = "cargo mommy run --release";
      cmb = "cargo mommy build";
      cmbr = "cargo mommy build --release";
      cma = "cargo mommy add";
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      # Mac-only: Kubernetes aliases
      k = "kubectl";
      kl = "kubectl logs";
      klf = "kubectl logs -f";
      kg = "kubectl get";
      kgp = "kubectl get pod";
      kd = "kubectl describe";
      kdp = "kubectl describe pod";
      kpf = "kubectl port-forward";
      kctx = "kubectx";
      kns = "kubens";
      gl = "GITLAB_HOST=source.golabs.io glab";
      v = "nvim";
    };

    history = {
      size = 100000;
    };
  };
}
