{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf mkMerge;

  cfg = config.modules.security.gpg;
in
{
  options.modules.security.gpg =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) package;
    in
    {
      enable = mkEnableOption "Enable GnuPG (GPG) agent and tools";
      enableSSHSupport = mkEnableOption "Enable GPG agent SSH key support (replaces ssh-agent)" // {
        default = true;
      };
      pinentryPackage = mkOption {
        type = package;
        default = pkgs.pinentry-curses;
        description = "Pinentry program used by the GPG agent for passphrase prompts";
      };
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnupg
      pinentry-curses
    ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = cfg.enableSSHSupport;
      pinentryPackage = cfg.pinentryPackage;
    };

    # Ensure gpg-agent socket is available for user sessions
    security.pam.services.login.gnupg.enable = true;
  };
}
