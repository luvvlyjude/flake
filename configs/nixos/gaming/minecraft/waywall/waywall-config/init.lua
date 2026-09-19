local waywall = require("waywall")
local helpers = require("waywall.helpers")
local res = require("res_helpers")
local state = require("state_helpers")
local paths = require("paths")
local misc = require("misc_helpers")
local options = require("options")

-- ==== RESOLUTIONS ====
local RESOLUTIONS = {
	WIDE = res.make_res(3840, 640, res.wide_enable, res.res_disable),
	THIN = res.make_res(640, 2160, res.thin_enable, res.res_disable),
	TALL = res.make_res(640, 16384, res.tall_enable, res.res_disable),
	MEASURE = res.make_res(640, 16384, res.measure_enable, res.res_disable),
}

-- ==== CONFIG ====
local config = {
	input = {
		sensitivity = options.NORMAL_SENS,
		remaps = options.REMAPS,
	},
	theme = {
		background = "#00000000",
		ninb_anchor = {
			position = "topright",
			y = 120,
		},
		ninb_opacity = 0.85,
	},
	shaders = {
		["pie_chart"] = {
			vertex = misc.read_file("general.vert"),
			fragment = misc.read_file("pie_chart.frag"),
		},
		["timer"] = {
			vertex = misc.read_file("general.vert"),
			fragment = misc.read_file("timer.frag"),
		},
	},
	experimental = {
		tearing = true,
		-- debug = true,
	},
	window = {
		fullscreen_width = options.SCREEN_WIDTH,
		fullscreen_height = options.SCREEN_HEIGHT,
	},
}

config.actions = {
	[options.WIDE] = RESOLUTIONS.WIDE,
	[options.THIN] = RESOLUTIONS.THIN,
	[options.TALL] = RESOLUTIONS.TALL,
	[options.MEASURE] = RESOLUTIONS.MEASURE,

	[options.FULLSCREEN] = waywall.toggle_fullscreen,

	[options.F3_T] = function()
		return misc.f3_shortcut("D")
	end,
	[options.F3_N] = function()
		return misc.f3_shortcut("N")
	end,

	[options.TOGGLE_NBB] = misc.toggle_nbb,

	[options.SUSPEND] = function()
		waywall.set_remaps({})
	end,
	[options.UNSUSPEND] = function()
		waywall.set_remaps(options.REMAPS)
	end,
}

-- ==== STARTUP ====
waywall.listen("load", function()
	waywall.sleep(10000)
	waywall.listen("state", state.instance_state_checker())

	if not misc.is_nbb_running() then
		waywall.sleep(5000)
		misc.toggle_nbb()
	end
end)

require("ww_temporary_ninbot.init").setup(config, {
	timer_length = 15,
})

return config
