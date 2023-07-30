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
        myPython = pkgs.python310.withPackages (ps: with ps; [
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
        ]);
      in
      with pkgs; [
        pkgs.unstable.distrobox
        # themes
        # Icons
        gnome.adwaita-icon-theme
        papirus-icon-theme
        whitesur-icon-theme
        # GTK
        mojave-gtk-theme
        whitesur-gtk-theme
        adapta-gtk-theme
        numix-gtk-theme
        orchis-theme
        # Cursor
        numix-cursor-theme
        # Small Utilities
        # nix
        nixpkgs-fmt
        nix-du
        nix-tree
        # nix-ld stuff
        nix-autobahn
        nix-alien
        nix-index
        fzf
        playerctl
        pcmanfm
        tmsu
        qdirstat
        lm_sensors
        appimage-run
        trashy
        cobang
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
        meld
        cookiecutter
        git
        gh
        unstable.gitkraken
        exa
        ripgrep
        pdfgrep
        fd
        bat
        power-profiles-daemon
        emote
        # archiving
        zip
        unzip
        toilet
        htop-vim
        nvimpager
        # TODO: add manual how to add nix-flakes as system-programs
        # TODO: add this manual to reddit post
        st-nix
        alacritty
        # Window Manager
        rofi
        rofimoji
        networkmanager_dmenu
        networkmanagerapplet
        openvpn
        networkmanager-openvpn
        # File manager
        gparted
        onboard
        # TODO: Add swypeGuess
        # https://git.sr.ht/~earboxer/swipeGuess
        (pkgs.svkbd.override {
          layout = "de";
        })
        jgmenu
        pamixer
        nitrogen
        xdotool
        neofetch
        onefetch
        libnotify
        screenrotate
        # inputs.rescreenapp.defaultPackage.x86_64-linux
        # inputs.control_center.defaultPackage.x86_64-linux
        batsignal
        polkit_gnome
        lightlocker
        xidlehook
        # Storage
        rclone
        # emulation
        virt-manager
        virglrenderer
        # Wine
        wineWowPackages.full
        pkgs.unstable.bottles
        # stuff that is needed pretty much everywhere
        nodePackages.http-server
        myPython
        (haskellPackages.ghcWithPackages myGHCPackages)
        unstable.haskell-language-server
        unstable.ghc
        unstable.haskellPackages.haskell-dap
        unstable.haskellPackages.ghci-dap
        unstable.haskellPackages.haskell-debug-adapter
        unstable.cabal-install
        # unstable.stack
      ];
  };
}

