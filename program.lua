local LASER = require("laser")
local ASTEROID = require("asteroid")
local program = {}
local laserBlaster = {onCoolDown = false, coolDownTimer = .40, coolDownTime = 0}
function program.readState(programState)
    if programState == "gameOver" then
        local highScore = love.filesystem.read("highscores.sav")
        local highScore = tonumber(highScore)
        if player.score > 0 then
           player.sessionScore = player.score
        end
        if player.sessionScore > highScore then
            love.filesystem.write("highscores.sav", player.score)
        end
        button(programData.button.mainMenu.w, programData.button.mainMenu.h, programData.button.mainMenu.x, programData.button.mainMenu.y, "menu")


    elseif programState == "menu" then
        button(programData.button.start.w, programData.button.start.h, programData.button.start.x, programData.button.start.y, "game")
        programData.highScores = love.filesystem.read("highscores.sav")
        programData.highScores = tonumber(programData.highScores)


    elseif programState == "game" then
        --Laser blaster cooldown timer
        if laserBlaster.onCoolDown == true then
            if laserBlaster.coolDownTime < laserBlaster.coolDownTimer then
                laserBlaster.coolDownTime = laserBlaster.coolDownTime + love.timer.getDelta()
            elseif laserBlaster.coolDownTime >= laserBlaster.coolDownTimer then
                laserBlaster.coolDownTime = 0
                laserBlaster.onCoolDown = false
            end
        end

        -- Player controls
        if love.keyboard.isDown("down") and player.y < WINDOW_HEIGHT - 30 then
            player.y = player.y + player.spd * love.timer.getDelta()
        elseif love.keyboard.isDown("up") and player.y > 10 then
            player.y = player.y - player.spd * love.timer.getDelta()
        end
        if love.keyboard.isDown("space") and laserBlaster.onCoolDown == false then
            local laser = LASER.new(player.x + 40, player.y + 19)
            table.insert(lasers, laser) -- Insert new laser into lasers table
            laserBlaster.onCoolDown = true
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
                asteroidY = math.random(asteroidY + 100, asteroidY + 130)
                asteroidSpawn = true
            elseif asteroidSpawn == true and asteroidY >= 50 and asteroidY <= WINDOW_HEIGHT - 50 then
                    local asteroid = ASTEROID.new(WINDOW_WIDTH + asteroidWidth + 2, asteroidY)
                    table.insert(asteroids, asteroid)
                    activeAsteroids = activeAsteroids + 1
                    asteroidY = math.random(asteroidY + 100, asteroidY + 130)
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
            if checkCollision(asteroidWidth, asteroidHeight, 62, 46, asteroid.x, asteroid.y, player.x, player.y) == true then
                activeAsteroids = activeAsteroids - 1
                table.remove(asteroids, key2)
                player.HP = player.HP - 1
                if player.HP < 1 then
                    programData.programStatus = "gameOver"
                end
            end
        end
        
        for key, laser in pairs(lasers) do
            if laser.x >= WINDOW_WIDTH then
                table.remove(lasers, key)
            end
            for key2, asteroid in pairs(asteroids) do
                if checkCollision(laserWidth, laserHeight, asteroidWidth, asteroidHeight, laser.x, laser.y, asteroid.x, asteroid.y) == true then
                    table.remove(lasers, key)
                    activeAsteroids = activeAsteroids - 1
                    table.remove(asteroids, key2)
                    updateScore("increase", 1)
                end
            end
        end
    end
end

return{readState = program.readState}