local init = require("init")
local options = require("options")
local misc = require("misc_helpers")

init.actions[options.RESET_1] = function()
	return misc.try_lock(1, 1)
end
init.actions[options.RESET_2] = function()
	return misc.try_lock(2, 1)
end
init.actions[options.RESET_3] = function()
	return misc.try_lock(3, 1)
end

return init
