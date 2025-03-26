--[[
	Schedule one-time and recurring events
]]
local RunService = game:GetService("RunService")

local Core = require(script.Parent.Core)

local Scheduler = {}

-- Priv storage
local scheduledEvents = {}
local nextEventID = 1
local updateConnection = nil
local nextEventTime = nil

-- Event obj (internal)
local Event = {}
Event.__index = Event

-- Private functions --
-- Internal function. Acts as the 'heart' of the script. Designed to be called when modifying schedules.
local function updateSchedulerStatus()
	local nextTime = math.huge -- Starts as a high number
	local hasEvents = false
	
	for _, event in pairs(scheduledEvents) do
		if event.cancelled then
			continue
		end
		hasEvents = true
		if event.nextTriggerTime >= nextTime then
			continue
		end
		nextTime = event.nextTriggerTime
	end
	-- update nextEventTime
	nextEventTime = hasEvents and nextTime or nil
	
	-- manage heartbeat connection
	if not hasEvents and updateConnection then
		-- Disconnect
		updateConnection:Disconnect()
		updateConnection = nil
		return -- If there is no events, returns out
	end
	-- Otherwise, connect
	updateConnection = RunService.Heartbeat:Connect(function()
		local now = Core.getUnixTimestamp()
		
		-- check if any events need proecssing
		if nextEventTime and now >= (nextEventTime - 0.016) then -- Small buffer
			local eventsToRemove = {}
			
			for id, event in pairs(scheduledEvents) do
				if event.cancelled then
					table.insert(eventsToRemove, id)
				elseif now >= event.nextTriggerTime then
					task.spawn(event.callback) -- Calls
					
					if event.recurring then
						event:Reschedule() -- Calls reschedule method
					else
						table.insert(eventsToRemove, id) -- Removes the event
					end
				end
			end
			
			-- Cleanup
			for _, id in ipairs(eventsToRemove) do
				scheduledEvents[id] = nil
			end
			
			-- recalculate next event frame
			updateSchedulerStatus()
		end
	end)
end

function Event.new(delay: number, callback: () -> (), recurring: boolean)
	local self = setmetatable({
		id = nextEventID,
		delay = delay,
		callback = callback,
		recurring = recurring or false,
		nextTriggerTime = Core.getUnixTimestamp() + delay,
		cancelled = false
	}, Event)
	
	nextEventID += 1
	return self
end

-- Cancels an event
function Event:Cancel(): boolean
	self.cancelled = true
	updateSchedulerStatus()
	return true
end

--[[
	Reschedule a recurring or non-recurring event. If no delay is passed, uses the previous delay passed to the constructor.
]]
function Event:Reschedule(newDelay: number): boolean
	if not self.cancelled then
		local now = Core.getUnixTimestamp()
		-- Update nextTriggerTime
		if newDelay then
			self.delay = newDelay
		end
		self.nextTriggerTime = now + self.delay
		updateSchedulerStatus()
		return true
	end
	return false
end

-- Get the time remaining for the scheduled event in seconds. If the event is cancelled, returns 0
function Event:GetTimeRemaining(): number
	if self.cancelled then
		return 0
	end
	return math.max(0, self.nextTriggerTime - Core.getUnixTimestamp())
end

-- Returns a boolean that indicates whether the event is active or is currently scheduled
function Event:IsScheduled(): boolean
	return not self.cancelled and scheduledEvents[self.id] ~= nil
end

-- Returns a DateTime object indicative of the next trigger time or scheduled event
function Event:GetScheduledTime(): DateTime
	return Core.fromUnixTimestamp(self.nextTriggerTime)
end

-- Gets the events' current ID number
function Event:GetID(): number
	return self.id
end

-- Schedule a one-time event
function Scheduler.scheduleOnce(delay: number, callback: () -> ())
	assert(typeof(delay) == "number" and delay >= 0, "Delay must be a non-negative number")
	assert(typeof(callback) == "function", "Callback must be a function")
	
	local event = Event.new(delay, callback, false)
	scheduledEvents[event.id] = event
	
	updateSchedulerStatus()
	-- Returns the event for methods
	return event
end

-- Schedule a recurring event
function Scheduler.scheduleRecurring(interval: number, callback: () -> ())
	assert(typeof(interval) == "number" and interval > 0, "Interval must be a positive number")
	assert(typeof(callback) == "function", "Callback must be a function")
	
	local event = Event.new(interval, callback, true)
	scheduledEvents[event.id] = event
	
	updateSchedulerStatus()
	-- Returns the event for methods
	return event
end

-- Cancel a scheduled event by ID
function Scheduler.cancel(eventId: number)
	if scheduledEvents[eventId] then
		scheduledEvents[eventId]:Cancel()
		return true
	end
	return false
end

-- Cancel all scheduled events
function Scheduler.cancelAll()
	for _, event in pairs(scheduledEvents) do
		event:Cancel()
	end
	scheduledEvents = {}
	-- Update scheduler status again (Should disconnect heartbeat)
	updateSchedulerStatus()
	return true
end

-- Get count of active scheduled events
function Scheduler.getActiveCount()
	local ct = 0
	for _, event in pairs(scheduledEvents) do
		if event.cancelled then
			continue
		end
		ct += 1
	end
	return ct
end

-- Get all scheduled events (for debugging)
function Scheduler.getEvents()
	local events = {}
	for id, event in pairs(scheduledEvents) do
		if event.cancelled then
			continue
		end
		table.insert(events, {
			id = id,
			nextTrigger = Core.fromUnixTimestamp(event.nextTriggerTime),
			timeRemaining = math.max(0, event.nextTriggerTime - Core.getUnixTimestamp()),
			recurring = event.recurring
		})
	end
	return events
end

return Scheduler
