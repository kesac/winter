
-- [Ice Project 2 (2017), turtlesort.com]

--[[
  The tileset manager is responsible for:
  * Caching tilesets declared in maps
  * Calculating and building quads given the path
    to an image and the dimensions of tiles and tileset
  * Rendering a specific tile of a tileset given the
    desired tile index
--]]


local manager = {}
manager.mapsFolder = nil

local tileMath = require 'libtsl.tile-math'
local tilesets = {}

-- Here the image path of the tileset image relative to the map file it is used in.
function manager.defineTileset(imagePath, imageWidth, imageHeight, tileWidth, tileHeight)
  local tileset = {}

  tileset.image = love.graphics.newImage(manager.mapsFolder .. imagePath)
  tileset.imagePath = imagePath
  tileset.imageWidth = imageWidth
  tileset.imageHeight = imageHeight
  tileset.tileWidth = tileWidth
  tileset.tileHeight = tileHeight

  tileset.quads = {} -- These are partitions of the tileset that correspond to a single tile

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
    table.insert(tileset.quads, quad);
  end

  tilesets[imagePath] = tileset
end

-- The tile index is expected to be 1-indexed due to Tiled
-- (ie. the value is expected to be 1 or greater)
-- Tiled uses the value 0 to denote no tile at that position
function manager.drawTile(imagePath, tileIndex, x, y)

  local tileset = tilesets[imagePath]
  -- Does the desired tileset exist?
  -- Is the desired tileIndex within the dimensions of the tileset?
  if tileset and tileIndex >= 1 and tileIndex <= #tileset.quads then
    love.graphics.draw(tileset.image, tileset.quads[tileIndex], x, y)
  end
end

function manager.hasTileset(imagePath)
  if tilesets[imagePath] then return true
  else return false end
end

return manager
