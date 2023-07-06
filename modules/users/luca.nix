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
      ];
      shell = pkgs.zsh;
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
              pkgs.unstable.android-studio
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
          pkgs.stable.google-chrome
          (tts.overrideAttrs (new: old: {
            propagatedBuildInputs = old.propagatedBuildInputs ++ [
              pkgs.unstable.espeak-ng
            ];
          }))
          # microsoft-edge
          # discord
          # whatsapp-for-linux
          ferdium
          transmission-gtk
          birdtray
          thunderbird
          # Privacy
          veracrypt
          lesspass-cli
          # Video-Editing
          obs-studio
          kdenlive
          glaxnimate
          mediainfo
          # Drawing
          xournalpp
          pkgs.unstable.rnote
          inkscape
          mypaint
          gimp
          aseprite
          (pkgs.blender.override {
            cudaSupport = true;
          })
          krita
          # Media
          vlc
          mpv
          yt-dlp
          evince
          deadbeef
          sxiv
          sony-headphones-client
          # Gaming
          (retroarch.override {
            cores = with libretro; [
              mupen64plus
              libretro.pcsx2
            ];
          })
          # Productivity
          libreoffice
          # Programming
          dbeaver
          # inputs.neovim-luca.defaultPackage.x86_64-linux
          unstable.neovim
          rnix-lsp
          luajit
          lazygit
          emacs-gtk
          hlint
          devdocs-desktop
          # devdocs-desktop
          # math
          sage
          julia-bin
          unstable.rstudio
          # JavaScript/TypeScript
          nodejs_20
          jetbrains.webstorm
          # python
          jetbrains.pycharm-professional
          # Latex
          pandoc
          quarto
          poppler_utils
          texlive.combined.scheme-full
          tex-match
          # Rust
          cargo
          rustc
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
          gdbgui
          conan
          # C#
          mono
          dotnet-sdk_7
          dotnetCorePackages.aspnetcore_7_0
          dotnetCorePackages.sdk_7_0
          dotnetCorePackages.runtime_7_0
          unstable.jetbrains.rider
          # R
          R
          # Spelling
          hunspell
          hunspellDicts.de_DE
          hunspellDicts.en_US
          # Android
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
          godotMono
          # pkgs.unstable.godot
          pkgs.unstable.unityhub
          # UNI HHU ZEUG
          # konferenzen
          zoom-us
          # teams
          # slack
          # PROPORA
          mob

        ];
    };
  };
}