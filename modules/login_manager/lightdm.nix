{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktopManager.lightdm;
in
{
  options.modules.desktopManager.lightdm =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable the LightDM desktop manager";
    };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    security.pam.services.lightdm.enableKwallet = true;
    security.pam.services.lightdm.enableGnomeKeyring = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.displayManager.greeters.pantheon.enable = true;
    # Security
    security.pam.services.lightdm.fprintAuth = true;
    security.pam.services.login.fprintAuth = true;
  };
}
