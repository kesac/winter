
-- [Ice Project 2 (2017), turtlesort.com]

local player = {}
player.x = 0
player.y = 0
player.canMove = true
player.isMoving = false -- Used receive one directional button action at a time
player.speed = 100
player.direction = 'down'

-- This will eventually handle player input, collision, sprite state,
-- world interaction, and notifying observers of events.
function player.update(dt)

  player.isMoving = false

  if player.canMove then
  		if not player.isMoving and love.keyboard.isDown('left','a') then
  			player.x = player.x - dt * player.speed -- Move left
  			player.direction = 'left'
  			player.isMoving = true
  		end

  		if not player.isMoving and love.keyboard.isDown('right','d') then
  			player.x = player.x + dt * player.speed
  			player.direction = 'right'
  			player.isMoving = true
  		end

  		if love.keyboard.isDown('up','w') then
  			player.y = player.y - dt * player.speed
  			player.direction = 'up'
  			player.isMoving = true
  		end

  		if love.keyboard.isDown('down','s') then
  			player.y = player.y + dt * player.speed
  			player.direction = 'down'
  			player.isMoving = true
  		end
  	end

end

-- This will eventually handle rendering the player sprite
function player.draw()
  love.graphics.setColor(100,255,255)
  love.graphics.circle('fill', player.x, player.y, 5, 10)
end

function player.keypressed(key, scancode, isrepeat)

end


return player
