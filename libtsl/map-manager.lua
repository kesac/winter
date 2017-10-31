
-- [Ice Project 2 (2017), turtlesort.com]

--[[
  The map manager is responsible for:
  * Loading and storing maps exported from Tiled (expected format: lua with csv tile data)
  * Caching tilesets declared in maps (through tileset-manager)
  * Rendering map data on screen
--]]

local manager  = {}
local maps     = {}
local tileMath = require 'libtsl.tile-math'
local tilesetManager = require 'libtsl.tileset-manager'
tilesetManager.mapsFolder = 'maps/'

-- 'data' is expected to be the contents of a Tiled map
-- exported into lua format. (ie. 'require' was called on
-- the exported lua file and the resulting table was passed)
--
-- 'id' is the desired identifier for the map.
function manager.addMap(data, id)

  local map = {}
  map.id = id
  map.tileColumns = data.width
  map.tileRows = data.height
  map.tileWidth = data.tilewidth   -- Warning: tileWidth vs tilewidth (the first
                                   -- adheres to source code naming conventions, the
                                   -- second is used by Tiled)
  map.tileHeight = data.tileheight
  map.layers = {}

  -- We only capture information required to
  -- calculate quads on the tileset image
  for _,d in pairs(data.tilesets) do
    if not tilesetManager.hasTileset(d.image) then
      tilesetManager.defineTileset(d.image, d.imagewidth, d.imageheight, map.tileWidth, map.tileHeight)

      map.tilesetImagePath = d.image -- WARNING: This is a hack until we can add support for multiple tilesets per map
    end
  end

  -- We only capture information required to
  -- draw each layer of the map. The order of layers
  -- defined within the Tiled map matters!
  for _,l in pairs(data.layers) do

    local layer = {}
    layer.name = l.name             -- so layer 'player' can be identified
    layer.type = l.type             -- only type 'tilelayer' can get drawn
    layer.properties = l.properties -- to parse triggers and events
    layer.data = l.data             -- this is expected to be a list of tile
                                    --   indexes that can be used to select
                                    --   the exact quad on the tileset image

    table.insert(map.layers, layer)
  end

  maps[id] = map

end


function manager.drawMap(id)

  if maps[id] then
    local map = maps[id]

    for i = 1, #map.layers do
      local layer = map.layers[i]

      if layer.type == 'tilelayer' then
        for j = 1, #layer.data do
          local drawX = map.tileWidth  * tileMath.tileIndexToColumn(j, map.tileColumns)
          local drawY = map.tileHeight * tileMath.tileIndexToRow(j, map.tileColumns)
          local tilesetIndex = layer.data[j]

          if tilesetIndex ~= 0 then
            local imagePath = map.tilesetImagePath -- WARNING: This is a hack until we can add support for multiple tilesets per map
            tilesetManager.drawTile(imagePath, tilesetIndex, drawX, drawY)
          end

        end -- map tiles
      end -- if drawable
    end -- layers
  end -- if map exists

end

return manager
