{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktop.cosmic;
in
{
  options.modules.desktop.cosmic =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable the Cosmic desktop environment";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cosmic-applets
      cosmic-applibrary
      cosmic-bg
      cosmic-comp
      cosmic-design-demo
      cosmic-edit
      cosmic-files
      cosmic-greeter
      cosmic-icons
      cosmic-launcher
      cosmic-notifications
      cosmic-osd
      cosmic-panel
      cosmic-protocols
      cosmic-randr
      cosmic-screenshot
      cosmic-session
      cosmic-settings
      cosmic-settings-daemon
      cosmic-store
      cosmic-tasks
      cosmic-term
      cosmic-workspaces-epoch
    ];

    # COSMIC portal doesn't support everything yet

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-cosmic xdg-desktop-portal-gtk ];
    xdg.portal.config.common.default = "*";

    # session files for display manager and systemd
    services.displayManager.sessionPackages = with pkgs; [ cosmic-session ];
    systemd.packages = with pkgs; [ cosmic-session ];
  };
}
