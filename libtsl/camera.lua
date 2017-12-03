

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
camera.x = 0
camera.y = 0
camera.scale = 1.0
camera._targetEntity = nil

-- These should be the value of the game canvas dimensions,
-- which is expected not to change even if the window is
-- is resized.
camera.screenWidth = 800
camera.screenHeight = 600

-- The camera will try its best to "stay" within the map
-- if it knows the dimensions of the map. This ensures that
-- nothing beyond a maps edges is showed on screen.
camera.stayInMapBounds = true
camera.mapWidth = nil
camera.mapHeight = nil

function camera.notify(event, values)
  if event == 'mapsizechange' then
    camera.mapWidth = values.width
    camera.mapHeight = values.height
  end

end

function camera.move(targetX, targetY)
  if targetX and targetY then
    camera._targetEntity = nil
    game.flux.to(camera, 1, {x = targetX + camera.screenWidth/2, y = targetY + camera.screenHeight/2}):ease("quadout")
  end
end

function camera.follow(entity)
  if entity and entity.x and entity.y then
    camera._targetEntity = entity
  end
end

function camera.zoom(targetScale)
    if targetScale and camera.scale ~= targetScale then
      game.flux.to(camera, 1, {scale = targetScale}):ease("quadout")
    end
end

function camera.update(dt)
  if camera._targetEntity then
    camera.x = math.floor(-(math.floor(math.floor(camera._targetEntity.x)*camera.scale)) + camera.screenWidth/2)
    camera.y = math.floor(-(math.floor(math.floor(camera._targetEntity.y)*camera.scale)) + camera.screenHeight/2)

    if camera.stayInMapBounds then
      if camera._targetEntity.y < camera.screenHeight/2 then camera.y = 0 end
      if camera._targetEntity.x < camera.screenWidth/2 then camera.x = 0 end

      if camera.mapHeight and camera.mapWidth then
        if camera._targetEntity.y > camera.mapHeight - camera.screenHeight/2 then camera.y = -camera.mapHeight + camera.screenHeight end
        if camera._targetEntity.x > camera.mapWidth - camera.screenWidth/2 then camera.x = -camera.mapWidth + camera.screenWidth end
      end
    end
  end
end

return camera
