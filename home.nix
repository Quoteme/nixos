{ config, pkgs, attrs, ... }: {
  home.file.".ghci".text = ''
    import Data.Function
    :set prompt "\ESC[1;34m%s\n\ESC[0;34mλ> \ESC[m"
  '';
  home.file.".haskeline".text = ''
    editMode: Vi
  '';
  home.file.".ipython/profile_default/ipython_config.py".text = ''
    c.TerminalInteractiveShell.editing_mode = 'vi'
  '';
  home.stateVersion = "22.05";
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
  programs.atuin.settings = { keymap_mode = "auto"; };
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      set -o vi
      bind -m vi-command 'Control-l: clear-screen'
      bind -m vi-insert 'Control-l: clear-screen'
    '';
    enableCompletion = true;
    sessionVariables = {
      VISUAL = "nvim";
      EDITOR = "nvim";
    };
  };
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };
  # ipython vim bindings
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
  # ghci vim bindings
  programs.gitui.enable = true;
  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.lazygit.enable = true;
  programs.mpv = {
    enable = true;
    config = {
      profile = " gpu-hq ";
      ytdl-format = " bestvideo + bestaudio ";
      webui-port = " 4000 ";
      script-opts = " ytdl_hook-ytdl_path=yt-dlp";
      osc = " no ";
      border = " no ";
    };
    scripts = with pkgs.mpvScripts; [
      sponsorblock
      mpris
      mpv-playlistmanager
      thumbfast
      simple-mpv-webui
      modernx
    ];
  };
  programs.neovim = {
    enable = true;
    extraLuaPackages = luaPkgs: with luaPkgs; [ luarocks magick ];
    extraPackages = with pkgs; [
      clang
      cmake-lint
      hlint
      imagemagick
      lazygit
      lua-language-server
      luajit
      manix
      mathimg
      neocmakelsp
      nixfmt-classic
      poppler_utils
      tectonic
      tree-sitter
    ];
    extraPython3Packages = pyPkgs:
      with pyPkgs; [
        pylatexenc
        pynvim
        jupyter-client
        cairosvg # for image rendering
        pnglatex # for image rendering
        plotly # for image rendering
        numpy
        matplotlib
        sympy
        pyperclip
        ipython
        ipykernel
      ];
    plugins = with pkgs; [ vimPlugins.neotest-haskell ];
    vimAlias = true;
    vimdiffAlias = true;
  };
  programs.nushell = {
    enable = true;
    configFile.source = ./config/nushell/config.nu;
    envFile.source = ./config/nushell/env.nu;
    shellAliases = {
      cd = "z";
      explain = "gh copilot explain";
      fm = "yazi";
      ghce = "gh copilot explain";
      ghcs = "gh copilot suggest";
      help-explain = "gh copilot explain";
      help-suggest = "gh copilot suggest";
      lg = "lazygit";
      o = "xdg-open";
      python-enter-venv = "sh -i -c 'source .venv/bin/activate ; nu'";
      suggest = "gh copilot suggest";
      v = "nvim";
    };
  };
  programs.readline = {
    enable = true;
    variables = {
      # see https://www.man7.org/linux/man-pages/man3/readline.3.html
      editing-mode = "vi";
      keymap = "vi";
      completion-ignore-case = "on";
      show-all-if-ambiguous = "on";
    };
  };
  programs.rofi = {
    enable = true;
    font = "scientifica, Gohu GohuFont, Siji 8";
    theme = "sidebar";
    extraConfig = {
      modi = "combi";
      combi-modi = "drun,window,ssh";
      show-icons = true;
    };
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
  programs.zsh = {
    enable = true;
    initExtra = ''
      transfer(){ if [ $# -eq 0 ];then echo "No arguments specified.\nUsage:\n transfer <file|directory>\n ... | transfer <file_name>">&2;return 1;fi;if tty -s;then file="$1";file_name=$(basename "$file");if [ ! -e "$file" ];then echo "$file: No such file or directory">&2;return 1;fi;if [ -d "$file" ];then file_name="$file_name.zip" ,;(cd "$file"&&zip -r -q - .)|curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null,;else cat "$file"|curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;fi;else file_name=$1;curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;fi;}
    '';
    shellAliases = {
      # Monti
      montissh = "TERM=xterm-256color ssh mmbs@monti.hhu.de";
      montikuma =
        "xdg-open http://localhost:3001 && ssh -L 3001:localhost:3001 mmbs@monti.hhu.de";
      montiprometheus =
        "xdg-open http://localhost:9090 && ssh -L 9090:localhost:9090 mmbs@monti.hhu.de";
      montigrafana =
        "xdg-open http://localhost:3000 && ssh -L 3000:localhost:3000 mmbs@monti.hhu.de";
      montipostgres = "ssh -L 5432:localhost:5432 mmbs@monti.hhu.de";
      # Steam
      steammount = ''
        udisksctl unmount -b /dev/disk/by-uuid/98bf9471-2174-498f-b8d8-9b918a387ec4 &&
        udisksctl mount -b /dev/disk/by-uuid/98bf9471-2174-498f-b8d8-9b918a387ec4 --options " exec "
      '';

      l = "eza";
      lg = "lazygit";
      ll = "eza --long --icons --color --hyperlink";
      lt = "eza --long --tree --icons --color --hyperlink";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      o = "xdg-open";
    };
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        {
          name = "dracula/zsh";
          tags = [ "as:theme" "depth:1" ];
        }
        {
          name = "plugins/dirhistory";
          tags = [ "from:oh-my-zsh" "depth:1" ];
        }
        {
          name = "jeffreytse/zsh-vi-mode";
          tags = [ "depth:1" ];
        }
        {
          name = "plugins/zoxide";
          tags = [ "from:oh-my-zsh" "depth:1" ];
        }
        {
          name = "plugins/flutter";
          tags = [ "from:oh-my-zsh" "depth:1" ];
        }
        {
          name = "plugins/fd";
          tags = [ "from:oh-my-zsh" "depth:1" ];
        }
      ];
    };
  };
  services.picom = {
    # disabled for now. Configure multiple monitors someday
    enable = false;
    shadow = false;
    shadowOpacity = 0.8;
    fade = false;
    fadeDelta = 5;
    fadeExclude = [ "window_type *= 'menu'" ];
    inactiveOpacity = 1.0;
    opacityRules = [
      "100:name *= 'Netflix'"
      "100:name *= 'Wikipedia'"
      "100:name *= 'Youtube'"
      "97:name *= 'control_center'"
    ];
  };
  services.polybar = {
    enable = false;
    package = pkgs.polybar.override { pulseSupport = true; };
    config = ./config/polybar;
    script = "polybar top &";
  };
  services.syncthing = {
    enable = true;
    tray = { enable = true; };
  };
  systemd.user.services.mpris-proxy = {
    Unit.Description = "Mpris proxy";
    Unit.After = [ "network.target" "sound.target" ];
    Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    Install.WantedBy = [ "default.target" ];
  };
  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = rofi
    wifi_chars = ▂▄▆█
  '';
  xdg.configFile."nushell/completion.nu".source =
    ./config/nushell/completion.nu;
  xdg.configFile."xmonad/build".executable = true;
  xdg.configFile."xmonad/build".text = ''
    #!/usr/bin/env bash

    export XMONAD_DEV_DIR=$HOME/Dokumente/dev/xmonad-luca

    # create the directory where the xmonad-dev binary will be stored
    mkdir -p $HOME/.cache/xmonad/
    # build xmonad using nix
    nix build $XMONAD_DEV_DIR -o $HOME/.config/xmonad/result
    # copy the resuslt to where xmonad expects it
    cp $HOME/.config/xmonad/result/bin/xmonad-luca $HOME/.cache/xmonad/xmonad-x86_64-linux
    # make the file overwritable, so we can hot-reload xmonad by doing:
    # ```
    # xmonad --recompile
    # ```
    # followed by <kbd>Mod</kbd>+<kbd>Shift</kbd>+<kbd>Delete</kbd>
    chmod +w $HOME/.cache/xmonad/xmonad-x86_64-linux
  '';
}
