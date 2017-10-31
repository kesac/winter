

local scene = {}

function scene.load()

  game.text.displayText(
		{
			"{@2}",
			"Press {#green}spacebar{#} or {#green}enter{#} to",
			"advance text.",

			"{@3}",
			"This is a small demo showcasing",
			"some basic features you would",
			"find in a tile-based rpg game.",

			"{@2}",
			"Now switching to another {#green}scene{#}!",
			"",
		},

		function()
			game.transitionTo('test-text-2')
		end
	)

end

function scene.draw()
  g.clear(150,150,150)
  g.setColor(255, 255, 255)
  g.print("Hello World!", 400, 300)
end

function scene.update(dt)

end

function scene.keypressed(key, scancode, isrepeat)

end

function scene.keyreleased(key)

end

return scene
