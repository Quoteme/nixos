{ pkgs ? import <nixpkgs> {} }: with pkgs;
let
  haskellDeps = ps: with ps; [
    base
    xmonad
    xmonad-contrib
  ];
  #haskellPackages.ghcWithPackages
  haskellEnv = haskellPackages.ghcWithPackages haskellDeps;
in
mkShell {
  buildInputs = [
    haskellEnv
  ];
}
