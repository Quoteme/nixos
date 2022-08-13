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
  # power management
  systemd.services.batterThreshold = {
    script = ''
      echo 80 | tee /sys/class/power_supply/BAT0/charge_control_end_threshold
    '';
    wantedBy = [ "multi-user.target" ];
    description = "Set the charge threshold to protect battery life";
    serviceConfig = {
      Restart = "on-failure";
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
    # pkgs.cudatoolkit # TODO: Maybe add this again when there is more internet
    # pkgs.cudaPackages.cuda-samples
    pkgs.pciutils
    (pkgs.writeShellScriptBin "powerprofilesctl-cycle" ''
      case $(powerprofilesctl get) in
        power-saver)
          notify-send -a \"changepowerprofile\" -u low -i /etc/nixos/xmonad/icon/powerprofilesctl-balanced.png \"powerprofile: balanced\"
          powerprofilesctl set balanced;;
        balanced)
          notify-send -a \"changepowerprofile\" -u low -i /etc/nixos/xmonad/icon/powerprofilesctl-performance.png \"powerprofile: performance\"
          powerprofilesctl set performance;;
        performance)
          notify-send -a \"changepowerprofile\" -u low -i /etc/nixos/xmonad/icon/powerprofilesctl-power-saver.png \"powerprofile: power-saver\"
          powerprofilesctl set power-saver;;
      esac
    '')
  ];
  services.power-profiles-daemon.enable = true;
  services.acpid.enable = true;
  services.udev.extraHwdb = ''
    evdev:input:b0003v0B05p19B6*
      KEYBOARD_KEY_ff31007c=f20 # x11 mic-mute
  '';
}
