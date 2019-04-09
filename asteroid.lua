local asteroid = {
	x = 0, y = 0
}

function asteroid.update(self)
	self.x = self.x - 110 * love.timer.getDelta()
end

function new(x, y)
	local newAsteroid = {}
	for key, value in pairs(asteroid) do
		newAsteroid[key] = value
	end

	newAsteroid.x = x or newAsteroid.x
	newAsteroid.y = y or newAsteroid.y

	return newAsteroid
end

return {
	new = new
}