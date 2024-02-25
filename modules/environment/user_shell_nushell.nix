{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.environment.user_shell_nushell;
in
{
  options.modules.environment.user_shell_nushell =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable my custom Nushell";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.nushellFull
      pkgs.carapace
      pkgs.atuin
      pkgs.starship
    ];
  };
}
