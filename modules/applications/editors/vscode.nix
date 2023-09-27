{ config
, options
, lib
, pkgs
, ...
}@inputs:
let
  inherit (builtins) pathExists readFile;
  inherit (lib.modules) mkIf;
  system = "x86_64-linux";
  cfg = config.modules.applications.editors.vscode;
in
{
  options.modules.applications.editors.vscode =
    let
      inherit (lib.options) mkEnableOption mkOption;
      inherit (lib.types) nullOr path;
    in
    {
      enable = mkEnableOption "Enable VSCode";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (unstable.vscode-with-extensions.override {
        vscodeExtensions = with pkgs.vscode-marketplace; [
          # Language packs
          ms-ceintl.vscode-language-pack-de
          vscodevim.vim
          christian-kohler.path-intellisense
          streetsidesoftware.code-spell-checker
          # haskell
          haskell.haskell
          justusadam.language-haskell
          visortelle.haskell-spotlight
          ucl.haskelly
          phoityne.phoityne-vscode # Haskell GHCi Debug Adapter
          # PHP
          xdebug.php-debug
          devsense.phptools-vscode
          bmewburn.vscode-intelephense-client
          zobo.php-intellisense
          # nix
          bbenoist.nix
          jnoortheen.nix-ide
          mkhl.direnv
          arrterian.nix-env-selector
          # python
          ms-python.python
          # vscode-extensions.ms-python.python
          ms-python.vscode-pylance
          ms-python.pylint
          ms-python.flake8
          matangover.mypy
          charliermarsh.ruff
          ms-python.mypy-type-checker
          ms-toolsai.jupyter
          ms-toolsai.jupyter-renderers
          ms-toolsai.jupyter-keymap
          ms-toolsai.vscode-jupyter-cell-tags
          ms-toolsai.vscode-jupyter-slideshow
          kevinrose.vsc-python-indent
          dongli.python-preview
          tushortz.python-extended-snippets
          littlefoxteam.vscode-python-test-adapter
          donjayamanne.python-environment-manager
          cameron.vscode-pytest
          ms-python.black-formatter
          mgesbert.python-path
          ## Mako Python-Templating
          chaojie.better-mako
          tommorris.mako
          ## Flask
          wholroyd.jinja
          # NGINX
          william-voyek.vscode-nginx
          ahmadalli.vscode-nginx-conf
          # markdown 
          yzhang.markdown-all-in-one
          koehlma.markdown-math
          davidanson.vscode-markdownlint
          bierner.markdown-checkbox
          shd101wyy.markdown-preview-enhanced
          ## Quarto
          quarto.quarto
          # org-mode
          tootone.org-mode
          # latex
          mathematic.vscode-latex
          james-yu.latex-workshop
          # lean
          leanprover.lean4
          jroesch.lean
          hoskinson-ml.lean-chat-vscode
          # web/javascript/typescript/react/svelte
          antfu.vite
          dbaeumer.vscode-eslint
          dbaeumer.jshint
          ecmel.vscode-html-css
          abusaidm.html-snippets
          formulahendry.auto-rename-tag
          mgmcdermott.vscode-language-babel
          ms-vscode.vscode-typescript-next
          ms-vscode.js-debug-nightly
          ms-vscode.js-debug-companion
          msjsdiag.debugger-for-chrome-nightly
          sburg.vscode-javascript-booster
          dsznajder.es7-react-js-snippets
          msjsdiag.vscode-react-native
          svelte.svelte-vscode
          ardenivanov.svelte-intellisense
          fivethree.vscode-svelte-snippets
          pivaszbs.svelte-autoimport
          bradlc.vscode-tailwindcss
          sissel.shopify-liquid
          syler.sass-indented
          firefox-devtools.vscode-firefox-debug
          # R
          reditorsupport.r
          rdebugger.r-debugger
          mikhail-arkhipov.r
          # bash
          rogalmic.bash-debug
          mads-hartmann.bash-ide-vscode
          # flutter/dart
          dart-code.dart-code
          dart-code.flutter
          alexisvt.flutter-snippets
          marcelovelasquez.flutter-tree
          localizely.flutter-intl
          aksharpatel47.vscode-flutter-helper
          nash.awesome-flutter-snippets
          circlecodesolution.ccs-flutter-color
          # Java
          redhat.java
          vscjava.vscode-java-debug
          vscjava.vscode-java-test
          vscjava.vscode-java-dependency
          vscjava.vscode-maven
          vscjava.vscode-gradle
          naco-siren.gradle-language
          vscjava.vscode-lombok
          ## Spring
          vscjava.vscode-spring-initializr
          vmware.vscode-spring-boot
          vscjava.vscode-spring-boot-dashboard
          # Kotlin
          mathiasfrohlich.kotlin
          fwcd.kotlin
          esafirm.kotlin-formatter
          # c/c++
          ms-vscode.cpptools
          ms-vscode.cpptools-themes
          twxs.cmake
          ms-vscode.cmake-tools
          ms-vscode.cpptools-extension-pack
          ms-vscode.makefile-tools
          vadimcn.vscode-lldb
          jeff-hykin.better-cpp-syntax
          # SQL
          ms-ossdata.vscode-postgresql
          mongodb.mongodb-vscode
          # Rust
          rust-lang.rust-analyzer
          swellaby.vscode-rust-test-adapter
          # Remote
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh-edit
          ms-vscode.remote-explorer
          ms-vscode.remote-server
          ms-vscode.remote-repositories
          ms-azuretools.vscode-docker
          ms-azuretools.vscode-docker
          ms-vscode-remote.remote-ssh
          # .env
          irongeek.vscode-env
          ctf0.env-symbol-provider
          # Copilot / Github
          github.copilot-labs
          github.copilot
          github.remotehub
          github.copilot-chat
          github.vscode-pull-request-github
          eamodio.gitlens
          donjayamanne.githistory
          # github.heygithub
          # github.vscode-codeql
          # testing
          hbenl.vscode-test-explorer
          ms-vscode.test-adapter-converter
          # German/English
          adamvoss.vscode-languagetool
          adamvoss.vscode-languagetool-de
          #
          usernamehw.errorlens
          ms-vscode.remote-repositories
          ms-dotnettools.csharp
          # ms-dotnettools.vscode-dotnet-runtime
          ms-dotnettools.vscode-dotnet-pack
          visualstudioexptteam.intellicode-api-usage-examples
          visualstudioexptteam.vscodeintellicode
          visualstudioexptteam.vscodeintellicode-completions
          # visualstudioexptteam.vscodeintellicode-insiders
          jgclark.vscode-todo-highlight
          esbenp.prettier-vscode
          kisstkondoros.vscode-gutter-preview
          # code visualization
          tintinweb.graphviz-interactive-preview
          ## Rainbow 
          mechatroner.rainbow-csv
          oderwat.indent-rainbow
          # Icons / Themes
          pkief.material-icon-theme
          github.github-vscode-theme
        ];
      })
    ];
  };
}
