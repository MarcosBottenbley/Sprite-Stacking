function love.load()
    love.window.setFullscreen(true)
    windowXLength, windowYLength = love.graphics.getDimensions()
    cameraX = windowXLength/2
    cameraY = windowYLength/2
    cameraZoom = 2
    isometricTransform = love.math.newTransform(cameraX, cameraY, 45 * (math.pi/180), cameraZoom, cameraZoom, 0, 0, -0.5, -0.5)
    rectWidth = 16
    rectHeight = 16
    gridYLength = 10
    gridXLength = 10
    gridXOrigin = 1
    gridYOrigin = 1
    gridDepth = 16
    love.graphics.setDefaultFilter('nearest', 'nearest')
    sprite = love.graphics.newImage('sprites/test.png')
    playerSprite = love.graphics.newImage('sprites/test_player.png')
    blockSprite = love.graphics.newImage('sprites/block.png')
    playerX, playerY = gridCoordToScreenCoord(0,0)
    playerRotation = 0
    mouseX = 0
    mouseY = 0
    targetX = playerX
    targetY = playerY
end

function gridCoordToScreenCoord(gx, gy)
    return ((gx * rectWidth) + (rectWidth/2)), ((gy * rectHeight) + (rectHeight/2))
end

function screenCoordToGridCoord(sx,sy)
    return ((sx-(rectWidth/2))/rectWidth),((sy-(rectHeight/2))/rectHeight)
end

function love.update(dt)
    setGridToIsometric()
    mouseX, mouseY = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
    love.graphics.origin()
    local x = 0.5
    local y = 0.5
    if love.mouse.isDown(1) then
        targetX = mouseX
        targetY = mouseY
    end
    if math.floor(playerX) ~= math.floor(targetX) then
        playerX = (1-dt) * playerX + dt * targetX
    end
    if math.floor(playerY) ~= math.floor(targetY) then
        playerY = (1-dt) * playerY + dt * targetY
    end
    if love.keyboard.isDown('escape') then
        love.window.close()
    end
    if love.keyboard.isDown('a') then
        cameraX = cameraX + 100 * dt
    end
    if love.keyboard.isDown('d') then
        cameraX = cameraX - 100 * dt
    end
    if love.keyboard.isDown('w') then
        cameraY = cameraY + 100 * dt
    end
    if love.keyboard.isDown('s') then
        cameraY = cameraY - 100 * dt
    end

    -- Moves the camera
    isometricTransform = love.math.newTransform(
        cameraX,
        cameraY,
        45 * (math.pi/180),
        cameraZoom,
        cameraZoom,
        (gridXLength/2)*rectWidth,
        (gridYLength/2)*rectHeight,
        -0.5,
        -0.5
    )
end

function love.wheelmoved(x,y)
    cameraZoom = cameraZoom + y * 0.1
end

function love.draw()
    love.graphics.setBackgroundColor(0,0,1)
    gMouseX, gMouseY = gridCoordToScreenCoord(mouseX, mouseY)
    love.graphics.print('ISOmouseX: ' .. mouseX .. ' ISOmouseY: ' .. mouseY, 10, 10)
    love.graphics.print('mouseX: ' .. gMouseX .. ' mouseY: ' .. gMouseY, 10, 25)
    love.graphics.print('playerX: ' .. playerX .. ' playerY: ' .. playerY, 10, 40)
    love.graphics.print('playerRotation: ' .. playerRotation, 10, 55)
    --drawGrid()
    playerRotation = math.atan2(targetY - playerY, targetX - playerX)
    setGridToIsometric()
    drawGridSides()
    --drawISOCoords()
    love.graphics.circle('line', mouseX, mouseY, 10)
    love.graphics.setColor(1,1,0)
    love.graphics.circle('line', targetX, targetY, 10)
    love.graphics.setColor(1,1,1)
    for p = 0, 16, 1 do
        love.graphics.draw(playerSprite, playerX-p, playerY-p, playerRotation, 1, 1, 8, 8)
    end
    love.graphics.line(playerX, playerY, targetX, targetY)
    love.graphics.origin()
    love.graphics.getWidth()
    love.graphics.setColor(1,1,1)
end

function drawGridSides()
    for offset = 0, gridDepth, 1 do
        for x = gridXOrigin, gridXOrigin + gridXLength - 1, 1 do
            for y = gridYOrigin, gridYOrigin + gridYLength - 1, 1 do
                love.graphics.draw(sprite, x*rectWidth-offset, y*rectHeight-offset, 0, 1, 1, 0, 0)
            end
        end
    end
end

function drawGrid()
    for x = 0, gridXLength - 1, 1 do
        for y = 0, gridYLength - 1, 1 do
            offset = 0
            transform = love.math.newTransform(
                x * 0.5 * 32 + y * -0.5 * 32,
                x * 0.25 * 32 + y * 0.25 * 32,
                0,
                1,
                1,
                -windowYLength/2,
                -windowXLength/2
            )
            love.graphics.draw(blockSprite, transform)
        end
    end
end

function drawISOCoords()
    love.graphics.setColor(1,0,0)
    for x = 0, 100, 1 do
        for y = 0, 100, 1 do
            love.graphics.rectangle('line', x * 16, y * 16, 16, 16)
        end
    end
    love.graphics.setColor(1,1,1)
end

function setGridToIsometric()
    --local rotationAngle = 45
    --local rotationAngleRadians = rotationAngle * (math.pi/180)
    --love.graphics.rotate(rotationAngleRadians)
    --love.graphics.shear(-0.5, -0.5)
    love.graphics.applyTransform(isometricTransform)
end