{ config, options, lib, pkgs, ... }@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.hardware.metered_connection;
in {
  options.modules.hardware.metered_connection = let
    inherit (lib.options) mkEnableOption mkOption;
    inherit (lib.types) nullOr path;
  in {
    enable = mkEnableOption
      "Enable settings for NixOS usage on a metered internet connection";
  };

  config = mkIf cfg.enable {
    nix = {
      extraOptions = ''
        keep-outputs = true
        keep-env-derivations = true
      '';
    };
  };
}

