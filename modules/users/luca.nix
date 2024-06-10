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
      packages = with pkgs; [
        # Internet
        firefox
        opendrop # NOTE: share files between devices
        transmission-gtk # NOTE: torrent client
        birdtray # NOTE: Thunderbird tray icon
        thunderbird # NOTE: Email client
        # Privacy
        veracrypt
        # Video-Editing
        obs-studio
        kdenlive
        glaxnimate
        mediainfo
        # Drawing
        xournalpp
        inkscape
        gimp
        aseprite
        krita
        # Media
        vlc
        mpv
        yt-dlp
        # Gaming
        xboxdrv
        # Productivity
        libreoffice
        # Programming
        neovim
        luajit
        lazygit
        hlint
        devdocs-desktop
        # JavaScript/TypeScript
        nodejs_20
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
        # Java
        jetbrains.idea-ultimate
        jdk
        gradle
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
        android-tools
        (writeScriptBin "shareAndroidScreen" ''
          #!/usr/bin/env bash
          adb exec-out screenrecord --output-format=h264 - | ${pkgs.ffmpeg-full}/bin/ffplay -framerate 60 -probesize 32 -sync video  -
        '')
        # MongoDB
        mongodb-compass
        # game-dev
        # godotMono
        godot_4
        # Hardware
        miraclecast
      ];
    };
  };
}
