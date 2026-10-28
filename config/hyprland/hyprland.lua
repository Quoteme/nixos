-- vim: ft=lua
-- Main Hyprland config (Lua, Hyprland >= 0.56).
-- Loaded from the NixOS-generated /etc/xdg/hypr/hyprland.lua (modules/desktop/hyprland.nix),
-- which also loads the plugins and starts the Nix-provided autostart programs.
-- Editing this file triggers an automatic reload.
-- API stubs for LuaLS: /run/current-system/sw/share/hypr/stubs/hl.meta.lua
-- See https://wiki.hypr.land/Configuring/Start/


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "eDP-1",    mode = "preferred", position = "auto",    scale = "1" })
hl.monitor({ output = "HDMI-A-1", mode = "highres",   position = "auto-up", scale = "1" })
hl.monitor({ output = "DP-1",     mode = "highres",   position = "auto-up", scale = "1" })
hl.monitor({ output = "DP-2",     mode = "highres",   position = "auto-up", scale = "1" })

hl.config({
    xwayland = {
        force_zero_scaling   = true,
        use_nearest_neighbor = false,
    },
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal         = "ghostty --working-directory=$HOME"
local fileManager      = "org.kde.dolphin"
local ipc              = "noctalia-shell ipc call"
local menu             = ipc .. " launcher toggle"
-- local clipboardHistory = "rofi -modi clipboard:clipvault_rofi.sh -show clipboard -show-icons"
local clipboardHistory = ipc .. " plugin:clipper toggle"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("wvkbd-mobintl -L 400 --hidden")
    hl.exec_cmd("hypridle")
    -- hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly

-- hl.config({ ecosystem = { enforce_permissions = true } })
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 0,
        gaps_out = 0,

        border_size = 1,

        col = {
            active_border   = "rgba(ff0000ff)",
            inactive_border = "rgba(595959aa)",
        },

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",

        resize_on_border        = true,
        extend_border_grab_area = 10,
    },

    decoration = {
        rounding       = 0,
        rounding_power = 0,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
            range        = 20,
            render_power = 10,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = false,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- "Smart gaps" / "No gaps when only"
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})
-- layouts
-- hl.workspace_rule({ workspace = "3", layout = "scrolling" })

hl.config({
    -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
    dwindle = {
        -- pseudotile = true,
        preserve_split     = true,
        precise_mouse_move = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true,
        -- enable_swallow = true,
        -- swallow_regex  = "*",
        focus_on_activate       = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "de",
        kb_variant = "nodeadkeys",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Per-device config, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({ name = "elan9008:00-04f3:2c82-stylus", output = "eDP-1" })
hl.device({ name = "wacom-one-by-wacom-s-pen", output = "eDP-1", left_handed = true })
-- corne keyboard
hl.device({ name = "corne-keyboard", kb_layout = "en" })
hl.device({ name = "luca-corne",     kb_layout = "en" })


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Shorthands
local function bind(keys, dispatcher, description, opts)
    opts = opts or {}
    opts.description = description
    return hl.bind(keys, dispatcher, opts)
end
local exec = hl.dsp.exec_cmd

-- Plugin dispatchers only exist once the plugin is loaded (after the first config pass),
-- so they are looked up lazily when the bind fires.
local function gloview(fn, ...)
    local args = { ... }
    return function()
        local p = hl.plugin.gloview
        if p then return p[fn](table.unpack(args)) end
    end
end

-- Cheatsheet annotations (noctalia keybind-cheatsheet plugin):
--   category header = comment line "-- <N>. NAME", label = description = "..." on the bind's line

-- 1. APPS
bind(mainMod .. " + Return",    exec(terminal),                    "Terminal")
bind(mainMod .. " + X",         exec(terminal),                    "Terminal")
bind(mainMod .. " + SHIFT + E", exec(fileManager),                 "File manager")
bind(mainMod .. " + D",         exec(menu),                        "App launcher")
bind(mainMod .. " + W",         exec(ipc .. " launcher windows"),  "Window switcher")
bind(mainMod .. " + period",    exec(ipc .. " launcher emoji"),    "Emoji picker")
bind(mainMod .. " + U",         exec(ipc .. " plugin:unicode toggle"), "Unicode picker")
bind(mainMod .. " + Escape",    exec(ipc .. " lockScreen lock"),   "Lock screen")

-- 2. PANELS
bind(mainMod .. " + C",         exec(ipc .. " controlCenter toggle"),         "Control center")
bind(mainMod .. " + N",         exec(ipc .. " network togglePanel"),          "Network panel")
bind(mainMod .. " + B",         exec(ipc .. " bluetooth togglePanel"),        "Bluetooth panel")
bind(mainMod .. " + SHIFT + B", exec(ipc .. " battery togglePanel"),          "Battery panel")
bind(mainMod .. " + comma",     exec(ipc .. " settings toggle"),              "Noctalia settings")
bind(mainMod .. " + O",         exec(ipc .. " systemMonitor toggle"),         "System monitor")
bind(mainMod .. " + minus",     exec(ipc .. " notifications toggleHistory"),  "Notification history")
bind(mainMod .. " + SHIFT + D", exec('darkmode-toggle && notify-send "toggling dark/light mode"'), "Toggle dark/light mode (apps)")
bind("XF86Launch3",             exec(ipc .. " darkMode toggle"),              "Toggle dark/light mode (shell)")

-- 3. WINDOWS
bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close(), "Close window")
bind(mainMod .. " + F",         hl.dsp.window.float(), "Toggle floating")
-- pin only works on floating windows, hence float first
bind(mainMod .. " + P", function()
    hl.dispatch(hl.dsp.window.float({ action = "on" }))
    hl.dispatch(hl.dsp.window.pin())
end, "Pin window (sticky on all workspaces)")
-- maximized mode keeps the bar; press again to restore
bind(mainMod .. " + Z",         hl.dsp.window.fullscreen({ mode = "maximized" }), "Toggle maximize")
bind(mainMod .. " + R",         hl.dsp.layout("togglesplit"),                   "Toggle split direction")
bind(mainMod .. " + SHIFT + R", exec("/etc/nixos/config/hyprland/rebalance.sh"), "Rebalance window sizes")

-- dwindle
-- bind(mainMod .. " + P",   hl.dsp.window.pseudo())
-- bind(mainMod .. " + T",   hl.dsp.group.toggle())
-- bind(mainMod .. " + Tab", hl.dsp.group.next())

-- 4. OVERVIEW
-- GloView
bind(mainMod .. " + space",        gloview("toggle"), "Toggle overview")
-- bind(mainMod .. " + SHIFT + Tab", gloview("desktop"))
-- bind(mainMod .. " + CTRL + Tab",  gloview("allworkspaces"))
bind(mainMod .. " + bracketright", gloview("next"),   "Overview: next workspace")
bind(mainMod .. " + bracketleft",  gloview("prev"),   "Overview: previous workspace")

-- 5. TOOLS
-- Easymotion (SUPER + S, "Jump to window") is disabled: the plugin only registers
-- hyprlang dispatchers, which can't be called from a Lua config.
bind(mainMod .. " + SHIFT + S",       exec("/etc/nixos/config/hyprland/screenshot.sh ask"), "Screenshot area (then edit/OCR/copy)")
bind(mainMod .. " + SHIFT + ALT + S", exec("/etc/nixos/config/hyprland/screenshot.sh ocr"), "Screenshot area to text (OCR)")
bind(mainMod .. " + V",               exec(clipboardHistory),                               "Clipboard history")

-- active while screenshot.sh asks what to do; presses a button on its notification
-- (newest one with app name "screenshot", so other notifications arriving meanwhile are ignored)
local screenshotAction = ipc .. " notifications invokeAction \"$(" .. ipc
    .. " notifications getHistory | jq -r 'map(select(.appName | ascii_downcase == \"screenshot\"))[0].id')\""
hl.define_submap("screenshot", function()
    -- 6. SCREENSHOT PROMPT (WHILE ITS NOTIFICATION IS SHOWN)
    bind("E",      exec(screenshotAction .. " edit"), "Edit in swappy")
    bind("Return", exec(screenshotAction .. " edit"), "Edit in swappy")
    bind("O",      exec(screenshotAction .. " ocr"),  "OCR text to clipboard")
    bind("C",      exec(screenshotAction .. " copy"), "Copy image to clipboard")
    bind("Escape", exec(screenshotAction .. " copy"), "Copy image to clipboard")
end)

-- 7. CHEATSHEET
-- Hold SUPER (longer than input:repeat_delay) -> keybind cheatsheet, release -> close.
-- The flag file makes release only close what the long press opened (not on short taps).
local keyhintFlag = "/run/user/1000/keyhint-open"
bind("Super_L",           exec("touch " .. keyhintFlag .. " && " .. ipc .. " plugin:keybind-cheatsheet toggle"), "Hold: show this cheatsheet", { long_press = true, non_consuming = true })
bind("SUPER + Super_L",   exec("rm " .. keyhintFlag .. " && " .. ipc .. " plugin:keybind-cheatsheet toggle"),    "Release: close cheatsheet",  { release = true, non_consuming = true })

-- 8. FOCUS, MOVE & RESIZE
bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }),  "Focus left")
bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), "Focus right")
bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }),    "Focus up")
bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }),  "Focus down")
bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left" }),  "Focus left")
bind(mainMod .. " + L",     hl.dsp.focus({ direction = "right" }), "Focus right")
bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up" }),    "Focus up")
bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down" }),  "Focus down")
bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }),  "Move window left")
bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }), "Move window right")
bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }),    "Move window up")
bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }),  "Move window down")
bind(mainMod .. " + CTRL + H",  hl.dsp.window.resize({ x = -50, y = 0,   relative = true }), "Shrink width")
bind(mainMod .. " + CTRL + L",  hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }), "Grow width")
bind(mainMod .. " + CTRL + K",  hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), "Shrink height")
bind(mainMod .. " + CTRL + J",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }), "Grow height")

-- 9. WORKSPACES
-- mainMod + [0-9]: switch workspace. While the GloView overview is open, this switches the
-- displayed workspace instead (gloview's setworkspace only handles existing workspaces).
-- mainMod + SHIFT + [0-9]: move active window to a workspace (silently)
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    bind(mainMod .. " + " .. key, function()
        local p = hl.plugin.gloview
        if not (p and p.setworkspace(i)) then
            hl.dispatch(hl.dsp.focus({ workspace = i }))
        end
    end, "Go to workspace " .. i)
    bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }), "Send window to workspace " .. i)
end

-- Special workspace (scratchpad)
bind(mainMod .. " + M",         hl.dsp.workspace.toggle_special("magic"),           "Toggle scratchpad")
bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:magic" }), "Send window to scratchpad")

-- Scroll through existing workspaces with mainMod + scroll
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")

-- 10. MOUSE
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   "Drag to move window",   { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "Drag to resize window", { mouse = true })

-- 11. HARDWARE KEYS
local lockedRepeat = function() return { locked = true, repeating = true } end
bind("XF86AudioRaiseVolume",  exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), "Volume up",       lockedRepeat())
bind("XF86AudioLowerVolume",  exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      "Volume down",     lockedRepeat())
bind("XF86AudioMute",         exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     "Mute audio",      lockedRepeat())
bind("XF86AudioMicMute",      exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   "Mute microphone", lockedRepeat())
bind("XF86MonBrightnessUp",   exec("brightnessctl set 5%+"),                          "Screen brightness up",   lockedRepeat())
bind("XF86MonBrightnessDown", exec("brightnessctl set 5%-"),                          "Screen brightness down", lockedRepeat())
bind("XF86KbdBrightnessUp",   exec("brightnessctl --device='asus::kbd_backlight' set 1+"), "Keyboard backlight up",   lockedRepeat())
bind("XF86KbdBrightnessDown", exec("brightnessctl --device='asus::kbd_backlight' set 1-"), "Keyboard backlight down", lockedRepeat())
bind("XF86Launch4",           exec(ipc .. " powerProfile cycle"),                     "Cycle power profile",    lockedRepeat())

-- Requires playerctl
bind("XF86AudioNext",  exec("playerctl next"),       "Next track",     { locked = true })
bind("XF86AudioPause", exec("playerctl play-pause"), "Play/pause",     { locked = true })
bind("XF86AudioPlay",  exec("playerctl play-pause"), "Play/pause",     { locked = true })
bind("XF86AudioPrev",  exec("playerctl previous"),   "Previous track", { locked = true })

-- Laptop suspend/resume
bind("switch:on:Lid Switch",  exec(ipc .. " lockScreen lock"),           "Lid switch on: lock screen",       { locked = true })
bind("switch:off:Lid Switch", exec(ipc .. " lockScreen lockAndSuspend"), "Lid switch off: lock and suspend", { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
hl.window_rule({
    name  = "bitwarden",
    match = { class = "^(Bitwarden)$" },

    animation        = "popin",
    float            = true,
    size             = "960 535",
    center           = true,
    fullscreen_state = "0",
    fullscreen       = false,
    maximize         = false,
})
hl.window_rule({
    name  = "blender-floating",
    match = { class = "blender", float = true },

    size = "960 535",
})
hl.window_rule({
    name  = "zotero-citing",
    match = { class = "org.zotero.Zotero", title = "(Zitations-Dialog|Zotero-Einstellungen)" },

    move           = "0 0",
    size           = "500 350",
    animation      = "popin",
    float          = true,
    center         = false,
    suppress_event = "maximize",
})
hl.window_rule({
    name  = "thunderbird-workspace",
    match = { class = "^(thunderbird)$" },

    workspace = "9",
})

-- No fade-out for slurp's selection overlay / wayfreeze, otherwise grim captures
-- the still-fading overlay (shows up as a dark border around screenshots)
hl.layer_rule({ name = "no-anim-selection", match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ name = "no-anim-wayfreeze", match = { namespace = "wayfreeze" }, no_anim = true })


-----------------
---- PLUGINS ----
-----------------

-- Plugin config keys and functions are registered when the plugin loads, which happens
-- after the first config pass (Hyprland then reloads the config), hence the guards.

if hl.plugin.hyprbars then
    hl.config({
        plugin = {
            hyprbars = {
                bar_height      = 30,
                -- cmd to run on double click of the bar
                on_double_click = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\" })'",
            },
        },
    })

    -- buttons (R -> L)
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(ff4040)",
        fg_color = "rgb(ffffff)",
        size     = 20,
        icon     = "󰖭",
        action   = "hyprctl dispatch 'hl.dsp.window.close()'",
    })
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(eeee11)",
        fg_color = "rgb(ffffff)",
        size     = 20,
        icon     = "",
        action   = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\" })'",
    })

    -- title bars only on floating windows
    hl.window_rule({
        name  = "hyprbars-floating-only",
        match = { float = false },
        ["hyprbars:no_bar"] = true,
    })
end

-- The configs for the currently disabled plugins (hyprgrass, hy3, hyprtasking, hyprexpo,
-- hyprfocus, dynamic-cursors) lived in the old extra.conf; see git history when re-enabling one.
