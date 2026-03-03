{ config, options, lib, pkgs, ... }@inputs:
let
  inherit (lib.modules) mkIf;

  cfg = config.modules.hardware.mullvad;
in {
  options.modules.hardware.mullvad = let
    inherit (lib.options) mkEnableOption;
  in { enable = mkEnableOption "Enable Mullvad VPN"; };

  config = mkIf cfg.enable {
    services.mullvad-vpn.enable = true;
    environment.systemPackages = [ pkgs.mullvad-vpn ];
  };
}
