
-- █▀▀ █▀█ █░░ █▀█ █▀█ 
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ 

local clib = require("modules.color")

local _color = {}

local function round(x, p)
	local power = 10 ^ (p or 0)
	return (x * power + 0.5 - (x * power + 0.5) % 1) / power
end

function _color.lighten(color, amount)
  color = clib.color{ hex = color }

	color.r = round(color.r + (255 - color.r) * amount)
	color.g = round(color.g + (255 - color.g) * amount)
	color.b = round(color.b + (255 - color.b) * amount)

	return color.hex
end

function _color.darken(color, amount)
	color = clib.color({ hex = color })

	color.r = round(color.r * (1 - amount))
	color.g = round(color.g * (1 - amount))
	color.b = round(color.b * (1 - amount))

	return color.hex
end

function _color.blend(color1, color2)
	color1 = clib.color({ hex = color1 })
	color2 = clib.color({ hex = color2 })

	return clib.color({
		r = round(0.5 * color1.r + 0.5 * color2.r),
		g = round(0.5 * color1.g + 0.5 * color2.g),
		b = round(0.5 * color1.b + 0.5 * color2.b),
	}).hex
end

return _color
