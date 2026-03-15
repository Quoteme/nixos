{
  config,
  options,
  lib,
  pkgs,
  nixpkgs,
  nixpkgs-stable,
  nur,
  nix-gl-host,
  ...
}@inputs:
{
  options.modules.applications.nix-extras = {
    enable = lib.options.mkEnableOption {
      type = lib.types.bool;
      default = true;
      description = "Enable further nix settings";
    };
  };

  config = lib.modules.mkIf config.modules.applications.nix-extras.enable {
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
        warn-dirty = false
      '';
      nixPath = [
        "nixpkgs=${nixpkgs}"
        "stable=${nixpkgs-stable}"
      ];
      # based on https://nixos.wiki/wiki/flakes#:~:text=Pinning%20the%20registry%20to%20the%20system%20pkgs%20on%20NixOS
      # registry = {
      #   # nixpkgs.flake = nixpkgs;
      #   nixpkgs = {
      #     from = {
      #       type = "indirect";
      #       id = "nixpkgs";
      #     };
      #     to = {
      #       type = "path";
      #       path = nixpkgs.outPath;
      #     };
      #   };
      #   stable.flake = nixpkgs-stable;
      #   nur.flake = nur;
      # };
      settings = {
        auto-optimise-store = true;
        trusted-users = [
          "root"
          "luca"
        ];
        substituters = [
          "https://nix-community.cachix.org/"
          "https://gvolpe-nixos.cachix.org"
          "https://cache.garnix.io"
          "https://cuda-maintainers.cachix.org"
          "https://cache.nixos.org/"
          "https://lean4.cachix.org/"
          "https://install.determinate.systems"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "gvolpe-nixos.cachix.org-1:0MPlBIMwYmrNqoEaYTox15Ds2t1+3R+6Ycj0hZWMcL0="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "lean4.cachix.org-1:mawtxSxcaiWE24xCXXgh3qnvlTkyU7evRRnGeAhD4Wk="
          "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        ];
      };
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/etc/nixos";
    };
    environment.variables = {
      FLAKE = lib.mkForce "/etc/nixos";
    };
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
        # CUDA (https://gist.github.com/chrishenn/77b5d4c05a781a266d74f39d29a110e5)
        cudaPackages.cudatoolkit
        cudaPackages.cuda_cudart
        cudaPackages.cuda_cupti
        cudaPackages.cuda_nvrtc
        cudaPackages.cuda_nvtx
        cudaPackages.cudnn
        cudaPackages.libcublas
        cudaPackages.libcufft
        cudaPackages.libcurand
        cudaPackages.libcusolver
        cudaPackages.libcusparse
        cudaPackages.libnvjitlink
        cudaPackages.nccl
        nix-gl-host.defaultPackage.x86_64-linux
        ffmpeg-full
        # List by default
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd

        # My own additions
        xorg.libXcomposite
        xorg.libXtst
        xorg.libXrandr
        xorg.libXext
        xorg.libX11
        xorg.libXfixes
        libGL
        libva
        pipewire
        xorg.libxcb
        xorg.libXdamage
        xorg.libxshmfence
        xorg.libXxf86vm
        libelf

        # Required
        glib
        gtk2

        # Inspired by steam
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/st/steam/package.nix#L36-L85
        networkmanager
        vulkan-loader
        libgbm
        libdrm
        libxcrypt
        coreutils
        pciutils
        zenity
        # glibc_multi.bin # Seems to cause issue in ARM

        # # Without these it silently fails
        xorg.libXinerama
        xorg.libXcursor
        xorg.libXrender
        xorg.libXScrnSaver
        xorg.libXi
        xorg.libSM
        xorg.libICE
        gnome2.GConf
        nspr
        nss
        cups
        libcap
        SDL2
        libusb1
        dbus-glib
        ffmpeg
        # Only libraries are needed from those two
        libudev0-shim

        # needed to run unity
        gtk3
        icu
        libnotify
        gsettings-desktop-schemas
        # https://github.com/NixOS/nixpkgs/issues/72282
        # https://github.com/NixOS/nixpkgs/blob/2e87260fafdd3d18aa1719246fd704b35e55b0f2/pkgs/applications/misc/joplin-desktop/default.nix#L16
        # log in /home/leo/.config/unity3d/Editor.log
        # it will segfault when opening files if you don’t do:
        # export XDG_DATA_DIRS=/nix/store/0nfsywbk0qml4faa7sk3sdfmbd85b7ra-gsettings-desktop-schemas-43.0/share/gsettings-schemas/gsettings-desktop-schemas-43.0:/nix/store/rkscn1raa3x850zq7jp9q3j5ghcf6zi2-gtk+3-3.24.35/share/gsettings-schemas/gtk+3-3.24.35/:$XDG_DATA_DIRS
        # other issue: (Unity:377230): GLib-GIO-CRITICAL **: 21:09:04.706: g_dbus_proxy_call_sync_internal: assertion 'G_IS_DBUS_PROXY (proxy)' failed

        # Verified games requirements
        xorg.libXt
        xorg.libXmu
        libogg
        libvorbis
        SDL
        SDL2_image
        glew110
        libidn
        tbb

        # Other things from runtime
        flac
        freeglut
        libjpeg
        libpng
        libpng12
        libsamplerate
        libmikmod
        libtheora
        libtiff
        pixman
        speex
        SDL_image
        SDL_ttf
        SDL_mixer
        SDL2_ttf
        SDL2_mixer
        libappindicator-gtk2
        libdbusmenu-gtk2
        libindicator-gtk2
        libcaca
        libcanberra
        libgcrypt
        libvpx
        librsvg
        xorg.libXft
        libvdpau
        # ...
        # Some more libraries that I needed to run programs
        pango
        cairo
        atk
        gdk-pixbuf
        fontconfig
        freetype
        dbus
        alsa-lib
        expat
        # for blender
        libxkbcommon

        libxcrypt-legacy # For natron
        libGLU # For natron

        # Appimages need fuse, e.g. https://musescore.org/fr/download/musescore-x86_64.AppImage
        fuse
        e2fsprogs
      ];
    };
  };
}
