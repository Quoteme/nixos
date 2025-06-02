{ config, options, lib, pkgs, nixpkgs, nixpkgs-stable, nur, ... }@inputs: {
  options.modules.applications.nix-extras = {
    enable = lib.options.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable further nix settings";
    };
  };

  config = lib.modules.mkIf config.modules.applications.nix-extras.enable {
    nix = {
      package = pkgs.nix;
      extraOptions = ''
        experimental-features = nix-command flakes
        warn-dirty = false
      '';
      nixPath = [ "nixpkgs=${nixpkgs}" "stable=${nixpkgs-stable}" ];
      registry = {
        # nixpkgs.flake = nixpkgs;
        nixpkgs = {
          from = {
            type = "indirect";
            id = "nixpkgs";
          };
          to = {
            type = "path";
            path = nixpkgs.outPath;
          };
        };
        stable.flake = nixpkgs-stable;
        nur.flake = nur;
      };
      settings = {
        auto-optimise-store = true;
        substituters = [
          "https://nix-community.cachix.org/"
          "https://gvolpe-nixos.cachix.org"
          "https://cache.garnix.io"
          "https://cuda-maintainers.cachix.org"
          "https://cache.nixos.org/"
          "https://lean4.cachix.org/"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "gvolpe-nixos.cachix.org-1:0MPlBIMwYmrNqoEaYTox15Ds2t1+3R+6Ycj0hZWMcL0="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "lean4.cachix.org-1:mawtxSxcaiWE24xCXXgh3qnvlTkyU7evRRnGeAhD4Wk="
        ];
      };
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/etc/nixos";
    };
    environment.variables = { FLAKE = lib.mkForce "/etc/nixos"; };
    environment.systemPackages = with pkgs; [
      nix-output-monitor
      nixpkgs-fmt
      nix-du
      nix-tree
      nix-health
    ];
    # programs.nix-index = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   enableZshIntegration = true;
    # };
    # https://github.com/Mic92/nix-ld
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        gcc.cc
        glibc
        icu
        libGL
        openssl
        stdenv.cc.cc
        xorg.libX11
        zlib
      ];
    };
  };
}
