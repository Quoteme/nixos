{ config, options, lib, pkgs, ... }@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.hardware.keyboard-de;
in {
  options.modules.hardware.keyboard-de = let
    inherit (lib.options) mkEnableOption mkOption;
    inherit (lib.types) nullOr path;
  in {
    enable =
      mkEnableOption "Enable keyboard-de: The German keyboard layout for X11";
  };

  config = mkIf cfg.enable {
    services.xserver.xkb.layout = "de";
    services.xserver.exportConfiguration = true;
    services.xserver.xkb.variant = "nodeadkeys";
    services.xserver.xkb.options =
      "caps:escape,shift:both_capslock,mod_led,compose:rctrl-altgr";
    # services.xserver.xkb.extraLayouts.hyper = {
    #   # TODO this does not work :(
    #   description = "Use escape key as Hyper key";
    #   languages = [ ];
    #   symbolsFile = pkgs.writeText "hyper" ''
    #     partial modifier_keys
    #     xkb_symbols "hyper" {
    #     key <ESC> { [Hyper_R] };
    #     modifier_map Mod3 { <HYPR>, Hyper_R };
    #     }
    #   '';
    # };
  };
}
