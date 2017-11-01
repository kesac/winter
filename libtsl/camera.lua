

-- [Ice Project 2 (2017), turtlesort.com]

--[[
   A primitive camera. Eventually, this will be responsible for:
   * Keeping track of a target entity so it is always centered on screen
   * Gracefully glide towards a desired coordinate
     or map tile
   The camera doesn't render things on its own, but you can use its x,y
   coordinates for world space translations, which has the same effect
   as centering something on screen.
--]]

local camera = {}
camera.x = 0
camera.y = 0
camera._target = nil -- If not nil, it needs to be something with x,y coordinates

function camera.follow(entity)
  if entity and entity.x and entity.y then
    camera._target = entity
  end
end

function camera.reset()
  camera.x = 0
  camera.y = 0
  camera._target = nil
end

function camera.update(dt)
  if camera._target then
    camera.x = -(math.floor(camera._target.x) --[[ + game.player.width/2 --]]) + love.graphics.getWidth()/2
    camera.y = -(math.floor(camera._target.y) --[[ - game.player.height/2 --]]) + love.graphics.getHeight()/2
  end
end

return camera
