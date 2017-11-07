--[[
	Copyright (c) 2012 Kevin Sacro

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including without limitation
	the rights to use, copy, modify, merge, publish, distribute, sublicense,
	and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
	NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
	DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
	OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
	USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

-- This script is from the original Child of Winter game. It's been
-- modified slightly (global variable names) to work in this game.

-- Script for creating, updating, and drawing all
-- snowflake entites.

local snowmanager = {}
local snowflakes = {}    -- all active snowflakes are put in here
local recycle = {} -- all inactive snowflakes are placed in here for recycling

local instantiated = 0 -- for debugging
local recycled = 0     -- for debugging

local snowtimer = 0
local snowfrequency = 0.035 -- in seconds

snowmanager.on = false

-- Instantiates a new snowflake entity in the game.
function snowmanager.newflake()

	local snowflake = nil

	if #recycle == 0 then
		snowflake = game.entity.new(
			math.random(0,love.graphics.getWidth()+150),
			-10,
			math.pi*3/2 - math.pi/20,
			math.random(30,90)
		)
		instantiated = instantiated + 1
	else
		snowflake = table.remove(recycle)
		snowflake.x = math.random(0,love.graphics.getWidth()+150)
		snowflake.y = -10
		recycled = recycled + 1
	end

	table.insert(snowflakes,snowflake)
	return snowflake

end

function snowmanager.fillscreen()
	for i=1,200 do
		snowmanager.newflake().y = math.random(0,love.graphics.getHeight() + 150)
	end

end


-- Updates snowflake positions based on their
-- given angle and speed. Removes snowflakes from
-- the game if they fly off the screen.
function snowmanager.update(dt)

	if not snowmanager.on then return end

	snowtimer = snowtimer + dt

	if snowtimer > snowfrequency then
		snowtimer = 0
		--[[
		snowmanager.new(
			math.random(love.graphics.getWidth()/2,love.graphics.getWidth()*3/2),
			-1 * math.random(0,love.graphics.getHeight()/2),
			180+45 - 12 + math.random(0,13),
			5
		)
		--]]
		snowmanager.newflake()

	end

	for i = # snowflakes, 1, -1 do

		-- position update
		local snowflake = snowflakes[i]
		game.entity.update(snowflake,dt)

		-- check if we can remove
		if snowflake.x < 0 or snowflake.y > love.graphics.getHeight() then
			local o = table.remove(snowflakes,i)
			table.insert(recycle,o) -- we reuse removed snowflakes later
		end
	end

end

-- Draws snowflakes on the screen.
function snowmanager.draw()

	if not snowmanager.on then return end

--[[ -- DEBUGGING
	love.graphics.setColor(51,51,51)
	love.graphics.setFont(game.font.get(14))
	love.graphics.print('Snowflakes active: '..#snowflakes,10,50)
	love.graphics.print('Snowflakes to-be-recycled: '..#recycle,10,70)
	love.graphics.print('Instantiated total: '..instantiated,10,90)
	love.graphics.print('Recycled total: '..recycled,10,110)
--]]

	love.graphics.setColor(255,255,255)

	for i = 1, #snowflakes do
		local o = snowflakes[i]
		love.graphics.rectangle('fill',o.x,o.y,3,3)
	end

end


function snowmanager.clear()
	size = #snowflakes
	for i = size, 1, -1 do
		table.remove(snowflakes,i)
	end
end


return snowmanager
