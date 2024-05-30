{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.environment.systemPackages;
in
{
  options.modules.environment.systemPackages =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable my opinionated set of default system packages";
    };

  config = mkIf cfg.enable {
    environment.systemPackages =
      let
        myGHCPackages = (hpkgs: with hpkgs; [
          xmonad
          xmonad-contrib
          xmonad-extras
          text-format-simple
        ]);
        myPython = pkgs.python311.withPackages (ps: with ps; [
          pyclip
          debugpy
          pytest
          ipython
          jupyterlab
          jupyter-lsp
          pandas
          sympy
          numpy
          scipy
          uritools
          matplotlib
          plotly
          pipx
          frida-python
        ]);
      in
      with pkgs; [
        distrobox
        # themes
        # Icon
        gnome.adwaita-icon-theme
        papirus-icon-theme
        whitesur-icon-theme
        # GTK
        mojave-gtk-theme
        whitesur-gtk-theme
        # adapta-gtk-theme
        # numix-gtk-theme
        # orchis-theme
        # fluent-gtk-theme
        # Cursor
        # numix-cursor-theme
        # Small Utilities
        # nix
        nixpkgs-fmt
        nix-du
        nix-tree
        # nix-ld stuff
        # nix-autobahn
        # nix-alien
        nix-index
        fzf
        playerctl
        pcmanfm
        tmsu
        qdirstat
        lm_sensors
        appimage-run
        trashy
        mons
        arandr
        brightnessctl
        iw
        ffmpeg
        linux-router
        macchanger
        pavucontrol
        imagemagick
        maim
        jq
        tldr
        flameshot
        xclip
        wl-clipboard
        xcolor
        peek
        killall
        xorg.xkill
        wget
        cookiecutter
        git
        gh
        gitkraken
        eza
        # [10 Rust CLI tools for 2022](https://www.youtube.com/watch?v=haitmoSyTls)
        ripgrep
        delta
        kondo
        sd
        just
        pdfgrep
        fd
        bat
        power-profiles-daemon
        # archiving
        zip
        unzip
        toilet
        htop-vim
        btop
        stable.nvimpager
        # TODO: add manual how to add nix-flakes as system-programs
        # TODO: add this manual to reddit post
        # st-nix
        # alacritty
        kitty
        # Window Manager
        rofi
        rofimoji
        # networkmanager_dmenu
        networkmanagerapplet
        openvpn
        networkmanager-openvpn
        # File manager
        gparted
        # onboard
        # TODO: Add swypeGuess
        # https://git.sr.ht/~earboxer/swipeGuess
        (pkgs.svkbd.override {
          layout = "de";
        })
        pamixer
        neofetch
        onefetch
        libnotify
        screenrotate
        # inputs.rescreenapp.defaultPackage.x86_64-linux
        # inputs.control_center.defaultPackage.x86_64-linux
        batsignal
        # polkit_gnome
        xidlehook
        # Storage
        rclone
        # emulation
        virt-manager
        virglrenderer
        # Wine
        wineWowPackages.full
        # bottles
        # stuff that is needed pretty much everywhere
        nodePackages.http-server
        myPython
        (haskellPackages.ghcWithPackages myGHCPackages)
        haskell-language-server
        ghc
        haskellPackages.haskell-dap
        haskellPackages.ghci-dap
        haskellPackages.haskell-debug-adapter
        cabal-install
      ];
  };
}

