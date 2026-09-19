local waywall = require("waywall")
local mirrors = require("mirror_helpers")
local options = require("options")

local M = {}

M.make_res = function(width, height, enable, disable)
	return function()
		local active_width, active_height = waywall.active_res()
		local state = waywall.state()

		if active_width == width and active_height == height then
			waywall.set_resolution(0, 0)
			disable()
		elseif state.screen == "inworld" and state.inworld ~= "menu" then
			waywall.set_resolution(width, height)
			enable()
		end
		return false
	end
end

M.wide_enable = function()
	mirrors.show_mirrors(true, false, false, false)
	waywall.set_sensitivity(options.NORMAL_SENS)
end

M.thin_enable = function()
	mirrors.show_mirrors(false, true, false, false)
	waywall.set_sensitivity(options.NORMAL_SENS)
end

M.tall_enable = function()
	mirrors.show_mirrors(false, false, true, false)
	waywall.set_sensitivity(options.NORMAL_SENS)
end

M.measure_enable = function()
	mirrors.show_mirrors(false, false, false, true)
	waywall.set_sensitivity(options.MEASURE_SENS)
end

M.res_disable = function()
	mirrors.show_mirrors(false, false, false, false)
	waywall.set_sensitivity(options.NORMAL_SENS)
end

return M
