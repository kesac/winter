--[[
	Copyright (c) 2017 Kevin Sacro

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

-- Simulates an interface for observable objects.
--
-- Example usage:
--	local obs = require('observable').new()
--  obs.notifyObservers('example-event', {type='example', desc='this is an example event'})
--

local lib = {}

function lib.new() -- works around require
	local observable = {}

	observable._observers = {}

	-- Expecting any table with the notify(event, ...)
	-- function defined.
	function observable.addObserver(observer)
		table.insert(observable._observers,observer)
	end

	function observable.notifyObservers(event, values)
		for _, observer in pairs(observable._observers) do
			if observer.notify then observer.notify(event, values) end
		end

	end

	return observable
end

return lib
