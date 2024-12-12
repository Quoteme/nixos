{ config, options, lib, pkgs, ... }@inputs: {

  options.modules.fonts = {
    enable = lib.options.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable font configuration";
    };
  };

  config = lib.modules.mkIf config.modules.fonts.enable {
    # List fonts installed in system profile
    fonts.packages = with pkgs; [
      # nerdfonts
      # (nerdfonts.override { fonts = [ "FiraCode" "Monaspace" "Hasklig" ]; })
      nerd-fonts.monaspace
      nerd-fonts.hasklug
      nerd-fonts.fira-code
      font-awesome
      julia-mono
      liberation_ttf
      material-icons
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      openmoji-color
      scientifica
      siji
      unifont
    ];
    fonts.fontconfig.defaultFonts.emoji =
      [ "Noto Color Emoji" "openmoji-color" ];
  };
}
