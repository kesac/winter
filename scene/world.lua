
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
world.camera = require 'libtsl.camera'
world.maps = require 'libtsl.map-manager'
world.player = require 'player'

--[[]]
world.player.canMove = function(tileX, tileY) -- overrides existing function
  return not world.maps.isCollidable(tileX, tileY)
end
--]]

world.entities = {}
world.entities.all = {}
world.entities.current = {}

function scene.initialize(manager)
    world.maps.loadTileset('meta-tileset', 'maps/tilesets/meta-tileset.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('overworld-tileset', 'maps/tilesets/overworld-tileset.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('overworld-mountains', 'maps/tilesets/overworld-mountains.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.loadTileset('overworld-water', 'maps/tilesets/overworld-water.png', TILE_WIDTH, TILE_HEIGHT)
    world.maps.defineTileAnimation('overworld-water', 1, 1, 15)
    world.maps.loadMap('prototype', require 'maps.prototype')
    world.maps.setCurrentMap('prototype')
end

function scene.load()
    world.player.setTile(0, 0)
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

  love.graphics.push()
  love.graphics.translate(world.camera.x, world.camera.y)
  love.graphics.scale(world.camera.scale)
  world.maps.draw()
  world.player.draw()
  love.graphics.pop()

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
