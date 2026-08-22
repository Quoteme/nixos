{
  config,
  options,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;
  system = "x86_64-linux";
  cfg = config.modules.applications.ai.claude;
in
{
  options.modules.applications.ai.claude =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable claude";
    };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.claude-desktop ];
  };
}
