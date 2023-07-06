{
  config,
  options,
  lib,
  pkgs,
  ...
}@inputs: let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktop.xmonad-luca;
in {
  options.modules.desktop.xmonad-luca = let
    inherit (lib.options) mkEnableOption mkOption;
    inherit (lib.types) nullOr path;
  in {
    enable = mkEnableOption "Enable xmonad-luca: a xmonad configuration for Luca";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inputs.xmonad-luca.packages.x86_64-linux.xmonad-luca-alldeps
    ];
    services.xserver.windowManager.session = [
      {
        name = "xmonad-home";
        start = ''
          $HOME/.cache/xmonad/xmonad-x86_64-linux
        '';
      }
      {
        name = "xmonad-luca";
        start = ''
          ${inputs.xmonad-luca.packages.x86_64-linux.xmonad-luca-alldeps}/bin/xmonad-luca
        '';
      }
    ];
  };
}