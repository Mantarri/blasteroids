local LASER = require("laser")
local ASTEROID = require("asteroid")

function love.load()
    love.window.setTitle("Asteroids") -- Sets window title, don't change window title often
    WINDOW_HEIGHT = love.graphics.getHeight()
    WINDOW_WIDTH = love.graphics.getWidth()

    player = {}
    player.x = 20
    player.y = WINDOW_HEIGHT / 2 - 25

    lasers = {} -- Initialize an empty table to store lasers in
    asteroids = {}
    asteroidSpawn = false
    asteroidSpawnTime = 3
    asteroidSpawnTimer = 0
    asteroidSpawnCount = 0
    MAX_ASTEROID_SPAWNS = 6

    -- Disable key repeat for love.keypressed function
    -- A likely better solution is to move the key down detection back to love.update (where
    -- key repeat is enabled) and instead implement a cooldown before another laser can be
    -- fired. Keep in mind that the dt/dtime argument passed to love.update can be used to
    -- decrement a cooldown timer as it represents the time since the last update call.
    -- For example: player.cooldown = player.cooldown - dt
    love.keyboard.setKeyRepeat(false)
end

function love.update(dt)
    -- DEBUG REMOVE THIS CODE BLOCK BEFORE RELEASE
    if love.keyboard.isDown("p") then
        startSpawn = true
    end

    -- Player controls
    if love.keyboard.isDown("down") and player.y <= WINDOW_HEIGHT - 30 then
        player.y = player.y + .4
    elseif love.keyboard.isDown("up") and player.y >= 10 then
        player.y = player.y - .4
    end


    -- Move laser to the right via increasing laser.x value
    for _, laser in pairs(lasers) do
        laser:update()
    end

    -- Asteroids

    if asteroidSpawnTimer <= asteroidSpawnTime and startSpawn == true then -- REMOVE 'and startSpawn == true' BEFORE RELEASE
        asteroidSpawnTimer = asteroidSpawnTimer + dt
    elseif asteroidSpawnTimer >= asteroidSpawnTime then
        asteroidSpawn = true
        asteroidSpawnTimer = 0
    end

    if asteroidSpawn == true then
        for i = 1, math.random(2, MAX_ASTEROID_SPAWNS) do
            local asteroid = ASTEROID.new(WINDOW_WIDTH, math.random(30, WINDOW_HEIGHT - 30))
            table.insert(asteroids, asteroid)
        end
        asteroidSpawn = false
    end

    for _, asteroid in pairs(asteroids) do
        asteroid:update()
    end
end

function love.keypressed(key, isrepeat)
    if key == "space" then
        -- Initialize a new laser at the player position with a horizontal offset of 10
        local laser = LASER.new(player.x + 50, player.y + 10)
        table.insert(lasers, laser) -- Insert new laser into lasers table
    end
end

function love.draw()
    -- Player ship
    love.graphics.rectangle("fill", player.x, player.y, 80, 20) -- Draw solid rectangle for ship

    -- Lasers
    for _, laser in pairs(lasers) do
        love.graphics.rectangle("fill", laser.x, laser.y, 20, 5) -- Draw solid rectangle for laser
    end

    -- Asteroids
    for _, asteroid in pairs(asteroids) do
        love.graphics.rectangle("fill", asteroid.x, asteroid.y, 20, 20)
    end
end