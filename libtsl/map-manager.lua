
-- [Ice Project 2 (2017), turtlesort.com]

--[[
  The map manager is responsible for:
  * Processing and caching maps exported from Tiled (expected format: lua with csv tile data)
  * Caching tilesets declared in maps
  * Calculating and building quads given the path
    to an image and the dimensions of tiles and tileset
  * Rendering a specific tile of a tileset given the
    desired tile index
  * Rendering map data on screen
--]]

local lib      = {}
local maps     = {}
local tilesetRenderCache = {} -- Each entry is a table containing: loaded image and quads for that image

local tileMath = require 'libtsl.tile-math'
lib.mapsFolder = 'maps/'

-- 'data' is expected to be the contents of a Tiled map
-- exported into lua format. (ie. 'require' was called on
-- the exported lua file and the resulting table was passed)
--
-- 'id' is the desired identifier for the map.
function lib.cacheMap(data, id)

  local map = {}
  map.id = id
  map.tileColumns = data.width
  map.tileRows = data.height
  map.tileWidth = data.tilewidth   -- Warning: tileWidth vs tilewidth (the first
                                   -- adheres to source code naming conventions, the
                                   -- second is used by Tiled)
  map.tileHeight = data.tileheight

  map.tileset = {}
  map.layers = {}

  -- We only capture information required to
  -- calculate quads on the tileset image.
  -- The order of the tilesets matters.
  for _,ts in pairs(data.tilesets) do

    local tileset = {}
    tileset.imagePath = ts.image
    tileset.firstTileIndex = ts.firstgid
    table.insert(map.tileset, tileset)

    if not lib._isTilesetImageCached(tileset.imagePath) then
      -- This also gets quads calculated. Cache results are placed in tilesetRenderCache.
      lib._cacheTilesetImage(tileset.imagePath, ts.imagewidth, ts.imageheight, map.tileWidth, map.tileHeight)
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


-- Here imagePath is relative to the map file the tileset is used in.
-- This function loads the specified tileset image into memory then
-- calculates the quads for each tile in the tileset.
function lib._cacheTilesetImage(imagePath, imageWidth, imageHeight, tileWidth, tileHeight)

  local tilesetRenderData = {}
  tilesetRenderData.image = love.graphics.newImage(lib.mapsFolder .. imagePath)
  tilesetRenderData.quads = {} -- These are partitions of the tileset that correspond to a single tile

  local totalColumns = imageWidth/tileWidth
  local totalRows = imageHeight/tileHeight
  local totalTiles = totalColumns * totalRows

  -- Quads are pre-calculated to line up with tileset indexes for the tileset
  -- (Given a 3x3 tileset, index 1 is always the top-left most tile and index 9 is the
  -- bottom-right most tile)
  for i = 1, totalTiles do
    local x = tileMath.tileIndexToColumn(i, totalColumns) * tileWidth
    local y = tileMath.tileIndexToRow(i, totalColumns) * tileHeight -- that is not a typo: we need the number of columns to determine tile row
    local quad = love.graphics.newQuad(x, y, tileWidth, tileHeight, imageWidth, imageHeight)
    table.insert(tilesetRenderData.quads, quad);
  end

  tilesetRenderCache[imagePath] = tilesetRenderData
end

function lib._isTilesetImageCached(imagePath)
  if tilesetRenderCache[imagePath] then return true
  else return false end
end

-- The tile index is expected to be 1-indexed due to Tiled
-- (ie. the value is expected to be 1 or greater)
-- Tiled uses the value 0 to denote no tile at that position
function lib._drawTile(imagePath, tileIndex, x, y)

  local tilesetRenderData = tilesetRenderCache[imagePath]
  -- Does the desired tileset exist?
  -- Is the desired tileIndex within the dimensions of the tileset?
  if tilesetRenderData and tileIndex >= 1 and tileIndex <= #tilesetRenderData.quads then
    love.graphics.draw(tilesetRenderData.image, tilesetRenderData.quads[tileIndex], math.floor(x), math.floor(y))
  end
end


-- If there are multiple tilesets in use on a single map
-- then some of the tileset indexes used will have an offset.
-- This function returns the tileset image path to use and
-- the true tileset index.
function lib._findTileset(map, tilesetIndex)
  for i = #map.tileset, 1, -1 do
    if tilesetIndex >= map.tileset[i].firstTileIndex then
      return map.tileset[i].imagePath, (tilesetIndex - map.tileset[i].firstTileIndex + 1)
    end
  end

  return nil, 0
end

function lib.drawMap(id)

  love.graphics.setColor(255,255,255,255)

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
            local imagePath, imageTilesetIndex = lib._findTileset(map, tilesetIndex)
            -- TODO: Check if animated tile?
            lib._drawTile(imagePath, imageTilesetIndex, drawX, drawY)
          end

        end -- for map tiles
      end -- if drawable
    end -- for layers
  end -- if map exists

end

return lib
