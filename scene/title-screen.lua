
-- This is a protoype title screen for test purposes only

local scene = {}
scene._manager = nil
scene._maps = require 'libtsl.map-manager' -- this only works if title-menu is initialized after the world scene
scene._titlefont = game.font.get(40)
scene._menufont = game.font.get(20)
scene._music = 'bgm-title'

local logo = love.graphics.newImage('images/game-logo-1.png')
scene.logoAlpha = 0
local logoBlackWhite = love.graphics.newImage('images/game-logo-1-bw.png')
scene.logoBlackWhiteAlpha = 255

scene.transitionLength = 5

local background = {}
background.x = 0
background.y = 0
background.targets = {
  {x = 0,   y = 0},
  {x = 50,  y = 300},
  {x = 150, y = 50}
}
background.currentTarget = 1
background.fluxMovement = nil
background.fluxAlpha = nil

local snow = require 'libtsl.snow'
snow.on = true

function scene.initialize(manager)
  scene._manager = manager
    -- called when this scene is added to a scenemanager
    -- passes the manager as the only argument
end


function scene.goToNextPoint()
  background.currentTarget = background.currentTarget + 1

  if background.currentTarget > #background.targets then
    background.currentTarget = 1
  end

  local target = background.targets[background.currentTarget]
  background.fluxMovement = game.flux.to(background, 20, {x = target.x, y = target.y}):ease("linear"):oncomplete(scene.goToNextPoint)

end

function scene.load()
    -- called when the scene becomes the current scene
    background.x = 0
    background.y = 0
    background.currentTarget = 1

    -- Background fades in
    scene._maps.alpha = 0
    --scene._maps.alpha = 255
    background.fluxAlpha = game.flux.to(scene._maps, scene.transitionLength, {alpha = 255}):ease("linear")

    game.flux.to(scene, scene.transitionLength, {logoAlpha = 255}):ease("quadinout")
    game.flux.to(scene, scene.transitionLength, {logoBlackWhiteAlpha = 0}):ease("quadinout")

    scene.goToNextPoint()
    snow.fillscreen()

    game.audio.loop(scene._music)
end

function scene.unload()
  if background.fluxMovement then
    background.fluxMovement:stop() -- background flux callbacks chain each other forver so need to stop it here
    background.fluxMovement = nil
  end

  if background.fluxAlpha then
    background.fluxAlpha:stop() -- background flux callbacks chain each other forver so need to stop it here
    background.fluxAlpha = nil
    scene._maps.alpha = 255
  end

  snow.clear()

  game.audio.fadestop(scene._music)
end

function scene.update(dt)
	-- called when the scene needs to update itself
  snow.update(dt)
end

function scene.draw()

	-- moving background
  love.graphics.push()
  love.graphics.scale(1.25)
  love.graphics.translate(-background.x, -background.y)
  -- scene._maps.draw()
  love.graphics.pop()

  -- falling snow
  love.graphics.setColor(255,255,255,255)
  snow.draw()

  -- title
  -- love.graphics.setColor(0,0,0,150)
  -- love.graphics.rectangle('fill', 0, GAME_CANVAS_HEIGHT/2 - 50 - 20, GAME_CANVAS_WIDTH, 85)

  -- love.graphics.setColor(255,255,255,255)
  --love.graphics.setFont(scene._titlefont)
  --love.graphics.print(game.text.gamename, GAME_CANVAS_WIDTH/2 - scene._titlefont:getWidth(game.text.gamename)/2 , GAME_CANVAS_HEIGHT/2 - scene._titlefont:getHeight(game.text.gamename)/2 - 20)

  love.graphics.setColor(255,255,255,scene.logoAlpha)
  love.graphics.draw(logo,100,100,0,1.2,1.2)
  love.graphics.setColor(255,255,255,scene.logoBlackWhiteAlpha)
  love.graphics.draw(logoBlackWhite,100,100,0,1.2,1.2)

  -- menu
  -- love.graphics.setColor(0,0,0,150)
  -- love.graphics.rectangle('fill', GAME_CANVAS_WIDTH/2 + 120, GAME_CANVAS_HEIGHT/2 + 100, 200, 150)

  love.graphics.setFont(scene._menufont)
  love.graphics.setColor(255,255,255,255)
  love.graphics.print(game.text.title.new, GAME_CANVAS_WIDTH/2 + 120 + 10, GAME_CANVAS_HEIGHT/2 + 100 + 10)
  love.graphics.print(game.text.title.load, GAME_CANVAS_WIDTH/2 + 120 + 10, GAME_CANVAS_HEIGHT/2 + 100 + 10 + 35)
  love.graphics.print(game.text.title.options, GAME_CANVAS_WIDTH/2 + 120 + 10, GAME_CANVAS_HEIGHT/2 + 100 + 10 + 70)
  love.graphics.print(game.text.title.exit, GAME_CANVAS_WIDTH/2 + 120 + 10, GAME_CANVAS_HEIGHT/2 + 100 + 10 + 110)

end

function scene.keypressed(key,unicode)
  scene._manager.transitionTo('world')
	-- called when the scene needs to handle a keypressed event
end

function scene.keyreleased(key,unicode)
	-- called when the scene needs to handle a key released event
end


return scene
