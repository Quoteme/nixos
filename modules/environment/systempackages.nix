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
        myPython = pkgs.python312.withPackages (ps: with ps; [
          pytest
          debugpy
          ipython
          pandas
          numpy
          scipy
          matplotlib
          plotly
          pipx
        ]);
      in
      with pkgs; [
        distrobox
        devbox
        fzf
        playerctl
        tmsu
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
        wl-clipboard
        xcolor
        xclip
        killall
        xorg.xkill
        wget
        git
        gh
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
        nvimpager
        # TODO: add manual how to add nix-flakes as system-programs
        # TODO: add this manual to reddit post
        # st-nix
        # alacritty
        kitty
        # Window Manager
        rofi
        rofimoji
        # networkmanager_dmenu
        openvpn
        networkmanager-openvpn
        # File manager
        # onboard
        # TODO: Add swypeGuess
        # https://git.sr.ht/~earboxer/swipeGuess
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
        # https://github.com/Mic92/nix-ld?tab=readme-ov-file#my-pythonnodejsrubyinterpreter-libraries-do-not-find-the-libraries-configured-by-nix-ld
        (pkgs.writeShellScriptBin "python" ''
          export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
          exec ${pkgs.python3}/bin/python "$@"
        '')
        (haskellPackages.ghcWithPackages (hpkgs: with hpkgs; [
          text-format-simple
          haskell-dap
          ghci-dap
          haskell-debug-adapter
        ]))
        haskell-language-server
        cabal-install
      ];
  };
}

