{ pkgs, config, attrs, ... }:
{
  imports = [
    attrs.xremap-flake.nixosModules.default
  ];
  services.xremap = {
    serviceMode = "user";
    userName = "luca";
  };
  services.xremap.config.modmap = [
    {
      name = "Better Vim bindings";
      remap = {
        "CAPSLOCK" = {
          held = "BACKSLASH";
          alone = "ESC";
          alone_timeout_millis = 500;
        };
        "LEFTCTRL" = {
          held = "LEFTCTRL";
          alone = "SLASH";
          alone_timeout_millis = 500;
        };
        "LEFTALT" = {
          held = "LEFTALT";
          alone = "LEFTBRACE";
          alone_timeout_millis = 1000;
        };
        "RIGHTALT" = {
          held = "RIGHTALT";
          alone = "RIGHTBRACE";
          alone_timeout_millis = 1000;
        };
      };
    }
  ];
}
