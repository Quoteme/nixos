{
  config,
  options,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktop.niri;
in
{
  options.modules.desktop.niri =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable the niri compositor";
    };

  config =
    with pkgs;
    mkIf cfg.enable {
      environment.systemPackages = [
        cliphist
        wl-clipboard
        libnotify
        blueman
        hypridle
        nwg-drawer
        swaybg
        swipe-guess
        waytrogen
        wtype
        wvkbd
        hyprshot
        grim
        slurp
        swappy
        jq
        libsecret
        gsettings-desktop-schemas
        dconf
        noctalia-shell
        adw-gtk3
        nwg-look
      ];
      nix.settings = {
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };

      programs.dconf.enable = true;
      programs.gamescope = {
        enable = true;
        env = {
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          __NV_PRIME_RENDER_OFFLOAD = "1";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
        };
      };
      programs.niri.enable = true;
      services.iio-niri.enable = true;
      security.pam.services.greetd-password.enableGnomeKeyring = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
      security.pam.services.login.enableGnomeKeyring = true;
      services.dbus.packages = [
        pkgs.dconf
        pkgs.gnome-keyring
      ];
      services.gnome.gnome-keyring.enable = true;
      services.logind.settings.Login = {
        HandlePowerKey = "ignore";
        HandlePowerKeyLongPress = "suspend-then-hibernate";
      };

      services.upower.enable = true;
      services.xserver.displayManager.sessionCommands = ''
        eval $(gnome-keyring-daemon --start --daemonize --components=ssh,secrets)
        export SSH_AUTH_SOCK
      '';
      services.xserver.updateDbusEnvironment = true;
      system.userActivationScripts.niri = {
        text = ''
          ln -sfn /etc/nixos/config/niri/ "$HOME/.config/niri"
          ln -sfn /etc/nixos/config/noctalia/ "$HOME/.config/noctalia"
        '';
        deps = [ ];
      };
    };
}
