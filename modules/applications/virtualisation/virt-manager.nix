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
  cfg = config.modules.applications.virtualisation.virt-manager;
in
{
  options.modules.applications.virtualisation.virt-manager =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable virt-manager";
    };

  config = mkIf cfg.enable {
    programs.virt-manager.enable = true;
    services.spice-vdagentd.enable = true;
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          package = (
            pkgs.qemu_full.override {
              gtkSupport = true;
              sdlSupport = true;
              virglSupport = true;
              openGLSupport = true;
            }
          );
          swtpm.enable = true;
        };
      };
    };
  };
}
