{config, lib, pkgs, ...}:

{
  boot = {
    initrd.kernelModules = ["amdgpu"];
    kernelModules = ["kvm-amd"];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    # Use the GRUB 2 boot loader.
    loader.grub = {
      device = "/dev/sda";
      enable = true;
      configurationLimit = 1;
      version = 2;
    };
  };
  services = {
    xserver = {
      # Enable different input methods
        libinput = {
          enable = true;
          touchpad.tapping = false;
          touchpad.naturalScrolling = true;
        };
        wacom.enable = true;
    };
    fprintd = {
      enable = true;
    };
  };
  hardware = {
    sensor.iio.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
}
