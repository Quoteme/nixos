{
  description = "Luca Happels nixos ";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-old.url = "nixpkgs/nixos-22.05";
    nur.url = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    st-nix.url = "github:Quoteme/st-nix";
    neovim-luca.url = "github:Quoteme/neovim-luca";
    emacs-overlay.url = "github:nix-community/emacs-overlay/da2f552d133497abd434006e0cae996c0a282394";
    nix-autobahn.url = "github:Lassulus/nix-autobahn";
    nix-alien.url = "github:thiagokokada/nix-alien";
    screenrotate.url = "github:Quoteme/screenrotate";
    screenrotate.inputs.nixpkgs.follows = "nixpkgs";
    rescreenapp.url = "github:Quoteme/rescreenapp";
    control_center.url = "github:Quoteme/control_center";
    xmonad-luca.url = "github:Quoteme/xmonad-luca";
    godot.url = "github:Quoteme/nixos-godot-bin";
    hmenke-nixos-modules.url = "github:hmenke/nixos-modules";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
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
      overlay-old = final: prev: {
        nixpkgs-old = import attrs.nixpkgs-old {
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
          overlay-old
          attrs.emacs-overlay.overlay
          attrs.nix-vscode-extensions.overlays.default
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
          ({ config, nixpkgs, ... }@inputs:
            let
              myGHCPackages = (hpkgs: with hpkgs; [
                xmonad
                xmonad-contrib
                xmonad-extras
                text-format-simple
              ]);
              myCLion = pkgs.symlinkJoin {
                name = "myCLion";
                paths = with pkgs; [
                  jetbrains.clion
                  gnumake
                  check
                  pkg-config
                  myPython
                ];

                nativeBuildInputs = [ pkgs.makeWrapper ];
                postBuild = ''
                  wrapProgram $out/bin/clion \
                    --prefix "$out/bin":PATH
                '';
              };
              myAndroidStudio = pkgs.symlinkJoin {
                name = "myAndroidStudio";
                paths = with pkgs; [
                  pkgs.unstable.android-studio
                  # pkgs.unstable.flutter
                  # dart
                  gnumake
                  check
                  pkg-config
                  glibc
                  android-tools
                  jdk
                  git
                ];
                nativeBuildInputs = [ pkgs.makeWrapper ];
                postBuild = ''
                  wrapProgram $out/bin/android-studio \
                    --prefix PUB_CACHE=/home/luca/.pub-cache \
                    --prefix ANDROID_SDK_ROOT=/home/luca/.local/lib/arch-id/android-sdk/ \
                    --prefix ANDROID_HOME=/home/luca/.local/lib/arch-id/android-sdk/ \
                    --prefix ANDROID_JAVA_HOME=${pkgs.jdk.home}
                '';
              };
              myIDEA = pkgs.symlinkJoin {
                name = "myIDEA";
                paths = with pkgs; [
                  jetbrains.idea-ultimate
                  # instead use:
                  # https://discourse.nixos.org/t/flutter-run-d-linux-build-process-failed/16552/3
                  # flutter
                  # dart
                ];
              };
              myPython = pkgs.python310.withPackages (ps: with ps; [
                debugpy
                pytest
                ipython
                jupyterlab
                jupyter-lsp
                pandas
                sympy
                numpy
                scipy
                matplotlib
                plotly
                pipx
              ]);
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
                nixPath = [
                  "nixpkgs=${nixpkgs}"
                  "unstable=${nixpkgs-unstable}"
                  "stable=${attrs.nixpkgs-old}"
                  "nur=${attrs.nur}"
                  "nix-vscode=${attrs.nix-vscode-extensions}"
                ];
                registry = {
                  nixpkgs.flake = nixpkgs;
                  unstable.flake = nixpkgs-unstable;
                  stable.flake = attrs.nixpkgs-old;
                  nur.flake = attrs.nur;
                };
              };

              boot = {
                kernelPackages = pkgs.nixpkgs-old.linuxPackages_latest;
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

              # Enable the X11 windowing system.
              # TODO clean this up
              services = {
                xserver = {
                  enable = true;
                  # keyboard settings
                  layout = "de";
                  extraLayouts.hyper = {
                    # TODO this does not work :(
                    description = "Use escape key as Hyper key";
                    languages = [ ];
                    symbolsFile = pkgs.writeText "hyper" ''
                      partial modifier_keys
                      xkb_symbols "hyper" {
                      key <ESC> { [Hyper_R] };
                      modifier_map Mod3 { <HYPR>, Hyper_R };
                      }
                    '';
                  };
                  xkbVariant = "nodeadkeys";
                  xkbOptions = "caps:escape,shift:both_capslock,mod_led,compose:rctrl-altgr";
                  updateDbusEnvironment = true;
                  # Display Manager
                  displayManager = {
                    gdm.enable = true;
                    # lightdm = {
                    #   enable = true;
                    #   greeters.gtk = {
                    #     theme.package = pkgs.mojave-gtk-theme;
                    #     theme.name = "Mojave-Dark";
                    #     iconTheme.name ="Papirus";
                    #     iconTheme.package = pkgs.papirus-icon-theme;
                    #     indicators = [ "~host" "~spacer" "~clock" "~spacer" "~session" "~language" "~a11y" "~power" ];
                    #     extraConfig = "keyboard=onboard";
                    #   };
                    # };
                    # defaultSession = "none+xmonad-luca";
                  };
                  # Desktop Manager
                  # desktopManager.phosh = {
                  #   enable = true;
                  #   group = "users";
                  #   user = "luca";
                  # };
                  desktopManager.gnome.enable = true;
                  # Window managers / Desktop managers
                  windowManager = {
                    session = [
                      {
                        name = "xmonad-luca";
                        start = ''
                          ${inputs.xmonad-luca.packages.x86_64-linux.xmonad-luca-alldeps}/bin/xmonad-luca
                        '';
                      }
                    ];
                    bspwm = {
                      enable = true;
                      configFile = ./config/bspwmrc;
                      sxhkd.configFile = ./config/sxhkdrc;
                    };
                  };
                };
                logind.extraConfig = ''
                  # don’t shutdown when power button is short-pressed
                  HandlePowerKey=ignore
                '';
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
                gnome.gnome-settings-daemon.enable = true;
                gnome.gnome-online-accounts.enable = true;
                gnome.gnome-browser-connector.enable = true;
                gnome.evolution-data-server.enable = true;
                blueman.enable = true;
                udisks2.enable = true;
                devmon.enable = true;
                gvfs.enable = true;
                tumbler.enable = true;
                # redshift.enable = true;
                # Lock screen
                # physlock = {
                #   enable = true;
                #   lockMessage = "Lulca\'s Laptop";
                # };
              };
              services.clipcat.enable = true;
              # Enable OneDrive
              services.onedrive = {
                enable = true;
                package = pkgs.unstable.onedrive;
              };
              # Enable flatpak
              services.flatpak.enable = true;
              xdg.portal.enable = true;
              # make qt apps look like gtk
              # https://nixos.org/manual/nixos/stable/index.html#sec-x11-gtk-and-qt-themes
              qt5.enable = true;
              qt5.platformTheme = "gtk2";
              qt5.style = "gtk2";
              # Enable sound.
              # sound = {
              #   enable = true;
              #   mediaKeys.enable = true;
              # };
              # Use Pipewire
              # rtkit is optional but recommended
              security.rtkit.enable = true;
              services.pipewire = {
                enable = true;
                alsa.enable = true;
                alsa.support32Bit = true;
                pulse.enable = true;
                jack.enable = true;
                config.pipewire-pulse = {
                  "pulse.cmd" = [
                    {
                      "cmd" = "load-module";
                      "args" = "module-always-sink";
                      "flags" = [ ];
                    }
                    {
                      "cmd" = "load-module";
                      "args" = "module-switch-on-connect";
                    }
                  ];
                };
              };
              hardware = {
                pulseaudio.enable = false;
                bluetooth = {
                  enable = true;
                  powerOnBoot = false;
                  settings = {
                    General = {
                      Enable = "Source,Sink,Media,Socket";
                    };
                  };
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
                  pkgs.unstable.google-chrome
                  tts
                  # microsoft-edge
                  # discord
                  # whatsapp-for-linux
                  unstable.ferdium
                  transmission-gtk
                  thunderbird
                  # Privacy
                  veracrypt
                  lesspass-cli
                  # Video-Editing
                  obs-studio
                  kdenlive
                  # # Drawing
                  xournalpp
                  pkgs.unstable.rnote
                  inkscape
                  mypaint
                  gimp
                  aseprite
                  (pkgs.blender.override {
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
                  (retroarch.override {
                    cores = with libretro; [
                      mupen64plus
                      libretro.pcsx2
                    ];
                  })
                  # Productivity
                  libreoffice
                  # Programming
                  inputs.neovim-luca.defaultPackage.x86_64-linux
                  unstable.neovim
                  luajit
                  lazygit
                  emacs-gtk
                  # pkgs.unstable.vscode-fhs
                  (pkgs.unstable.vscode-with-extensions.override {
                    vscodeExtensions = with pkgs.vscode-marketplace; [
                      vscodevim.vim
                      # haskell
                      haskell.haskell
                      phoityne.phoityne-vscode # Haskell GHCi Debug Adapter
                      # nix
                      bbenoist.nix
                      # python
                      ms-python.python
                      ms-toolsai.jupyter
                      # lean
                      leanprover.lean4
                      jroesch.lean
                      hoskinson-ml.lean-chat-vscode
                      # web
                      ecmel.vscode-html-css
                      sissel.shopify-liquid
                      # bash
                      rogalmic.bash-debug
                      mads-hartmann.bash-ide-vscode
                      # flutter/dart
                      dart-code.dart-code
                      dart-code.flutter
                      # c/c++
                      ms-vscode.cpptools
                      ms-vscode.cpptools-themes
                      twxs.cmake
                      ms-vscode.cmake-tools
                      ms-vscode.cpptools-extension-pack
                      # Remove
                      ms-vscode-remote.remote-containers
                      ms-vscode-remote.remote-ssh-edit
                      ms-vscode.remote-explorer
                      ms-vscode.remote-server
                      ms-vscode.remote-repositories
                      ms-azuretools.vscode-docker
                      ms-azuretools.vscode-docker
                      ms-vscode-remote.remote-ssh
                      # Copilot
                      github.copilot-labs
                      pkgs.unstable.vscode-extensions.github.copilot
                      #
                      visualstudioexptteam.vscodeintellicode
                      visualstudioexptteam.vscodeintellicode-completions
                      visualstudioexptteam.vscodeintellicode-insiders
                    ];
                  })
                  hlint
                  devdocs-desktop
                  # devdocs-desktop
                  # math
                  sage
                  julia-bin
                  unstable.rstudio
                  # python
                  jetbrains.pycharm-professional
                  # poetry
                  myPython
                  # Latex
                  pandoc
                  poppler_utils
                  texlive.combined.scheme-full
                  tex-match
                  # Haskell
                  (haskellPackages.ghcWithPackages myGHCPackages)
                  # Rust
                  cargo
                  rustc
                  # Lean
                  elan
                  mathlibtools
                  # Java
                  jdk
                  gradle
                  myIDEA
                  # C
                  myCLion
                  valgrind
                  gcc
                  check
                  lldb
                  gdb
                  gdbgui
                  conan
                  # C#
                  mono
                  dotnet-sdk
                  dotnetCorePackages.aspnetcore_7_0
                  dotnetCorePackages.sdk_7_0
                  dotnetCorePackages.runtime_7_0
                  unstable.jetbrains.rider
                  # Spelling
                  hunspell
                  hunspellDicts.de_DE
                  hunspellDicts.en_US
                  # Android
                  libmtp
                  usbutils
                  scrcpy
                  nodePackages.cordova
                  android-tools
                  myAndroidStudio
                  (writeScriptBin "shareAndroidScreen" ''
                    #!/usr/bin/env bash
                    adb exec-out screenrecord --output-format=h264 - | ${pkgs.ffmpeg-full}/bin/ffplay -framerate 60 -probesize 32 -sync video  -
                  '')
                  # Flutter
                  clang
                  cmake
                  ninja
                  gtk3
                  # flutter
                  # dart
                  # MongoDB / Docker
                  docker-compose
                  mongodb-compass
                  # game-dev
                  inputs.godot.packages.x86_64-linux.godotMono
                  # pkgs.unstable.godot
                  pkgs.unstable.unityhub
                  # UNI HHU ZEUG
                  # konferenzen
                  zoom-us
                  # teams
                  # slack
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
                (pkgs.unstable.nerdfonts.override { fonts = [ "FiraCode" ]; })

                noto-fonts
                noto-fonts-cjk
                noto-fonts-emoji
                liberation_ttf
              ];
              fonts.fontconfig.defaultFonts.emoji = [ "openmoji-color" ];
              # List packages installed in system profile. To search, run:
              # $ nix search nixpkgs wget
              # TODO: move this into another file
              environment.systemPackages = with pkgs; [
                inputs.xmonad-luca.packages.x86_64-linux.xmonad-luca-alldeps
                pkgs.unstable.distrobox
                gnome.gnome-tweaks
                gnomeExtensions.pop-shell
                gnomeExtensions.gsconnect
                unstable.gnomeExtensions.one-drive-resurrect
                # themes
                # Icons
                gnome.adwaita-icon-theme
                papirus-icon-theme
                whitesur-icon-theme
                # GTK
                mojave-gtk-theme
                whitesur-gtk-theme
                adapta-gtk-theme
                numix-gtk-theme
                orchis-theme
                # Cursor
                numix-cursor-theme
                # Small Utilities
                # nix
                nix-du
                nix-tree
                # nix-ld stuff
                inputs.nix-autobahn.defaultPackage.x86_64-linux
                inputs.nix-alien.defaultPackage.x86_64-linux
                nix-index
                fzf
                playerctl
                pcmanfm
                qdirstat
                lm_sensors
                appimage-run
                trashy
                cobang
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
                jq
                tldr
                flameshot
                xclip
                xcolor
                peek
                killall
                xorg.xkill
                wget
                meld
                git
                gh
                unstable.gitkraken
                exa
                ripgrep
                pdfgrep
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
                alacritty
                # Window Manager
                rofi
                rofimoji
                networkmanager_dmenu
                networkmanagerapplet
                openvpn
                networkmanager-openvpn
                # File manager
                gparted
                onboard
                # TODO: Add swypeGuess
                # https://git.sr.ht/~earboxer/swipeGuess
                (pkgs.svkbd.override {
                  layout = "de";
                })
                jgmenu
                pamixer
                nitrogen
                xdotool
                neofetch
                onefetch
                libnotify
                inputs.screenrotate.defaultPackage.x86_64-linux
                # inputs.rescreenapp.defaultPackage.x86_64-linux
                # inputs.control_center.defaultPackage.x86_64-linux
                batsignal
                polkit_gnome
                lightlocker
                xidlehook
                # Storage
                rclone
                # emulation
                virt-manager
                virglrenderer
                # Wine
                wineWowPackages.full
                pkgs.unstable.bottles
                # Hier werde ich wohl lieber ganz selber ein eigenes
                # stuff that is needed pretty much everywhere
                myPython
                (haskellPackages.ghcWithPackages myGHCPackages)
                unstable.haskell-language-server
                unstable.ghc
                unstable.haskellPackages.haskell-dap
                unstable.haskellPackages.ghci-dap
                unstable.haskellPackages.haskell-debug-adapter
                unstable.cabal-install
                # unstable.stack
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

                kdeconnect.enable = true;

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
                      "keychain"
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
              programs.sway = {
                enable = true;
                wrapperFeatures.base = true;
                wrapperFeatures.gtk = true;
                extraPackages = with pkgs.unstable; [
                  swayidle
                  swaynag-battery
                  swayest-workstyle
                  swaynotificationcenter
                  pkgs.unstable.swaycons
                  swaysettings
                  pkgs.unstable.sov
                  waybar
                  nwg-launchers
                  nwg-wrapper
                  nwg-panel
                  nwg-drawer
                  nwg-menu
                ];
                extraOptions = [
                  "--unsupported-gpu"
                ];
              };

              # Gaming
              programs.gamemode.enable = true;
              programs.steam = {
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
                NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (config.systemd.packages ++ config.environment.systemPackages);
                NIX_LD = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
              };
              environment.sessionVariables = {
                XDG_CACHE_HOME = "\${HOME}/.cache";
                XDG_CONFIG_HOME = "\${HOME}/.config";
                XDG_LIB_HOME = "\${HOME}/.local/lib";
                XDG_BIN_HOME = "\${HOME}/.local/bin";
                XDG_DATA_HOME = "\${HOME}/.local/share";

                # XMONAD_DATA_DIR = "/etc/nixos/xmonad";
                # XMONAD_CONFIG_DIR = "/etc/nixos/xmonad";
                # XMONAD_CACHE_DIR = "/etc/nixos/xmonad/.cache";
                MOZ_USE_XINPUT2 = "1";

                FLUTTER_SDK = "\${XDG_LIB_HOME}/arch-id/flutter";

                ANDROID_SDK_ROOT = "\${XDG_LIB_HOME}arch-id/android-sdk/";
                PATH = [
                  "\${XDG_BIN_HOME}"
                  "\${FLUTTER_SDK}/bin"
                  "\${ANDROID_SDK_ROOT}/platform-tools"
                  "\${HOME}/.config/emacs/bin"
                  "\${HOME}/.elan/bin"
                  "\${HOME}/.local/share/npm/bin"
                ];
              };
              environment.gnome.excludePackages = (with pkgs.gnome; [
                gnome-terminal
                geary
                epiphany
              ]);
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
                waydroid.enable = true;
                lxd.enable = true;
              };
              users.extraGroups.vboxusers.members = [ "luca" ];
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
                    luca = {
                      fprintAuth = true;
                      sshAgentAuth = true;
                      gnupg.enable = true;
                      enableGnomeKeyring = true;
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
