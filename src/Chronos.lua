--[[
	Chronos Module Initializer
]]
local Chronos = {}

-- Module imports
local Core = require(script.Core)
local Cooldown = require(script.Cooldown)
local Timer = require(script.Timer)
local Scheduler = require(script.Scheduler)
local Format = require(script.Format)

-- Expose sub-modules
Chronos.Core = Core
Chronos.Cooldown = Cooldown
Chronos.Timer = Timer
Chronos.Scheduler = Scheduler
Chronos.Format = Format

-- Common Convenience functions


--[[
	Enhanced thread yielding function with optional debugging. If seconds is not passed, defaults to 0.0001 seconds.
	Returns 2 numbers, the result of task.wait and the actual wait time
]] 
function Chronos.Yield(seconds: number, debug: boolean?)
	seconds = seconds or 0.0001 -- Sets to default of 0.0001
	
	local startTime = Core.getUnixTimestamp()
	local result = task.wait(seconds) -- Returns number
	local resultingTime = Core.getUnixTimestamp()
	local actualWaitTime = resultingTime - startTime
	
	-- If debug is enabled log info about the wait
	if debug then
		print(("Wait: Requested %.4fs, actual %.4fs (delta: %.4fs)"):format(seconds, actualWaitTime, actualWaitTime - seconds))
	end
	return result, actualWaitTime -- Returns the result, and the actual wait time
end

-- Get the current server time
function Chronos.Now()
	return Core.getUnixTimestamp()
end

-- Schedule a one-time event
function Chronos.Schedule(delay: number, callback: () -> ()?)
	return Scheduler.scheduleOnce(delay, callback)
end

-- Schedule a recurring event
function Chronos.Recur(interval: number, callback: () -> ()?)
	return Scheduler.scheduleRecurring(interval, callback)
end

-- Create a new cooldown object
function Chronos.CreateCooldown(duration: number)
	return Cooldown.new(duration)
end

function Chronos.DateTime()
	local timestamp = Chronos.Now()
	return Core.fromUnixTimestamp(timestamp)
end

-- Format time as string (mm:ss)
function Chronos.FormatTime(seconds: number)
	return Format.asMinutesAndSeconds(seconds)
end

-- Create a DateTime from year, month, day, etc...
function Chronos.CreateDateTime(year: number, month: number, day: number, hour: number, minute: number, second: number)
	return Core.createDateTime(year, month, day, hour, minute, second)
end

-- Convert Unix timestamp to DateTime object
function Chronos.FromUnixTimestamp(timestamp: number)
	return Core.fromUnixTimestamp(timestamp)
end

-- Convert DateTime object to formatted string
function Chronos.FormatDateTime(dateTime: DateTime, format: string, locale: string)
	return Core.dateTimeToString(dateTime, format, locale)
end

-- Version info
Chronos.Version = {
	Major = 0,
	Minor = 1,
	Patch = 0,
	String = "0.1.0"
}

return Chronos
