{
  config,
  options,
  lib,
  pkgs,
  ...
}@inputs:
{
  options.modules.applications.networking.filesharing = {
    enable = lib.options.mkEnableOption {
      type = lib.types.bool;
      default = false;
      description = "Enable filesharing stuff (Localsend)";
    };
  };

  config = lib.modules.mkIf config.modules.applications.networking.filesharing.enable {
    programs.localsend = {
      enable = true;
    };
  };
}
