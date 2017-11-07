
-- [Ice Project 2 (2017), turtlesort.com]

function love.load()

  -- Global constants
  TILE_WIDTH = 32
  TILE_HEIGHT = 32

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

  -- Languages
  game.text   = require 'text.english'

  -- Setup

  game.audio.add('music/Snowfall-Loop.ogg','stream',"snowfall",1)

  game.font.setDefaultFont('fonts/PressStart2P/PressStart2P.ttf')
  game.textbox.init(game.font.get(16))

  game.addScene(require 'scene.test-text-1', 'test-text-1')
  game.addScene(require 'scene.test-text-2', 'test-text-2')
  game.addScene(require 'scene.world', 'world')
  game.addScene(require 'scene.title-menu', 'title-menu')

  -- game.setCurrentScene('test-text-1')
  game.setCurrentScene('world')
  -- game.setCurrentScene('title-menu')

end

function love.update(dt)
  game.audio.update(dt)
  game.flux.update(dt)
  game.timer.update(dt)
  game.textbox.update(dt)
  game.update(dt)
end

function love.draw()
  game.draw()
  game.textbox.draw()
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
