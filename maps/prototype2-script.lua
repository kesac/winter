

local script = {}

function script.initialize()

end

function script.load()

end

function script.unload()

end

function script.testDialogue()

  game.textbox.displayText(
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
    }
  )

end

return script
