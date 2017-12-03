
-- [Ice Project 2 (2017), turtlesort.com]

local player = require('libtsl.observable').new()
player.x = 0
player.y = 0
player.canMove = true
player.tileMoveTime = 0.22 -- Time it takes to move from one tile to the next
player.direction = 'down'
player.flux = nil


function player.getTileX() -- tile coordinates are 0-indexed!
  return math.floor(player.x / TILE_WIDTH)
end

function player.getTileY() -- tile coordinates are 0-indexed!
  return math.floor(player.y / TILE_WIDTH)
end

function player.setTile(tileX, tileY)
  player.x = (tileX * TILE_WIDTH) + (TILE_WIDTH / 2)
  player.y = (tileY * TILE_HEIGHT) + (TILE_HEIGHT / 2)
end

function player.isMoving()
  if player.flux then return true else return false end
end

function player._movementComplete()

  player.flux = nil -- order of this statement matters

  player.notifyObservers('playermove', {newX = player.getTileX(), newY = player.getTileY()})

  if player.nextMove then
    player.nextMove()
  elseif love.keyboard.isDown('left','a') then
    player.moveLeft()
  elseif love.keyboard.isDown('right','d') then
    player.moveRight()
  elseif love.keyboard.isDown('up','w') then
    player.moveUp()
  elseif love.keyboard.isDown('down','s') then
    player.moveDown()
  end

  player.nextMove = nil -- order of this statement matters

end

function player._canMove(tileX, tileY)
  if player.canMove then  -- canMove (without the underscore) is meant to be defined outside of this table (in the world scene)
    return player.canMove(tileX, tileY)
  else
    return true -- if it's not, we permit any movement
  end
end

function player.moveLeft()
  player.direction = 'left'
  if player._canMove(player.getTileX() - 1, player.getTileY()) then
    player.flux = game.flux.to(player, player.tileMoveTime, {x = player.x - TILE_WIDTH}):ease("linear"):oncomplete(player._movementComplete)
  end
end

function player.moveRight()
  player.direction = 'right'
  if player._canMove(player.getTileX() + 1, player.getTileY()) then
    player.flux = game.flux.to(player, player.tileMoveTime, {x = player.x + TILE_WIDTH}):ease("linear"):oncomplete(player._movementComplete)
  end
end

function player.moveUp()
  player.direction = 'up'
  if player._canMove(player.getTileX(), player.getTileY() - 1) then
    player.flux = game.flux.to(player, player.tileMoveTime, {y = player.y - TILE_WIDTH}):ease("linear"):oncomplete(player._movementComplete)
  end
end

function player.moveDown()
  player.direction = 'down'
  if player._canMove(player.getTileX(), player.getTileY() + 1) then
    player.flux = game.flux.to(player, player.tileMoveTime, {y = player.y + TILE_WIDTH}):ease("linear"):oncomplete(player._movementComplete)
  end
end

function player.update(dt)
  -- animate player sprite
end

function player.draw()
  -- This will eventually handle rendering the player sprite
  love.graphics.setColor(100,255,255)
  love.graphics.circle('fill', math.floor(player.x), math.floor(player.y), 10)
end

function player.keypressed(key, scancode, isrepeat)

  if player.canMove then
    if not player.isMoving() then

      -- From stationary to initial movement to next tile
      if key == 'left' or key == 'a'  then
        player.moveLeft()
      elseif key == 'right' or key =='d' then
        player.moveRight()
      elseif key == 'up' or key == 'w' then
        player.moveUp()
      elseif key == 'down' or key == 's' then
        player.moveDown()
      end
    -- Allow player to queue up another move for better control
    else
      if key == 'left' or key == 'a' then
        player.nextMove = player.moveLeft
      elseif key == 'right' or key =='d' then
        player.nextMove = player.moveRight
      elseif key == 'up' or key == 'w' then
        player.nextMove = player.moveUp
      elseif key == 'down' or key == 's' then
        player.nextMove = player.moveDown
      end
    end

  end -- if player can move
end


return player
