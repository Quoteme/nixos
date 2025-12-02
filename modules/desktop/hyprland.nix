{ config, options, lib, pkgs, ... }@inputs:
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
        ashell
        nemo
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
        wofi
        wtype
        wvkbd
        grim
        slurp
        swappy
        jq
        libsecret
        gsettings-desktop-schemas
        dconf
      ];
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.gdm.enableGnomeKeyring = true;
      services.logind.settings.Login = {
        HandlePowerKey = "ignore";
        HandlePowerKeyLongPress = "suspend-then-hibernate";
      };
      programs.hyprland = {
        # Install the packages from nixpkgs
        #
        enable = true;
        plugins = [
          pkgs.stable.hyprlandPlugins.hyprgrass
          pkgs.stable.hyprlandPlugins.hyprspace
        ];
        extraConfig = ''
          exec-once = waytrogen --restore
          exec-once = ashell --config-path /etc/nixos/config/hyprland/ashell/config.toml
          exec-once = swaync
          exec-once = iio-hyprland
          source = /etc/nixos/config/hyprland/extra.conf
        '';
        # Whether to enable XWayland
        xwayland.enable = true;
        withUWSM = true;
      };
      programs.iio-hyprland.enable = true;
      programs.dconf.enable = true;
      services.dbus.packages = [ pkgs.dconf ];

      services.xserver.updateDbusEnvironment = true;
      services.upower.enable = true;
      security.pam.services.hyprlock = { };
      # xdg.portal = {
      #   enable = true;
      #   wlr.enable = true;
      #   extraPortals = [
      #     xdg-desktop-portal-wlr
      #     xdg-desktop-portal-gtk
      #     xdg-desktop-portal-hyprland
      #   ];
      #   configPackages = [ gnome-session ];
      #   config = {
      #     common = {
      #       default = [ "gtk" ];
      #       "org.freedesktop.impl.portal.Settings" = "gtk";
      #     };
      #     hyprland = { default = [ "hyprland" "gtk" "wlr" ]; };
      #   };
      # };
    };
}
