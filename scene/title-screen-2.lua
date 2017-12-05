
-- Another prototype screen

local scene = {}
local sceneManager = nil
local music = 'bgm-title'
local snow = require('libtsl.snow')

local parallaxImage = love.graphics.newImage('images/jetrel-exterior-parallaxBG1-2x.png')
local parallaxEntities = {}

local logo = {
  transitionLength = 5,
  states = {
    {
      image = love.graphics.newImage('images/game-logo-1-bw.png'),

      alpha = 255,
      visible = true
    },
    {
      image = love.graphics.newImage('images/game-logo-1.png'),
      alpha = 0,
      visible = true
    }
  }
}

local menu = {
  font = game.font.get(20),
  highlightColor = {255, 255, 255, 255},
  defaultColor = {180, 180, 180, 255},
  currentButtonIndex = 1,
  buttons = {
    {
      text = game.text.title.new
    },
    {
      text = game.text.title.load
    },
    {
      text = game.text.title.options
    },
    {
      text = game.text.title.exit
    }
  }
}

function scene.initialize(manager)
    sceneManager = manager

    local totalParallaxClones = 3 -- For complete coverage, ensure: (clones * parallaxImageWidth) > GAME_CANVAS_WIDTH * 2

    local parallaxDraw = function(self)
      love.graphics.draw(parallaxImage, math.floor(self.x), math.floor(self.y))
    end

    local parallaxUpdate = function(self, dt)
      if self.x <=  -parallaxImage:getWidth() then
        self.x = self.x + (parallaxImage:getWidth() * (totalParallaxClones))
      end
    end

    for i = 1, totalParallaxClones, 1 do
      local parallax = game.entity.new((i-1) * parallaxImage:getWidth(), 0, math.pi, 10)
      parallax.draw = parallaxDraw
      parallax.update = parallaxUpdate
      table.insert(parallaxEntities, parallax)
    end
end

function scene.load()
    snow.on = true
    snow.angle = math.pi*3/2 - math.pi/8
    snow.fillscreen()

    game.flux.to(logo.states[1], logo.transitionLength*3, {alpha = 0}):ease("quadinout")
    game.flux.to(logo.states[2], logo.transitionLength, {alpha = 255}):ease("quadinout")

    game.audio.loop(music)
end

function scene.unload()
    snow.clear()
    game.audio.fadestop(music)
end

function scene.update(dt)
	for _, e in pairs(parallaxEntities) do
    game.entity.update(e, dt) -- location
    e:update(dt) -- parallax effect
  end

  snow.update(dt)
end

function scene.draw()
  love.graphics.setColor(255,255,255,255)

  -- Order matters!
  for _, e in pairs(parallaxEntities) do
    e:draw() -- parallax effect
  end

  snow.draw()

  for i=1, #logo.states, 1 do
    local state = logo.states[i]
    love.graphics.setColor(255, 255, 255, state.alpha)
    love.graphics.draw(state.image, GAME_CANVAS_WIDTH/2 - parallaxImage:getWidth()/2 - 20, 30, 0, 1.2, 1.2)
  end

  love.graphics.setFont(menu.font)
  for i=1, #menu.buttons, 1 do
    local button = menu.buttons[i]

    if i == menu.currentButtonIndex then
      love.graphics.setColor(unpack(menu.highlightColor))
    else
      love.graphics.setColor(unpack(menu.defaultColor))
    end

    love.graphics.print(button.text, i*GAME_CANVAS_WIDTH/(#menu.buttons+1) - menu.font:getWidth(button.text)/2, 535)
  end

end

function scene.keypressed(key,unicode)

  if key == 'left' or key == 'a' then
    menu.currentButtonIndex = menu.currentButtonIndex - 1
    if menu.currentButtonIndex <= 0 then
      menu.currentButtonIndex = 1
    else
      game.audio.play('sfx-menu')
    end

  end

  if key == 'right' or key == 'd' then
    menu.currentButtonIndex = menu.currentButtonIndex + 1
    if menu.currentButtonIndex > #menu.buttons then
      menu.currentButtonIndex = #menu.buttons
    else
      game.audio.play('sfx-menu')
    end
  end

  if key == 'space' or key == 'enter' then
    if menu.currentButtonIndex == 1 then
      sceneManager.transitionTo('world')
    end

    game.audio.play('sfx-confirm')
  end

end

function scene.keyreleased(key,unicode)
	-- called when the scene needs to handle a key released event
end

return scene
