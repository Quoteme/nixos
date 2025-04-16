{ config, options, lib, pkgs, ... }@inputs: {
  options.modules.hardware.laptop.asus-rog-flow-x13 = {
    enable = lib.options.mkEnableOption {
      type = lib.types.bool;
      default = false;
      description = "Enable support for the Asus ROG Flow X13";
    };
  };

  config =
    lib.modules.mkIf config.modules.hardware.laptop.asus-rog-flow-x13.enable {
      nixpkgs.config.allowUnfree = true;
      # Secure boot
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.systemd-boot.configurationLimit = 5;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
      boot.loader.efi.canTouchEfiVariables = true;
      services = {
        # Enable different input methods
        libinput = {
          enable = true;
          touchpad.tapping = true;
          touchpad.naturalScrolling = true;
        };
        xserver = { wacom.enable = true; };
      };
      # power management
      powerManagement.powertop.enable = true;
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
      boot.initrd.kernelModules = [ "kvm-amd" "amdgpu" ];
      programs.corectrl.enable = true;
      services.thermald.enable = true;
      # supergfxd
      services.supergfxd = {
        enable = true;
        settings = {
          mode = "Integrated";
          vfio_enable = false;
          vfio_save = false;
          always_reboot = false;
          no_logind = false;
          logout_timeout_s = 20;
          hotplug_type = "Asus";
        };
      };
      systemd.services.supergfxd.path = [ pkgs.kmod pkgs.pciutils ];
      # NVIDIA settings
      hardware = {
        nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          open = true;
          modesetting.enable = true;
          powerManagement.enable = true;
          powerManagement.finegrained = true;
          nvidiaSettings = true;
          prime = {
            offload.enable = true;
            offload.enableOffloadCmd = true;
            amdgpuBusId = "PCI:08:00:0";
            nvidiaBusId = "PCI:01:00:0";
          };
        };
        graphics = {
          enable = true;
          # driSupport = true;
          enable32Bit = true;
          extraPackages = with pkgs.stable; [ amdvlk rocmPackages.clr.icd ];
          extraPackages32 = with pkgs.stable; [ driversi686Linux.amdvlk ];
        };
      };
      services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

      environment.systemPackages = with pkgs; [
        # OpenCL
        clinfo
        # Secure boot
        sbctl
        # NVIDIA
        vulkan-tools
        vulkan-loader
        vulkan-headers
        radeontop
        powertop
        config.boot.kernelPackages.turbostat
        config.boot.kernelPackages.cpupower
        pkgs.cudatoolkit # TODO: Maybe add this again when there is more internet
        ryzenadj
        # pkgs.cudaPackages.cuda-samples
        pciutils
        (writeShellScriptBin "powerprofilesctl-cycle" ''
          case $(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get) in
            power-saver)
              ${pkgs.libnotify}/bin/notify-send -a \"changepowerprofile\" -u low -i /etc/nixos/xmonad/icon/powerprofilesctl-balanced.png \"powerprofile: balanced\"
              ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced;;
            balanced)
              ${pkgs.libnotify}/bin/notify-send -a \"changepowerprofile\" -u low -i /etc/nixos/xmonad/icon/powerprofilesctl-performance.png \"powerprofile: performance\"
              ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance;;
            performance)
              ${pkgs.libnotify}/bin/notify-send -a \"changepowerprofile\" -u low -i /etc/nixos/xmonad/icon/powerprofilesctl-power-saver.png \"powerprofile: power-saver\"
              ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver;;
          esac
        '')
      ];
      programs.rog-control-center.enable = true;
      # Start the fingerprint driver at boot
      systemd.services.fprintd = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "simple";
      };
      services.fprintd = {
        enable = true;
        # tod.enable = true;
        # tod.driver = pkgs.libfprint-2-tod1-goodix;
      };
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
      # We use the following UDEV rule, to allow normal users to change the keyboard backlight by writing its value (0,1,2,3) into:
      # /devices/pci0000:00/0000:00:08.1/0000:08:00.3/usb1/1-3/1-3:1.0/0003:0B05:19B6.0001/leds/asus::kbd_backlight/brightness
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="leds", KERNEL=="asus::kbd_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys%p/brightness"
      '';

      # tablet-mode patch
      # See: https://github.com/camillemndn/nixos-config/blob/f71c2b099bec17ceb8a894f099791447deac70bf/hardware/asus/gv301qe/default.nix#L46
      boot.kernelPatches = [{
        name = "asus-rog-flow-x13-tablet-mode";
        patch = builtins.fetchurl {
          # url = "https://gitlab.com/asus-linux/fedora-kernel/-/raw/rog-6.5/0001-HID-amd_sfh-Add-support-ior-tablet-mode-switch-senso.patch";
          # sha256 = "sha256:08qw7qq88dy96jxa0f4x33gj2nb4qxa6fh2f25lcl8bgmk00k7l2";
          url =
            "https://gitlab.com/asus-linux/fedora-kernel/-/raw/rog-6.10/amd-tablet-sfh.patch?ref_type=heads";
          sha256 =
            "sha256:011b4q0v8mkfrv96d4bvg8fd5dg6y5q38w20qmf196hsx35r13sh";
        };
      }];
      # Automatically hibernate when suspended for some time
      services.logind.lidSwitch = "suspend-then-hibernate";
      systemd.sleep.extraConfig = ''
        HibernateDelaySec=5min
        SuspendState=mem
      '';
    };
}
