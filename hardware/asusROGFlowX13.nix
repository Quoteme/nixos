{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
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
  # powerManagement.powertop.enable = true;
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
    enableRedistributableFirmware = true;
  };
  # AMD settings
  boot.initrd.kernelModules = [ "amdgpu" ];
  programs.corectrl.enable = true;
  services.auto-cpufreq.enable = true;
  #  services.auto-cpufreq.settings =
  #    let
  #      MHz = x: x * 1000;
  #    in
  #    {
  #      battery = {
  #        governor = "powersave";
  #        scaling_min_freq = (MHz 400);
  #        scaling_max_freq = (MHz 1800);
  #        turbo = "never";
  #      };
  #      charger = {
  #        governor = "performance";
  #        # governor = "powersave";
  #        # scaling_min_freq = (MHz 400);
  #        # scaling_max_freq = (MHz 1800);
  #        turbo = "auto";
  #      };
  #    };
  # services.cpupower-gui.enable = true;
  services.thermald.enable = true;
  # supergfxd
  boot.kernelParams = [
    # "supergfxd.mode=integrated"
    # "nvidia"
    # "nvidia_modeset"
    # "nvidia_uvm"
    # "nvidia_drm"
  ];
  services.supergfxd = {
    enable = true;
    settings = {
      # mode = "Integrated";
      vfio_enable = true;
      vfio_save = false;
      always_reboot = false;
      no_logind = false;
      logout_timeout_s = 20;
      hotplug_type = "Asus";
    };
  };
  systemd.services.supergfxd.path = [ pkgs.kmod pkgs.pciutils ];
  # NVIDIA settings
  # FIX: fix this
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.open = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;
    amdgpuBusId = "PCI:08:00:0";
    nvidiaBusId = "PCI:01:00:0";
  };

  environment.systemPackages = with pkgs; [
    powertop
    config.boot.kernelPackages.turbostat
    config.boot.kernelPackages.cpupower
    pkgs.cudatoolkit # TODO: Maybe add this again when there is more internet
    ryzenadj
    # pkgs.cudaPackages.cuda-samples
    pciutils
    (writeShellScriptBin "powerprofilesctl-cycle" ''
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
    (writeShellScriptBin "asusrog-dgpu-disable" ''
      echo 1 |sudo tee /sys/devices/platform/asus-nb-wmi/dgpu_disable
      echo 0 |sudo tee /sys/bus/pci/rescan
      echo 1 |sudo tee /sys/devices/platform/asus-nb-wmi/dgpu_disable
      echo "please logout and login again to use integrated graphics"
    '')
    (writeShellScriptBin "asusrog-dgpu-enable" ''
      echo 0 |sudo tee /sys/devices/platform/asus-nb-wmi/dgpu_disable
      echo 1 |sudo tee /sys/bus/pci/rescan
      echo 0 |sudo tee /sys/devices/platform/asus-nb-wmi/dgpu_disable
      echo "please logout and login again to use discrete graphics"
    '')
    (writeShellScriptBin "asusrog-goboost" ''
      (set -x; powerprofilesctl set performance; sudo cpupower frequency-set -g ondemand >&/dev/null;)
    '')
    (writeShellScriptBin "asusrog-gonormal" ''
      (set -x; powerprofilesctl set balanced; sudo cpupower frequency-set -g schedutil >&/dev/null;)
    '')
    (writeShellScriptBin "asusrog-gosilent" ''
      (set -x; powerprofilesctl set power-saver; sudo cpupower frequency-set -g schedutil >&/dev/null;)
    '')
    (writeShellScriptBin "asusrog-gosave" ''
      (set -x; sudo ryzenadj --power-saving >&/dev/null; powerprofilesctl set power-saver; sudo cpupower frequency-set -g conservative >&/dev/null;)
    '')
    (writeShellScriptBin "asusrog-monitor-mhz" ''
      watch -n.1 "grep \"^[c]pu MHz\" /proc/cpuinfo"
    '')
  ];
  programs.rog-control-center.enable = true;
  services.asusd = {
    enable = true;
    enableUserService = true;
    # fanCurvesConfig = builtins.readFile ../config/fan_curves.ron;
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
      url = "https://gitlab.com/asus-linux/fedora-kernel/-/raw/rog-6.5/0001-HID-amd_sfh-Add-support-for-tablet-mode-switch-senso.patch";
      sha256 = "sha256:08qw7qq88dy96jxa0f4x33gj2nb4qxa6fh2f25lcl8bgmk00k7l2";
    };
  }];
  # Automatically Hybernate when suspended for 3 minutes
  # services.logind.lidSwitch = "suspend-then-hibernate";
  # environment.etc."systemd/sleep.conf".text = "HibernateDelaySec=180";
}
