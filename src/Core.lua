--[[
	Core module for Chronos framework
]]

local RunService = game:GetService("RunService")

local Core = {}

local IS_SERVER = RunService:IsServer() -- Returns a boolean

-- Main functions

-- Get current time as Unix timestamp (seconds since epoch)
function Core.getUnixTimestamp(): number
	return DateTime.now().UnixTimestamp
end

-- Get current time as Unix timestamp in milliseconds
function Core.getUnixTimestampMillis(): number
	return DateTime.now().UnixTimestampMillis
end

-- Create a DateTime object from Unix timestamp (seconds)
function Core.fromUnixTimestamp(seconds: number): DateTime
	return DateTime.fromUnixTimestamp(seconds)
end

-- Create a DateTime object from Unix timestamp (milliseconds)
function Core.fromUnixTimestampMillis(milliseconds: number): DateTime
	return DateTime.fromUnixTimestampMillis(milliseconds)
end

-- Add seconds to a DateTime object
function Core.addSeconds(dateTime: DateTime, seconds: number): DateTime
	assert(typeof(DateTime) == "DateTime", "Expected DateTime object")
	-- Get timestamp, add seconds, create new DateTime object
	local newTimestamp = dateTime.UnixTimestamp + seconds
	return DateTime.fromUnixTimestamp(newTimestamp)
end

-- Add minutes to a DateTime object
function Core.addMinutes(dateTime: DateTime, minutes: number): DateTime
	return Core.addSeconds(dateTime, minutes * 60) -- 60 seconds in a minute
end

-- Add hours to a DateTime object
function Core.addHours(dateTime: DateTime, hours: number): DateTime
	return Core.addSeconds(dateTime, hours * 3600) -- 3600 seconds in an hour
end

-- Add days to a DateTime object
function Core.addDays(dateTime: DateTime, days: number): DateTime
	return Core.addSeconds(dateTime, days * 86400) -- 86400 seconds in a day
end

-- Calculate time difference in seconds between two DateTime objects
function Core.timeDifferenceInSeconds(dateTimeA: DateTime, dateTimeB: DateTime): number
	assert(typeof(dateTimeA) == "DateTime", "Expected DateTime object for dateTimeA")
	assert(typeof(dateTimeB) == "DateTime", "Expected DateTime object for dateTimeB")
	
	-- Subtract from them, and use math.max() since, when comparing a previous difference that may have passed, it should be 0.
	local seconds = math.max(0, dateTimeB.UnixTimestamp - dateTimeA.UnixTimestamp)
	return seconds
end

-- Calculate time difference in minutes between two DateTime objects
function Core.timeDifferenceInMinutes(dateTimeA: DateTime, dateTimeB: DateTime): number
	assert(typeof(dateTimeA) == "DateTime", "Expected DateTime object for dateTimeA")
	assert(typeof(dateTimeB) == "DateTime", "Expected DateTime object for dateTimeB")
	
	local seconds = math.max(0, dateTimeB.UnixTimestamp - dateTimeA.UnixTimestamp)
	return seconds / 60
end

-- Calculate time difference in hours between two DateTime objects
function Core.timeDifferenceInHours(dateTimeA: DateTime, dateTimeB: DateTime): number
	assert(typeof(dateTimeA) == "DateTime", "Expected DateTime object for dateTimeA")
	assert(typeof(dateTimeB) == "DateTime", "Expected DateTime object for dateTimeB")
	
	local seconds = math.max(0, dateTimeB.UnixTimestamp - dateTimeA.UnixTimestamp) -- In seconds
	return seconds / 3600
end

-- Calculate time difference in days between two DateTime objects
function Core.timeDifferenceInDays(dateTimeA: DateTime, dateTimeB: DateTime): number
	assert(typeof(dateTimeA) == "DateTime", "Expected DateTime object for dateTimeA")
	assert(typeof(dateTimeB) == "DateTime", "Expected DateTime object for dateTimeB")
	
	local seconds = math.max(0, dateTimeB.UnixTimestamp - dateTimeA.UnixTimestamp)
	return seconds / 86400
end

-- Check if a time has passed (Comparing Unix timestamps)
function Core.hasTimePassed(targetTime: number): boolean
	return Core.getUnixTimestamp() >= targetTime
end

-- Calculate the seconds until a specific Unix timestamp
function Core.secondsUntil(targetTime: number): number
	local currentTime = Core.getUnixTimestamp()
	return math.max(0, targetTime - currentTime) -- From 0 - [number]
end

-- Convert a DateTime object to a formatted string. If no format is passed, the Iso date format will be used.
function Core.dateTimeToString(dateTime: DateTime, format: string, locale: string): string
	assert(typeof(dateTime) == "DateTime", "Expected DateTime object")
	
	locale = locale or "en-us"
	if not format then
		-- Default to ISO format if no custom format specified
		return dateTime:ToIsoDate()
	end
	-- Use FormatUniversalTime for custom formatting
	return dateTime:FormatUniversalTime(format, locale)
end

-- Get a DateTime object for a specific date and time in UTC
function Core.createDateTime(year, month, day, hour, minute, second): DateTime
	hour = hour or 0
	minute = minute or 0
	second = second or 0
	
	print(("Creating dateTime from: Year: %d | Month: %d | Day: %d | Hour: %d | Minute: %d | Second: %d"):format(
			year, month, day, hour, minute, second
		))
	
	return DateTime.fromUniversalTime(year, month, day, hour, minute, second)
end

return Core
