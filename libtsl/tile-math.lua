
-- [Ice Project 2 (2017), turtlesort.com]

--[[
  This file defines convenience functions for mapping
  tile indexes to tile coordinates and vice versa.

  Tile coordinates are 0-indexed, x and y coordinates that
  indicate which column and row a tile is located on a map or tileset.
  Tile indexes are single 1-indexed digits indicating the order
  of the tile in conjunction with other tiles on a map or tileset.
  The Tiled map editor encodes map data as a series of tile indexes
  that reference tileset tiles.

  Tile indexes are useful for expressing map information in a
  minimalistic format, but are not intuitive to use when
  thinking about world or map positions.
--]]

local lib = {}

function lib.tileIndexToColumn(tileIndex, totalColumns)
  return ((tileIndex-1) % totalColumns)
end

-- Tile indexes are 1-indexed
-- Tile row numbers are 0-indexed
function lib.tileIndexToRow(tileIndex, totalColumns)
  return math.floor((tileIndex-1) / totalColumns)
end

-- Tile column numbers are 0-indexed
-- Tile row numbers are 0-indexed
-- Tile indexes are 1-indexed
function lib.tileCoordinateToIndex(tileColumn, tileRow, totalColumns)
  return (tileRow * totalColumns) + (tileColumn % totalColumns) + 1
end

return lib
