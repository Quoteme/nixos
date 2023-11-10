{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktopManager.sddm;
in
{
  options.modules.desktopManager.sddm =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable the SDDM desktop manager";
    };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    # SDDM
    security.pam.services.sddm.enableKwallet = false;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.displayManager.sddm.theme = "breeze";
    services.xserver.displayManager.sddm.settings.General = {
      DisplayServer = "wayland";
      GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
    };
    environment.systemPackages = with pkgs; [
      libsForQt5.sddm
      libsForQt5.sddm-kcm
    ];
    # Security
    security.pam.services.sddm.fprintAuth = true;
    security.pam.services.login.fprintAuth = true;
    #
    environment.sessionVariables = {
      QT_QUICK_CONTROLS_STYLE = "org.kde.desktop";
    };
  };
}
