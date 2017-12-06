

-- [Ice Project 2 (2017), turtlesort.com]

--[[
   A primitive camera responsible for:
   * Keeping track of a target entity so it is always centered on screen
   * Gracefully glide towards a desired coordinate
     or map tile

   The camera doesn't render things on its own, but you can use its x,y
   coordinates for world space translations, which has the same effect
   as centering something on screen.

   Dependencies: flux
--]]

local camera = {}
camera.xTranslation = 0
camera.yTranslation = 0
camera.scale = 1.0
camera._targetEntity = nil

-- These should be the value of the game canvas dimensions,
-- which is expected not to change even if the window is
-- is resized.
camera.screenWidth = GAME_CANVAS_WIDTH
camera.screenHeight = GAME_CANVAS_HEIGHT

-- The camera will try its best to "stay" within the map
-- if it knows the dimensions of the map. This ensures that
-- nothing beyond a maps edges is showed on screen.
camera.stayInMapBounds = true
camera.mapWidth = nil
camera.mapHeight = nil

-- Events received from other game components
function camera.notify(event, values)
  if event == 'mapchange' then
    camera.mapWidth = values.width
    camera.mapHeight = values.height
  end
end

-- Call this before the draw routine
function camera.start()
  love.graphics.push()
  love.graphics.translate(camera.xTranslation, camera.yTranslation)
  love.graphics.scale(camera.scale)
end

-- Call this after the end of the draw routine
function camera.stop()
  love.graphics.pop()
end

-- Smoothly moves to the desired x,y coordinates
function camera.move(targetX, targetY)
  if targetX and targetY then
    camera._targetEntity = nil
    game.flux.to(camera, 1, {xTranslation = targetX + camera.screenWidth/2, yTranslation = targetY + camera.screenHeight/2}):ease("quadout")
  end
end

-- Centers on the entity described by the specified table.
-- The table must have 'x' and 'y' defined
function camera.follow(entity)
  if entity and entity.x and entity.y then
    camera._targetEntity = entity
  end
end

-- Smoothly zooms in and out to the desired scale
function camera.zoom(targetScale)
    if targetScale and camera.scale ~= targetScale then
      game.flux.to(camera, 1, {scale = targetScale}):ease("quadout")
    end
end

function camera.update(dt)
  if camera._targetEntity then
    camera.xTranslation = math.floor(-(math.floor(math.floor(camera._targetEntity.x)*camera.scale)) + camera.screenWidth/2)
    camera.yTranslation = math.floor(-(math.floor(math.floor(camera._targetEntity.y)*camera.scale)) + camera.screenHeight/2)

    if camera.stayInMapBounds then

      -- Left and top map border
      if camera._targetEntity.x < camera.screenWidth/2/camera.scale then
        camera.xTranslation = 0
      end
      if camera._targetEntity.y < camera.screenHeight/2/camera.scale then
        camera.yTranslation = 0
      end

      -- Right and bottom map border
      if camera.mapHeight and camera.mapWidth then
        if camera._targetEntity.x > camera.mapWidth - camera.screenWidth/2/camera.scale then
          camera.xTranslation = -(camera.mapWidth*camera.scale - camera.screenWidth)
        end
        if camera._targetEntity.y > camera.mapHeight - camera.screenHeight/2/camera.scale then
          camera.yTranslation = -(camera.mapHeight*camera.scale - camera.screenHeight)
        end
      end

    end -- stayInMapBounds
  end -- camera._targetEntity
end

return camera
