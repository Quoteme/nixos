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
import XMonad.Actions.EasyMotion (selectWindow)
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
import XMonad.Util.NamedActions (addDescrKeys, xMessage, addName, (^++^), subtitle)
import XMonad.Util.Hacks (windowedFullscreenFixEventHook)
import XMonad.Layout.Hidden
import XMonad.Actions.UpdatePointer (updatePointer)
import XMonad.Layout.Decoration (Theme (fontName))

-- Options
myTerminal                  = "st"
myFocusFollowsMouse         = True
myClickJustFocuses          = True -- clicking to focus passes click to window?
myBorderWidth               = 3
myModMask                   = mod4Mask
myWorkspaces                = ["1","2","3","4","5","6","7","8","9"]
myNormalBorderColor         = "#161616"
myFocusedBorderColor        = "#888888"

myKeys config = (subtitle "Custom Keys":) $ mkNamedKeymap config $
  -- Code | Key
  -- M    | super key
  -- C    | control
  -- S    | shift
  -- M1   | alt
  -- M2   | num lock
  -- M3   | 
  -- M4   | super
  [ ("M-<Return>"              , addName "Spawn Terminal" $ spawn $ terminal config)
  , ("M-d"                     , addName "Open program launcher" $ spawn "rofi -show combi -show-icons")
  , ("M-e"                     , addName "Open emoji selector" $ spawn "rofimoji")
  , ("M-S-w"                   , addName "Open network settings" $ spawn "networkmanager_dmenu")
  , ("M-S-q"                   , addName "Kill window" $ kill)
  , ("M-<Space>"               , addName "Layout: next" $ sendMessage NextLayout)
  , ("M-S-<Space>"             , addName "Layout: default" $ setLayout $ layoutHook config)
  -- Rotational Focus Movement
  , ("M-<Tab>"                 , addName "WindowStack: rotate next" $ windows W.focusDown   >> myUpdateFocus)
  , ("M-S-<Tab>"               , addName "WindowStack: rotate previous" $ windows W.focusUp >> myUpdateFocus)
  , ("M-C-<Tab>"               , addName "WindowStack: swap next" $ windows W.swapDown      >> myUpdateFocus)
  , ("M-C-S-<Tab>"             , addName "WindowStack: swap previous" $ windows W.swapUp    >> myUpdateFocus)
  -- Easymotion
  , ("M-f"                     , addName "Easymotion: focus" $ selectWindow def >>= (`whenJust` windows . W.focusWindow) >> myUpdateFocus)
  , ("M-C-f"                   , addName "Easymotion: kill" $ selectWindow def >>= (`whenJust` killWindow))
  -- Directional Focus Movement
  , ("M-h"                     , addName "Focus: left"   $ windowGo L False      >> myUpdateFocus)
  , ("M-j"                     , addName "Focus: down"   $ windowGo D False      >> myUpdateFocus)
  , ("M-k"                     , addName "Focus: up"     $ windowGo U False      >> myUpdateFocus)
  , ("M-l"                     , addName "Focus: right"  $ windowGo R False      >> myUpdateFocus)
  , ("M-<Left>"                , addName "Focus: left"   $ windowGo L False      >> myUpdateFocus)
  , ("M-<Down>"                , addName "Focus: down"   $ windowGo D False      >> myUpdateFocus)
  , ("M-<Up>"                  , addName "Focus: up"     $ windowGo U False      >> myUpdateFocus)
  , ("M-<Right>"               , addName "Focus: right"  $ windowGo R False      >> myUpdateFocus)
  , ("M-m"                     , addName "Focus: master" $ windows W.focusMaster >> myUpdateFocus)
  -- Directional Window Movement
  , ("M-S-h"                   , addName "Swap: left"   $ windowSwap L False   >> myUpdateFocus)
  , ("M-S-j"                   , addName "Swap: down"   $ windowSwap D False   >> myUpdateFocus)
  , ("M-S-k"                   , addName "Swap: up"     $ windowSwap U False   >> myUpdateFocus)
  , ("M-S-l"                   , addName "Swap: right"  $ windowSwap R False   >> myUpdateFocus)
  , ("M-S-<Left>"              , addName "Swap: left"   $ windowSwap L False   >> myUpdateFocus)
  , ("M-S-<Down>"              , addName "Swap: down"   $ windowSwap D False   >> myUpdateFocus)
  , ("M-S-<Up>"                , addName "Swap: up"     $ windowSwap U False   >> myUpdateFocus)
  , ("M-S-<Right>"             , addName "Swap: right"  $ windowSwap R False   >> myUpdateFocus)
  , ("M-S-m"                   , addName "Swap: master" $ windows W.swapMaster >> myUpdateFocus)
  -- Window resizing
  , ("M-C-h"                   , addName "Expand: left" $ sendMessage $ ExpandTowards L)
  , ("M-C-j"                   , addName "Expand: down" $ sendMessage $ ExpandTowards D)
  , ("M-C-k"                   , addName "Expand: up" $ sendMessage $ ExpandTowards U)
  , ("M-C-l"                   , addName "Expand: right" $ sendMessage $ ExpandTowards R)
  , ("M-C-<Left>"              , addName "Expand: left" $ sendMessage $ ExpandTowards L)
  , ("M-C-<Down>"              , addName "Expand: down" $ sendMessage $ ExpandTowards D)
  , ("M-C-<Up>"                , addName "Expand: up" $ sendMessage $ ExpandTowards U)
  , ("M-C-<Right>"             , addName "Expand: right" $ sendMessage $ ExpandTowards R)
  , ("M-M1-h"                  , addName "Expand: left" $ sendMessage $ ShrinkFrom L)
  , ("M-M1-j"                  , addName "Expand: down" $ sendMessage $ ShrinkFrom D)
  , ("M-M1-k"                  , addName "Expand: up" $ sendMessage $ ShrinkFrom U)
  , ("M-M1-l"                  , addName "Expand: right" $ sendMessage $ ShrinkFrom R)
  , ("M-M1-<Left>"             , addName "Expand: left" $ sendMessage $ ShrinkFrom L)
  , ("M-M1-<Down>"             , addName "Expand: down" $ sendMessage $ ShrinkFrom D)
  , ("M-M1-<Up>"               , addName "Expand: up" $ sendMessage $ ShrinkFrom U)
  , ("M-M1-<Right>"            , addName "Expand: right" $ sendMessage $ ShrinkFrom R)
  -- Splitting and moving
  , ("M-S-C-k"                 , addName "Split: next" $ sendMessage $ SplitShift Next )
  , ("M-S-C-j"                 , addName "Split: previous" $ sendMessage $ SplitShift Prev)
  -- Rotations/Swappings
  , ("M-r"                     , addName "BSP: rotate" $ myUpdateFocus <> sendMessage Rotate)
  , ("M-s"                     , addName "BSP: swap" $ myUpdateFocus <> sendMessage Swap)
  , ("M-n"                     , addName "BSP: focus parent" $ myUpdateFocus <> sendMessage FocusParent)
  , ("M-C-n"                   , addName "BSP: select node" $ sendMessage SelectNode)
  , ("M-S-n"                   , addName "BSP: move node" $ sendMessage MoveNode)
  , ("M-a"                     , addName "BSP: balance" $ sendMessage Balance)
  , ("M-S-a"                   , addName "BSP: equalize" $ sendMessage Equalize)
  -- (Un-)Hiding
  , ("M-<Backspace>"           , addName "Window: hide" $ withFocused hideWindow *> spawn "notify-send \"hidden a window\"")
  , ("M-S-<Backspace>"         , addName "Window: unhide" $ popOldestHiddenWindow >> myUpdateFocus)
  -- Other stuff
  , ("M-t"                     , addName "Window: unfloat" $ withFocused $ windows . W.sink)
  , ("M-,"                     , addName "Master: increase" $ sendMessage (IncMasterN 1))
  , ("M-."                     , addName "Master: decrease" $ sendMessage (IncMasterN (-1)))
  , ("M-o"                     , addName "Window: menu" $ windowMenu)
  , ("M-p"                     , addName "Screen: rescreen" $ rescreen *> spawn "notify-send \"changed screen config\"") -- confirmed keybinding works
  -- Statusbar
  , ("M-b"                     , addName "Statusbar: toggle" $ sendMessage ToggleStruts)
  -- Quitting
  , ("M-<Delete>"              , addName "Xmonad: exit" $ io exitSuccess)
  , ("M-S-<Delete>"            , addName "Xmonad: restart" $ restart "xmonad" True *> spawn "notify-send \"Xmonad: restarted\"")
  -- Function Keys
  , ("<XF86MonBrightnessUp>"   , addName "Brightness: Monitor: raise" $ raiseMonBrigthness)
  , ("<XF86MonBrightnessDown>" , addName "Brightness: Monitor: lower" $ lowerMonBrigthness)
  , ("<XF86KbdBrightnessUp>"   , addName "Brightness: Keyboard: raise"$ raiseKbdBrigthness)
  , ("<XF86KbdBrightnessDown>" , addName "Brightness: Keyboard: lower" $ lowerKbdBrigthness)
  , ("<XF86AudioLowerVolume>"  , addName "Volume: raise" $ raiseAudio)
  , ("<XF86AudioRaiseVolume>"  , addName "Volume: lower" $ lowerAudio)
  , ("<XF86AudioMicMute>"      , addName "Microphone: toggle" $ spawn "amixer set Capture toggle")
  , ("<XF86AudioMute>"         , addName "Volume: toggle" $ spawn "pamixer --toggle-mute")
  , ("<XF86AudioNext>"         , addName "Media: next" $ spawn "playerctl next")
  , ("<XF86AudioPrev>"         , addName "Media: previous" $ spawn "playerctl previous")
  , ("<XF86AudioPlay>"         , addName "Media: pause" $ spawn "playerctl play-pause")
  , ("<XF86Launch4>"           , addName "Power profile: cycle" $ spawn "powerprofilesctl-cycle")
  ] ^++^
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
    lowerAudio :: MonadIO m => m ()
    lowerAudio =  spawn "pamixer --increase 5"
                       *> spawn "notify-send -a \"changeVolume\" -u low -i /etc/nixos/xmonad/icon/high-volume.png \"volume up\""
    raiseAudio :: MonadIO m => m ()
    raiseAudio =  spawn "pamixer --decrease 5"
                       *> spawn "notify-send -a \"changeVolume\" -u low -i /etc/nixos/xmonad/icon/volume-down.png \"volume down\""
    myUpdateFocus = updatePointer (0.5, 0.5) (0.1, 0.1)

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

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList
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

-- myLogHook = updatePointer (0.5, 0.5) (0.1, 0.1)

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
        $ addDescrKeys ((myModMask, xK_F1), xMessage) myKeys
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
            -- mouse bindings
              mouseBindings      = myMouseBindings,
            -- hooks, layouts
              layoutHook         = myLayout,
              manageHook         = myManageHook,
              handleEventHook    = myEventHook,
              startupHook        = myStartupHook
              -- logHook            = myLogHook
          })
