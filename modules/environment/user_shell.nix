{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;

  cfg = config.modules.environment.user_shell;
in
{
  options.modules.environment.user_shell =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable my custom ZSH-/Bash-shell";
    };

  config = mkIf cfg.enable {
    programs.bash.shellInit = "set -o vi";
    programs.zsh = {
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
          # "lein"
          "gradle"
          # "poetry"
          "fd"
          "vi-mode"
          "dirhistory"
          # "gpg-agent"
          # "keychain"
          "zsh-interactive-cd"
          "flutter"
        ];
        theme = "robbyrussell";
      };
      autosuggestions.enable = true;
      promptInit = "autoload -U promptinit && promptinit && prompt fade && setopt prompt_sp";
      # also add `~/.zfunc` to $fpath
      interactiveShellInit = ''
        fpath+=~/.zfunc
      '';
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
  };
}
