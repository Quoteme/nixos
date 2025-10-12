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
      environment.systemPackages = [
        ashell
        nautilus
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
        enable = true;
        # Whether to enable XWayland
        xwayland.enable = true;
        withUWSM = true;
      };
      programs.iio-hyprland.enable = true;
      programs.dconf.enable = true;
      services.dbus.packages = [ pkgs.dconf ];

      services.xserver.updateDbusEnvironment = true;
      security.pam.services.hyprlock = { };
      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
          xdg-desktop-portal-hyprland
        ];
        configPackages = [ gnome-session ];
        config = {
          common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.Settings" = "gtk";
          };
          hyprland = { default = [ "hyprland" "gtk" "wlr" ]; };
        };
      };
    };
}
