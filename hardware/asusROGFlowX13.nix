{config, lib, pkgs, ...}:

{
  nixpkgs.config.allowUnfree = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
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
  # `nixos-generate-config --show-hardware-config` doesn't detect mount options automatically,
   # so to enable compression, you must specify it and other mount options
   # in a persistent configuration
   # https://nixos.wiki/wiki/Btrfs
   fileSystems = {
     "/".options = [ "compress=zstd" ];
     "/home".options = [ "compress=zstd" ];
     "/nix".options = [ "compress=zstd" "noatime" ];
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
  # FIX: fix this
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
}
