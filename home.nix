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
  home.shellAliases = {
    "..." = "cd ../..";
    cd = "z";
    explain = "gh copilot explain";
    fm = "yazi";
    ghce = "gh copilot explain";
    ghcs = "gh copilot suggest";
    help-explain = "gh copilot explain";
    less = "${pkgs.nvimpager}/bin/nvimpager";

    help-suggest = "gh copilot suggest";
    l = "eza --icons --git-ignore";
    lg = "lazygit";
    ll = "eza --long --icons --color --hyperlink";
    lt = "eza --long --tree --icons --color --hyperlink";
    gg = "${pkgs.git-graph}/bin/git-graph";
    montigrafana =
      "xdg-open http://localhost:3000 && ssh -L 3000:localhost:3000 mmbs@monti.hhu.de";
    montikuma =
      "xdg-open http://localhost:3001 && ssh -L 3001:localhost:3001 mmbs@monti.hhu.de";
    montipostgres = "ssh -L 5432:localhost:5432 mmbs@monti.hhu.de";
    montiprometheus =
      "xdg-open http://localhost:9090 && ssh -L 9090:localhost:9090 mmbs@monti.hhu.de";
    montissh = "TERM=xterm-256color ssh mmbs@monti.hhu.de";
    nd = "nix develop -c $SHELL";
    ndo = "nix develop --offline --command $SHELL";
    o = "xdg-open";
    steammount = ''
      udisksctl unmount -b /dev/disk/by-uuid/98bf9471-2174-498f-b8d8-9b918a387ec4 &&
      udisksctl mount -b /dev/disk/by-uuid/98bf9471-2174-498f-b8d8-9b918a387ec4 --options " exec "
    '';
    suggest = "gh copilot suggest";
    v = "nvim";
    ":e" = "nvim";
  };
  home.stateVersion = "22.05";
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
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
    enableFishIntegration = true;
  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fish_vi_key_bindings
    '';
  };
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.lazygit.enable = true;
  programs.neovim = {
    enable = true;
    extraLuaPackages = luaPkgs: with luaPkgs; [ luarocks magick jsregexp ];
    extraPackages = with pkgs; [
      inotify-tools
      clang
      ghostscript
      hlint
      imagemagick
      lazygit
      lua-language-server
      lua51Packages.lua
      luajit
      manix
      mermaid-cli
      nginx-language-server
      nil
      nixd
      nixfmt-classic
      poppler_utils
      tectonic
      tree-sitter
    ];
    extraPython3Packages = pyPkgs:
      with pyPkgs; [
        cairosvg # for image rendering
        ipykernel
        ipython
        jupyter-client
        matplotlib
        numpy
        plotly # for image rendering
        pnglatex # for image rendering
        pylatexenc
        pynvim
        pyperclip
        sympy
      ];
    plugins = with pkgs.vimPlugins; [ neotest-haskell image-nvim ];
    vimAlias = true;
    vimdiffAlias = true;
  };
  programs.nushell = {
    enable = false;
    configFile.source = ./config/nushell/config.nu;
    envFile.source = ./config/nushell/env.nu;
    shellAliases = {

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
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
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
    enableFishIntegration = true;
    enableNushellIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
  };
  programs.zsh = {
    enable = false;
    initExtra = ''
      # load completions from ~/.config/zsh/completions
      fpath=(~/.config/zsh/completions $fpath)
    '';
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
  systemd.user.services.mpris-proxy = {
    Unit.Description = "Mpris proxy";
    Unit.After = [ "network.target" "sound.target" ];
    Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    Install.WantedBy = [ "default.target" ];
  };
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [ pkgs.hyprlandPlugins.hyprgrass pkgs.hyprlandPlugins.hyprspace ];
    extraConfig = ''
      exec-once=waytrogen --restore
      source = /etc/nixos/config/hyprland/extra.conf
    '';
  };
  xdg.configFile."nushell/completion.nu".source =
    ./config/nushell/completion.nu;
}
