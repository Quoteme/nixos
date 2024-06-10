{ config, lib, pkgs, ... }:

{
  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };
  services = {
    xserver = {
      # Drivers
      videoDrivers = [ "amdgpu" ];
      # Enable different input methods
      libinput = {
        enable = true;
        touchpad.tapping = true;
        touchpad.naturalScrolling = true;
      };
      wacom.enable = true;
    };
    fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix;
      };
    };
  };
  hardware = {
    sensor.iio.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      driSupport32Bit = true;
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

}
