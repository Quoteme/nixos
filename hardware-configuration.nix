# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/53cbae83-9909-4cf4-a92c-c702d327fd6e";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-uuid/53cbae83-9909-4cf4-a92c-c702d327fd6e";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-uuid/53cbae83-9909-4cf4-a92c-c702d327fd6e";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/BCF6-4AB9";
      fsType = "vfat";
    };

  # fileSystems."/swap" =
  #   { device = "/dev/disk/by-uuid/53cbae83-9909-4cf4-a92c-c702d327fd6e";
  #     fsType = "btrfs";
  #     options = [ "subvol=swap" "noatime" ];
  #   };

  swapDevices = [{ device = "/dev/disk/by-uuid/73a5ff0f-9657-4b9c-91bf-c7bf90e31370"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
