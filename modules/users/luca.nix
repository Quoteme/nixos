{ config, options, lib, pkgs, attrs, ... }@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.users.luca;
in {
  options.modules.users.luca = let
    inherit (lib.options) mkEnableOption mkOption;
    inherit (lib.types) nullOr path;
  in { enable = mkEnableOption "Enable the user 'luca'"; };

  config = mkIf cfg.enable {
    programs.fish.enable = true;
    users.users.luca.shell = pkgs.fish;
    environment.pathsToLink = [ "/share/zsh" ];
    nix.settings.trusted-users = [ "luca" ];
    users.users.luca = {
      initialHashedPassword =
        "$6$W62LDzjtggxhhOiJ$KKM1yuHOrEr3Mz4MSstUGBtlpEF2AHR8bAzFeaqo2l.rrka/phKnzbKbyM5HX955d9et2NnV2fOr9LnDCgB5M1";
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
        # esp-idf
        "dialout"
        "uucp"
        "plugdev"
      ];
      packages = with pkgs; [
        # Internet
        bitwarden-cli
        # Video-Editing
        mediainfo
        # Media
        yt-dlp
        # Programming
        # JavaScript/TypeScript
        nodejs_20
        # Latex
        tectonic
        typst
        pandoc
        quarto
        poppler_utils
        texlive.combined.scheme-full
        # Rust
        # cargo
        # rustc
        rustup
        # Java
        jdk
        gradle
        # Spelling
        hunspell
        hunspellDicts.de_DE
        hunspellDicts.en_US
        # Android
        frida-tools
        libmtp
        usbutils
        scrcpy
        android-tools
        (writeScriptBin "shareAndroidScreen" ''
          #!/usr/bin/env bash
          adb exec-out screenrecord --output-format=h264 - | ${pkgs.ffmpeg-full}/bin/ffplay -framerate 60 -probesize 32 -sync video  -
        '')
      ];
    };
  };
}
