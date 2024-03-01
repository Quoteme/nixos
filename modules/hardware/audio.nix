{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.hardware.audio;
in
{
  options.modules.hardware.audio =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable audio support";
    };

  config = mkIf cfg.enable {
    # sound = {
    #   enable = true;
    #   mediaKeys.enable = true;
    # };
    # Use Pipewire
    environment.systemPackages = [ pkgs.qpwgraph ];
    # rtkit is optional but recommended
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    # Create a drop-in file in `/etc/pipewire/pipewire.conf.d/` to enable
    # pipewirte-pulse `module-switch-on-connect` and `module-always-sink`.
    hardware = {
      pulseaudio.enable = false;
      pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
      pulseaudio.extraConfig = ''
        load-module module-bluetooth-policy auto_switch=2
        load-module module-bluetooth-discover
        load-module module-bluetooth-policy
        load-module module-switch-on-connect
        load-module module-switch-on-port-available
      '';
      bluetooth = {
        enable = true;
        powerOnBoot = false;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            Experimental = true;
          };
        };
      };
    };
  };
}

