{ pkgs ? import <nixpkgs> { } }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "clipvault";
  version = "1.1.0"; # as of Sep 3, 2025
  src = pkgs.fetchFromGitHub {
    owner = "Rolv-Apneseth";
    repo = "clipvault";
    rev = "v${version}";
    sha256 = "sha256-ahhbUGijNZOjZ/egjdecn/4M6Nicq7PDDac09FNZz/Y=";
  };

  cargoHash = "sha256-Mm0att6zu9Yknoa9NBsdrA8lz1o0Q6FzWS0UU+1f/f0=";

  postInstall = ''
    install -Dm755 extras/clipvault_wofi.sh $out/bin/clipvault_wofi.sh
  '';

  # Tests write to a logs dir; sandbox blocks it --> disable.
  doCheck = false;

  meta = with lib; {
    description = "Clipboard history manager for Wayland";
    homepage = "https://github.com/Rolv-Apneseth/clipvault";
    license = "licenses.agpl30Only";
    mainProgram = "clipvault";
    platforms = platforms.linux;
  };
}
