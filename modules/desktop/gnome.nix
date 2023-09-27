{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.desktop.gnome;
in
{
  options.modules.desktop.gnome =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable the Gnome desktop environment (together with GDM and all other goodies)";
    };

  config = mkIf cfg.enable {
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.gnome.at-spi2-core.enable = true; # Accessibility Bus
    services.gnome.gnome-keyring.enable = true;
    services.gnome.gnome-settings-daemon.enable = true;
    services.gnome.gnome-online-accounts.enable = true;
    services.gnome.gnome-browser-connector.enable = true;
    services.gnome.evolution-data-server.enable = true;
    services.gnome.glib-networking.enable = true;
    services.gnome.sushi.enable = true;
    services.gnome.tracker.enable = true;
    services.gnome.tracker-miners.enable = true;
    services.gnome.gnome-online-miners.enable = true;
    services.gnome.gnome-user-share.enable = true;
    services.gnome.gnome-remote-desktop.enable = true;
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      gnomeExtensions.pop-shell
      gnomeExtensions.gsconnect
      gnomeExtensions.one-drive-resurrect
      ffmpegthumbnailer # thumbnails
      gnome.nautilus-python # enable plugins
      gst_all_1.gst-libav # thumbnails
      nautilus-open-any-terminal # terminal-context-entry
    ];
    environment.gnome.excludePackages = (with pkgs.gnome; [
      gnome-terminal
      geary
      epiphany
    ]);
    security.pam.services.gdm = {
      enableGnomeKeyring = true;
      fprintAuth = true;
      gnupg.enable = true;
      sshAgentAuth = true;
    };

    # make qt apps look like gtk
    # https://nixos.org/manual/nixos/stable/index.html#sec-x11-gtk-and-qt-themes
    qt.enable = true;
    qt.platformTheme = "gtk2";
    qt.style = "gtk2";
    programs.file-roller.enable = true;
  };
}
