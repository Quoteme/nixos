{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;

  cfg = config.modules.security.password-management.bitwarden;

  polkitPolicy = pkgs.stdenvNoCC.mkDerivation {
    pname = "bitwarden-polkit-policy";
    version = "unstable-2024-12-11";

    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/bitwarden/clients/92a620dd9c06c46127164d3c7a103aeafff92708/apps/desktop/resources/com.bitwarden.desktop.policy";
      sha256 = "sha256-4OC+DLfq0AB7r/HKbqzikGBH4byat5mFTnJCW50XdXc=";
    };

    dontUnpack = true;

    installPhase = ''
      install -Dm444 "$src" "$out/share/polkit-1/actions/com.bitwarden.Bitwarden.policy"
    '';
  };
in
{
  options.modules.security.password-management.bitwarden =
    let
      inherit (lib.options) mkEnableOption;
    in
    {
      enable = mkEnableOption "Bitwarden desktop biometrics integration (polkit action for the Flatpak build)";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = [ polkitPolicy ];
    security.polkit.enable = lib.mkDefault true;

    security.pam.services.polkit-1.fprintAuth = true;
  };
}
