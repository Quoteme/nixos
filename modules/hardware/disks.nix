{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.hardware.disks;
in
{
  options.modules.hardware.disks =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable automounting";
    };

  config = mkIf cfg.enable {
    udisks2.enable = true;
    environment.etc."udisks2/rules.d/10-custom-mount.rules".text = ''
      [block_id=="98bf9471-2174-498f-b8d8-9b918a387ec4"]
      mount_options=exec
    '';
  };
}

