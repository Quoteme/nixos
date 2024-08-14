{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktop.xmonad-luca;
in
{
  options.modules.desktop.xmonad-luca =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable xmonad-luca: a xmonad configuration for Luca";
    };

  config = mkIf cfg.enable {
    services.logind.extraConfig = ''
      # don’t shutdown when power button is short-pressed
      HandlePowerKey=ignore
    '';
    # make xmonad the default window manager
    services.gnome.at-spi2-core.enable = true;
    services.xserver.enable = true;
    services.xserver.updateDbusEnvironment = true;
    services.xserver.displayManager.sx.enable = true;
    services.xserver.windowManager.session = [
      {
        name = "xmonad-home";
        start = ''
          sx $HOME/.cache/xmonad/xmonad-x86_64-linux
        '';
      }
      {
        name = "xmonad-luca";
        start = ''
          sx ${inputs.xmonad-luca.packages.x86_64-linux.xmonad-luca}/bin/xmonad-luca
        '';
      }
    ];
    programs.xfconf.enable = true;

    services.xserver.displayManager.defaultSession = "none+xmonad-home";
    # services.touchegg.enable = true;
    # services.blueman.enable = true;
    services.udisks2.enable = true;
    services.devmon.enable = true;
    services.gvfs.enable = true;
    # services.tumbler.enable = true;
    # services.touchegg.enable = true;
    # enable wallet
    # services.gnome.gnome-keyring.enable = true;
    # services.blueman.enable = true;
    xdg.portal.enable = true;
    # FIXME: the nixos docs are pretty unhelpful here... Maybe in the future I will understand how to set this correctly?
    xdg.portal.config.common.default = "*";
    # xdg.portal.config = {
    #   "none+xmonad-home" = {
    #     default = [
    #       "gtk"
    #     ];
    #     "org.freedesktop.impl.portal.Secret" = [
    #       "gnome-keyring"
    #     ];
    #   };
    # };
  };
}
