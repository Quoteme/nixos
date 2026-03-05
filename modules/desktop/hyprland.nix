{
  config,
  options,
  lib,
  pkgs,
  hyprlandPlugins,
  ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktop.hyprland;
in
{
  options.modules.desktop.hyprland =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable the hyprland window manager";
    };

  config =
    with pkgs;
    mkIf cfg.enable {
      environment.systemPackages = [
        cliphist
        wl-clipboard
        libnotify
        blueman
        networkmanagerapplet
        hypridle
        nwg-drawer
        swaybg
        swipe-guess
        waytrogen
        wtype
        wvkbd
        grim
        slurp
        swappy
        jq
        libsecret
        gsettings-desktop-schemas
        dconf
        noctalia-shell
      ];
      nix.settings = {
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };

      programs.dconf.enable = true;
      programs.gamescope = {
        enable = true;
        env = {
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          __NV_PRIME_RENDER_OFFLOAD = "1";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
        };
      };
      programs.hyprland = {
        enable = true;
        plugins = hyprlandPlugins;
        extraConfig = ''
          exec-once = wl-paste --watch clipvault store --ignore-pattern '^<meta http-equiv='
          exec-once = wl-paste --type image --watch clipvault store
          exec-once = iio-hyprland
          exec-once = noctalia-shell
          exec-once = mullvad-gui
          exec-once = com.bitwarden.desktop
          source = /etc/nixos/config/hyprland/extra.conf
        '';
        # Whether to enable XWayland
        xwayland.enable = true;
        withUWSM = true;
      };
      programs.iio-hyprland.enable = true;
      security.pam.services.greetd-password.enableGnomeKeyring = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
      security.pam.services.login.enableGnomeKeyring = true;
      services.dbus.packages = [
        pkgs.dconf
        pkgs.gnome-keyring
      ];
      services.gnome.gnome-keyring.enable = true;
      services.hypridle.enable = true;
      services.logind.settings.Login = {
        HandlePowerKey = "ignore";
        HandlePowerKeyLongPress = "suspend-then-hibernate";
      };

      services.upower.enable = true;
      services.xserver.displayManager.sessionCommands = ''
        eval $(gnome-keyring-daemon --start --daemonize --components=ssh,secrets)
        export SSH_AUTH_SOCK
      '';
      services.xserver.updateDbusEnvironment = true;
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
    };
}
