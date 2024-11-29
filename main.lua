--=================================================================
-- ServerGuardian - BeamMP Resource
-- By Titch
--=================================================================

local pluginPath = debug.getinfo(1).source:gsub("\\","/")
pluginPath = pluginPath:sub(2,(pluginPath:find("main.lua"))-2)

-- Import required BeamMP API functions
local http = require("socket.http")
local ltn12 = require("ltn12")

local toml = require("toml")

-- Define your API key here
local apiKey = "YOUR_API_KEY_HERE"

-- Function to find the player's beammp identifier
local function GetPlayerBeamMPId(playerId)
    local identifiers = MP.GetPlayerIdentifiers(playerId)
    for _, identifier in pairs(identifiers) do
        if string.match(identifier, "^beammp:%d+$") then
            return identifier
        end
    end
    return nil
end

-- Function to send a POST request
local function SendReport(reportType, playerIdentifier, reason, callback)
    local apiUrl = "https://sg.yourthought.com/api/user/report"
    local requestData = {
        report_type = reportType,
        uuid = playerIdentifier,
        report = reason
    }

    http.request(apiUrl, {
        method = "POST",
        data = requestData,
        headers = {
            ["Content-Type"] = "application/json",
            ["x-api-key"] = apiKey
        },
        sink = ltn12.sink.table(callback) -- Capture the response in the callback table
    })
end

-- Function to handle console input (chat messages)
function handleConsoleInput(cmd)
    local delim = cmd:find(' ')
    if delim then
        local message = cmd:sub(delim+1)
        local command = cmd:sub(1, delim-1)

        if command == "/kick" or command == "/ban" then
            local targetPlayerId, rest = message:match("(%d+)%s*(.*)")
            if targetPlayerId and rest then
                local playerId = tonumber(targetPlayerId)
                local playerIdentifier = GetPlayerBeamMPId(playerId)
                if playerIdentifier then
                    if command == "/kick" then
                        MP.KickPlayer(playerId, rest)
                        MP.ConsolePrint("Kicked player " .. playerId .. " for reason: " .. rest)
                        SendReport("kick", playerIdentifier, rest, function(response_body, code, headers, status)
                            if code == 200 then
                                local response_text = table.concat(response_body)
                                print("Response Body:")
                                print(response_text)
                            else
                                print("Request failed with status code: " .. code)
                            end
                        end)
                    elseif command == "/ban" then
                        MP.BanPlayer(playerId, rest)
                        MP.ConsolePrint("Banned player " .. playerId .. " for reason: " .. rest)
                        SendReport("ban", playerIdentifier, rest, function(response_body, code, headers, status)
                            if code == 200 then
                                local response_text = table.concat(response_body)
                                print("Response Body:")
                                print(response_text)
                            else
                                print("Request failed with status code: " .. code)
                            end
                        end)
                    end
                else
                    MP.ConsolePrint("Failed to find player's BeamMP identifier.")
                end
            else
                MP.ConsolePrint("Usage: " .. command .. " <playerId> <reason>")
            end
        end
    end
end

-- Register the handleConsoleInput function for the onConsoleInput event
MP.RegisterEvent("onConsoleInput", "handleConsoleInput")

-- Load the config
local config = {}

function onInit()
	print('ServerGuardian Starting!')
	print('Loading Config..')

    local tomlFile, error = io.open(pluginPath.."/config.toml", "r")
	if error then return nil, error end

	local tomlText = tomlFile:read("*a")
	tomlFile:close()

	CFG = toml.parse(tomlText)
    
	if not CFG then 
		print('FAILED TO LOAD CONFIG!!!')
		return
	end
	local count = 0
	for line in bans_file:lines() do
		count = count + 1
		print('    '..line)
		table.insert(bans, line);
	end
	print(count..' Bans Loaded.')
end

function onPlayerAuth(name, role, isGuest)
    print(name, role, isGuest)
	if CFG.General.AllowGuests == "false" then
		return "You must be signed in to join this server!"
	end
	
	--local ids = MP.GetPlayerIdentifiers(playerID)
	
	if not isGuest and role == "STAFF" then

		--table.insert(admins, 
	end
	if not isGuest and role == "MDEV" then
		
	end
end

function onPlayerConnecting(id)
	print('Player '..MP.GetPlayerName(id)..' ('..id..') connecting.')
	local identifiers = MP.GetPlayerIdentifiers(id)
	for TYPE, ID in pairs(identifiers) do
		--print(TYPE, ID)
		
	end
end

MP.RegisterEvent("onPlayerConnecting","onPlayerConnecting")
