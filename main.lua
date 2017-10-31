
-- [Ice Project 2 (2017), turtlesort.com]

function love.load()

  -- Global aliases
  g = love.graphics

  -- My personal lua library for love2d development
  game        = require 'libtsl.scene-manager'
  game.timer  = require 'libtsl.timer'
  game.utf8   = require 'libtsl.utf8'
  game.font   = require 'libtsl.font'
  game.text   = require 'libtsl.textbox'

  -- Setup
  game.font.setDefaultFont('fonts/PressStart2P/PressStart2P.ttf')
	game.text.init(game.font.get(16))

  game.addScene(require 'scene.test-text-1', 'test-text-1')
  game.addScene(require 'scene.test-text-2', 'test-text-2')
  game.addScene(require 'scene.world', 'world')

  -- game.setCurrentScene('test-text-1')
  game.setCurrentScene('world')

end

function love.update(dt)
  game.update(dt)
  game.text.update(dt)
  game.timer.update(dt)
end

function love.draw()
  game.draw()
  game.text.draw()
end

function love.keypressed(key, scancode, isrepeat)
  game.keypressed(key, scancode)

  if key == "space" or key == "return" then
    game.text.advanceText()
  end
end

function love.keyreleased(key)
  game.keyreleased(key, scancode)
end
