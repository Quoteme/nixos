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
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;
    programs.dconf.enable = true;
    programs.kdeconnect.enable = true;
    security.pam.services.sddm.enableKwallet = true;
    environment.systemPackages = with pkgs; [
      libsForQt5.ark
      libsForQt5.bismuth
      libsForQt5.packagekit-qt
      libsForQt5.discover
      libsForQt5.kio-gdrive
      libsForQt5.plasma-integration
      libsForQt5.plasma-nm
      libsForQt5.kalendar
      libsForQt5.accounts-qt
      libsForQt5.mauikit-accounts
      libsForQt5.kaccounts-integration
      libsForQt5.kaccounts-providers
      libsForQt5.signond
      libsForQt5.qoauth
      libsForQt5.calendarsupport
      libsForQt5.qtspeech
      libsForQt5.sddm
      libsForQt5.sddm-kcm
      libsForQt5.flatpak-kcm
      libsForQt5.kcmutils
      # Keyboard
      libsForQt5.qt5.qtvirtualkeyboard
      maliit-keyboard
      maliit-framework
      # spellcheck
      aspell
      aspellDicts.de
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
    ];
  };
}
