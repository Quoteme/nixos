{ config, pkgs, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      name ="Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Mojave-Dark";
      package = pkgs.mojave-gtk-theme;
    };
    gtk3.extraConfig = {gtk-application-prefer-dark-theme = 1;};
    gtk4.extraConfig = {gtk-application-prefer-dark-theme = 1;};
  };
  # xsession = {
  #   enable = true;
  #   windowManager = {
  #     xmonad = {
  #       enable = true;
  #       enableContribAndExtras = true;
  #       extraPackages = hpkgs: with hpkgs; [
  #         xmonad
  #         xmonad-contrib
  #         xmonad-extras
  #       ];
  #       config = ./xmonad/xmonad.hs;
  #     };
  #   };
  # };
  programs.zsh = {
    enable = true;
  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      set -o vi
    '';
  };
  programs.mpv = {
    enable = true;
    config = {
      profile     = "gpu-hq";
      ytdl-format = "bestvideo+bestaudio";
      webui-port  = "4000";
      script-opts = "ytdl_hook-ytdl_path=yt-dlp";
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      mpv-playlistmanager
      thumbnail
      simple-mpv-webui
    ];
  };
  programs.rofi = {
    enable = true;
    font = "scientifica, Gohu GohuFont, Siji 8";
    theme = "sidebar";
    extraConfig = {
      modi = "combi";
      combi-modi ="drun,window,ssh";
      show-icons = true;
    };
  };
  services.picom = {
    # disabled for now. Configure multiple monitors someday
    enable = true;
    shadow = true;
    shadowOpacity = "0.8";
    fade = false;
    fadeDelta = 5;
    fadeExclude = ["window_type *= 'menu'"];
    inactiveOpacity = "0.95";
    opacityRule = [
      "100:name *= 'Netflix'"
      "100:name *= 'Wikipedia'"
      "100:name *= 'Youtube'"
      "97:name *= 'control_center'"
    ];
  };
  xdg.configFile."onedrive/config".text = ''
    sync_dir = "~/OneDrive"
    skip_dir = "*.git|Videos"
    skip_file = "*~"
  '';
  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = rofi
    wifi_chars = ▂▄▆█
  '';
  xdg.configFile."jgmenu/prepend.csv".text = ''
    Keyboard,onboard,onboard
    Screenshot,maim -su | xclip -selection clipboard -t image/png,accessories-screenshot-symbolic
    toggle screen rot.,toggleautoscreenrotation.sh,rotation-allowed-symbolic
    ^sep()
  '';
  xdg.configFile."jgmenu/append.csv".text = ''
    ^sep()
    Exit,^checkout(exit),system-shutdown
    ^tag(exit)
    Reboot,systemctl -i reboot,system-reboot
    Log-Out,xdotool super+del,system-log-out
    Suspend,systemctl -i suspend,system-suspend
    Hibernate,systemctl hibernate,system-suspend-hibernate
    Poweroff,systemctl -i poweroff,system-shutdown
  '';
  xdg.configFile."jgmenu/jgmenurc".text = ''
    stay_alive           = 1
    tint2_look           = 0
    position_mode        = fixed
    terminal_exec        = st
    terminal_args        = -e
    menu_width           = 200
    menu_padding_top     = 10
    menu_padding_right   = 2
    menu_padding_bottom  = 5
    menu_padding_left    = 2
    menu_radius          = 0
    menu_border          = 1
    menu_halign          = left
    menu_valign          = top
    menu_margin_y a      = 20
    sub_hover_action     = 1
    item_margin_y        = 5
    item_height          = 30
    item_padding_x       = 8
    item_radius          = 0
    item_border          = 0
    sep_height           = 5
    font                 = Ubuntu 12px
    icon_size            = 24
    color_menu_bg        = #0b0f10 100
    color_norm_bg        = #0b0f10 0
    color_norm_fg        = #c5c8c9 100
    color_menu_border	   = #0b0f10 100
    color_sel_bg         = #192022 100
    color_sel_fg         = #c5c8c9 100
    color_sep_fg         = #192022 400
  '';
  xdg.configFile."touchegg/touchegg.conf".text = ''
  <touchégg>

    <settings>
      <!--
        Delay, in milliseconds, since the gesture starts before the animation is displayed.
        Default: 150ms if this property is not set.
        Example: Use the MAXIMIZE_RESTORE_WINDOW action. You will notice that no animation is
        displayed if you complete the action quick enough. This property configures that time.
      -->
      <property name="animation_delay">150</property>

      <!--
        Percentage of the gesture to be completed to apply the action. Set to 0 to execute actions unconditionally.
        Default: 20% if this property is not set.
        Example: Use the MAXIMIZE_RESTORE_WINDOW action. You will notice that, even if the
        animation is displayed, the action is not executed if you did not move your fingers far
        enough. This property configures the percentage of the gesture that must be reached to
        execute the action.
      -->
      <property name="action_execute_threshold">20</property>

      <!--
        Global animation colors can be configured to match your system colors using HEX notation:

          <color>909090</color>
          <borderColor>FFFFFF</borderColor>

        You can also use auto:

          <property name="color">auto</property>
          <property name="borderColor">auto</property>

        Notice that you can override an specific animation color.
      -->
      <property name="color">auto</property>
      <property name="borderColor">auto</property>
    </settings>

    <!--
      Configuration for every application.
    -->
    <application name="All">

      <gesture type="PINCH" fingers="3" direction="IN">
        <action type="CLOSE_WINDOW">
          <animate>true</animate>
          <color>F84A53</color>
          <borderColor>F84A53</borderColor>
        </action>
      </gesture>

      <gesture type="PINCH" fingers="3" direction="OUT">
        <action type="RUN_COMMAND">
          <repeat>false</repeat>
          <command>sleep 0.4 && xmonadctl menu</command>
          <on>begin</on>
        </action>
      </gesture>

      <!-- Window Swapping -->
      <gesture type="SWIPE" fingers="3" direction="UP">
        <action type="RUN_COMMAND">
          <repeat>false</repeat>
          <command>xmonadctl swap-up</command>
          <on>begin</on>
        </action>
      </gesture>

      <gesture type="SWIPE" fingers="3" direction="DOWN">
        <action type="RUN_COMMAND">
          <repeat>false</repeat>
          <command>xmonadctl swap-down</command>
          <on>begin</on>
        </action>
      </gesture>

      <gesture type="SWIPE" fingers="3" direction="LEFT">
        <action type="RUN_COMMAND">
          <repeat>false</repeat>
          <command>xmonadctl swap-left</command>
          <on>begin</on>
        </action>
      </gesture>

      <gesture type="SWIPE" fingers="3" direction="RIGHT">
        <action type="RUN_COMMAND">
          <repeat>false</repeat>
          <command>xmonadctl swap-right</command>
          <on>begin</on>
        </action>
      </gesture>

      <gesture type="TAP" fingers="4">
        <action type="RUN_COMMAND">
          <repeat>false</repeat>
          <command>xmonadctl rotate</command>
          <on>begin</on>
        </action>
      </gesture>

      <gesture type="SWIPE" fingers="4" direction="LEFT">
        <action type="CHANGE_DESKTOP">
          <direction>auto</direction>
          <animate>true</animate>
          <animationPosition>auto</animationPosition>
        </action>
      </gesture>

      <gesture type="SWIPE" fingers="4" direction="RIGHT">
        <action type="CHANGE_DESKTOP">
          <direction>auto</direction>
          <animate>true</animate>
          <animationPosition>auto</animationPosition>
        </action>
      </gesture>

    <gesture type="SWIPE" fingers="4" direction="DOWN">
        <action type="RUN_COMMAND">
          <repeat>false</repeat>
          <command>xmonadctl toggle-struts</command>
          <on>begin</on>
        </action>
      </gesture>

      <gesture type="TAP" fingers="2">
        <action type="MOUSE_CLICK">
          <button>3</button>
          <on>begin</on>
        </action>
      </gesture>

      <gesture type="TAP" fingers="3">
        <action type="MOUSE_CLICK">
          <button>2</button>
          <on>begin</on>
        </action>
      </gesture>

    </application>

  </touchégg>
  '';
  services.network-manager-applet.enable = true;
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
      size="32x32";
    };
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        geometry = "320x5-15+15";
        indicate_hidden = "yes";
        shrink = "no";
        transparency = 0;
        notification_height = 0;
        separator_height = 2;
        padding = 10;
        horizontal_padding = 10;
        frame_width = 1;
        frame_color = "#232323";
        separator_color = "frame";
        sort = "yes";
        idle_threshold = 120;
        font = "scientifica 8";
        line_height = 0;
        markup = "full";
        format = "<span foreground='#f3f4f5'><b>%s %p</b></span>\n%b";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = "yes";
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";
        icon_position = "left";
        max_icon_size = 32;
        sticky_history = "yes";
        history_length = 20;
        always_run_script = true;
        startup_notification = false;
        verbosity = "mesg";
        corner_radius = 0;
        force_xinerama = false;
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action";
        mouse_right_click = "close_all";
      };
      urgency_low = {
        background = "#232323";
        foreground = "#a8a8a8";
        timeout = 10;
      };
      urgency_normal = {
        background = "#232323";
        foreground = "#a8a8a8";
        timeout = 10;
      };
      urgency_critical = {
        background = "#d64e4e";
        foreground = "#f0e0e0";
        frame_color = "#d64e4e";
        timeout = 0;
        icon = "${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/status/dialog-warning.svg";
      };
    };
  };
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      pulseSupport = true;
    };
    config = ./config/polybar;
    script = "polybar top &";
  };
  home.stateVersion = "22.05";
}
