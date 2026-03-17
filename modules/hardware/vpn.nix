{ config, lib, pkgs, ... }@inputs:
let
  inherit (lib.modules) mkIf mkMerge;

  cfg = config.modules.hardware.vpn;
in {
  options.modules.hardware.vpn = let
    inherit (lib.options) mkEnableOption ;
    mkEnabledOption = desc: (mkEnableOption desc) // { default = true; };
  in {
    enable        = mkEnableOption "Enable VPN support (NetworkManager + nm-applet + openvpn3)";
    mullvad       = { enable = mkEnabledOption "Enable Mullvad VPN"; };
    softether     = { enable = mkEnabledOption "Enable SoftEther VPN"; };
    strongswan    = { enable = mkEnabledOption "Enable strongSwan IKEv2/IPsec VPN"; };
    tailscale     = { enable = mkEnabledOption "Enable Tailscale VPN"; };
    wgNetmanager  = { enable = mkEnabledOption "Enable wg-netmanager (WireGuard NetworkManager integration)"; };
    xl2tpd        = { enable = mkEnabledOption "Enable xl2tpd L2TP daemon"; };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      networking.firewall.checkReversePath = "loose";

      networking.networkmanager = {
        enable = true;
        plugins = with pkgs; [
          networkmanager-fortisslvpn
          networkmanager-l2tp
          networkmanager-openvpn
          networkmanager_strongswan
        ];
      };

      programs = {
        nm-applet.enable = true;
        openvpn3.enable  = true;
      };
    })

    (mkIf cfg.mullvad.enable {
      services.mullvad-vpn.enable = true;
      environment.systemPackages = [ pkgs.mullvad-vpn ];
    })

    {
      services.softether.enable     = cfg.softether.enable;
      services.strongswan.enable    = cfg.strongswan.enable;
      services.tailscale.enable     = cfg.tailscale.enable;
      services.wg-netmanager.enable = cfg.wgNetmanager.enable;
      services.xl2tpd.enable        = cfg.xl2tpd.enable;
    }
  ];
}
