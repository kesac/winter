

local scene = {}

function scene.load()

  game.text.displayText(
		{
      "{@3}",
			"This demo comes with a basic",
			"rpg-like text system where",
			"text is slowly revealed.",

			"{@2}",
			"It can change text colors on",
			"the fly...",

			"{@3}",
			"{#blue}blue {#red}red {#green}green",
			"{#AF4E32}AF4E32 {#334455}334455 {#1FE2DD}1FE2DD",
			"{#00EE34}00EE34 {#6F2CCA}6F2CCA {#888888}888888",

			"{@2}",
			"and also change reveal speed",
			"on the fly {$9.0}like so!",

		},

		function()
			--
		end
	)

end

function scene.draw()
  g.clear(255,255,255)
end

return scene
