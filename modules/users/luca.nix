{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.users.luca;
in
{
  options.modules.users.luca =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable the user 'luca'";
    };

  config = mkIf cfg.enable {
    users.users.luca = {
      initialHashedPassword = "$6$W62LDzjtggxhhOiJ$KKM1yuHOrEr3Mz4MSstUGBtlpEF2AHR8bAzFeaqo2l.rrka/phKnzbKbyM5HX955d9et2NnV2fOr9LnDCgB5M1";
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "storage"
        "sdcard"
        "video"
        "bluetooth"
        "adbusers"
        "wheel"
        "kvm"
        "libvirtd"
        "libvirt"
        "docker"
        "input"
        "vboxusers" # maybe use `users.extraGroups.vboxusers.members = [ "luca" ];` 
        "nordvpn"
      ];
      shell = pkgs.nushell;
      # Web-eID / European Smart-Card support https://nixos.wiki/wiki/Web_eID
      # pkgs.config.firefox.euwebid = true;
      # services.pcscd.enable = true;
      packages =
        let
          myClion = pkgs.symlinkJoin {
            name = "myClion";
            paths = with pkgs; [
              jetbrains.clion
              gnumake
              check
              pkg-config
            ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/clion \
                --prefix "$out/bin":PATH
            '';
          };
          myAndroidStudio = pkgs.symlinkJoin {
            name = "myAndroidStudio";
            paths = with pkgs; [
              pkgs.android-studio
              gnumake
              check
              pkg-config
              glibc
              android-tools
              jdk
              git
            ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/android-studio \
                --prefix PUB_CACHE=/home/luca/.pub-cache \
                --prefix ANDROID_SDK_ROOT=/home/luca/.local/lib/arch-id/android-sdk/ \
                --prefix ANDROID_HOME=/home/luca/.local/lib/arch-id/android-sdk/ \
                --prefix ANDROID_JAVA_HOME=${pkgs.jdk.home}
            '';
          };
        in
        with pkgs; [
          # Internet
          # (tts.overrideAttrs (new: old: {
          #   propagatedBuildInputs = old.propagatedBuildInputs ++ [
          #     pkgs.espeak-ng
          #   ];
          # }))
          firefox
          # (firefox.override {
          #   extraNativeMessagingHosts = with pkgs.nur.repos.wolfangaukang; [ vdhcoapp ];
          #   cfg = {
          #     enablePlasmaBrowserIntegration = true;
          #     enableFXCastBridge = true;
          #     speechSynthesisSupport = true;
          #   };
          # })
          # config.nur.repos.xddxdd.deepspeech-gpu
          # bitwarden
          # microsoft-edge
          # discord
          # whatsapp-for-linux
          # ferdium
          opendrop # NOTE: share files between devices
          transmission-gtk # NOTE: torrent client
          birdtray # NOTE: Thunderbird tray icon
          thunderbird # NOTE: Email client
          # Privacy
          veracrypt
          # lesspass-cli
          # Video-Editing
          obs-studio
          kdenlive
          glaxnimate
          mediainfo
          # Drawing
          xournalpp
          # TODO: flathub rnote seems to be more up to date? Maybe change back to this someday...
          # pkgs.rnote
          inkscape
          # mypaint
          gimp
          aseprite
          # (pkgs.blender.override {
          #   cudaSupport = true;
          # })
          krita
          # Media
          vlc
          mpv
          # yt-dlp
          # evince
          # deadbeef
          # sxiv
          # sony-headphones-client
          # Gaming
          xboxdrv
          # (retroarch.override {
          #   cores = with libretro; [
          #     mupen64plus
          #     libretro.pcsx2
          #   ];
          # })
          # Productivity
          libreoffice
          # Programming
          # dbeaver
          # inputs.neovim-luca.defaultPackage.x86_64-linux
          neovim
          # rnix-lsp
          luajit
          lazygit
          # emacs-gtk
          hlint
          devdocs-desktop
          # devdocs-desktop
          # math
          # sage
          # julia-bin
          # rstudio
          # JavaScript/TypeScript
          nodejs_20
          jetbrains.webstorm
          jetbrains.phpstorm
          # (pkgs.php82.buildEnv {
          #   extensions = ({ enabled
          #                 , all
          #                 }: enabled ++ (with all; [
          #     apcu
          #     curl
          #     gd
          #     gmp
          #     intl
          #     ldap
          #     mbstring
          #     mysqli
          #     pdo_mysql
          #     pdo_sqlite
          #     readline
          #     redis
          #     soap
          #     sqlite3
          #     xdebug
          #     xml
          #     zip
          #   ]));
          #   extraConfig = ''
          #     xdebug.mode = debug
          #     xdebug.start_with_request = yes
          #   '';
          # })
          # php82Packages.composer
          # php82Packages.psysh
          # python
          # jetbrains.pycharm-professional
          # Latex
          pandoc
          quarto
          poppler_utils
          texlive.combined.scheme-full
          tex-match
          # Rust
          # cargo
          # rustc
          rustup
          # Lean
          elan
          mathlibtools
          # Java
          jdk
          gradle
          jetbrains.idea-ultimate
          # C
          myClion
          valgrind
          gcc
          check
          lldb
          gdb
          # conan
          # C#
          mono
          dotnet-sdk_7
          dotnetCorePackages.aspnetcore_7_0
          dotnetCorePackages.sdk_7_0
          dotnetCorePackages.runtime_7_0
          jetbrains.rider
          # R
          radianWrapper
          (
            rWrapper.override {
              packages = with rPackages; [
                ggplot2
                dplyr
                xts
                languageserver
                readr
                kableExtra
                dplyr
                ggplot2
                magrittr
                car
                statsr
                broom
                stargazer
                tidyr
                gridExtra
                ggpubr
                cowplot
                knitr
                ellipse
                lubridate
                webshot2
              ];
            }
          )
          # Spelling
          hunspell
          hunspellDicts.de_DE
          hunspellDicts.en_US
          # Android
          frida-tools
          jadx
          quark-engine
          apktool
          libmtp
          usbutils
          scrcpy
          nodePackages.cordova
          android-tools
          myAndroidStudio
          (writeScriptBin "shareAndroidScreen" ''
            #!/usr/bin/env bash
            adb exec-out screenrecord --output-format=h264 - | ${pkgs.ffmpeg-full}/bin/ffplay -framerate 60 -probesize 32 -sync video  -
          '')
          # Flutter
          clang
          cmake
          ninja
          gtk3
          # flutter
          # dart
          # MongoDB / Docker
          docker-compose
          mongodb-compass
          # game-dev
          # godotMono
          godot_4
          # pkgs.godot
          # pkgs.unityhub
          # UNI HHU ZEUG
          # konferenzen
          # zoom-us
          # teams
          # slack
          # PROPORA
          # mob
          # Hardware
          miraclecast
          # VPN
          # config.nur.repos.LuisChDev.nordvpn
        ];
    };
    programs.steam = {
      package = pkgs.steam;
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    # hardware.xpadneo.enable = true;
    # hardware.xone.enable = true;
  };
}
