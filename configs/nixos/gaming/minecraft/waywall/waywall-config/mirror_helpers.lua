local waywall = require("waywall")
local paths = require("paths")

local M = {}

M.make_mirror = function(options)
	local this = nil

	return function(enable)
		if enable and not this then
			this = waywall.mirror(options)
		elseif this and not enable then
			this:close()
			this = nil
		end
	end
end

M.make_image = function(path, dst)
	local this = nil

	return function(enable)
		if enable and not this then
			this = waywall.image(path, dst)
		elseif this and not enable then
			this:close()
			this = nil
		end
	end
end

M.mirrors = {
	wide_rta = M.make_mirror({
		src = { x = 3600, y = 20, w = 176, h = 18 },
		dst = { x = 3072, y = 64, w = 704, h = 72 },
		shader = "timer",
	}),

	wide_igt = M.make_mirror({
		src = { x = 3600, y = 48, w = 176, h = 18 },
		dst = { x = 3072, y = 160, w = 704, h = 72 },
		shader = "timer",
	}),

	wide_inv = M.make_mirror({
		src = { x = 840 * 2, y = 281 * 2, w = 211 * 2, h = 39 * 2 },
		dst = { x = 480 * 2, y = 924 * 2, w = 844 * 2, h = 156 * 2 },
	}),

	-- classic thin e position (above pie)
	-- thin_e = M.make_mirror({
	--     src = { x = 0, y = 37 * 2, w = 85 * 2, h = 9 * 2 },
	--     dst = { x = 1120 * 2, y = 618 * 2, w = 340 * 2, h = 4 * 9 * 2 },
	-- }),
	-- left of window above hotbar
	-- thin_e = M.make_mirror({
	--     src = { x = 0, y = 37 * 2, w = 65 * 2, h = 9 * 2 },
	--     dst = { x = 540 * 2, y = 522 * 2, w = 260 * 2, h = 4 * 9 * 2 },
	-- }),
	-- raised up to be above new pie chart
	--    thin_e = M.make_mirror({
	--        src = { x = 0, y = 37 * 2, w = 80 * 2, h = 9 * 2 },
	--        dst = { x = 800 * 2, y = 656 * 2, w = 320 * 2, h = 4 * 9 * 2 },
	-- color_key = { input = "#DCDCDC", output = "#DCDCDC" },
	--    }),
	thin_e = M.make_mirror({
		src = { x = 0, y = 37 * 2, w = 80 * 2, h = 9 * 2 },
		dst = { x = 800 * 2, y = 588 * 2, w = 320 * 2, h = 4 * 9 * 2 },
		color_key = { input = "#DCDCDC", output = "#DCDCDC" },
	}),

	-- classic thin pie position
	-- thin_pie = M.make_mirror({
	--     src = { x = 300, y = 1734, w = 340, h = 426 },
	--     dst = { x = 1120 * 2, y = 654 * 2, w = 340 * 2, h = 426 * 2 },
	-- }),
	-- not raised enough for hearts hotbar
	--    thin_pie = M.make_mirror({
	--        src = { x = 300, y = 1734, w = 340, h = 300 },
	--        dst = { x = 1600, y = 692 * 2, w = 320 * 2, h = 300 * 2 },
	-- shader = "pie_chart",
	--    }),
	thin_pie = M.make_mirror({
		src = { x = 300, y = 1734, w = 340, h = 300 },
		dst = { x = 1600, y = 624 * 2, w = 320 * 2, h = 300 * 2 },
		shader = "pie_chart",
	}),
	-- extra not shaded bit to cover the real piechart so it doesnt look weird
	thin_pie2 = M.make_mirror({
		src = { x = 300, y = 1982, w = 340, h = 52 },
		dst = { x = 1600, y = 872 * 2, w = 320 * 2, h = 52 * 2 },
		-- shader = "pie_chart",
	}),

	-- thin_inv = M.make_mirror({
	--     src = { x = 40 * 2, y = 1058 * 2, w = 211 * 2, h = 22 * 2 },
	--     dst = { x = 480 * 2, y = 992 * 2, w = 844 * 2, h = 88 * 2 },
	-- }),
	thin_inv = M.make_mirror({
		src = { x = 40 * 2, y = 1041 * 2, w = 211 * 2, h = 39 * 2 },
		dst = { x = 480 * 2, y = 924 * 2, w = 844 * 2, h = 156 * 2 },
	}),

	thin_rta = M.make_mirror({
		src = { x = 454, y = 72, w = 176, h = 18 },
		dst = { x = 3072, y = 64, w = 704, h = 72 },
		shader = "timer",
	}),

	thin_igt = M.make_mirror({
		src = { x = 454, y = 170, w = 176, h = 18 },
		dst = { x = 3072, y = 160, w = 704, h = 72 },
		shader = "timer",
	}),

	-- classic tall e position
	-- tall_e = M.make_mirror({
	--     src = { x = 0, y = 37 * 2, w = 85 * 2, h = 9 * 2 },
	--     dst = { x = 1120 * 2, y = 618 * 2, w = 340 * 2, h = 4 * 9 * 2 },
	-- }),
	-- left of window, above hotbar
	-- tall_e = M.make_mirror({
	--     src = { x = 0, y = 37 * 2, w = 65 * 2, h = 9 * 2 },
	--     dst = { x = 540 * 2, y = 522 * 2, w = 260 * 2, h = 4 * 9 * 2 },
	-- }),
	--    tall_e = M.make_mirror({
	--        src = { x = 0, y = 37 * 2, w = 80 * 2, h = 9 * 2 },
	--        dst = { x = 800 * 2, y = 656 * 2, w = 320 * 2, h = 4 * 9 * 2 },
	-- color_key = { input = "#DCDCDC", output = "#DCDCDC" },
	--    }),
	tall_e = M.make_mirror({
		src = { x = 0, y = 37 * 2, w = 80 * 2, h = 9 * 2 },
		dst = { x = 800 * 2, y = 588 * 2, w = 320 * 2, h = 4 * 9 * 2 },
		color_key = { input = "#DCDCDC", output = "#DCDCDC" },
	}),

	-- classic tall pie position
	-- tall_pie = M.make_mirror({
	--     src = { x = 300, y = 15958, w = 340, h = 426 },
	--     dst = { x = 1120 * 2, y = 654 * 2, w = 340 * 2, h = 426 * 2 },
	-- }),
	tall_pie = M.make_mirror({
		src = { x = 300, y = 15958, w = 340, h = 300 },
		dst = { x = 1600, y = 624 * 2, w = 320 * 2, h = 300 * 2 },
		shader = "pie_chart",
	}),

	-- tall_inv = M.make_mirror({
	--     src = { x = 40 * 2, y = 16340, w = 211 * 2, h = 22 * 2 },
	--     dst = { x = 480 * 2, y = 992 * 2, w = 844 * 2, h = 88 * 2 },
	-- }),
	tall_inv = M.make_mirror({
		src = { x = 40 * 2, y = 16306, w = 211 * 2, h = 39 * 2 },
		dst = { x = 480 * 2, y = 924 * 2, w = 844 * 2, h = 156 * 2 },
	}),

	tall_rta = M.make_mirror({
		src = { x = 454, y = 570, w = 176, h = 18 },
		dst = { x = 3072, y = 64, w = 704, h = 72 },
		shader = "timer",
	}),

	tall_igt = M.make_mirror({
		src = { x = 454, y = 1308, w = 176, h = 18 },
		dst = { x = 3072, y = 160, w = 704, h = 72 },
		shader = "timer",
	}),

	-- classic measuring position
	-- eye_measure = M.make_mirror({
	--     src = { x = 305, y = 7592, w = 30, h = 600 * 2 },
	--     dst = { x = 0, y = 370 * 2, w = 800 * 2, h = 340 * 2 },
	-- }),
	eye_measure = M.make_mirror({
		src = { x = 305, y = 7592, w = 30, h = 600 * 2 },
		dst = { x = 0, y = 584 * 2, w = 800 * 2, h = 340 * 2 },
	}),
}

M.images = {
	-- classic measuring position
	-- measuring_overlay = M.make_image(paths.overlay, {
	--     dst = { x = 0, y = 370 * 2, w = 800 * 2, h = 340 * 2 },
	-- }),
	measuring_overlay = M.make_image(paths.overlay, {
		dst = { x = 0, y = 584 * 2, w = 800 * 2, h = 340 * 2 },
	}),
}

M.show_mirrors = function(wide, thin, tall, measure)
	-- WIDE
	M.mirrors.wide_rta(wide)
	M.mirrors.wide_igt(wide)
	M.mirrors.wide_inv(wide)

	-- THIN
	M.mirrors.thin_e(thin)
	M.mirrors.thin_pie(thin)
	M.mirrors.thin_pie2(thin)
	M.mirrors.thin_rta(thin)
	M.mirrors.thin_igt(thin)
	M.mirrors.thin_inv(thin)

	-- TALL
	M.mirrors.tall_e(tall)
	M.mirrors.tall_pie(tall)

	-- MEASURE
	M.mirrors.eye_measure(measure)
	M.images.measuring_overlay(measure)

	-- TALL + MEASURE
	M.mirrors.tall_rta(tall or measure)
	M.mirrors.tall_igt(tall or measure)
	M.mirrors.tall_inv(tall or measure)
end

return M
