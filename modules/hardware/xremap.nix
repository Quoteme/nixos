{ pkgs, config, attrs, ... }: {
  imports = [ attrs.xremap-flake.nixosModules.default ];
  services.xremap = {
    serviceMode = "user";
    userName = "luca";
  };

  services.xremap.config.modmap = [{
    name = "Better Vim bindings";
    remap = {
      # "CAPSLOCK" = {
      #   held = "KEY_FINANCE";
      #   alone = "ESC";
      #   alone_timeout_millis = 500;
      # };
      "CAPSLOCK" = "ESC";
      "FN" = {
        held = "FN";
        alone = "KEY_FINANCE";
        alone_timeout_millis = 500;
      };
      "LEFTALT" = {
        held = "LEFTALT";
        alone = "KEY_CONNECT";
        alone_timeout_millis = 500;
      };
      "LEFTCTRL" = {
        held = "LEFTCTRL";
        alone = "KEY_SPORT";
        alone_timeout_millis = 500;
      };
      "RIGHTCTRL" = {
        held = "RIGHTCTRL";
        alone = "KEY_SHOP";
        alone_timeout_millis = 500;
      };
      "RIGHTALT" = {
        held = "RIGHTALT";
        alone = "KEY_FINANCE";
        alone_timeout_millis = 500;
      };
    };
  }];

  services.xremap.config.keymap = [{
    name = "Better Vim bindings";
    remap = {
      # slash key "/"
      "KEY_CONNECT" = "SHIFT-7";
      # backslash key "\"
      "KEY_FINANCE" = "RIGHTALT-MINUS";
      # Open square brace key "["
      "KEY_SPORT" = "RIGHTALT-8";
      # Close square brace key "]"
      "KEY_SHOP" = "RIGHTALT-9";
    };
  }];
}
