{ config
, options
, lib
, pkgs
, ...
}@inputs:
{
  options.modules.applications.gaming.steam = {
    enable = lib.options.mkEnableOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Steam";
    };
  };

  config = lib.modules.mkIf config.modules.applications.gaming.steam.enable {
    programs.gamemode = {
      enable = true;
      settings = {
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send -u LOW -i input-gaming 'Gamemode started' 'gamemode started'";
          end = "${pkgs.libnotify}/bin/notify-send -u LOW -i input-gaming 'Gamemode ended' 'gamemode ended'";
        };
      };
    };
    hardware.steam-hardware.enable = true;
    programs.steam = {
      package = pkgs.steam;
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };
}
