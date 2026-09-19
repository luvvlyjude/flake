local waywall = require("waywall")
local res = require("res_helpers")
local options = require("options")

local M = {}

-- Lock the scrollwheel if unpaused ingame
M.set_scroll = function(state)
	if state.screen == "inworld" and state.inworld == "unpaused" then
		-- waywall.exec("swaymsg input type:pointer scroll_factor 0.0")
		-- waywall.exec("jay input device 48 set-px-per-wheel-scroll 0")
		waywall.exec("bash /home/jude/.config/waywall/jay_scroll.sh 0")
	else
		-- waywall.exec("swaymsg input type:pointer scroll_factor 1.0")
		-- waywall.exec("jay input device 48 set-px-per-wheel-scroll 15")
		waywall.exec("bash /home/jude/.config/waywall/jay_scroll.sh 15")
	end
end

-- Disable sway keybinds if unpaused ingame
M.set_binds = function(state)
	if state.screen == "inworld" and state.inworld ~= "paused" then
		-- DISABLED FOR TESTING TURN BACK ON
		waywall.exec("ydotool key -d 0 194:1 194:0")
		-- waywall.exec("swaymsg mode \"binds_disabled\"")
	else
		-- DISABLED FOR TESTING TURN BACK ON
		waywall.exec("ydotool key -d 0 193:1 193:0")
		-- waywall.exec("swaymsg mode \"default\"")
	end
end

-- Run world joining commands if joining a world
M.join_world_check = function(prev_state, new_state, callback)
	if prev_state.screen ~= "inworld" and new_state.screen == "inworld" then
		callback()
	end
end

-- Run world leaveing commands if leaving a world
M.leave_world_check = function(prev_state, new_state, callback)
	if prev_state.screen == "inworld" and new_state.screen ~= "inworld" then
		callback()
	end
end

-- ==== STATE CHECKER ====
M.instance_state_checker = function()
	local prev_state = waywall.state()

	return function()
		local new_state = waywall.state()

		-- the file flush for stateoutput file causes an update and retriggers for this file can
		-- cause jay cli scroll sens changes in set_scroll to come in out of order, this fixes that
		if
			new_state.screen == "inworld"
			and new_state.screen == prev_state.screen
			and new_state.inworld == prev_state.inworld
		then
			return
		end

		-- some weird possible bug fix i found in jingle code
		-- jingle/instance/statetracker line ~130
		if prev_state.screen == "previewing" and new_state.screen == "generating" then
			new_state.screen = "previewing"
		end

		waywall.set_remaps(options.REMAPS)

		M.set_scroll(new_state)

		M.set_binds(new_state)

		M.join_world_check(prev_state, new_state, options.NORMAL_JOIN)

		M.leave_world_check(prev_state, new_state, options.NORMAL_LEAVE)

		prev_state = new_state
	end
end

return M
