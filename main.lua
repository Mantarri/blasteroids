local LASER = require("laser")
local ASTEROID = require("asteroid")
local PROGRAM = require("program")
savedScore = love.filesystem.read("highscores.sav")
savedScore = tonumber(savedScore)
asteroidSpeed = 90

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    menuFont = love.graphics.newFont("/resources/Mister Pixel Regular.ttf", 34)
    menuFont:setFilter( "nearest", "nearest")
    gameFont = love.graphics.newFont("/resources/Mister Pixel Regular.ttf", 26)
    gameFont:setFilter( "nearest", "nearest")
    WINDOW_HEIGHT = love.graphics.getHeight()
    WINDOW_WIDTH = love.graphics.getWidth()

    programData = {}
    programData.menuTransition = false
    programData.menuTransitionTimer = 0
    programData.highScores = 0
    programData.programStatus = "menu"
    programData.mouse = {x = 0, y = 0, isHeld = false}
    programData.button = {
    start = {x = WINDOW_WIDTH / 2 - 140, y = 80, w = 196, h = 64, textContent = "Start Game", textColour = "black"},
    mainMenu = {x = WINDOW_WIDTH / 2 - 140, y = 196, w = 196, h = 64, textContent = "Main Menu", textColour = "black"},
    waitingForRelease = false,
    image = love.graphics.newImage("/resources/sprites/button.png")}
    programData.background = {image = love.graphics.newImage("/resources/sprites/background.png"), x = 0, y = 0}
    programData.headerImage = love.graphics.newImage("/resources/sprites/header.png")
    

    

    player = {}
    player.x = 20
    player.y = WINDOW_HEIGHT / 2 - 25
    player.spd = 225 -- Set player speed
    player.shipImage = love.graphics.newImage("/resources/sprites/ship.png")
    player.HP = 3
    player.HPImage = love.graphics.newImage("/resources/sprites/hp.png")
    HP3 = love.graphics.newQuad(0, 0, 8, 8, player.HPImage:getDimensions())
    HP2 = love.graphics.newQuad(8, 0, 8, 8, player.HPImage:getDimensions())
    HP1 = love.graphics.newQuad(16, 0, 8, 8, player.HPImage:getDimensions())
    player.score = 0
    player.sessionScore = 0

    lasers = {} -- Initialize an empty table to store lasers in
    laserSprite = love.graphics.newImage("/resources/sprites/lazer.png")
    laserWidth = 14
    laserHeight = 5

    asteroids = {}
    asteroidY = 0
    asteroidWidth = 48
    asteroidHeight = 48
    activeAsteroids = 0
    asteroidSprite = love.graphics.newImage("/resources/sprites/asteroid.png")

    -- Functions

    function resetGame()
        asteroids = {}
        asteroidY = 0
        activeAsteroids = 0
        asteroidSpeed = 90

        lasers = {}

        player.HP = 3
        player.score = 0
        player.sessionScore = 0
    end

    function getAsteroidSpeed()
        return asteroidSpeed
    end

    function updateScore(mode, amount)
        if mode == "increase" then
            player.score = player.score + amount
        elseif mode == "decrease" and player.score > 0 then
            player.score = player.score - amount
        elseif mode == nil or amount == nil then
            print("ERROR: missing argument(s) for updateScore function")
        end
    end
    love.filesystem.read("highscores.sav")
    function checkCollision(w1, h1, w2, h2, x1, y1, x2, y2)
        if x1 > x2 + w2 - 1 or
        y1 > y2 + h2 - 1 or
        x2 > x1 + w1 - 1 or
        y2 > y1 + h1 - 1
        then
            return false
        else
            return true
        end
    end

    function buttonClicked(w1, h1, x1, y1, x2, y2)
        if x2 > x1 and
        x2 < x1 + w1 and
        y2 > y1 and
        y2 < y1 + h1
        then
            return true
        else
            return false
        end
    end

    function love.mousepressed(x2, y2, button)
        programData.mouse.isHeld = true
    end

    function love.mousereleased(x, y, button)
        programData.mouse.isHeld = false
    end

    function button(w, h, x, y, changeToMenu)
        programData.mouse.x, programData.mouse.y = love.mouse.getPosition()
        if programData.mouse.isHeld == false and programData.button.waitingForRelease == true then
            programData.programStatus = changeToMenu
            programData.button.waitingForRelease = false
        end
    end

    function buttonDraw(x, y, textContent, textColour)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(programData.button.image, x, y)
        if textColour == "white" then
            love.graphics.setColor(1, 1, 1)
        elseif textColour == "black" then
            love.graphics.setColor(0, 0, 0)
        elseif textColour == "red" then
            love.graphics.setColor(1, 0, 0)
        elseif textColour == "green" then
            love.graphics.setColor(0, 1, 0)
        elseif textColour == "blue" then
            love.graphics.setColor(0, 0, 1)
        end
        love.graphics.print(textContent, x + 8, y + 12)
    end
end

function love.update(dt)
    if programData.background.x > -800 then
        programData.background.x = programData.background.x - .5
    elseif programData.background.x <= 0 then
        programData.background.x = 0
    end
    -- Create save file if it doesn't exist
    if savedScore < 0 then
        love.filesystem.write("highscores.sav", 0)
    end

    -- Game Over
    if programData.programStatus == "gameOver" then
        PROGRAM.readState("gameOver")
        if programData.mouse.isHeld == true then
            programData.mouse.x, programData.mouse.y = love.mouse.getPosition()
            if buttonClicked(programData.button.mainMenu.w, programData.button.mainMenu.h, programData.button.mainMenu.x, programData.button.mainMenu.y, programData.mouse.x, programData.mouse.y) == true then
                programData.button.waitingForRelease = true
            end
        end


    -- Main Menu
    elseif programData.programStatus == "menu" then
        PROGRAM.readState("menu")
        if programData.mouse.isHeld == true then
            programData.mouse.x, programData.mouse.y = love.mouse.getPosition()
            if buttonClicked(programData.button.start.w, programData.button.start.h, programData.button.start.x, programData.button.start.y, programData.mouse.x, programData.mouse.y) == true then
                programData.button.waitingForRelease = true
            end
        end


    -- Active Game Loop
    elseif programData.programStatus == "game" then
        PROGRAM.readState("game")
    end
end


function love.draw()
    love.graphics.draw(programData.background.image, programData.background.x, 0)
    love.graphics.setBackgroundColor(.10588235294, .12156862745, .1294117647)
    love.graphics.setFont(menuFont)

    --Game over
    if programData.programStatus == "gameOver" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Game over", WINDOW_WIDTH / 2 - 120, 80)
        love.graphics.print("Score: " .. player.sessionScore, WINDOW_WIDTH / 2 - 120, 120)
        buttonDraw(programData.button.mainMenu.x, programData.button.mainMenu.y, programData.button.mainMenu.textContent, programData.button.mainMenu.textColour)
    end

    --Main Menu
    if programData.programStatus == "menu" then
        buttonDraw(programData.button.start.x, programData.button.start.y, programData.button.start.textContent, programData.button.start.textColour)
        love.graphics.setColor(1, 1, 1)
        if savedScore > 0 then
            local showScore = love.filesystem.read("highscores.sav")
            love.graphics.print("High score is " .. showScore, WINDOW_WIDTH / 2 - 150, 32)
        elseif savedScore <= 0 then
            love.graphics.print("No recorded high score", WINDOW_WIDTH / 2 - 200, 32)
        end
    end

    --Game
    if programData.programStatus == "game" then
        love.graphics.draw(programData.headerImage, 0, 0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(gameFont)
        love.graphics.print("Score: " .. player.score, 60, 10)

        -- Asteroids
        for _, asteroid in pairs(asteroids) do
            love.graphics.draw(asteroidSprite, asteroid.x, asteroid.y, 0, 2)
        end

        -- Lasers
        for _, laser in pairs(lasers) do
            love.graphics.draw(laserSprite, laser.x, laser.y, 0, 2)
        end

        -- Player ship
        love.graphics.draw(player.shipImage, player.x, player.y, 0, 2)
        if player.HP == 3 then
            love.graphics.draw(player.HPImage, HP3, 8, 4, 0, 4)
        elseif player.HP == 2 then
            love.graphics.draw(player.HPImage, HP2, 8, 4, 0, 4)
        elseif player.HP == 1 then
            love.graphics.draw(player.HPImage, HP1, 8, 4, 0, 4)
        end
    end
end
