{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.loginManager.greetd;
in
{
  options.modules.loginManager.greetd =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable the Greetd login manager";
    };

  config = mkIf cfg.enable {
    services.greetd.enable = true;
    programs.regreet.enable = true;
  };
}
