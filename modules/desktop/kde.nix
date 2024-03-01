{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktop.kde;
in
{
  options.modules.desktop.kde =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable the KDE desktop environment";
    };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    # lightdm
    # services.xserver.displayManager.lightdm.enable = true;
    # services.xserver.displayManager.defaultSession = "plasmawayland";
    # services.xserver.displayManager.setupCommands = ''
    #   supergfxctl -m Integrated
    # '';
    services.xserver.desktopManager.plasma6.enable = true;
    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    xdg.portal.extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    programs.dconf.enable = true;
    programs.kdeconnect.enable = true;
    environment.systemPackages = with pkgs; [
      kdePackages.ark
      unrar
      p7zip
      kdePackages.kamoso
      kdePackages.skanlite
      kdePackages.okular
      kdePackages.packagekit-qt
      kdePackages.discover
      kdePackages.kio
      kio-fuse
      kdePackages.kio-gdrive
      kdePackages.kio-extras
      kdePackages.plasma-integration
      kdePackages.plasma-nm
      kdePackages.kdepim-runtime
      kdePackages.accounts-qt
      kdePackages.mauikit-accounts
      kdePackages.kaccounts-integration
      kdePackages.kaccounts-providers
      kdePackages.signond
      kdePackages.qoauth
      kdePackages.flatpak-kcm
      kdePackages.kcmutils
      kdePackages.plasma-vault
      kdePackages.kscreenlocker
      # Settings
      wayland-utils

      # Keyboard
      kdePackages.qt5.qtwayland
      kdePackages.qt5.qtvirtualkeyboard
      maliit-keyboard
      maliit-framework
      # spellcheck
      aspell
      aspellDicts.de
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      config.nur.repos.baduhai.koi
      # Settings
      # CLI programs required by Plasma
      wayland-utils
      linuxquota
      pciutils
      ydotool
    ];
    # Settings
    services.fwupd.enable = true;
    # Security
    security.pam.services.kde.fprintAuth = true;
    security.pam.services.sudo.fprintAuth = true;
    #
    environment.sessionVariables = {
      QT_QUICK_CONTROLS_STYLE = "org.kde.desktop";
      GTK_USE_PORTAL = "1";
      ELECTRON_TRASH = "gio";
    };
  };
}
