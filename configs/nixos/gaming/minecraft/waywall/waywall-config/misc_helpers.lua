local waywall = require("waywall")
local helpers = require("waywall.helpers")
local paths = require("paths")
local options = require("options")

local M = {}

M.read_file = function(name)
	local file = io.open(paths.home .. "/.config/waywall/" .. name, "r")
	local data = file:read("*a")
	file:close()
	return data
end

-- Dynamic F3 shortcut
M.f3_shortcut = function(exception)
	if waywall.get_key("F3") then
		waywall.press_key(exception)
	else
		return false
	end
end

M.lock_instance = function(inst_x, inst_y)
	local x_pos = (options.SCREEN_WIDTH * options.X)
		+ (((options.SCREEN_WIDTH * options.WIDTH) / (options.COLS * 2)) * (inst_x * 2 - 1))
	local y_pos = (options.SCREEN_HEIGHT * options.Y)
		+ (((options.SCREEN_HEIGHT * options.HEIGHT) / (options.ROWS * 2)) * (inst_y * 2 - 1))

	waywall.exec("ydotool mousemove -a -- " .. x_pos .. " " .. y_pos)
	waywall.exec("ydotool click -D 0 0xC0")

	waywall.sleep(45)

	waywall.press_key("SPACE")

	return true
end

M.try_lock = function(inst_x, inst_y)
	return waywall.state().screen == "wall" and M.lock_instance(inst_x, inst_y)
end

M.is_nbb_running = function()
	local handle = io.popen("pgrep -fi 'java.*ninjabrain.*bot.*jar'")
	local result = handle:read("*l")
	handle:close()
	return result ~= nil
end

M.toggle_nbb = function()
	if not M.is_nbb_running() then
		-- custom nix package for ninjabrain bot
		-- waywall.exec("java -Dawt.useSystemAAFontSettings=on -Dsun.java2d.uiScale=1.0 -jar " .. paths.nbb)
		waywall.exec(paths.nbb)
		waywall.show_floating(true)
	else
		helpers.toggle_floating()
	end
end

return M

-- technically shouldnt be using this i think because cheating so ill try to avoid
-- local get_latest_world = function()
--     local latest_world_file = io.open(latest_world_path, "r")
--     local data = latest_world_file:read("*all")
--     latest_world_file:close()
--     return data:match('"world_path":"([^"]+)"')
-- end
-- local check_srigt_events = function(event, hit_callback, miss_callback)
--     local events = io.open(get_latest_world() .. "/speedrunigt/events.log", "r")
--     local data = events:read("*all")
--     events:close()
--     if data:find(event) then
--         hit_callback()
--     else
-- 	miss_callback()
--     end
-- end
-- local stronghold_check = function()
--     check_srigt_events("enter_stronghold", function() waywall.show_floating(false) end, function() return end)
-- end
