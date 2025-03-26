local Format = {}

local Core = require(script.Parent.Core)

-- Format seconds as MM:SS
function Format.asMinutesAndSeconds(seconds: number)
	assert(type(seconds) == "number", "Expected number for seconds")
	
	seconds = math.max(0, seconds)
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = math.floor(seconds % 60)
	
	return string.format("%02d:%02d", minutes, remainingSeconds)
end

-- Format seconds as HH:MM:SS
function Format.asHoursMinutesSeconds(seconds: number)
	assert(type(seconds) == "number", "Expected number for seconds")
	
	seconds = math.max(0, seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local remainingSeconds = math.floor(seconds % 60)
	
	return string.format("%02d:%02d:%02d", hours, minutes, remainingSeconds)
end

-- Format seconds as a human-readable string (e.g., "2 hours, 5 minutes, 10 seconds")
function Format.asHumanReadable(seconds: number, options: {})
	assert(typeof(seconds) == "number", "Expected number for seconds")
	
	options = options or {}
	local showSeconds = options.showSeconds ~= false
	local showMinutes = options.showMinutes ~= false
	local showHours = options.showHours ~= false
	local shortFormat = options.short == true
	
	seconds = math.max(0, math.floor(seconds))
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local remainingSeconds = seconds % 60
	
	local parts = {}
	
	if hours > 0 or showHours then
		if shortFormat then
			table.insert(parts, hours .. "h")
		else
			table.insert(parts, hours .. (hours == 1 and " hour" or " hours"))
		end
	end
	
	if minutes > 0 or showMinutes then
		if shortFormat then
			table.insert(parts, minutes .. "m")
		else
			table.insert(parts, minutes .. (minutes == 1 and " minute" or " minutes"))
		end
	end
	
	if remainingSeconds > 0 or showSeconds then
		if shortFormat then
			table.insert(parts, remainingSeconds .. "s")
		else
			table.insert(parts, remainingSeconds .. (remainingSeconds == 1 and " second" or " seconds"))
		end
	end
	
	return table.concat(parts, shortFormat and " " or ", ")
end

-- Format seconds as a compact duration (e.g., "2h 5m 10s")
function Format.asCompact(seconds: number)
	return Format.asHumanReadable(seconds, {short = true})
end

-- Format DateTime object as a string using direct DateTime methods where possible
function Format.dateTime(dateTime: DateTime, formatString: string, locale: string)
	assert(typeof(dateTime) == "DateTime", "Expected DateTime object")
	return Core.dateTimeToString(dateTime, formatString, locale)
end

-- Format a date range between two DateTime objects
function Format.dateTimeRange(startDateTime: DateTime, endDateTime: DateTime, formatString: string)
	assert(typeof(startDateTime) == "DateTime", "Expected DateTime object for start time")
	assert(typeof(endDateTime) == "DateTime", "Expected DateTime object for end time")
	
	formatString = formatString or "%Y-%m-%d"
	
	local startString = Format.dateTime(startDateTime, formatString)
	local endString = Format.dateTime(endDateTime, formatString)
	
	return startString .. " to " .. endString
end

--

return Format
