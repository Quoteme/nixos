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
  powerManagement.powertop.enable = true;
  systemd.sleep.extraConfig = "HibernateDelaySec=5min";
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
  # AMD settings
  boot.initrd.kernelModules = [ "amdgpu" ];
  programs.corectrl.enable = true;
  services.auto-cpufreq.enable = true;
  # NVIDIA settings
  # FIX: fix this
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;
    amdgpuBusId = "PCI:08:00:0";
    nvidiaBusId = "PCI:01:00:0";
  };
  environment.systemPackages =  [
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
  programs.rog-control-center.enable = true;
  services.asusd = {
    enable = true;
    enableUserService = true;
    fanCurvesConfig = builtins.readFile ../config/fan_curves.ron;
  };
  services.power-profiles-daemon.enable = true;
  services.acpid.enable = true;
  services.udev.extraHwdb = ''
    evdev:input:b0003v0B05p19B6*
      KEYBOARD_KEY_ff31007c=f20 # x11 mic-mute
  '';

  # tablet-mode patch
  # 
  # Only for Linux 5.19
  # boot.kernelPatches = [
  #   { name = "asus-rog-flow-x13-tablet-mode";
  #     patch = builtins.fetchurl {
  #       url = "https://raw.githubusercontent.com/IvanDovgal/asus-rog-flow-x13-tablet-mode/main/support_sw_tablet_mode.patch";
  #       sha256 = "sha256:1qk63h1fvcqs6hyrz0djw9gay7ixcfh4rdqvza1x62j0wkrmrkky";
  #     };
  #   }
  # ];
  # See: https://github.com/camillemndn/nixos-config/blob/f71c2b099bec17ceb8a894f099791447deac70bf/hardware/asus/gv301qe/default.nix#L46
  boot.kernelPatches = [{
      name = "asus-rog-flow-x13-tablet-mode";
      patch = builtins.fetchurl {
        url = "https://gitlab.com/asus-linux/fedora-kernel/-/raw/rog-6.1/0001-HID-amd_sfh-Add-support-for-tablet-mode-switch-senso.patch";
        sha256 = "sha256:08qw7qq88dy96jxa0f4x33gj2nb4qxa6fh2f25lcl8bgmk00k7l2";
      };
    }];
}
