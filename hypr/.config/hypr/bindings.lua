-- Personal keybinding overrides shared by Quattro machines.
-- See current bindings and descriptions with: omarchy menu keybindings --print

-- Keep laptop-friendly screenshot shortcuts on Home for keyboards where Print
-- is inconvenient. These replace Omarchy's default window-width shortcuts on
-- SUPER+Home / SUPER+ALT+Home.
hl.unbind("SUPER + Home")
hl.unbind("SUPER + ALT + Home")

o.bind("Home", "Screenshot", "omarchy capture screenshot")
o.bind("SHIFT + Home", "Screenshot smart copy", "omarchy capture screenshot smart copy")
o.bind("ALT + Home", "Screenrecording", "omarchy capture screenrecording")
o.bind("SUPER + Home", "Color picker", "pkill hyprpicker || hyprpicker -a")

-- Omarchy Quattro already provides the old shared app bindings, including:
-- SUPER+Return terminal, SUPER+ALT+Return tmux, SUPER+CTRL+Return herdr,
-- SUPER+Shift app/webapp launchers, and Print screenshot bindings.
