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
    security.pam.services.sddm.kwallet.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.displayManager.sddm.package = lib.mkForce pkgs.kdePackages.sddm;
    services.xserver.displayManager.sddm.wayland.enable = true;
    environment.systemPackages = with pkgs; [
      kdePackages.sddm
      kdePackages.sddm-kcm
      kdePackages.plasma5support
      kdePackages.kirigami
      kdePackages.qt5compat
      kdePackages.breeze
      kdePackages.ksvg
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
