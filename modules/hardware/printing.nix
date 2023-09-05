{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.hardware.printing;
in
{
  options.modules.hardware.printing =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable printing";
    };

  config = mkIf cfg.enable {
    services.printing.enable = true;
    services.printing.browsing = true;
    services.printing.drivers = with pkgs; [
      gutenprint
      gutenprintBin
      epson_201207w
      epson-workforce-635-nx625-series
      epson-escpr2
      epson-escpr
      epson-alc1100
      epson-201401w
      epson-201106w
      hplip
      samsung-unified-linux-driver
      splix
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
      cnijfilter2
    ];
    services.avahi.enable = true;
    services.avahi.nssmdns = true;
    services.avahi.openFirewall = true;
  };
}

