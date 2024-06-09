{ config
, options
, lib
, pkgs
, ...
}@inputs:
{

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
      julia-mono
      scientifica
      font-awesome
      unifont
      siji
      openmoji-color
      fira-code
      hasklig
      material-icons
      # nerdfonts
      (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })

      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
    ];
    fonts.fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" "openmoji-color" ];
  };
}
