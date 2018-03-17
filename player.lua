
-- [Ice Project 2 (2017), turtlesort.com]

local player = require('libtsl.observable').new()
local anim8  = require 'lib.anim8'

player.x = 0
player.y = 0
player.canMove = true
player.tileMoveTime = 0.22 -- Time it takes to move from one tile to the next
player.direction = 'down'
player.flux = nil
player._isSolidTile = nil

player.sprite = {}
player.sprite.image = love.graphics.newImage('gfx/charsets_warrior_bordered_2x.png')
player.sprite.image:setFilter('nearest','nearest')
player.sprite.frameWidth = 32
player.sprite.frameHeight = 36

player.sprite.grid = anim8.newGrid(
  player.sprite.frameWidth,
  player.sprite.frameHeight,
  player.sprite.image:getWidth(),
  player.sprite.image:getHeight(),
  1, --left
  1, --top
  1 --border
)

player.sprite.standing = {
  up = anim8.newAnimation(player.sprite.grid(2,1),1),
  right = anim8.newAnimation(player.sprite.grid(2,2),1),
  down = anim8.newAnimation(player.sprite.grid(2,3),1),
  left = anim8.newAnimation(player.sprite.grid(2,4),1)
}

player.sprite.moving = {
  up = anim8.newAnimation(player.sprite.grid('1-3',1, 2,1),0.15),
  right = anim8.newAnimation(player.sprite.grid('1-3',2, 2,2),0.15),
  down = anim8.newAnimation(player.sprite.grid('1-3',3, 2,3),0.15),
  left = anim8.newAnimation(player.sprite.grid('1-3',4, 2,4),0.15)
}

-- Events received from other game components
function player.notify(event, values)
  if event == 'mapchange' then
    player._isSolidTile = values.isSolidTile
  end
end

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

  player.notifyObservers('playermove', {tileX = player.getTileX(), tileY = player.getTileY()})

  if player.canMove then
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
  end

  player.nextMove = nil -- order of this statement matters

end

function player._canMove(tileX, tileY)
  if player._isSolidTile then  -- canMove (without the underscore) is meant to be defined outside of this table (in the world scene)
    return not player._isSolidTile(tileX, tileY)
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

function player.interact()

  local args = {}

  if player.direction == 'up' then
    args.tileX = player.getTileX()
    args.tileY = player.getTileY() - 1
  elseif player.direction == 'down' then
    args.tileX = player.getTileX()
    args.tileY = player.getTileY() + 1
  elseif player.direction == 'right' then
    args.tileX = player.getTileX() + 1
    args.tileY = player.getTileY()
  elseif player.direction == 'left' then
    args.tileX = player.getTileX() - 1
    args.tileY = player.getTileY()
  end

  player.notifyObservers('playerinteract', args)

end

function player.update(dt)
  -- animate player sprite
  if player.isMoving() then
    if player.sprite.moving[player.direction] then
      player.sprite.moving[player.direction]:update(dt)
    end
  end

end

function player.draw()
  -- This will eventually handle rendering the player sprite

  love.graphics.setColor(255,255,255)
  if player.isMoving() then
    if player.sprite.moving[player.direction] then
      player.sprite.moving[player.direction]:draw(player.sprite.image, math.floor(player.x - 16), math.floor(player.y - 18 - 2))
    end
  else
    if player.sprite.standing[player.direction] then
      player.sprite.standing[player.direction]:draw(player.sprite.image, math.floor(player.x - 16), math.floor(player.y - 18 - 2))
    end
  end

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
      elseif key == 'space' or key == 'enter' then
        player.interact()
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
