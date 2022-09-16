{
  description = "Luca Happels nixos ";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    st-nix.url = "github:Quoteme/st-nix";
    neovim-luca.url = "github:Quoteme/neovim-luca";
    nix-autobahn.url = "github:Lassulus/nix-autobahn";
    nix-alien.url = "github:thiagokokada/nix-alien";
    screenrotate.url = "github:Quoteme/screenrotate";
    screenrotate.inputs.nixpkgs.follows = "nixpkgs";
    rescreenapp.url = "github:Quoteme/rescreenapp";
    rescreenapp.inputs.nixpkgs.follows = "nixpkgs";
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
          # TODO: make use of overlay stable
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
          xmonadctl = (pkgs.callPackage (pkgs.fetchFromGitHub {
            owner = "quoteme";
            repo = "xmonadctl";
            rev = "v1.0";
            sha256 = "1bjf3wnxsghfb64jji53m88vpin916yqlg3j0r83kz9k79vqzqxd";
          }) {} );
          myGHCPackages = (hpkgs: with hpkgs; [
            xmonad
            xmonad-contrib
            xmonad-extras
          ]);
          myIDEA = pkgs.symlinkJoin {
            name = "myIDEA";
            paths = with pkgs; [
              jetbrains.idea-community
              # instead use:
              # https://discourse.nixos.org/t/flutter-run-d-linux-build-process-failed/16552/3
              flutter
              dart
            ];
          };
        in
        {
          imports = [
            ./hardware-configuration.nix
            ./hardware/asusROGFlowX13.nix
          ];

          nix = {
            package = pkgs.unstable.nix;
            extraOptions = ''
              experimental-features = nix-command flakes
              warn-dirty = false
           '';
          };

          boot = {
            kernelPackages = pkgs.linuxPackages_latest;
            # windows integration
            supportedFilesystems = [ "ntfs" ];
          };
	  
          # Networking
          networking = {
            hostName = "nixos";
            networkmanager.enable = true;
            firewall = {
              allowedUDPPortRanges = [{from=32768; to=61000;}];
              allowedTCPPortRanges = [{from=8008; to=8009;}];
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
                  lightdm = {
                    enable = true;
                    greeters.gtk = {
                      theme.package = pkgs.mojave-gtk-theme;
                      theme.name = "Mojave-Dark";
                      iconTheme.name ="Papirus";
                      iconTheme.package = pkgs.papirus-icon-theme;
                      indicators = [ "~host" "~spacer" "~clock" "~spacer" "~session" "~language" "~a11y" "~power" ];
                      extraConfig = "keyboard=onboard";
                    };
                  };
                  defaultSession = "none+xmonad";
                };
              # Window managers / Desktop managers
                windowManager = {
                  xmonad = {
                    enable = true;
                    enableContribAndExtras = true;
                    extraPackages = myGHCPackages;
                    config = ./xmonad/xmonad.hs;
                  };
                  bspwm = {
                    enable = true;
                    configFile = ./config/bspwmrc;
                    sxhkd.configFile = ./config/sxhkdrc;
                  };
                };
              };
            
            printing.enable = true;
            printing.drivers = with pkgs; [
              gutenprint
              gutenprintBin
              hplip
              hplipWithPlugin
              samsung-unified-linux-driver
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
            picom.enable = true;
            redshift.enable = true;
            # Lock screen
            # physlock = {
            #   enable = true;
            #   lockMessage = "Lulca\'s Laptop";
            # };
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
          # TODO: set passwort using hashed password
          users.users.root.initialHashedPassword = "";
          users.users.luca = {
            initialHashedPassword = "$6$W62LDzjtggxhhOiJ$KKM1yuHOrEr3Mz4MSstUGBtlpEF2AHR8bAzFeaqo2l.rrka/phKnzbKbyM5HX955d9et2NnV2fOr9LnDCgB5M1";
            isNormalUser = true;
            extraGroups = [
              "networkmanager"
              "storage"
              "video"
              "bluetooth"
              "adbusers"
              "wheel"
              "kvm"
              "libvirtd"
              "libvirt"
              "docker"
              "input"
            ];
            shell = pkgs.zsh;
            packages = with pkgs; [
            # Internet
              google-chrome
              microsoft-edge
              discord
              transmission-gtk
              thunderbird
              birdtray
            # # Drawing
              xournalpp
              inkscape
              gimp
              aseprite
              (pkgs.unstable.blender.override {
                cudaSupport = true;
              })
              krita
            # # Media
              vlc
              mpv
              yt-dlp
              evince
              deadbeef
              sxiv
            # Gaming
              pkgs.unstable.minecraft
            # Productivity
              libreoffice
            # Programming
              inputs.neovim-luca.defaultPackage.x86_64-linux
              vscode-fhs
              devdocs-desktop
              # devdocs-desktop
              # math
                # pkgs.unstable.sage # FIX: This currently is insecure and takes too long to compile :(
                julia-bin
              # python
                poetry
                ((pkgs.python310.withPackages(ps : with ps; [
                  ipython
                  jupyterlab
                  sympy
                  numpy
                  scipy
                  matplotlib
                  (qiskit.overrideAttrs (prev: {
                    doCheck = false;
                  }))
                  # qiskit optional dependencies
                    pylatexenc
                  # pysimplegui
                  # qiskit
                ])).override (args: { ignoreCollisions = true; })) # this is for qiskit
              # Latex
                pandoc
                poppler_utils
                texlive.combined.scheme-full
                tex-match
              # Haskell
                (haskellPackages.ghcWithPackages myGHCPackages)
              # Java
                jdk
                gradle
                myIDEA
              # C
                valgrind
                gcc
                check
                lldb
                gdb
                gdbgui
              # Spelling
                hunspell
                hunspellDicts.de_DE
                hunspellDicts.en_US
              # Android
                libmtp
                usbutils
                scrcpy
                nodePackages.cordova
              # Flutter
                android-tools
                android-studio
                flutter
                dart
              # game-dev
                godot
              # UNI HHU ZEUG
                # konferenzen
                  zoom-us
                  teams
                  slack
                # PROPORA
                  mob
            ];
          };
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
            (nerdfonts.override { fonts = [ "FiraCode" ]; })
          ];
          fonts.fontconfig.defaultFonts.emoji = ["openmoji-color"];
          # List packages installed in system profile. To search, run:
          # $ nix search nixpkgs wget
          # TODO: move this into another file
          environment.systemPackages = with pkgs; [
            # Small Utilities
              # nix-ld stuff
                inputs.nix-autobahn.defaultPackage.x86_64-linux
                inputs.nix-alien.defaultPackage.x86_64-linux
                nix-index
                fzf
              mons
              arandr
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
              gh
              gitkraken
              exa
              ripgrep
              fd
              bat
              power-profiles-daemon
              # archiving
                zip
                unzip
              toilet
              htop-vim
              nvimpager
              # TODO: add manual how to add nix-flakes as system-programs
              # TODO: add this manual to reddit post
              inputs.st-nix.defaultPackage.x86_64-linux
            # Window Manager
              rofi
              rofimoji
              networkmanager_dmenu
              networkmanagerapplet
              openvpn
              networkmanager-openvpn
            # File manager
              cinnamon.nemo
              pcmanfm-qt
                # Thumbnailers
                ffmpegthumbnailer
                f3d
              gparted
              onboard
              jgmenu
              pamixer
              nitrogen
              xdotool
              neofetch
              onefetch
              libnotify
              dunst
              #xmobar-luca
              xmonadctl
              inputs.screenrotate.defaultPackage.x86_64-linux
              inputs.rescreenapp.defaultPackage.x86_64-linux
              batsignal
              polkit_gnome
              gnome.gnome-clocks
              lightlocker
            # emulation
              virt-manager
              virglrenderer
              # Wine
                wineWowPackages.full
                bottles
            # FIX: This should be under home.nix
              pkgs.unstable.eww
              # Hier werde ich wohl lieber ganz selber ein eigenes
              # UI Programm in Flutter schreiben.
          ];
          programs = {
            # https://github.com/Mic92/nix-ld
            nix-ld.enable = true;

            # Some programs need SUID wrappers, can be configured further or are
            # started in user sessions.
            mtr.enable = true;
            gnupg.agent = {
              enable = true;
              enableSSHSupport = true;
            };

	    # Password stuff
            seahorse.enable = true;
            ssh.enableAskPassword = true;

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
                  "flutter"
                  "lein"
                  "gradle"
                  "poetry"
                  "fd"
                  "vi-mode"
                  "dirhistory"
                  "gpg-agent"
                  "keychain"
                  "zsh-interactive-cd"
                ];
                theme = "robbyrussell";
              };
              autosuggestions.enable = true;
              promptInit = "autoload -U promptinit && promptinit && prompt fade && setopt prompt_sp";
              shellAliases = {
                l = "exa";
                ll = "exa -l";
                lt = "exa -lT";
                webcam = "mpv av://v4l2:/dev/video0 --profile=low-latency --untimed";
              };
            };

            # Android
            adb.enable = true;

            # Other
            file-roller.enable = true;
            dconf.enable = true;

            # development
            java.enable = true;

            # Gaming
            steam = {
              enable = true;
              remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
              dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
            };
          };

          # Shell configuration
          environment.variables = {
            "CHROME_EXECUTABLE" = "${pkgs.google-chrome}/bin/google-chrome-stable";
            "ACCESSIBILITY_ENABLED" = "1";
            "PAGER" = "nvimpager";
            # FZF - Ripgrep integration
            "INITIAL_QUERY" = "";
            "RG_PREFIX"="rg --column --line-number --no-heading --color=always --smart-case ";
          };
          # environment.sessionVariables = {
          #   PATH = [ 
          #     "/home/luca/Android/Sdk/cmdline-tools/latest/bin/"
          #   ];
          # };
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
            virtualbox.host = {
              enable = true;
              package = pkgs.virtualboxWithExtpack;
              enableExtensionPack = true;
            };
            docker.enable = true;
          };
          users.extraGroups.vboxusers.members = [ "luca" ];
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
                  gnupg.enable = true;
                };
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
