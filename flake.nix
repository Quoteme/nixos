{
  description = "Luca Happels nixos ";

  inputs = {
    hmenke-nixos-modules.url = "github:hmenke/nixos-modules";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nix-gl-host.url = "github:numtide/nix-gl-host";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nixd.url = "github:nix-community/nixd";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap-flake.url = "github:xremap/nix-flake/1924f2dc1a7c219b5323050a7fb27920e3a225d4";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };
    hy3 = {
      url = "github:outfoxxed/hy3?ref=9625801";
      inputs.hyprland.follows = "hyprland";
    };
    hyprtasking = {
      url = "github:raybbian/hyprtasking";
      inputs.hyprland.follows = "hyprland";
    };
    hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };
    hyprfocus = {
      url = "github:pyt0xic/hyprfocus";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-index-database,
      lanzaboote,
      xremap-flake,
      nix-gl-host,
      determinate,
      ...
    }@attrs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      # Recursively collect every .nix file under ./modules
      allModules = lib.filter (p: lib.hasSuffix ".nix" (toString p)) (
        lib.filesystem.listFilesRecursive ./modules
      );
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        # All flake inputs + derived values are available as module arguments
        specialArgs = attrs // {
          inherit attrs;
          # hyprland plugins passed as a single 'hyprlandPlugins' arg consumed by hyprland.nix
          hyprlandPlugins = [
            # attrs.hyprgrass.packages.${system}.default
            # attrs.hyprspace.packages.${system}.default
            # attrs.hy3.packages.${system}.hy3
            # attrs.hyprtasking.packages.${system}.hyprtasking
            # attrs.hyprfocus.packages.${system}.default
          ];
        };
        modules = [
          determinate.nixosModules.default
          attrs.hyprland.nixosModules.default
          attrs.nur.modules.nixos.default
          lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
        ]
        ++ allModules
        ++ [
          # ┏━╸┏━┓┏┓╻┏━╸╻┏━╸╻ ╻┏━┓┏━┓╺┳╸╻┏━┓┏┓╻ ┏┓╻╻╻ ╻
          # ┃  ┃ ┃┃┗┫┣╸ ┃┃╺┓┃ ┃┣┳┛┣━┫ ┃ ┃┃ ┃┃┗┫ ┃┗┫┃┏╋┛
          # ┗━╸┗━┛╹ ╹╹  ╹┗━┛┗━┛╹┗╸╹ ╹ ╹ ╹┗━┛╹ ╹╹╹ ╹╹╹ ╹
          (
            { pkgs, nixpkgs-stable, ... }:
            {
              nixpkgs.overlays = [
                (final: prev: {
                  stable = import nixpkgs-stable {
                    inherit system;
                    config.allowUnfree = true;
                  };
                  nixd-nightly = attrs.nixd.packages.${system}.nixd;
                  screenrotate = attrs.screenrotate.defaultPackage.${system};
                })
              ];
              nixpkgs.config.allowUnfree = true;

              boot = {
                kernelPackages = pkgs.stable.linuxPackages_latest;
                # windows integration
                supportedFilesystems = [ "ntfs" ];
              };

              # Networking
              networking = {
                hostName = "nixos";
                networkmanager.enable = true;
                firewall = {
                  allowedUDPPortRanges = [
                    {
                      from = 32768;
                      to = 61000;
                    }
                    {
                      from = 1714;
                      to = 1764;
                    }
                  ];
                  allowedUDPPorts = [
                    51413
                    10001
                    10002
                    10011
                    10012
                    5187
                  ];
                  allowedTCPPortRanges = [
                    {
                      from = 1714;
                      to = 1764;
                    }
                  ];
                  allowedTCPPorts = [
                    22
                    24800
                    25565
                    80
                    5000
                    8000
                    8008
                    8009
                    8080
                    27017
                    51413
                    5187
                  ];
                };
              };

              # Time and location settings
              time.timeZone = "Europe/Berlin";
              time.hardwareClockInLocalTime = true;
              location.provider = "geoclue2";

              # Select internationalisation properties.
              i18n.defaultLocale = "en_US.UTF-8";
              i18n.supportedLocales = [
                "en_US.UTF-8/UTF-8"
                "de_DE.UTF-8/UTF-8"
              ];
              # To launch an app in German:
              #   LANG=de_DE.UTF-8 some-app
              # To switch the whole session temporarily:
              #   export LANG=de_DE.UTF-8
              console = {
                font = "Lat2-Terminus16";
                useXkbConfig = true;
              };

              modules.applications.editors.vscode-fhs.enable = true;
              modules.applications.ai.ollama.enable = true;
              modules.applications.gaming.steam.enable = false;
              modules.applications.nix-extras.enable = true;
              modules.applications.virtualisation.docker.enable = true;
              modules.applications.virtualisation.virt-manager.enable = true;
              modules.desktop.cosmic.enable = false;
              modules.desktop.hyprland.enable = true;
              modules.desktop.gnome.enable = false;
              modules.desktop.kde.enable = false;
              modules.desktop.sway.enable = false;
              modules.desktopManager.lightdm.enable = false;
              modules.desktopManager.sddm.enable = false;
              modules.loginManager.greetd.enable = true;
              modules.environment.systemPackages.enable = true;
              modules.environment.user_shell_nushell.enable = true;
              modules.fonts.enable = true;
              modules.hardware.audio.enable = true;
              modules.hardware.disks.enable = true;
              modules.hardware.keyboard-de.enable = true;
              modules.hardware.laptop.asus-rog-flow-x13.enable = true;
              modules.hardware.printing.enable = true;
              modules.hardware.metered_connection.enable = true;
              modules.users.luca.enable = true;

              services.flatpak.enable = true;
              services.packagekit.enable = true;
              xdg.portal.enable = true;
              users.users.root.initialHashedPassword = "";
              users.defaultUserShell = pkgs.fish;

              programs = {
                # Some programs need SUID wrappers, can be configured further or are
                # started in user sessions.
                mtr.enable = true;

                # Other
                dconf.enable = true;

                # security
                firejail.enable = true;
              };
              # development
              programs.java.enable = true;
              programs.npm = {
                enable = true;
                npmrc = ''
                  prefix = ''${HOME}/.npm
                  color=true
                '';
              };

              # Shell configuration
              environment.variables = {
                TERMINAL = "kitty";
                VISUAL = "nvim";
                EDITOR = "nvim";
                ACCESSIBILITY_ENABLED = "1";
                PAGER = "nvimpager";
                # FZF - Ripgrep integration
                INITIAL_QUERY = "";
                RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case ";
                CHROME_EXECUTABLE = "/var/lib/flatpak/app/com.google.Chrome/x86_64/stable/active/export/bin/com.google.Chrome";
                GAMEMODERUNEXEC = "nvidia-offload";
              };
              environment.localBinInPath = true;
              environment.sessionVariables = {
                XDG_BIN_HOME = "\${HOME}/.local/bin";
                XDG_CACHE_HOME = "\${HOME}/.cache";
                XDG_CONFIG_HOME = "\${HOME}/.config";
                XDG_DATA_HOME = "\${HOME}/.local/share";
                XDG_LIB_HOME = "\${HOME}/.local/lib";

                # DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";

                # XMONAD_DATA_DIR = "/etc/nixos/xmonad";
                # XMONAD_CONFIG_DIR = "/etc/nixos/xmonad";
                # XMONAD_CACHE_DIR = "/etc/nixos/xmonad/.cache";
                # NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";

                VISUAL = "nvim";
                EDITOR = "nvim";

                CARGO_HOME = "\${HOME}/.cargo";
                RUSTUP_HOME = "\${HOME}/.rustup";

                # FLUTTER_SDK = "${xdg_lib_home}/arch-id/flutter";
                # ANDROID_SDK_ROOT = "${xdg_lib_home}/arch-id/android-sdk/";
                PATH = [
                  "$XDG_BIN_HOME"
                  "$FLUTTER_SDK/bin"
                  # "\$ANDROID_SDK_ROOT/platform-tools"
                  "$HOME/.elan/bin"
                  "$HOME/.local/share/npm/bin"
                  "$HOME/.npm/bin"
                  # add rustup and cargo bin paths
                  "$CARGO_HOME/bin"
                  "$RUSTUP_HOME/toolchains/stable-x86_64-unknown-linux-gnu/bin"
                ];
              };

              virtualisation = {
                libvirtd = {
                  enable = false;
                  qemu.package = (
                    pkgs.stable.qemu_full.override {
                      gtkSupport = true;
                      sdlSupport = true;
                      virglSupport = true;
                      openGLSupport = true;
                    }
                  );
                };
                waydroid.enable = false;
                # lxd.enable = false;
              };
              security = {
                polkit.enable = true;
                sudo.extraRules = [
                  {
                    groups = [ "wheel" ];
                    commands = [
                      {
                        command = "/run/current-system/sw/bin/bluetooth";
                        options = [ "NOPASSWD" ];
                      }
                    ];
                  }
                ];
                # pam = {
                #   enableSSHAgentAuth = true;
                # };
              };
              # This value determines the NixOS release from which the default
              # settings for stateful data, like file locations and database versions
              # on your system were taken. It‘s perfectly fine and recommended to leave
              # this value at the release version of the first install of this system.
              # Before changing this value read the documentation for this option
              # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
              system.stateVersion = "22.05"; # Did you read the comment?
              # system.nixos.label = pkgs.lib.commitIdFromGitRepo "/etc/nixos/";
            }
          )
          # ╻ ╻┏━┓┏┳┓┏━╸   ┏┳┓┏━┓┏┓╻┏━┓┏━╸┏━╸┏━┓
          # ┣━┫┃ ┃┃┃┃┣╸ ╺━╸┃┃┃┣━┫┃┗┫┣━┫┃╺┓┣╸ ┣┳┛
          # ╹ ╹┗━┛╹ ╹┗━╸   ╹ ╹╹ ╹╹ ╹╹ ╹┗━┛┗━╸╹┗╸
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.luca.imports = [
              nix-index-database.homeModules.nix-index
              { programs.nix-index-database.comma.enable = true; }
              ./home.nix
            ];
          }
        ];
      };
    };
}
