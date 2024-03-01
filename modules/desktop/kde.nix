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
      pkgs.libsForQt5.xdg-desktop-portal-kde
    ];
    programs.dconf.enable = true;
    programs.kdeconnect.enable = true;
    environment.systemPackages = with pkgs; [
      libsForQt5.ark
      unrar
      p7zip
      libsForQt5.kamoso
      libsForQt5.skanlite
      # libsForQt5.bismuth
      libsForQt5.okular
      libsForQt5.packagekit-qt
      libsForQt5.discover
      libsForQt5.kio
      kio-fuse
      libsForQt5.kio-gdrive
      libsForQt5.kio-extras
      libsForQt5.plasma-integration
      libsForQt5.plasma-nm
      libsForQt5.kdepim-runtime
      libsForQt5.accounts-qt
      libsForQt5.mauikit-accounts
      libsForQt5.kaccounts-integration
      libsForQt5.kaccounts-providers
      libsForQt5.signond
      libsForQt5.qoauth
      libsForQt5.flatpak-kcm
      libsForQt5.kcmutils
      libsForQt5.plasma-vault
      libsForQt5.kscreenlocker
      # Settings
      wayland-utils

      # Keyboard
      libsForQt5.qt5.qtwayland
      libsForQt5.qt5.qtvirtualkeyboard
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
