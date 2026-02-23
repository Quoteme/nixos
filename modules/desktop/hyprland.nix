{ config, options, lib, pkgs, plugins, ... }@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktop.hyprland;
in {
  options.modules.desktop.hyprland = let
    inherit (lib.options) mkEnableOption mkOption;
    inherit (lib.types) nullOr path;
  in { enable = mkEnableOption "Enable the hyprland window manager"; };

  config = with pkgs;
    mkIf cfg.enable {
      nix.settings = {
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };
      environment.systemPackages = [
        blueman
        networkmanagerapplet
        cliphist
        hypridle
        hyprlock
        nwg-drawer
        swaybg
        swaynotificationcenter
        swipe-guess
        waytrogen
        rofi
        wtype
        wvkbd
        grim
        slurp
        swappy
        jq
        libsecret
        gsettings-desktop-schemas
        dconf
        hyprpanel
        (pkgs.callPackage (import ../../pkgs/clipvault) { })
      ];
      system.userActivationScripts.hyprland = {
        text = ''
          mkdir -p "$HOME/.config/hyprpanel/"
          mkdir -p "$HOME/.config/hypr/"
          mkdir -p "$HOME/.config/rofi/"
          ln -sfn /etc/nixos/config/hyprland/hyprpanel/config.json "$HOME/.config/hyprpanel/config.json"
          ln -sfn /etc/nixos/config/hyprland/hypridle/hypridle.conf "$HOME/.config/hypr/hypridle.conf"
          ln -sfn /etc/nixos/config/rofi/config.rasi "$HOME/.config/rofi/config.rasi"
          ln -sfn /etc/nixos/config/rofi/theme.rasi "$HOME/.config/rofi/theme.rasi"
        '';
        deps = [ ];
      };
      programs.hyprlock.enable = true;
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.login.enableGnomeKeyring = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
      security.pam.services.greetd-password.enableGnomeKeyring = true;
      services.logind.settings.Login = {
        HandlePowerKey = "ignore";
        HandlePowerKeyLongPress = "suspend-then-hibernate";
      };
      services.hypridle.enable = true;
      programs.hyprland = {
        enable = true;
        plugins = plugins ++ [ pkgs.stable.hyprlandPlugins.hyprspace ];
        extraConfig = ''
          exec-once = waytrogen --restore
          exec-once = swaync
          exec-once = wl-paste --watch clipvault store --ignore-pattern '^<meta http-equiv='
          exec-once = wl-paste --type image --watch clipvault store
          exec-once = iio-hyprland
          exec-once = hyprpanel
          exec-once = com.bitwarden.desktop
          source = /etc/nixos/config/hyprland/extra.conf
        '';
        # Whether to enable XWayland
        xwayland.enable = true;
        withUWSM = true;
      };
      programs.iio-hyprland.enable = true;
      programs.dconf.enable = true;
      services.dbus.packages = [ pkgs.dconf pkgs.gnome-keyring ];

      services.xserver.updateDbusEnvironment = true;
      services.xserver.displayManager.sessionCommands = ''
        eval $(gnome-keyring-daemon --start --daemonize --components=ssh,secrets)
        export SSH_AUTH_SOCK
      '';
      services.upower.enable = true;
      security.pam.services.hyprlock = { };
    };
}
