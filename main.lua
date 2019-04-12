local LASER = require("laser")
local ASTEROID = require("asteroid")



function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    WINDOW_HEIGHT = love.graphics.getHeight()
    WINDOW_WIDTH = love.graphics.getWidth()
    score = 0
    gameOver = false

    player = {}
    player.x = 20
    player.y = WINDOW_HEIGHT / 2 - 25
    player.spd = 200 -- Set player speed
    player.shipImage = love.graphics.newImage("/resources/sprites/ship.png")
    player.HP = 1
    player.score = 0

    lasers = {} -- Initialize an empty table to store lasers in
    laserSprite = love.graphics.newImage("/resources/sprites/lazer.png")
    laserWidth = 24
    laserHeight = 16

    asteroids = {}
    asteroidY = 0
    asteroidWidth = 48
    asteroidHeight = 48
    asteroidSpawn = false
    spawnedASteroids = 0
    activeAsteroids = 0
    asteroidSpawnTimer = 0
    asteroidSpawnCount = 0
    MAX_ASTEROID_SPAWNS = 4
    asteroidSprite = love.graphics.newImage("/resources/sprites/asteroid.png")

    -- Functions

    function updateScore(mode, amount)
        if mode == "increase" then
            player.score = player.score + amount
        elseif mode == "decrease" and player.score > 0 then
            player.score = player.score - amount
        else
            print("ERROR: missing argument(s) for updateScore function")
        end
    end
    
    function checkCollision(w1, h1, w2, h2, x1, y1, x2, y2)
        --[[
        w1/h1 are the dims of the "checker object", that will be checking for collisions
          and w2/h2 are collision object's dims
        
        x1/y1 are the coords of the "checker object", 
          and x2/y2 are the collision object's coords.
        --]]
        if x1 >= x2 and x1 <= x2 + w2 and y1 >= y2 and y1 <= y2 + h2 then
          return "collision"
        end
    end

    -- Disable key repeat for love.keypressed function
    -- A likely better solution is to move the key down detection back to love.update (where
    -- key repeat is enabled) and instead implement a cooldown before another laser can be
    -- fired. Keep in mind that the dt/dtime argument passed to love.update can be used to
    -- decrement a cooldown timer as it represents the time since the last update call.
    -- For example: player.cooldown = player.cooldown - dt
    love.keyboard.setKeyRepeat(false)
end

function love.update(dt)
    if gameOver == false then
        -- Player controls
        if love.keyboard.isDown("down") and player.y <= WINDOW_HEIGHT - 30 then
            player.y = player.y + player.spd * dt
        elseif love.keyboard.isDown("up") and player.y >= 10 then
            player.y = player.y - player.spd * dt
        end


        -- Move laser to the right via increasing laser.x value
        for _, laser in pairs(lasers) do
            laser:update()
        end

        -- Asteroids

        if asteroidSpawn == true or activeAsteroids == 0 then
            if activeAsteroids == 0 then
                asteroidY = math.random(50, 70)
                local asteroid = ASTEROID.new(WINDOW_WIDTH + asteroidWidth + 2, asteroidY)
                table.insert(asteroids, asteroid)
                activeAsteroids = activeAsteroids + 1
                asteroidY = math.random(asteroidY + 60, asteroidY + 120)
                asteroidSpawn = true
            elseif asteroidSpawn == true and asteroidY >= 50 and asteroidY <= WINDOW_HEIGHT - 50 then
                    local asteroid = ASTEROID.new(WINDOW_WIDTH + asteroidWidth + 2, asteroidY)
                    table.insert(asteroids, asteroid)
                    activeAsteroids = activeAsteroids + 1
                    asteroidY = math.random(asteroidY + 60, asteroidY + 120)
            else
                asteroidSpawn = false
            end
        end

        for _, asteroid in pairs(asteroids) do
            asteroid:update()
        end
        
        for key2, asteroid in pairs(asteroids) do
            if asteroid.x <= -42 then
                activeAsteroids = activeAsteroids - 1
                table.remove(asteroids, key2)
                updateScore("decrease", 1)
            end
            if checkCollision(asteroidWidth, asteroidHeight, 64, 48, asteroid.x, asteroid.y, player.x, player.y) == "collision" then
                activeAsteroids = activeAsteroids - 1
                table.remove(asteroids, key2)
                player.HP = player.HP - 1
                updateScore("decrease", 2)
            end
        end
        
        for key, laser in pairs(lasers) do
            if laser.x >= WINDOW_WIDTH then
                table.remove(lasers, key)
            end
            for key2, asteroid in pairs(asteroids) do
                if checkCollision(laserWidth, laserHeight, asteroidWidth, asteroidHeight, laser.x, laser.y, asteroid.x, asteroid.y) == "collision" then
                    table.remove(lasers, key)
                    activeAsteroids = activeAsteroids - 1
                    table.remove(asteroids, key2)
                    updateScore("increase", 1)
                end
            end
        end
        if player.HP == 0 then
            gameOver = true
        end
    end
end

function love.keypressed(key, isrepeat)
    if key == "space" then
        -- Initialize a new laser at the player position with a horizontal offset of 10
        local laser = LASER.new(player.x + 75, player.y + 9)
        table.insert(lasers, laser) -- Insert new laser into lasers table
    end
end

function love.draw()
    if gameOver == false then
        love.graphics.print(player.score)

        -- Asteroids
        for _, asteroid in pairs(asteroids) do
            love.graphics.draw(asteroidSprite, asteroid.x, asteroid.y, 0, 2)
        end

        -- Player ship
        love.graphics.draw(player.shipImage, player.x, player.y, 0, 2)

        -- Lasers
        for _, laser in pairs(lasers) do
            love.graphics.draw(laserSprite, laser.x, laser.y, 0, 2)
        end
    end
    if gameOver == true then
        love.graphics.print("Game over, your score was " .. player.score, 50, 50, 0, 1.5)
    end
end