# Chronos-Roblox-Time-Management
A comprehensive time management library for Roblox

## **Overview**
Chronos provides solutions to your Roblox timing needs. From precise timers to recurring events, cooldown systems to human-readable formatting, Chronos delivers a robust set of tools or utilities that make time-based mechanics a bit easier to develop.

## **Features**
This library features 5 tool modules:
- **Core:** Common DateTime operations simplified with conversions, manipulation, and comparison functions
- **Timer:** Countdown and countup timer with event-driven callbacks
- **Scheduler:** One-time and recurring event execution with quick millisecond execution
- **Cooldown:** Simple Action throttling with progress tracking methods
- **Format:** Time visualization in many human-readable format options
  
## **Installation**

**Method 1:** Github:
Simply navigate to the 'Release' page and download the .RBXM file. Make sure it is the release tagged with 'Latest Release'.

**Method 2:** Roblox:
In Roblox Marketplace, you can directly import the Chronos framework into your game: [Chronos | Marketplace](https://create.roblox.com/store/asset/107231765974752/Chronos-Time-Manager)

**Method 3:** Wally:
For Wally Package manager users [Coming Soon]

## **API Reference**
### **Core Module**
The foundation in which all other modules are built upon on.
```
-- Get current Unix timestamp
local now = Chronos.Now() -- Returns seconds since epoch

-- Create DateTime objects
local dt = Chronos.DateTime() -- Current time
local custom = Chronos.CreateDateTime(2025, 3, 26, 12, 0, 0) -- Specific time

-- Calculate time differences
local difference = Chronos.Core.timeDifferenceInUnits(dt, custom, "seconds")
```
### **Timer Module**
For when you need to countdown or up
```
-- Create a timer (countdown or countup)
local timer = Chronos.Timer.new(duration, Chronos.Timer.TypeEnum.COUNTDOWN)

-- Register callbacks
timer:OnTick(function(timeRemaining) end)
timer:OnComplete(function() end)

-- Control methods
timer:Start()
timer:Pause()
timer:Resume()
timer:Stop()

-- Get information
local timeRemaining = timer:GetTime()
local progress = timer:GetProgress() -- 0 to 1
local formatted = timer:GetTimeString("human") -- "2 hours, 5 minutes, 10 seconds"
```
### **Scheduler Module**
For executing code at precise moments in the future
```
-- Schedule a one-time event
local event = Chronos.Schedule(delayInSeconds, function()
    print("This happens once")
end)

-- Schedule a recurring event
local recurringEvent = Chronos.Recur(intervalInSeconds, function()
    print("This happens repeatedly")
end)

-- Control scheduled events
event:Cancel()
recurringEvent:Reschedule(newInterval)

-- Get information
local remaining = event:GetTimeRemaining()
local nextTime = event:GetScheduledTime() -- Returns DateTime
```
### **Cooldown Module**
For limiting the frequency of actions; a debounce if you will
```
-- Create a cooldown
local cooldown = Chronos.CreateCooldown(durationInSeconds)

-- Use and check
if cooldown:IsReady() then
    cooldown:Use()
    -- Execute action
end

-- get information
local remaining = cooldown:GetRemaining()
local progress = cooldown:GetProgress() -- 0 to 1
```

### **Format Module**
For formatting time operations into a readable format
```
-- format time values
local formatted = Chronos.FormatTime(seconds) -- "05:30"
local human = Chronos.Format.asHumanReadable(seconds) -- "5 minutes, 30 seconds"
local compact = Chronos.Format.asCompact(seconds) -- "5m 30s"

-- format DateTime objects
local dateString = Chronos.FormatDateTime(dateTime, "LL", "en-us)
```
## **Best Practice**
1. **Use the appropriate timer type** - Countdown timers are best for situations with a defined end point, while countup timers are best for tracking elapsed time; almost like a stop watch
2. **Clean up timers and scheduled event** - Don't forget to stop timers and scheduled events when a player leaves or other scenarios to prevent memory issues
3. **Handle time synchronization with consideration** - Remember that client and server time may drift. Always rely on server for a single source of truth
4. **Format time appropriately for the scenario** - Sometimes, a compact format like "5m 30s" is better than something like: "5 minutes, 30 seconds" for user experience
5. **Formatting tokens** - When formatting time using a DateTime object as an argument, for simplicity you can use a token for the format string like: "LL". Don't forget to also include a 'locale' like 'en-us'. (Refer to 'Format Module' section for an example)

## **Contribution**
Contributions are welcome! Please feel free to submit a 'pull request'.
## **License Info**
This project is licensed under the 'MIT License' - see the [LICENSE](https://github.com/chumnyman/Chronos-Roblox-Time-Management/blob/main/LICENSE) for details
