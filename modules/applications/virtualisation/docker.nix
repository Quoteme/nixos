{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;
  system = "x86_64-linux";
  cfg = config.modules.applications.virtualisation.docker;
in
{
  options.modules.applications.virtualisation.docker =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable Docker";
    };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.enableOnBoot = false;
    virtualisation.docker.enableNvidia = true;
    virtualisation.docker.storageDriver = "btrfs";
    users.users.luca.extraGroups = [ "docker" ];
    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
