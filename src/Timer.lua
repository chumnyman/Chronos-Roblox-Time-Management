--[[
	Countdown and countup timers with event callbacks
]]
local RunService = game:GetService("RunService")

local Core = require(script.Parent.Core)
local Format = require(script.Parent.Format)

local Timer = {}
Timer.__index = Timer

Timer.TypeEnum = {
	COUNTDOWN = "countdown", COUNTUP = "countup"
}

-- Create a new Timer object
function Timer.new(duration: number, timerType: "countdown" | "countup")
	assert(typeof(duration) == "number" and duration >= 0, "Timer duration must be a non-negative number")
	
	timerType = timerType or Timer.TypeEnum.COUNTDOWN
	assert(timerType == Timer.TypeEnum.COUNTDOWN or timerType == Timer.TypeEnum.COUNTUP, "Invalid timer type")
	
	local self = setmetatable({
		_duration = duration,
		_startTime = 0,
		_pauseTime = 0,
		_timeElapsed = 0,
		_timerType = timerType,
		_running = false,
		_paused = false,
		_tickConnection = nil,
		_tickCallbacks = {},
		_completeCallbacks = {},
		_endDateTime = nil, -- For countdown timers
		_lastTickTime = nil -- For tracking tick intervals
	}, Timer)
	
	return self
end

function Timer:_Update()
	if not self._running or self._paused then
		return
	end
	
	local currentTime = self:GetTime()
	
	-- Fire tick callbacks (with rate limiting to prevent excessive updates)
	local now = Core.getUnixTimestamp()
	if not self._lastTickTime or (now - self._lastTickTime) >= 0.05 then
		for _, callback in pairs(self._tickCallbacks) do
			callback(currentTime)
		end
		self._lastTickTime = now
	end
	
	-- Check if countdown timer is complete
	if self._timerType == Timer.TypeEnum.COUNTDOWN and currentTime <= 0 then
		self:_Complete()
	end
end

function Timer:_Complete()
	-- Fire completion callbacks
	for _, callback in pairs(self._completeCallbacks) do
		task.spawn(callback) -- Runs in own thread
	end
	
	self:Stop()
end


-- Start the Timer
function Timer:Start()
	if self._running then
		return false
	end
	
	self._startTime = Core.getUnixTimestamp()
	self._running = true
	self._paused = false
	
	-- For countdown timers, calculate the end DateTime
	if self._timerType == Timer.TypeEnum.COUNTDOWN then
		-- Calculate end timestamp and create DateTime object
		local endTimestamp = self._startTime + self._duration
		self._endDateTime = Core.fromUnixTimestamp(endTimestamp)
	end
	
	-- Connect update function
	self._tickConnection = RunService.Heartbeat:Connect(function()
		self:_Update()
	end)
	return true
end

function Timer:Stop()
	if not self._running then
		return false
	end
	
	if self._tickConnection then
		self._tickConnection:Disconnect()
		self._tickConnection = nil
	end
	
	self._running = false
	self._paused = false
	self._timeElapsed = 0
	self._endDateTime = nil
	
	return true
end

function Timer:Pause()
	if not self._running or self._paused then
		return false
	end
	
	self._pauseTime = Core.getUnixTimestamp()
	self._paused = true
	
	return true
end

function Timer:Resume()
	if not self._running or not self._paused then
		return false
	end
	
	local pauseDuration = Core.getUnixTimestamp() - self._pauseTime
	self._startTime += pauseDuration
	self._paused = false
	
	-- adjust end DateTime for countdown timers
	if self._timerType == Timer.TypeEnum.COUNTDOWN and self._endDateTime then
		-- Calculate new end time based on adjusted start time
		local newEndTimestamp = self._startTime + self._duration
		self._endDateTime = Core.fromUnixTimestamp(newEndTimestamp)
	end
	return true
end

function Timer:GetTime()
	if not self._running then
		return self._timerType == Timer.TypeEnum.COUNTDOWN and self._duration or 0
	end
	
	if self._paused then
		return self._timerType == Timer.TypeEnum.COUNTDOWN and (self._duration - (self._pauseTime - self._startTime)) or
			(self._pauseTime - self._startTime)
	end
	
	local currentTime = Core.getUnixTimestamp()
	local timeElapsed = currentTime - self._startTime
	
	if self._timerType == Timer.TypeEnum.COUNTDOWN then
		return math.max(0, self._duration - timeElapsed)
	end
	return timeElapsed
end

-- Set a new duration
function Timer:SetDuration(newDuration: number)
	assert(typeof(newDuration) == "number" and newDuration >= 0, "Timer duration must be a non-negative number")
	self._duration = newDuration
	
	-- If timer is countdown type and already running, adjust to new duration
	if self._running and not self._paused and self._timerType == Timer.TypeEnum.COUNTDOWN then
		-- Calculate time elapsed so far
		local timeElapsed = Core.getUnixTimestamp() - self._startTime
		
		-- If new duration is less than elapsed time, complete the timer
		if timeElapsed >= newDuration then
			self:_Complete()
		else
			local newEndTimestamp = self._startTime + newDuration
			self._endDateTime = Core.fromUnixTimestamp(newEndTimestamp)
		end
	end
	
	return true
end

-- Get the progress of the timer in a percentage from 0 to 1
function Timer:GetProgress()
	if not self._running then
		return self._timerType == Timer.TypeEnum.COUNTDOWN and 0 or 1
	end
	
	local current = self:GetTime()
	
	if self._timerType == Timer.TypeEnum.COUNTDOWN then
		return 1 - (current / self._duration)
	else
		return math.min(current / self._duration, 1)
	end
end

-- Get the DateTime when the timer will complete (countdown only)
function Timer:GetEndDateTime()
	if not self._running or self._timerType ~= Timer.TypeEnum.COUNTDOWN then
		return nil
	end
	
	if self._paused then
		-- When paused, calculate a new end time based on remaining time
		local remaining = self:GetTime()
		local endTimestamp = Core.getUnixTimestamp() + remaining
		return Core.fromUnixTimestamp(endTimestamp)
	end
	
	return self._endDateTime
end

-- Format the remaining time as a string
function Timer:GetTimeString(format: "compact" | "human" | any)
	local timeVal = self:GetTime()
	if format == "compact" then
		-- Return formatted as compact as possible, less readable
		return Format.asCompact(timeVal)
	elseif format == "human" then
		-- Return formatted as human readable
		return Format.asHumanReadable(timeVal)
	else
		-- Default format is MM:SS or HH:MM:SS depending on duration
		if timeVal >= 3600 then
			-- Return formatted as hours minutes seconds
			return Format.asHoursMinutesSeconds(timeVal)
		else
			-- Return formatted as minutes and seconds
			return Format.asMinutesAndSeconds(timeVal)
		end
	end
end

function Timer:IsRunning(): boolean
	return self._running
end

function Timer:IsPaused(): boolean
	return self._paused
end

-- Register a tick callback
function Timer:OnTick(callback: () -> ()?): number -- (Returns the inserted index)
	assert(typeof(callback) == "function", "Tick callback must be a function")
	table.insert(self._tickCallbacks, callback)
	return #self._tickCallbacks
end

-- Remove a tick callback
function Timer:RemoveTickCallback(identifier: number | () -> ()): boolean
	assert(typeof(identifier) == "number" or typeof(identifier) == "function", "Identifier passed must be a number or function")
	
	if typeof(identifier) == "function" then
		-- Use table.remove
		table.remove(self._tickCallbacks, table.find(self._tickCallbacks, identifier))
		return true
	end
	-- Else, if it is a number
	if self._tickCallbacks[identifier] then
		self._tickCallbacks[identifier] = nil
		return true
	end
	
	return false
end

-- Register a completion callback
function Timer:OnComplete(callback: () -> ()): number -- (Returns the inserted index)
	assert(typeof(callback) == "function", "Complete callback must be a valid function")
	table.insert(self._completeCallbacks, callback)
	return #self._completeCallbacks
end

function Timer:RemoveCompleteCallback(identifier: number | () -> ())
	assert(typeof(identifier) == "number" or typeof(identifier) == "function", "Identifier passed must be a number or function")
	
	if typeof(identifier) == "function" then
		table.remove(self._completeCallbacks, table.find(self._completeCallbacks, identifier))
		return true
	end
	-- If it s a number
	if self._completeCallbacks[identifier] then
		self._completeCallbacks[identifier] = nil
		return true
	end
	
	return false
end

return Timer