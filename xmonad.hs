import XMonad
import XMonad.Config
import XMonad.Config.Desktop
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.NoBorders
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import System.IO
import Control.Monad (liftM2)

myWorkspaces = ["1","2","3","4","5","6","7","8","9"]


myManageHook = composeAll
    [ className =? "stalonetray" --> doIgnore
    , className =? "jetbrains-webstorm" --> doShift "1"
    , className =? "Google-chrome" --> doShift "2"
    , className =? "robo3t" --> viewShift "3"
    , className =? "Firefox" --> viewShift "4"
    , className =? "Slack" --> doShift "9"
    , manageDocks
    ]
    where viewShift = doF . liftM2 (.) W.greedyView W.shift

myLayout = avoidStruts (mouseResizableTile { draggerType = BordersDragger } ||| noBorders Full ||| mouseResizableTileMirrored { draggerType = BordersDragger })

mykeys = 
    [ (("M-u"), sendMessage ShrinkSlave)
    , (("M-i"), sendMessage ExpandSlave)
    , (("M-b"), sendMessage ToggleStruts)
    , (("M-<R>"), spawn "pulsemixer --change-volume +5")
    , (("M-<L>"), spawn "pulsemixer --change-volume -5")
    , (("M--"), spawn "mpc volume -10")
    , (("M-+"), spawn "mpc volume +10")
    , (("M-S-<"), spawn "mpc next")
    , (("M-<"), spawn "mpc prev")
    , (("M-S-p"), spawn "mpc toggle")
    , ("<XF86MonBrightnessUp>", spawn "xbacklight +5")
    , ("<XF86MonBrightnessDown>", spawn "xbacklight -4")
    ] ++ --dual monitor workspace switching (view = focus monitor instead of swapping workspace, greedyView = swap)
    [ (otherModMasks ++ "M-" ++ [key], action tag)
      | (tag, key)  <- zip myWorkspaces "123456789"
      , (otherModMasks, action) <- [ ("", windows . W.greedyView) -- change to W.view
                                      , ("S-", windows . W.shift)]
    ] 

--myLogHook
--outputs workspace layout and title to stdout/xmobar stdin
--see for more info: http://xmonad.org/xmonad-docs/xmonad-contrib/XMonad-Hooks-DynamicLog.html#t:PP
grey1 = "#181818"
grey2 = "#383838"
grey3 = "#585858"
grey4 = "#b8b8b8"
green1 = "#a1b56c"
green2 = "#80924e"

myLoghook h = dynamicLogWithPP xmobarPP
    { ppCurrent         = wrap "<fc=#181818,#a1b56c>  " "  </fc>"  . pad 
    , ppVisible		= wrap "<fc=#181818,#a1b56c> " " </fc>"
    , ppHidden 		= wrap "<fc=#80924e,#a1b56c> " " </fc>"
    , ppSep 		= ""
    , ppWsSep 		= "<fc=#a1b56c,#80924e>\xe0b0</fc><fc=#80924e,#a1b56c>\xe0b0</fc>"
    , ppLayout		= wrap "<fc=#a1b56c,#80924e>\xe0b0</fc><fc=#80924e,#585858>\xe0b0</fc><fc=#b8b8b8,#585858> " " </fc><fc=#585858,#383838>\xe0b0</fc><fc=#383838>\xe0b0</fc>" . 
		(\x -> case x of 
			"MouseResizableTile" 		-> "MRT"
			"Mirror MouseResizableTile" 	-> "MMRT"
			"Full"				-> "FULL"
			_				-> x
		)
    , ppTitle 		= wrap "<fc=#b8b8b8>" "</fc>" . shorten 50 . pad
    , ppOutput		= hPutStrLn h 
    }   

main = do
    xmproc <- spawnPipe "xmobar ~/.config/xmobarrc"
    xmonad $ docks $ ewmh def
        { startupHook = ewmhDesktopsStartup <+> setWMName "LG3D"
        , manageHook = myManageHook
        , handleEventHook = ewmhDesktopsEventHook
        , modMask = mod4Mask
        , layoutHook = myLayout
        , logHook = myLoghook xmproc 
        , terminal = "urxvt"
        , normalBorderColor = "#383838"
        , focusedBorderColor = "#a1b56c"
        , borderWidth = 2
        }
	`additionalKeysP` mykeys



