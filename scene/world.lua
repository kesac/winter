
-- [Ice Project 2 (2017), turtlesort.com]

--[[
  The world scene is responsible for:
  * Drawing maps
  * Updating and drawing entities, including the player
  * Collision and keeping entities inside map dimensions
  * Events between the player and the map or other entities
--]]

local scene = {}
local world = {}
local sceneManager = nil

world.maps = require 'libtsl.map-manager'
world.player = require 'player'
world.camera = require 'camera'

world.maps.addObserver(world.camera)
world.maps.addObserver(world.player)
world.player.addObserver(scene)

game.textbox.preDisplayText = function() world.player.canMove = false end
game.textbox.postDisplayText = function() world.player.canMove = true end

world.entities = {}
world.entities.all = {}
world.entities.current = {}


-- Events received from other game components
function scene.notify(event, values)

  if event == 'playermove' or event == 'playerinteract' then
    local tileEvents = world.maps.getTileEvents(values.tileX, values.tileY, event)
    for _, tileEvent in pairs(tileEvents) do
      if tileEvent['WarpTo'] then scene.tileEventWarpTo(tileEvent['WarpTo']) end
      if tileEvent['Call'] then scene.tileEventCall(tileEvent['Call']) end
    end -- for tileEvent
  end -- if event
end

function scene.tileEventWarpTo(warpToArgs)
  local args = game.utf8.split2(warpToArgs, ' ')
  local mapId = args[1]
  local tileX = tonumber(args[2])
  local tileY = tonumber(args[3])

  -- yes world scene is transitioning to itself
  -- so there is a fade out and back in to cover
  -- map and player location change
  world.player.canMove = false
  sceneManager.transitionTo('world', function()
    world.maps.setCurrentMap(mapId)
    world.player.setTile(tileX, tileY)
    world.player.canMove = true
  end)
end

function scene.tileEventCall(callArgs)
  local args = game.utf8.split2(callArgs, ' ')

  local mapScript = world.maps.getMapScript()
  if mapScript and args[1] and mapScript[args[1]] then
    mapScript[args[1]]()
  end

end

function scene.initialize(manager)

    sceneManager = manager

    world.maps.loadTileset('meta-tileset', 'maps/tilesets/meta-tileset.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('gb-1-main', 'maps/tilesets/gb-1-main.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('gb-3-flora', 'maps/tilesets/gb-3-flora.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('gb-5-waterfall', 'maps/tilesets/gb-5-waterfall.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('gb-7-outdoor', 'maps/tilesets/gb-7-outdoor.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('gb-8-cave', 'maps/tilesets/gb-8-cave.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('overworld-tileset', 'maps/tilesets/overworld-tileset.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('overworld-mountains', 'maps/tilesets/overworld-mountains.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('overworld-water', 'maps/tilesets/overworld-water.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.defineTileAnimation('overworld-water', 1, 1, 15)
    world.maps.loadMap('prototype', require 'maps.prototype')
    world.maps.loadMap('prototype2', require 'maps.prototype2')
    world.maps.loadMapScript('prototype2', require 'maps.prototype2-script')
    world.maps.setCurrentMap('prototype2')
end

function scene.load()
    world.player.setTile(1,1)
    world.camera.follow(world.player)
    love.graphics.setDefaultFilter('nearest', 'nearest')
end

function scene.unload()
    -- called when the scene is replaced by another scene
end

function scene.update(dt)

	-- update entities
  world.maps.update(dt)
  world.player.update(dt)
  -- update animations?
  world.camera.update(dt)
end

function scene.draw()
  world.camera.start()
  world.maps.drawBelow()
  world.player.draw()
  world.maps.drawAbove()
  world.camera.stop()
end

function scene.keypressed(key,unicode)
	-- called when the scene needs to handle a keypressed event
  if DEBUG_MODE then print('scene.keypressed: player is currently at (x,y): ' .. world.player.x .. ',' .. world.player.y) end
  world.player.keypressed(key,unicode)

  if key == "1" then
    world.camera.zoom(1)
  elseif key == "2" then
    world.camera.zoom(1.5)
  elseif key == "3" then
    world.camera.zoom(4)
  elseif key == "4" then
    world.camera.move(0,0)
  elseif key == "5" then
    world.camera.follow(world.player)
  end

end

function scene.keyreleased(key,unicode)
	-- called when the scene needs to handle a key released event
end

return scene
