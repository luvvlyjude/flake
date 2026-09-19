local waywall = require("waywall")
local mirrors = require("mirror_helpers")

local O = {}

O.SCREEN_WIDTH = 3840
O.SCREEN_HEIGHT = 2160

-- SeedQueue main group grid dimensions
O.ROWS = 1
O.COLS = 3
O.X = 0.075
O.Y = 0.55
O.WIDTH = 0.85
O.HEIGHT = 0.0075

O.NORMAL_SENS = 16
O.MEASURE_SENS = 1

O.WIDE = "*-H"
O.THIN = "*-X"
O.TALL = "Shift-Tab"
O.MEASURE = "Tab"

O.RESET_1 = "S"
O.RESET_2 = "D"
O.RESET_3 = "F"

O.FULLSCREEN = "*-F11"

O.F3_T = "*-T"
O.F3_N = "*-N"

O.F3_C = "*-C"

O.TOGGLE_NBB = "GRAVE"
O.SUSPEND = "*-Alt_R"
O.UNSUSPEND = "*-Shift-Alt_R"

-- waywall rebinds affect keys sent by ydotool
if waywall.profile() == "seedqueue" then
	O.NORMAL_JOIN = function()
		waywall.exec("ydotool key -d 0 59:1 59:0 61:1 34:1 34:0 48:1 48:0 20:1 20:0 61:0")
	end
else
	O.NORMAL_JOIN = function() end
end

O.NORMAL_LEAVE = function()
	waywall.set_resolution(0, 0)
	mirrors.show_mirrors(false, false, false, false)
	waywall.set_sensitivity(O.NORMAL_SENS)
	waywall.exec("ydotool key -d 0 66:1 66:0")
	waywall.show_floating(false)
end

O.REMAPS = {
	["Q"] = "D",
	["D"] = "N",
	["N"] = "S",
	["S"] = "E",
	["E"] = "O",
	["O"] = "Q",

	["Z"] = "P",
	["P"] = "Z",

	["LEFTMETA"] = "LEFTCTRL",
}

return O
