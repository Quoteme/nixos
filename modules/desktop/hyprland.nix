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
      programs.hyprland = {
        # Install the packages from nixpkgs
        enable = true;
        # Whether to enable XWayland
        xwayland.enable = true;
      };
      security.pam.services.hyprlock = { };
      environment.systemPackages = [
        wvkbd
        swipe-guess
        wtype
        hypridle
        hyprlock
        waytrogen
        swaybg
        nwg-drawer
        wofi
        ashell
        cliphist
        swaynotificationcenter
      ];
    };
}
