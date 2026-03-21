{ config, options, lib, pkgs, ... }@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;
  system = "x86_64-linux";
  cfg = config.modules.applications.virtualisation.podman;
in {
  options.modules.applications.virtualisation.podman = let
    inherit (lib.options) mkEnableOption mkOption;
    inherit (lib.types) nullOr path;
  in { enable = mkEnableOption "Enable Podman"; };

  config = mkIf cfg.enable {
    virtualisation.podman.enable = true;
    virtualisation.podman.dockerCompat = false;
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    users.users.luca.extraGroups = [ "podman" ];
    environment.systemPackages = with pkgs; [ podman-compose ];
  };
}
