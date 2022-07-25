--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import XMonad
import XMonad.Util.SpawnOnce
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Hooks.DynamicLog (xmobarAction)
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.Place (placeHook, withGaps, smart)
import XMonad.Hooks.SetWMName (setWMName)
import XMonad.Hooks.ServerMode (serverModeEventHookF)
-- import XMonad.Hooks.Rescreen
import XMonad.Actions.Navigation2D
import XMonad.Actions.UpdateFocus ( adjustEventInput, focusOnMouseMove )
import XMonad.Actions.WindowMenu (windowMenu)
import XMonad.Layout.Renamed
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.BorderResize (borderResize)
import XMonad.Layout.DecorationMadness ( mirrorTallSimpleDecoResizable, shrinkText )
import XMonad.Layout.Spiral (spiral)
import XMonad.Layout.LayoutHints
import XMonad.Layout.WindowSwitcherDecoration
import Data.Maybe (isJust, fromJust)
import Data.List (elemIndex)
import System.Exit
import System.IO (hPutStrLn)
import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import XMonad.Layout.DraggingVisualizer
import XMonad.Layout.ImageButtonDecoration

-- Options
myTerminal                  = "st"
myFocusFollowsMouse         = True
myClickJustFocuses          = True -- clicking to focus passes click to window?
myBorderWidth               = 3
myModMask                   = mod4Mask
myWorkspaces                = ["1","2","3","4","5","6","7","8","9"]
myNormalBorderColor         = "#161616"
myFocusedBorderColor        = "#888888"

myKeys config = mkKeymap config $
  -- Code | Key
  -- M    | super key
  -- C    | control
  -- S    | shift
  -- M1   | alt
  -- M2   | num lock
  -- M3   | 
  -- M4   | super
  [ ("M-<Return>"              , spawn $ terminal config)
  , ("M-d"                     , spawn "rofi -show combi -show-icons")
  , ("M-e"                     , spawn "rofimoji")
  , ("M-S-w"                   , spawn "networkmanager_dmenu")
  , ("M-S-q"                   , kill)
  , ("M-<Space>"               , sendMessage NextLayout)
  , ("M-S-<Space>"             , setLayout $ layoutHook config)
  -- Rotational Focus Movement
  , ("M-<Tab>"                 , windows W.focusDown)
  , ("M-S-<Tab>"               , windows W.focusUp)
  , ("M-C-<Tab>"               , windows W.swapDown)
  , ("M-C-S-<Tab>"             , windows W.swapUp)
  -- Directional Focus Movement
  , ("M-h"                     , windowGo L False)
  , ("M-j"                     , windowGo D False)
  , ("M-k"                     , windowGo U False)
  , ("M-l"                     , windowGo R False)
  , ("M-<Left>"                , windowGo L False)
  , ("M-<Down>"                , windowGo D False)
  , ("M-<Up>"                  , windowGo U False)
  , ("M-<Right>"               , windowGo R False)
  , ("M-m"                     , windows W.focusMaster  )
  -- Directional Window Movement
  , ("M-S-h"                   , windowSwap L False)
  , ("M-S-j"                   , windowSwap D False)
  , ("M-S-k"                   , windowSwap U False)
  , ("M-S-l"                   , windowSwap R False)
  , ("M-S-<Left>"              , windowSwap L False)
  , ("M-S-<Down>"              , windowSwap D False)
  , ("M-S-<Up>"                , windowSwap U False)
  , ("M-S-<Right>"             , windowSwap R False)
  , ("M-S-m"                   , windows W.swapMaster)
  -- Window resizing
  , ("M-C-h"                   , sendMessage $ ExpandTowards L)
  , ("M-C-j"                   , sendMessage $ ExpandTowards D)
  , ("M-C-k"                   , sendMessage $ ExpandTowards U)
  , ("M-C-l"                   , sendMessage $ ExpandTowards R)
  , ("M-C-<Left>"              , sendMessage $ ExpandTowards L)
  , ("M-C-<Down>"              , sendMessage $ ExpandTowards D)
  , ("M-C-<Up>"                , sendMessage $ ExpandTowards U)
  , ("M-C-<Right>"             , sendMessage $ ExpandTowards R)
  , ("M-M1-h"                  , sendMessage $ ShrinkFrom L)
  , ("M-M1-j"                  , sendMessage $ ShrinkFrom D)
  , ("M-M1-k"                  , sendMessage $ ShrinkFrom U)
  , ("M-M1-l"                  , sendMessage $ ShrinkFrom R)
  , ("M-M1-<Left>"             , sendMessage $ ShrinkFrom L)
  , ("M-M1-<Down>"             , sendMessage $ ShrinkFrom D)
  , ("M-M1-<Up>"               , sendMessage $ ShrinkFrom U)
  , ("M-M1-<Right>"            , sendMessage $ ShrinkFrom R)
  -- Splitting and moving
  , ("M-S-C-j"                 , sendMessage $ SplitShift Prev)
  , ("M-S-C-k"                 , sendMessage $ SplitShift Next)
  -- Rotations/Swappings
  , ("M-r"                     , sendMessage Rotate)
  , ("M-s"                     , sendMessage Swap)
  , ("M-n"                     , sendMessage FocusParent)
  , ("M-C-n"                   , sendMessage SelectNode)
  , ("M-S-n"                   , sendMessage MoveNode)
  , ("M-a"                     , sendMessage Balance)
  , ("M-S-a"                   , sendMessage Equalize)
  -- Other stuff
  , ("M-t"                     , withFocused $ windows . W.sink)
  , ("M-,"                     , sendMessage (IncMasterN 1))
  , ("M-."                     , sendMessage (IncMasterN (-1)))
  , ("M-o"                     , windowMenu)
  , ("M-p"                     , rescreen *> spawn "notify-send \"changed screen config\"") -- confirmed keybinding works
  -- XMobar
  , ("M-b"                     , sendMessage ToggleStruts)
  -- Quitting
  , ("M-<Delete>"           , io exitSuccess)
  , ("M-S-<Delete>"         , restart "xmonad" True)
  -- Function Keys
  , ("<XF86MonBrightnessUp>"   , raiseMonBrigthness)
  , ("<XF86MonBrightnessDown>" , lowerMonBrigthness)
  , ("<XF86KbdBrightnessUp>"   , raiseKbdBrigthness)
  , ("<XF86KbdBrightnessDown>" , lowerKbdBrigthness)
  , ("<XF86AudioRaiseVolume>"  , spawn "pamixer --increase 5 && notify-send -a \"changeVolume\" -u low -i /etc/nixos/xmonad/icon/high-volume.png \"volume up\"")
  , ("<XF86AudioLowerVolume>"  , spawn "pamixer --decrease 5 && notify-send -a \"changeVolume\" -u low -i /etc/nixos/xmonad/icon/volume-down.png \"volume down\"")
  , ("<XF86AudioMicMute>"      , spawn "amixer set Capture toggle")
  , ("<XF86AudioMute>"         , spawn "pamixer --toggle-mute")
  , ("<XF86AudioNext>"         , spawn "playerctl next")
  , ("<XF86AudioPrev>"         , spawn "playerctl previous")
  , ("<XF86AudioPlay>"         , spawn "playerctl play-pause")
  , ("<XF86Launch4>"           , spawn "powerprofilesctl-cycle")
  ] ++
  [ (m ++ i, windows $ f j)
      | (i, j) <- zip (map show [1..9]) (workspaces config)
      , (m, f) <- [("M-", W.greedyView), ("M-S-", W.shift)]
  ]
  where
    lowerMonBrigthness :: MonadIO m => m ()
    lowerMonBrigthness =  spawn "brightnessctl set 5%-"
                       *> spawn "notify-send 'Brightness lowered'"
    raiseMonBrigthness :: MonadIO m => m ()
    raiseMonBrigthness =  spawn "brightnessctl set 5%+"
                       *> spawn "notify-send 'Brightness raised'"
    lowerKbdBrigthness :: MonadIO m => m ()
    lowerKbdBrigthness =  spawn "brightnessctl --device=\"asus::kbd_backlight\" set 1-"
                       *> spawn "notify-send 'Brightness lowered'"
    raiseKbdBrigthness :: MonadIO m => m ()
    raiseKbdBrigthness =  spawn "brightnessctl --device=\"asus::kbd_backlight\" set 1+"
                       *> spawn "notify-send 'Brightness raised'"

myAdditionalKeys config = additionalKeys config
  [ ((0                 , xF86XK_TouchpadToggle ), disableTouchpad)
  , ((0                 , xF86XK_TouchpadOn     ), enableTouchpad)
  -- Thinkpad X201T keys
  , ((0                 , xF86XK_RotateWindows  ), spawn "screenrotation.sh cycle_left")
  , ((0                 , xF86XK_TaskPane       ), spawn "screenrotation.sh swap")
  -- , ((0                 , xF86XK_ScreenSaver    ), spawn "xdotool key super+s")
  -- , ((0                 , xF86XK_Launch1        ), spawn "xdotool key super+r")
  ]
  -- mod-{y,x,c}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{y,x,c}, Move client to screen 1, 2, or 3
  -- [((m, key), screenWorkspace sc >>= flip whenJust (windows . f))
  --     | (key, sc) <- zip [xK_y, xK_x, xK_c] [0..]
  --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
  where
    enableTouchpad :: MonadIO m => m ()
    enableTouchpad =  spawn "xinput --enable \"ELAN1201:00 04F3:3098 Touchpad\""
                   *> spawn "xinput --enable \"AT Translated Set 2 keyboard\""
                   *> spawn "notify-send 'touchpad enabled'"
    disableTouchpad :: MonadIO m => m ()
    disableTouchpad =  spawn "xinput --disable \"ELAN1201:00 04F3:3098 Touchpad\""
                    *> spawn "xinput --disable \"AT Translated Set 2 keyboard\""
                    *> spawn "notify-send 'touchpad disabled'"

myNavigation2DConfig = def { layoutNavigation = [
    ("myBSP", hybridOf sideNavigation lineNavigation )
  ] }

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster)
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster)
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

myLayout = (avoidStruts . smartBorders) defaultLayouts
  where
    defaultLayouts =   myBSP
                   ||| tabletmodeBSP
                   ||| Full
    -- TODO: add tabs to this layout
    myBSP = renamed [Replace "myBSP"] 
          $ hiddenWindows
          $ (layoutHints (borderResize emptyBSP))
    tabletmodeBSP = renamed [Replace "tabletmodeBSP"]
                    (windowSwitcherDecorationWithImageButtons shrinkText defaultThemeWithImageButtons (draggingVisualizer myBSP))

myManageHook = placeHook (withGaps (10,10,10,10) (smart (0.5,0.5)))
  <+> composeAll [
    className =? "Onboard" --> doFloat]

myEventHook = focusOnMouseMove
            <+> hintsEventHook
            <+> windowedFullscreenFixEventHook
            <+> serverModeEventHookF "XMONAD_COMMAND" defaultServerCommands
              where
                defaultServerCommands "menu"        = windowMenu
                defaultServerCommands "swap-up"     = windowSwap U False
                defaultServerCommands "swap-down"   = windowSwap D False
                defaultServerCommands "swap-left"   = windowSwap L False
                defaultServerCommands "swap-right"  = windowSwap R False
                defaultServerCommands "rotate"      = sendMessage Rotate
                defaultServerCommands "layout-next" = sendMessage NextLayout

myStartupHook = do
   spawnOnce "sudo bluetooth off"
   spawnOnce "$(echo $(nix eval --raw nixos.polkit_gnome.outPath)/libexec/polkit-gnome-authentication-agent-1)"
   spawnOnce "xinput disable \"ThinkPad Extra Buttons\""
   spawnOnce "redshift"
   spawnOnce "birdtray"
   spawnOnce "nitrogen --restore &"
   spawnOnce "autoscreenrotation.sh &"
   spawnOnce "dunst -conf /etc/nixos/dunstrc"
   spawnOnce "polybar top"
   -- spawnOnce "onboard ; xdotool key 199 ; xdotool key 200"
   spawnOnce "nm-applet"
   spawnOnce "blueman-applet"
   spawnOnce "export $(dbus-launch)"
   spawnOnce "eval $(gnome-keyring-daemon --daemonize)"
   spawnOnce "export SSH_AUTH_SOCK"
   spawnOnce "batsignal -b"
   spawnOnce "touchegg &"
   -- spawnOnce "udiskie"
   setWMName "LG3D"
   adjustEventInput

main = getDirectories >>= launch
        ( docks
        $ ewmh
        $ myAdditionalKeys
        $ withNavigation2DConfig myNavigation2DConfig
        $ def
          {
            -- simple stuff
              terminal           = myTerminal,
              focusFollowsMouse  = myFocusFollowsMouse,
              clickJustFocuses   = myClickJustFocuses,
              borderWidth        = myBorderWidth,
              modMask            = myModMask,
              workspaces         = myWorkspaces,
              normalBorderColor  = myNormalBorderColor,
              focusedBorderColor = myFocusedBorderColor,
            -- key bindings
              keys               = myKeys,
              mouseBindings      = myMouseBindings,
            -- hooks, layouts
              layoutHook         = myLayout,
              manageHook         = myManageHook,
              handleEventHook    = myEventHook,
              startupHook        = myStartupHook
          })
