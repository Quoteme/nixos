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
  cfg = config.modules.applications.editors.emacs;
in
{
  options.modules.applications.editors.emacs =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable emacs";
    };

  config =
    with pkgs;
    mkIf cfg.enable {
      environment.shellAliases = {
        doom = "~/.config/emacs/bin/doom";
      };
      services.emacs = {
        enable = true;
        package = emacs;
      };
      environment.systemPackages = [
        gcc
      ];
    };
}
