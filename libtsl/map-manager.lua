
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

local lib         = require('libtsl.observable').new()
lib.alpha         = 255
--local canvas      = love.graphics.newCanvas(800, 600)
local canvasBelow = love.graphics.newCanvas(GAME_CANVAS_WIDTH, GAME_CANVAS_HEIGHT)
local canvasAbove = love.graphics.newCanvas(GAME_CANVAS_WIDTH, GAME_CANVAS_HEIGHT)
-- local canvasDrawn = false -- Future optimization
local maps        = {}
local currentMap  = nil
local tilesetRenderCache = {}
local tileMath    = require 'libtsl.tile-math'

function lib.setCurrentMap(id)
  if maps[id] then
    currentMap = maps[id]

    local newWidth = maps[id].tileColumns * TILE_WIDTH
    local newHeight = maps[id].tileRows * TILE_WIDTH

    canvasBelow = love.graphics.newCanvas(newWidth, newHeight)
    canvasAbove = love.graphics.newCanvas(newWidth, newHeight)

    lib.notifyObservers('mapchange', {
      mapName = id,
      width = newWidth,
      height = newHeight,
      isSolidTile = lib._isSolidTile,
      getTileEvents = nil
    })
    -- canvasDrawn = false
  end
end

-- Loads images into memory and calculates quads for later lookup.
function lib.loadTileset(tilesetId, imagePath, tileWidth, tileHeight)

  local tilesetRenderData = {}
  tilesetRenderData.id = tilesetId
  tilesetRenderData.image = love.graphics.newImage(imagePath)
  tilesetRenderData.tileWidth = tileWidth
  tilesetRenderData.tileHeight = tileHeight
  tilesetRenderData.quads = {}
  tilesetRenderData.animations = {}

  local imageWidth = tilesetRenderData.image:getWidth()
  local imageHeight = tilesetRenderData.image:getHeight()
  local totalColumns = imageWidth/tileWidth
  local totalRows = imageHeight/tileHeight
  local totalTiles = totalColumns * totalRows

  tilesetRenderData.tileColumns = totalColumns
  tilesetRenderData.tileRows = totalRows

  -- Quads are pre-calculated to line up with tileset indexes for the tileset
  -- (Given a 3x3 tileset, index 1 is always the top-left most tile and index 9 is the
  -- bottom-right most tile)
  for i = 1, totalTiles do
    local x = tileMath.tileIndexToColumn(i, totalColumns) * tileWidth
    local y = tileMath.tileIndexToRow(i, totalColumns) * tileHeight -- that is not a typo: we need the number of columns to determine tile row
    local quad = love.graphics.newQuad(x, y, tileWidth, tileHeight, imageWidth, imageHeight)
    table.insert(tilesetRenderData.quads, quad);
  end

  tilesetRenderCache[tilesetId] = tilesetRenderData
end

-- Sometimes, tilesets will have embedded animations. (Like water tiles.)
-- This function is used to identify the embedded animations so they may be
-- substituted in for static tiles. The tileset must already be loaded into
-- memory before calling this function.
-- 'substituteTileIndex' is the index of the tile within the tileset to replace
-- 'startTileIndex' is the index of the tile that starts the animation
-- 'endTileIndex' is the index of the tile that ends the animation
function lib.defineTileAnimation(tilesetId, substituteTileIndex, startTileIndex, endTileIndex)

  local tilesetRenderData = tilesetRenderCache[tilesetId]

  if tilesetRenderData then
    local imageWidth = tilesetRenderData.image:getWidth()
    local imageHeight = tilesetRenderData.image:getHeight()
    local grid = game.anim8.newGrid(tilesetRenderData.tileWidth, tilesetRenderData.tileHeight, imageWidth, imageHeight)
    local tileAnimation = game.anim8.newAnimation(grid(startTileIndex .. '-' .. endTileIndex, 1), 0.33) -- TODO: this code only works for tilesets with only 1 row
    tilesetRenderData.animations[substituteTileIndex] = tileAnimation
  end

end

-- Similar to other defineTileAnimation, but takes in an animation array from Tiled maps
function lib.defineTileAnimation2(tilesetId, substituteTileIndex, tiledAnimationData)

  local tilesetRenderData = tilesetRenderCache[tilesetId]

  if tilesetRenderData then
    local imageWidth = tilesetRenderData.image:getWidth()
    local imageHeight = tilesetRenderData.image:getHeight()
    local grid = game.anim8.newGrid(tilesetRenderData.tileWidth, tilesetRenderData.tileHeight, imageWidth, imageHeight)

    local gridArgs = {}
    local frameDurations = {}
    for _,frame in pairs(tiledAnimationData) do
      table.insert(gridArgs, tileMath.tileIndexToColumn(frame.tileid, tilesetRenderData.tileColumns) + 1)
      table.insert(gridArgs, tileMath.tileIndexToRow(frame.tileid, tilesetRenderData.tileColumns) + 1)
      table.insert(frameDurations, frame.duration/1000)
    end

    local tileAnimation = game.anim8.newAnimation(grid(unpack(gridArgs)), frameDurations)
    tilesetRenderData.animations[substituteTileIndex] = tileAnimation
  end
end

-- Loads map data into memory.
-- 'data' is expected to be the contents of a Tiled map
-- exported into lua format. (ie. 'require' was called on
-- the exported lua file and the resulting table was passed)
-- 'id' is the desired identifier for the map.
function lib.loadMap(id, data)

  local map = {}
  map.id = id
  map.tileColumns = data.width
  map.tileRows = data.height
  map.tileWidth = data.tilewidth   -- Warning: tileWidth vs tilewidth (the first
                                   -- adheres to source code naming conventions, the
                                   -- second is used by Tiled)
  map.tileHeight = data.tileheight

  map.tileset = {}   -- list of tilesets used in map (but not the tileset data)
  map.layers = {}    -- list of tile layers
  map.layersBelow = {} -- list of tile layers to be rendered below player
  map.layersAbove = {} -- list of tile layers to be rendered above player
  map.collision = {} -- keys are tile x,y coordinates as single strings with no spaces delimited by a single comma

  -- If a map uses more than one tileset, the tile indexes can have offsets (to differentiate
  -- different tilesets). We need to capture that offset here so that the draw routine can
  -- correctly determine the tileset to use later on.
  for _,ts in pairs(data.tilesets) do

    local tileset = {}
    tileset.id = ts.name

    if not tilesetRenderCache[tileset.id] then
      error('Undefined tileset referenced: "'.. tileset.id ..'". Tilesets must be loaded before maps are loaded.')
    end

    -- tileset.imagePath = ts.image
    tileset.firstTileIndex = ts.firstgid
    -- tileset.tileColumns = ts.imagewidth/ts.tilewidth -- TODO: assert that columns and rows are integers
    -- tileset.tileRows = ts.imageheight/ts.tileheight

    for _,animatedTile in pairs(ts.tiles) do

      -- We add 1 to the indexes here to make them 1-indexed
      -- Also, the animation tile indexes are relative to the tileset not the maps
      -- (So there is no need to use offsets)
      local targetIndex = animatedTile.id + 1
      local animationData = animatedTile.animation

      for _,animationFrame in pairs(animatedTile.animation) do
        animationFrame.tileid = animationFrame.tileid + 1
      end

      lib.defineTileAnimation2(tileset.id, targetIndex, animationData)

    end

    table.insert(map.tileset, tileset)
  end

  local playerLayerEncountered = false

  -- We only capture information required to
  -- draw each layer of the map. The order of layers
  -- defined within the Tiled map matters!
  for _,l in pairs(data.layers) do

    local layer = {}
    layer.visible = l.visible
    layer.name = l.name             -- so layer 'player' can be identified
    layer.type = l.type             -- only type 'tilelayer' can get drawn
    layer.properties = l.properties -- to parse triggers and events
    layer.data = l.data             -- this is expected to be a list of tile
                                    --   indexes that can be used to select
                                    --   the exact quad on the tileset image
    if layer.name == 'Collision' then
      layer.visible = DEBUG_MODE
      for mapTileIndex, tileValue in pairs(layer.data) do
        if tileValue ~= 0 then
          local tileX = tileMath.tileIndexToColumn(mapTileIndex, map.tileColumns)
          local tileY = tileMath.tileIndexToRow(mapTileIndex, map.tileColumns)
          map.collision[tileX .. ',' .. tileY] = true
        end
      end
    end

    table.insert(map.layers, layer)

    if playerLayerEncountered then
      table.insert(map.layersAbove, layer)
    else
      table.insert(map.layersBelow, layer)
    end

    if layer.name == 'Player' then
      playerLayerEncountered = true
    end

  end

  maps[id] = map

end

-- tile coordinates are 0-indexed! (The top left tile of any map is 0,0)
function lib._isSolidTile(tileX, tileY)

  if tileX < 0 or tileY < 0 then
    -- if DEBUG_MODE then print('isCollidable: tileX ('.. tileX ..') < 0 or tileY ('.. tileY ..') < 0') end
    return true
  end

  if currentMap then
    if tileX >= currentMap.tileColumns or tileY >= currentMap.tileRows then
      -- if DEBUG_MODE then print('isCollidable: tileX ('.. tileX ..') >= currentMap.tileColumns ('.. currentMap.tileColumns ..') or tileY ('.. tileY ..') >= currentMap.tileRows ('.. currentMap.tileRows ..')') end
      return true
    elseif currentMap.collision[tileX .. ',' .. tileY] then
      -- if DEBUG_MODE then print('isCollidable currentMap.collision[tileX ('.. tileX ..').. ',' .. tileY ('.. tileY ..')]') end
      return true
    end
  end

  return false

end

-- If there are multiple tilesets in use on a single map
-- then some of the tileset indexes used will have an offset.
-- This function returns the tileset id to use and
-- the true tileset index.
function lib._findTileset(map, tilesetIndex)
  for i = #map.tileset, 1, -1 do
    if tilesetIndex >= map.tileset[i].firstTileIndex then
      -- if DEBUG_MODE then print('map-manager:_findTileset: matched tilesetIndex ' .. tilesetIndex .. ' with tileset ' .. map.tileset[i].id .. ' (firstguid: ' .. map.tileset[i].firstTileIndex .. ' with becomes index ' .. (tilesetIndex - map.tileset[i].firstTileIndex + 1) .. ')') end
      return map.tileset[i].id, (tilesetIndex - map.tileset[i].firstTileIndex + 1)
    end
  end

  return nil, 0
end

-- The tile index is expected to be 1-indexed due to Tiled
-- (ie. the value is expected to be 1 or greater)
-- Tiled uses the value 0 to denote no tile at that position
function lib._drawTile(tilesetId, tileIndex, x, y)

  local tilesetRenderData = tilesetRenderCache[tilesetId]
  -- Does the desired tileset exist?
  -- Is the desired tileIndex within the dimensions of the tileset?
  if tilesetRenderData and tileIndex >= 1 and tileIndex <= #tilesetRenderData.quads then


    if tilesetRenderData.animations[tileIndex] then -- Is there a tile animation to substitute?
      tilesetRenderData.animations[tileIndex]:draw(tilesetRenderData.image, math.floor(x), math.floor(y))

    else
      love.graphics.draw(tilesetRenderData.image, tilesetRenderData.quads[tileIndex], math.floor(x), math.floor(y))

      -- Turn this on if you're having tile rendering issues (writes the tileset index on top of the tile):
      --[[
      love.graphics.setFont(game.font.get(6))
      love.graphics.setColor(255,0,0,255)
      love.graphics.print(tileIndex, math.floor(x), math.floor(y))
      love.graphics.setColor(255,255,255,255)
      --]]
    end
  end
end

function lib.update(dt)
  if currentMap then
    for i = 1, #currentMap.tileset do
      local tilesetRenderData = tilesetRenderCache[currentMap.tileset[i].id]
      for _, animation in pairs(tilesetRenderData.animations) do
        animation:update(dt)
      end
    end
  end
end


function lib._draw(canvas, layers)
  love.graphics.setCanvas(canvas)
  love.graphics.setColor(255,255,255, lib.alpha)
  love.graphics.clear()

  love.graphics.push()
  love.graphics.origin()

  local map = currentMap

  for i = 1, #layers do
    local layer = layers[i]

    if layer.visible and layer.type == 'tilelayer' then
      for j = 1, #layer.data do
        local tileX = tileMath.tileIndexToColumn(j, map.tileColumns)
        local tileY = tileMath.tileIndexToRow(j, map.tileColumns)
        local drawX = map.tileWidth  * tileX
        local drawY = map.tileHeight * tileY
        local tilesetIndex = layer.data[j]

        if tilesetIndex ~= 0 then
          local tilesetId, imageTilesetIndex = lib._findTileset(map, tilesetIndex)
          lib._drawTile(tilesetId, imageTilesetIndex, drawX, drawY)
        end

      end -- for map tiles
    end -- if drawable
  end -- for layers

  love.graphics.pop()
end


function lib.drawBelow()

  if currentMap then
    lib._draw(canvasBelow, currentMap.layersBelow)
    love.graphics.setCanvas()
    love.graphics.draw(canvasBelow)
  end -- if map exists

end

function lib.drawAbove()

  if currentMap then
    lib._draw(canvasAbove, currentMap.layersAbove)
    love.graphics.setCanvas()
    love.graphics.draw(canvasAbove)
  end -- if map exists

end


return lib
