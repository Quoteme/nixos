{ config, lib, pkgs, ... }: {
  options.modules.hardware.laptop.asus-k55vj = {
    enable = lib.options.mkEnableOption "Enable support for the Asus K55VJ";
  };

  config = lib.modules.mkIf config.modules.hardware.laptop.asus-k55vj.enable {
    nixpkgs.config.allowUnfree = true;
    boot = {
      # initrd.kernelModules = ["amdgpu"];
      # kernelModules = ["kvm-amd"];
      extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
      loader.efi.canTouchEfiVariables = true;
      loader.grub = {
        device = "nodev";
        enable = true;
        efiSupport = true;
        version = 2;
      };
    };
    services = {
      xserver = {
        # Enable different input methods
          libinput = {
            enable = true;
            touchpad.tapping = true;
            touchpad.naturalScrolling = true;
          };
          wacom.enable = true;
      };
    };
    hardware = {
      sensor.iio.enable = true;
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
      enableRedistributableFirmware = true;
    };
    # NVIDIA settings
    # services.xserver.videoDrivers = [ "nvidia" ];
    # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
  };
}
