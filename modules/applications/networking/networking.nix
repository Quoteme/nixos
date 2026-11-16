{
  config,
  options,
  lib,
  pkgs,
  ...
}@inputs:
{
  options.modules.applications.networking.filesharing = {
    enable = lib.options.mkEnableOption {
      type = lib.types.bool;
      default = false;
      description = "Enable filesharing stuff (Localsend, RQuickShare)";
    };
  };

  config = lib.modules.mkIf config.modules.applications.networking.filesharing.enable {
    programs.localsend = {
      enable = true;
    };

    # Android Quick Share / Nearby Share client
    environment.systemPackages = [ pkgs.rquickshare ];
    # mDNS discovery (5353/udp) + fixed transfer port.
    # Set the same port in RQuickShare's settings (it is random by default).
    networking.firewall = {
      allowedUDPPorts = [ 5353 ];
      allowedTCPPorts = [ 45231 ];
    };
  };
}
