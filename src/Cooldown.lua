local Core = require(script.Parent.Core)

local Cooldown = {}
Cooldown.__index = Cooldown

-- create a new cooldown object
function Cooldown.new(duration: number)
	assert(typeof(duration) == "number" and duration >= 0, "Cooldown duration must be a non-negative number")
	
	local self = setmetatable({
		_duration = duration,
		_lastUsed = 0,
		_isActive = false
	}, Cooldown)
	return self
end

-- Check if cooldown is ready
function Cooldown:IsReady()
	if not self._isActive then
		return true
	end
	
	local now = Core.getUnixTimestamp()
	local timeSinceUse = now - self._lastUsed
	
	return timeSinceUse >= self._duration
end

-- Get remaining cooldown time in seconds
function Cooldown:GetRemaining()
	if not self._isActive then
		return 0
	end
	local now = Core.getUnixTimestamp()
	local timeSinceUse = now - self._lastUsed
	local remaining = self._duration - timeSinceUse
	
	return math.max(0, remaining)
end

-- Get cooldown progress as a value between 0 and 1
function Cooldown:GetProgress()
	if not self._isActive then
		return 1
	end
	
	local remaining = self:GetRemaining()
	local progress = 1 - (remaining / self._duration)
	return math.clamp(progress, 0, 1)
end

-- Use the action, triggering the cooldown
function Cooldown:Use()
	self._lastUsed = Core.getUnixTimestamp()
	self._isActive = true
	return true
end

-- Force reset cooldown
function Cooldown:Reset()
	self._isActive = false
	return true
end

-- Set a new duration
function Cooldown:SetDuration(newDuration: number)
	assert(typeof(newDuration) == "number" and newDuration >= 0, "Cooldown duration must be a non-negative number")
	self._duration = newDuration
end

return Cooldown
