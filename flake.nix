{
  description = "Luca Happels nixos ";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-23.05";
    nur.url = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # st-nix.url = "github:Quoteme/st-nix";
    # neovim-luca.url = "github:Quoteme/neovim-luca";
    emacs-overlay.url = "github:nix-community/emacs-overlay/da2f552d133497abd434006e0cae996c0a282394";
    nix-autobahn.url = "github:Lassulus/nix-autobahn";
    nix-alien.url = "github:thiagokokada/nix-alien";
    screenrotate.url = "github:Quoteme/screenrotate";
    screenrotate.inputs.nixpkgs.follows = "nixpkgs";
    rescreenapp.url = "github:Quoteme/rescreenapp";
    control_center.url = "github:Quoteme/control_center";
    xmonad-luca.url = "github:Quoteme/xmonad-luca";
    xmonad-luca.inputs.control_center.follows = "control_center";
    godot.url = "github:Quoteme/nixos-godot-bin";
    hmenke-nixos-modules.url = "github:hmenke/nixos-modules";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, nixpkgs, home-manager, ... }@attrs:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import attrs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      overlay-stable = final: prev: {
        stable = import attrs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      overlay-nix-autobahn = final: prev: {
        nix-autobahn = attrs.nix-autobahn.defaultPackage.x86_64-linux;
      };
      overlay-nix-alien = final: prev: {
        nix-alien = attrs.nix-alien.defaultPackage.x86_64-linux;
      };
      overlay-st-nix = final: prev: {
        st-nix = attrs.st-nix.defaultPackage.x86_64-linux;
      };
      overlay-screenrotate = final: prev: {
        screenrotate = attrs.screenrotate.defaultPackage.x86_64-linux;
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          overlay-unstable
          overlay-stable
          attrs.emacs-overlay.overlay
          attrs.nix-vscode-extensions.overlays.default
          attrs.godot.overlays.x86_64-linux.default
          overlay-nix-autobahn
          overlay-nix-alien
          overlay-st-nix
          overlay-screenrotate
          attrs.nur.overlay
        ];
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          attrs.nur.nixosModules.nur
          # ┏━╸┏━┓┏┓╻┏━╸╻┏━╸╻ ╻┏━┓┏━┓╺┳╸╻┏━┓┏┓╻ ┏┓╻╻╻ ╻
          # ┃  ┃ ┃┃┗┫┣╸ ┃┃╺┓┃ ┃┣┳┛┣━┫ ┃ ┃┃ ┃┃┗┫ ┃┗┫┃┏╋┛
          # ┗━╸┗━┛╹ ╹╹  ╹┗━┛┗━┛╹┗╸╹ ╹ ╹ ╹┗━┛╹ ╹╹╹ ╹╹╹ ╹
          ({ config, lib, options, nixpkgs, ... }@inputs:
            let

            in
            {
              imports = [
                ./hardware-configuration.nix
                ./hardware/asusROGFlowX13.nix
                ./modules/desktop/xmonad-luca.nix
                ./modules/desktop/gnome.nix
                (import ./modules/desktop/kde.nix { inherit config lib options pkgs; })
                (import ./modules/desktop/sway.nix { inherit config lib options pkgs; })
                (import ./modules/applications/editors/vscode.nix { inherit config lib options pkgs; })
                ./modules/applications/virtualisation/docker.nix
                ./modules/hardware/keyboard_de.nix
                ./modules/hardware/printing.nix
                ./modules/hardware/audio.nix
                (import ./modules/users/luca.nix { inherit config lib options pkgs; })
                (import ./modules/environment/systempackages.nix { inherit config lib options pkgs; })
              ];

              nix = {
                package = pkgs.unstable.nix;
                extraOptions = ''
                  experimental-features = nix-command flakes
                  warn-dirty = false
                '';
                nixPath = [
                  "nixpkgs=${nixpkgs}"
                  "unstable=${attrs.nixpkgs-unstable}"
                  "stable=${attrs.nixpkgs-stable}"
                  "nur=${attrs.nur}"
                  "nix-vscode=${attrs.nix-vscode-extensions}"
                ];
                registry = {
                  # nixpkgs.flake = nixpkgs;
                  nixpkgs = {
                    from = {
                      type = "indirect";
                      id = "nixpkgs";
                    };
                    to = {
                      type = "path";
                      path = inputs.nixpkgs.outPath;
                    };
                  };
                  unstable.flake = attrs.nixpkgs-unstable;
                  stable.flake = attrs.nixpkgs-stable;
                  nur.flake = attrs.nur;
                };
                settings = {
                  auto-optimise-store = true;
                  substituters = [
                    "https://nix-community.cachix.org/"
                    "https://gvolpe-nixos.cachix.org"
                    #"https://cache.garnix.io"
                    "https://cuda-maintainers.cachix.org"
                    "https://cache.nixos.org/"
                  ];
                  trusted-public-keys = [
                    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                    "gvolpe-nixos.cachix.org-1:0MPlBIMwYmrNqoEaYTox15Ds2t1+3R+6Ycj0hZWMcL0="
                    #"cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
                    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
                    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                  ];
                };
              };

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
                  allowedUDPPortRanges = [{ from = 32768; to = 61000; } { from = 1714; to = 1764; }];
                  allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
                  allowedTCPPorts = [ 80 5000 8000 8008 8009 8080 27017 ];
                };
              };

              # Time and location settings
              time.timeZone = "Europe/Berlin";
              time.hardwareClockInLocalTime = true;
              location.provider = "geoclue2";

              # Select internationalisation properties.
              i18n.defaultLocale = "de_DE.UTF-8";
              console = {
                font = "Lat2-Terminus16";
                useXkbConfig = true;
              };

              modules.hardware.keyboard-de.enable = true;
              modules.hardware.printing.enable = true;
              modules.hardware.audio.enable = true;
              modules.desktop.xmonad-luca.enable = true;
              modules.desktop.gnome.enable = false;
              modules.desktop.kde.enable = true;
              modules.desktop.sway.enable = false;
              modules.applications.editors.vscode.enable = true;
              modules.applications.virtualisation.docker.enable = true;
              modules.users.luca.enable = true;
              modules.environment.systemPackages.enable = true;

              services.clipcat.enable = true;

              # Enable OneDrive
              services.onedrive = {
                enable = true;
                package = pkgs.unstable.onedrive;
              };
              # Enable flatpak
              services.flatpak.enable = true;
              services.packagekit.enable = true;
              xdg.portal.enable = true;

              # Define a user account. Don't forget to set a password with ‘passwd’.
              # TODO: set passwort using hashed password
              users.users.root.initialHashedPassword = "";
              users.defaultUserShell = pkgs.zsh;

              # List fonts installed in system profile
              fonts.fonts = with pkgs; [
                scientifica
                font-awesome
                unifont
                siji
                openmoji-color
                fira-code
                hasklig
                material-icons
                # nerdfonts
                (pkgs.unstable.nerdfonts.override { fonts = [ "FiraCode" ]; })

                noto-fonts
                noto-fonts-cjk
                noto-fonts-emoji
                liberation_ttf
              ];
              fonts.fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" "openmoji-color" ];
              # List packages installed in system profile. To search, run:
              # $ nix search nixpkgs wget
              # TODO: move this into another file

              programs = {
                # https://github.com/Mic92/nix-ld
                nix-ld.enable = true;
                # nix-ld.package = pkgs.stable.nix-ld;

                # Some programs need SUID wrappers, can be configured further or are
                # started in user sessions.
                mtr.enable = true;
                gnupg.agent = {
                  enable = true;
                  enableSSHSupport = true;
                };

                # Password stuff
                # seahorse.enable = true;
                # ssh.enableAskPassword = true;

                #kdeconnect.enable = true;

                # Shell stuff
                bash.shellInit = "set -o vi";
                zsh = {
                  enable = true;
                  syntaxHighlighting = {
                    enable = true;
                    highlighters = [ "main" "brackets" ];
                  };
                  ohMyZsh = {
                    enable = true;
                    plugins = [
                      "adb"
                      "cabal"
                      "docker-compose"
                      "docker-machine"
                      "docker"
                      "lein"
                      "gradle"
                      "poetry"
                      "fd"
                      "vi-mode"
                      "dirhistory"
                      "gpg-agent"
                      # "keychain"
                      "zsh-interactive-cd"
                      "flutter"
                    ];
                    theme = "robbyrussell";
                  };
                  autosuggestions.enable = true;
                  promptInit = "autoload -U promptinit && promptinit && prompt fade && setopt prompt_sp";
                  shellAliases = {
                    l = "exa";
                    ll = "exa -l --icons";
                    lt = "exa -lT";
                    vs = "vim -S";
                    neovimupdate = "cd /etc/nixos && sudo nix flake lock --update-input neovim-luca && sudo nixos-rebuild switch && notify-send \"updated system\"";
                    vi = "nvim";
                    vim = "nvim";
                    nvs = "nix shell ~/Dokumente/dev/neovim-luca/#neovimLuca";
                    enw = "emacs -nw";
                    haskellshell = "nix shell unstable\#haskell-language-server unstable\#ghc unstable\#haskellPackages.haskell-dap unstable\#haskellPackages.ghci-dap unstable\#haskellPackages.haskell-debug-adapter unstable\#cabal-install";
                    cppshell = "nix shell unstable\#cmake unstable#gcc unstable#pkg-config";
                    webcam = "mpv av://v4l2:/dev/video0 --profile=low-latency --untimed";
                  };
                };

                # Android
                adb.enable = true;

                # Other
                file-roller.enable = true;
                dconf.enable = true;

                # xfce4-panel
                xfconf.enable = true;

                # security
                firejail.enable = true;
              };
              # development
              programs.java.enable = true;
              programs.npm = {
                enable = true;
                npmrc = ''
                  prefix = \$HOME/.npm
                  color=true
                '';
              };
              programs.darling.enable = true;


              # Gaming
              programs.gamemode = {
                enable = true;
                settings = {
                  custom = {
                    start = "${pkgs.libnotify}/bin/notify-send -u LOW -i input-gaming 'Gamemode started' 'gamemode started'";
                    end = "${pkgs.libnotify}/bin/notify-send -u LOW -i input-gaming 'Gamemode ended' 'gamemode ended'";
                  };
                };
              };
              programs.steam = {
                package = pkgs.unstable.steam;
                enable = true;
                remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
                dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
              };
              hardware.steam-hardware.enable = true;

              # Shell configuration
              environment.variables = {
                TERMINAL = "alacritty";
                CHROME_EXECUTABLE = "${pkgs.unstable.google-chrome}/bin/google-chrome-stable";
                ACCESSIBILITY_ENABLED = "1";
                PAGER = "nvimpager";
                # FZF - Ripgrep integration
                INITIAL_QUERY = "";
                RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case ";
                # "NIX_LD_LIBRARY_PATH" = "/run/current-system/sw/share/nix-ld/lib";
                # "NIX_LD" = toString nix-ld-so;
                # NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (config.systemd.packages ++ config.environment.systemPackages);
                # NIX_LD = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
                GAMEMODERUNEXEC = "nvidia-offload";
              };
              environment.sessionVariables = 
              let
                xdg_lib_home = "\${HOME}/.local/lib";
              in {
                XDG_CACHE_HOME = "\${HOME}/.cache";
                XDG_CONFIG_HOME = "\${HOME}/.config";
                XDG_LIB_HOME = xdg_lib_home;
                XDG_BIN_HOME = "\${HOME}/.local/bin";
                XDG_DATA_HOME = "\${HOME}/.local/share";

                DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";

                # XMONAD_DATA_DIR = "/etc/nixos/xmonad";
                # XMONAD_CONFIG_DIR = "/etc/nixos/xmonad";
                # XMONAD_CACHE_DIR = "/etc/nixos/xmonad/.cache";
                # NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
                MOZ_USE_XINPUT2 = "1";
                MOZ_ENABLE_WAYLAND = "1";

                FLUTTER_SDK = "${xdg_lib_home}/arch-id/flutter";
                CARGO_HOME = "\${HOME}/.cargo";
                RUSTUP_HOME = "\${HOME}/.rustup";

                ANDROID_SDK_ROOT = "${xdg_lib_home}/arch-id/android-sdk/";
                PATH = [
                  "\$XDG_BIN_HOME"
                  "\$FLUTTER_SDK/bin"
                  "\$ANDROID_SDK_ROOT/platform-tools"
                  "\$HOME/.config/emacs/bin"
                  "\$HOME/.elan/bin"
                  "\$HOME/.local/share/npm/bin"
                  # add rustup and cargo bin paths
                  "\$CARGO_HOME/bin"
                  "\$RUSTUP_HOME/toolchains/stable-x86_64-unknown-linux-gnu/bin"
                ];
              };

              virtualisation = {
                libvirtd = {
                  enable = true;
                  qemu.package = (pkgs.qemu_full.override {
                    gtkSupport = true;
                    sdlSupport = true;
                    virglSupport = true;
                    openGLSupport = true;
                  });
                };
                # virtualbox.host = {
                #   enable = true;
                #   package = pkgs.virtualboxWithExtpack;
                #   enableExtensionPack = true;
                # };
                waydroid.enable = false; # temporarily disabled because of system shutdown issues
                lxd.enable = true;
              };
              security = {
                polkit.enable = true;
                sudo.extraRules = [
                  {
                    groups = [ "wheel" ];
                    commands = [
                      { command = "/run/current-system/sw/bin/bluetooth"; options = [ "NOPASSWD" ]; }
                    ];
                  }
                ];
                pam = {
                  # allow user Luca to authenticate using a fingerprint
                  services = {
                    lightdm.enableGnomeKeyring = true;
                  };
                  enableSSHAgentAuth = true;
                };
              };
              # This value determines the NixOS release from which the default
              # settings for stateful data, like file locations and database versions
              # on your system were taken. It‘s perfectly fine and recommended to leave
              # this value at the release version of the first install of this system.
              # Before changing this value read the documentation for this option
              # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
              system.stateVersion = "22.05"; # Did you read the comment?
              # system.nixos.label = pkgs.lib.commitIdFromGitRepo "/etc/nixos/";
            })
          # ╻ ╻┏━┓┏┳┓┏━╸   ┏┳┓┏━┓┏┓╻┏━┓┏━╸┏━╸┏━┓
          # ┣━┫┃ ┃┃┃┃┣╸ ╺━╸┃┃┃┣━┫┃┗┫┣━┫┃╺┓┣╸ ┣┳┛
          # ╹ ╹┗━┛╹ ╹┗━╸   ╹ ╹╹ ╹╹ ╹╹ ╹┗━┛┗━╸╹┗╸
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.luca = import ./home.nix;
            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
}
