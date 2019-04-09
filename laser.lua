local laser = {
	x = 0, y = 0
}

function laser.update(self)
	self.x = self.x + 350 * love.timer.getDelta()
end

function new(x, y)
	local newLaser = {}
	for key, value in pairs(laser) do
		newLaser[key] = value
	end

	newLaser.x = x or newLaser.x
	newLaser.y = y or newLaser.y

	return newLaser
end

return {
	new = new
}