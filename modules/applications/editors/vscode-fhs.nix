{ config, options, lib, pkgs, ... }@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;
  system = "x86_64-linux";
  cfg = config.modules.applications.editors.vscode-fhs;
in {
  options.modules.applications.editors.vscode-fhs = let
    inherit (lib.options) mkEnableOption mkOption;
    inherit (lib.types) nullOr path;
  in { enable = mkEnableOption "Enable vscode-fhs"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vscode-fhs
      nixd
      nixfmt-classic
      pkgs.platformio
      pkgs.avrdude
    ];
    services.udev.packages = [ pkgs.platformio-core pkgs.openocd ];
  };
}
