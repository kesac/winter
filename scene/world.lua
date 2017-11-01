
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
local mapManager = require 'libtsl.map-manager'

-- Placeholder variables
world.player = require 'player'
world.entities = {}
world.entities.all = {}
world.entities.current = {}
world.maps = {}
world.maps.all = {}
world.maps.current = {}
world.maps.current.events = {}
world.maps.current.layers = {}
world.maps.current.layers.below = {}
world.maps.current.layers.player = {}
world.maps.current.layers.above = {}

function scene.initialize(manager)
    -- called when this scene is added to a scenemanager
    -- passes the manager as the only argument

    mapManager.cacheMap(require 'maps.prototype', 'prototype')

    world.player.x = 0
    world.player.y = 0
end

function scene.load()
    -- called when the scene becomes the current scene

    -- load all maps

end

function scene.unload()
    -- called when the scene is replaced by another scene
end

function scene.update(dt)
	-- update entities
  world.player.update(dt)
  -- update animations?
end

function scene.draw()
  mapManager.drawMap('prototype')
  -- draw layers below
  -- draw layers at player's level
  world.player.draw()
  -- draw layers above

end

function scene.keypressed(key,unicode)
	-- called when the scene needs to handle a keypressed event
end

function scene.keyreleased(key,unicode)
	-- called when the scene needs to handle a key released event
end

return scene
