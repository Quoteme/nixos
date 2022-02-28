{
  description = "Luca Happels nixos ";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    st-nix.url = "github:Quoteme/st-nix";
    neovim-luca.url = "github:Quoteme/neovim-luca";
  };
  
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@attrs:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          # TODO make use of overlay stable
          overlay-unstable
        ];
      };
    in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        # ┏━╸┏━┓┏┓╻┏━╸╻┏━╸╻ ╻┏━┓┏━┓╺┳╸╻┏━┓┏┓╻ ┏┓╻╻╻ ╻
        # ┃  ┃ ┃┃┗┫┣╸ ┃┃╺┓┃ ┃┣┳┛┣━┫ ┃ ┃┃ ┃┃┗┫ ┃┗┫┃┏╋┛
        # ┗━╸┗━┛╹ ╹╹  ╹┗━┛┗━┛╹┗╸╹ ╹ ╹ ╹┗━┛╹ ╹╹╹ ╹╹╹ ╹
        ({ config, nixpkgs, ...}@inputs: 
        let
          xmobar-luca = (pkgs.callPackage (pkgs.fetchFromGitHub {
            owner = "quoteme";
            repo = "xmobar-luca";
            rev = "v1.3";
            sha256 = "07n05zz8fbddkp35ppay1pzw3rgk56ivph7c5hysp26ivris1mim";
          }) {} );
          flex5ScreenRotate = (pkgs.callPackage (pkgs.fetchFromGitHub {
            owner = "quoteme";
            repo = "flex5ScreenRotate";
            rev = "v1.5";
            sha256 = "17jsq5qwqkfsyk4b01wk6bjf6czhirbyh9z5a4b0d73ppykbjz9j";
          }) {} );
          xmonadctl = (pkgs.callPackage (pkgs.fetchFromGitHub {
            owner = "quoteme";
            repo = "xmonadctl";
            rev = "v1.0";
            sha256 = "1bjf3wnxsghfb64jji53m88vpin916yqlg3j0r83kz9k79vqzqxd";
          }) {} );
        in
        {
          imports = [
            ./hardware-configuration.nix
            # ./hardware/ideapadflex5.nix
            ./hardware/thinkpadx201t.nix
          ];
          nix = {
            package = pkgs.unstable.nix;
            extraOptions = ''
              experimental-features = nix-command flakes
              warn-dirty = false
           '';
          };
          boot = {
            # allow AMD graphics card
            kernelPackages = pkgs.linuxPackages_latest;
            # windows integration
            supportedFilesystems = [ "ntfs" ];
          };
          # enable swap
          swapDevices = [ {device = "/dev/disk/by-label/swap";} ];
          # Networking
          networking = {
            hostName = "nixos";
            networkmanager.enable = true;
            # The global useDHCP flag is deprecated, therefore explicitly set to false here.
            # Per-interface useDHCP will be mandatory in the future, so this generated config
            # replicates the default behaviour.
            useDHCP = false;
          };
          # Time and location settings
          time.timeZone = "Europe/Berlin";
          time.hardwareClockInLocalTime = true;
          location.provider = "manual";
          location.latitude = 51.192230;
          location.longitude = 6.439590;
          # Select internationalisation properties.
          i18n.defaultLocale = "de_DE.UTF-8";
          console = {
            font = "Lat2-Terminus16";
            keyMap = "de-latin1";
          };
          # Enable the X11 windowing system.
          # TODO clean this up
          services = {
            xserver = {
              enable = true;
              # keyboard settings
                layout = "de";
                extraLayouts.hyper = { # TODO this does not work :(
                  description = "Use escape key as Hyper key";
                  languages = [];
                  symbolsFile = pkgs.writeText "hyper" ''
                    partial modifier_keys
                    xkb_symbols "hyper" {
                    key <ESC> { [Hyper_R] };
                    modifier_map Mod3 { <HYPR>, Hyper_R };
                    }
                  '';
                };
                xkbVariant = "nodeadkeys";
                xkbOptions = "caps:swapescape";
                updateDbusEnvironment = true;
              # Display Manager
                displayManager = {
                  lightdm.enable = true;
                  defaultSession = "none+xmonad";
                };
              # Window managers / Desktop managers
                windowManager = {
                  xmonad = {
                    enable = true;
                    enableContribAndExtras = true;
                    extraPackages = hpkgs: with hpkgs; [
                      xmonad
                      xmonad-contrib
                      xmonad-extras
                    ];
                    config = ./xmonad/xmonad.hs;
                  };
                };
              };
            
            printing.enable = true;
            printing.drivers = with pkgs; [
              gutenprint
              gutenprintBin
              hplip
              hplipWithPlugin
              samsungUnifiedLinuxDriver
              splix
              brlaser
              brgenml1lpr
              brgenml1cupswrapper
              cnijfilter2
            ];
            avahi.enable = true;
            avahi.nssmdns = true;
            touchegg.enable = true;
            gnome.gnome-keyring.enable = true;
            gnome.at-spi2-core.enable = true; # Accessibility Bus
            blueman.enable = true;
            udisks2.enable = true;
            devmon.enable = true;
            gvfs.enable = true;
            tumbler.enable = true;
            # picom.enable = true;
            redshift.enable = true;
            # Powersaving
            tlp.enable = true;
            # cloud storage
            onedrive.enable = true;
          };
          # make qt apps look like gtk
          # https://nixos.org/manual/nixos/stable/index.html#sec-x11-gtk-and-qt-themes
          qt5.enable = true;
          qt5.platformTheme = "gtk2";
          qt5.style = "gtk2";
          # Enable sound.
          sound = {
            enable = true;
            mediaKeys.enable = true;
          };
          hardware = {
            pulseaudio.enable = true;
            bluetooth = {
              enable = true;
              powerOnBoot = false;
            };
          };
          # Define a user account. Don't forget to set a password with ‘passwd’.
          # TODO set passwort using hashed password
          users.users.root.initialHashedPassword = "";
          users.users.luca = {
            isNormalUser = true;
            extraGroups = [ "networkmanager" "storage" "video" "bluetooth" "adbusers" "wheel" "kvm" "libvirtd" ];
            shell = pkgs.zsh;
            initialHashedPassword = "";
          };
          users.defaultUserShell = pkgs.zsh;
          # List fonts installed in system profile
          fonts.fonts = with pkgs; [
            scientifica
            font-awesome
            unifont
            siji
            noto-fonts-emoji
            fira-code
            hasklig
            nerdfonts
          ];
          # List packages installed in system profile. To search, run:
          # $ nix search nixpkgs wget
          # TODO move this into another file
          environment.systemPackages = with pkgs; [
            # Internet
              chromium
              thunderbird
              discord
              transmission-gtk
            # # Drawing
              xournalpp
              write_stylus
              inkscape
              gimp
              blender
              krita # all the kde dependencies are annoying so far; TODO remove kde deps
            # # Media
              mpv
              vlc
              evince
              deadbeef
              sxiv
            # Gaming
              minecraft
            # Productivity
              libreoffice
            # Small Utilities
              mons
              brightnessctl
              iw
              ffmpeg
              linux-router
              macchanger
              pavucontrol
              imagemagick
              maim
              xclip
              peek
              killall
              xorg.xkill
              wget
              git
              exa
              fzf
              ripgrep
              bat
              toilet
              htop-vim
              nvimpager
              # TODO add manual how to add nix-flakes as system-programs
              # TODO add this manual to reddit post
              inputs.st-nix.defaultPackage.x86_64-linux
            # Programming
              inputs.neovim-luca.defaultPackage.x86_64-linux
              vscode
              devdocs-desktop
              # math
                sage
              # python
                poetry
                (pkgs.unstable.python39.withPackages(ps : with ps; [
                  numpy
                  scipy
                  matplotlib
                  pysimplegui
                ]))
              # Latex
                pandoc
                texlive.combined.scheme-full
              # Haskell
                (haskellPackages.ghcWithPackages (hpkgs: with hpkgs; [
                  base
                  xmonad
                  xmonad-contrib
                  comonad
                  containers_0_6_5_1
                ]))
              # Spelling
                hunspell
                hunspellDicts.de_DE
                hunspellDicts.en_US
              # Android
                libmtp
                usbutils
                scrcpy
            # Development
              # Language Server
                # LaTex
                  texlab
                # Haskell
                  haskell-language-server
                  ormolu
                # JavaScript / Typescript
                  nodePackages.typescript-language-server
                # NIX
                  rnix-lsp
                # Python
                  pyright
                # Rust
                  rls
                # Clojure
                  leiningen
                  clojure-lsp 
                # C
                  gcc
                  clang
                  clang-tools
            # Window Manager
              rofi
              rofimoji
              networkmanager_dmenu
              networkmanagerapplet
              openvpn
              networkmanager-openvpn
            # File manager
              pcmanfm
                # Thumbnailers
                ffmpegthumbnailer
                f3d
              onboard
              jgmenu
              pamixer
              nitrogen
              xdotool
              neofetch
              onefetch
              pywal
              dunst
              #xmobar-luca
              xmonadctl
              flex5ScreenRotate
              batsignal
              polkit_gnome
              gnome.gnome-clocks
              # emulation
              virt-manager # currently broken TODO
          ];
          programs = {
            # Some programs need SUID wrappers, can be configured further or are
            # started in user sessions.
            mtr.enable = true;
            gnupg.agent = {
              enable = true;
              enableSSHSupport = true;
            };
            # This option somehow does not work??? TODO
            # ssh.enableAskPassword = true;
            # Shell stuff
            bash.shellInit = "set -o vi";
            zsh = {
              enable = true;
              syntaxHighlighting = {
                enable = true;
                highlighters = [ "main" "brackets" ];
              };
              ohMyZsh.plugins = [
                "lein"
                "poetry"
              ];
              autosuggestions.enable = true;
              shellInit = "(cat ~/.cache/wal/sequences &) && bindkey -v";
              promptInit = "autoload -U promptinit && promptinit && prompt fade && setopt prompt_sp";
              shellAliases = {
                l = "exa";
                ls = "exa -l";
                lt = "exa -lT";
                webcam = "mpv av://v4l2:/dev/video0 --profile=low-latency --untimed";
              };
            };
            # Android
            adb.enable = true;
            # Other
            file-roller.enable = true;
            dconf.enable = true;
          };
          # Shell configuration
          environment.variables = {
            "ACCESSIBILITY_ENABLED" = "1";
            "PAGER" = "nvimpager";
            # FZF - Ripgrep integration
            "INITIAL_QUERY" = "";
            "RG_PREFIX"="rg --column --line-number --no-heading --color=always --smart-case ";
            "FZF_DEFAULT_COMMAND"=''$RG_PREFIX '$INITIAL_QUERY'" \
              fzf --bind "change:reload:$RG_PREFIX {q} || true" \
                  --ansi --disabled --query "$INITIAL_QUERY" \
                  --height=50% --layout=reverse'';
          };
          virtualisation = {
            libvirtd = {
              enable = true;
              qemu.package = pkgs.qemu_full;
            };
          };
          security = {
            polkit.enable = true;
            sudo.extraRules = [
              { groups = [ "wheel" ];
                commands = [
                  { command = "/run/current-system/sw/bin/bluetooth"; options = [ "NOPASSWD" ]; }
                ];
              }
            ];
            pam = {
              # allow user Luca to authenticate using a fingerprint
              services = {
                luca = {
                  fprintAuth = true;
                  sshAgentAuth = true;
                };
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
          system.stateVersion = "21.05"; # Did you read the comment?
        })
        # ╻ ╻┏━┓┏┳┓┏━╸   ┏┳┓┏━┓┏┓╻┏━┓┏━╸┏━╸┏━┓
        # ┣━┫┃ ┃┃┃┃┣╸ ╺━╸┃┃┃┣━┫┃┗┫┣━┫┃╺┓┣╸ ┣┳┛
        # ╹ ╹┗━┛╹ ╹┗━╸   ╹ ╹╹ ╹╹ ╹╹ ╹┗━┛┗━╸╹┗╸
        home-manager.nixosModules.home-manager{
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
