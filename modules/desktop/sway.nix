{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktop.sway;
in
{
  options.modules.desktop.sway =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable sway: a tiling Wayland compositor";
    };

  config = mkIf cfg.enable {
    programs.sway = {
      package = pkgs.unstable.sway;
      enable = true;
      wrapperFeatures.base = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swayidle
        swaynag-battery
        swayest-workstyle
        swaynotificationcenter
        pkgs.unstable.swaycons
        swaysettings
        pkgs.unstable.sov
        waybar
        nwg-launchers
        nwg-wrapper
        nwg-panel
        nwg-drawer
        nwg-menu
      ];
      extraOptions = [
        "--unsupported-gpu"
      ];
    };
  };
}
