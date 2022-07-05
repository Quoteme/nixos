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
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.prime = {
    offload.enable = true;
    amdgpuBusId = "PCI:08:00:0";
    nvidiaBusId = "PCI:01:00:0";
  };
  environment.systemPackages =  [
    (pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '')
  ];
  services.acpid.enable = true;
  services.udev.extraHwdb = ''
    evdev:input:b0003v0B05p19B6*
      KEYBOARD_KEY_ff31007c=f20 # x11 mic-mute
  '';
}
