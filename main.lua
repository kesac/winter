
-- [Ice Project 2 (2017), turtlesort.com]

function love.load()

  -- Global constants
  TILE_WIDTH  = 32
  TILE_HEIGHT = 32
  GAME_CANVAS_WIDTH = 800 -- canvas dimensions don't affect supported resolutions
  GAME_CANVAS_HEIGHT = 600
  GAME_POINT_SIZE = 1
  DEBUG_MODE  = false

  -- My personal lua library for love2d development
  game         = require 'libtsl.scene-manager'
  game.timer   = require 'libtsl.timer'
  game.utf8    = require 'libtsl.utf8'
  game.font    = require 'libtsl.font'
  game.textbox = require 'libtsl.textbox'
  game.entity  = require 'libtsl.entity'
  game.audio  = require 'libtsl.audio'

  -- External libraries for love2d games
  game.flux   = require 'lib.flux'
  game.anim8  = require 'lib.anim8'
  game.tlfres = require 'lib.tlfres'

  -- Languages
  game.text   = require 'text.english'

  -- Setup

  game.audio.add('music/FantasyOrchestralTheme_lq.ogg','stream',"bgm-title")
  game.audio.add('sfx/menu.wav','static',"sfx-menu")
  game.audio.add('sfx/confirm.wav','static',"sfx-confirm")

  game.audio.enabled = not DEBUG_MODE -- TODO: Re-enable before deploying

  game.font.setDefaultFont('fonts/PressStart2P/PressStart2P.ttf')
  game.textbox.init(game.font.get(16))

  game.addScene(require 'scene.test-text-1', 'test-text-1')
  game.addScene(require 'scene.test-text-2', 'test-text-2')
  game.addScene(require 'scene.world', 'world')
  game.addScene(require 'scene.title-screen', 'title-screen')
  game.addScene(require 'scene.title-screen-2', 'title-screen-2')

  -- game.setCurrentScene('test-text-1')
  -- game.setCurrentScene('world')
  -- game.setCurrentScene('title-screen')
  game.setCurrentScene('title-screen-2')

end

function love.update(dt)
  game.audio.update(dt)
  game.flux.update(dt)
  game.timer.update(dt)
  game.textbox.update(dt)
  game.update(dt)
end

function love.draw()

  game.tlfres.beginRendering(GAME_CANVAS_WIDTH, GAME_CANVAS_HEIGHT)
  --love.graphics.setPointSize(game.tlfres.getScale()*GAME_POINT_SIZE)


  game.draw()
  game.textbox.draw()

  if DEBUG_MODE then
    love.graphics.setFont(game.font.get(16))
    love.graphics.setColor(255,0,0,255)
    love.graphics.print("FPS: ".. love.timer.getFPS(), 10, 10)
  end

  game.tlfres.endRendering()

end

function love.keypressed(key, scancode, isrepeat)
  game.keypressed(key, scancode)

  if key == "space" or key == "return" then
    game.textbox.advanceText()
  end
end

function love.keyreleased(key)
  game.keyreleased(key, scancode)
end
