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

  cfg = config.modules.loginManager.greetd;
in
{
  options.modules.loginManager.greetd =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable the Greetd login manager";
    };

  config = mkIf cfg.enable {
    services.greetd.enable = true;
    programs.regreet = {
      enable = true;
      cursorTheme.package = pkgs.vimix-cursors;
      cursorTheme.name = "Vimix-cursors";
      iconTheme.package = pkgs.vimix-icon-theme;
      iconTheme.name = "Vimix-beryl-dark";
      # theme.package = pkgs.vimix-gtk-themes;
      # theme.name = "Vimix-dark-doder";
    };
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    # The login keyring is encrypted with the login password, so PAM can only
    # unlock it if a password was typed. By default greetd authenticates via the
    # `login` service, where a fingerprint match short-circuits the rest of the
    # stack and leaves the keyring locked. Use a password-only stack instead.
    # (`login` itself is left alone: the noctalia lockscreen uses it, and should
    # keep accepting fingerprints.)
    security.pam.services.greetd.rules.auth.login.modulePath = lib.mkForce "greetd-password";
    security.pam.services.greetd-password = {
      fprintAuth = false;
      enableGnomeKeyring = true;
      # match what greetd previously got from `login`
      allowNullPassword = config.security.pam.services.login.allowNullPassword;
      gnupg.enable = config.security.pam.services.login.gnupg.enable;
    };
  };
}
