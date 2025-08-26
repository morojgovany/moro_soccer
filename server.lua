local soccerStarted = false
local score = {}

local function resetScores()
    score = {}
    local goals = Config.goalEntities
    for i = 1, #goals do
        score[i] = 0
    end
end

local function notifyPlayers(message, originCoords)
    local players = GetPlayers()
    for i = 1, #players do
        local playerId = tonumber(players[i])
        local ped = GetPlayerPed(playerId)
        if ped then
            local coords = GetEntityCoords(ped)
            if #(coords - originCoords) <= Config.notificationDistance + 0.0 then
                TriggerEvent('moro_soccer:notify', playerId, message)
            end
        end
    end
end

resetScores()

RegisterNetEvent('moro_soccer:startSoccer')
AddEventHandler('moro_soccer:startSoccer', function()
    soccerStarted = true
    TriggerClientEvent('moro_soccer:startSoccer', -1)
    notifyPlayers(Config.gameStarts, Config.ballCoords)
    local players = GetPlayers()
    if #players > 0 then
        local randomIndex = math.random(1, #players)
        local randomPlayer = players[randomIndex]
        TriggerClientEvent('moro_soccer:spawnBall', randomPlayer)
    end
end)

RegisterNetEvent('moro_soccer:stopSoccer')
AddEventHandler('moro_soccer:stopSoccer', function()
    soccerStarted = false
    local finalScore = table.concat(score, ' - ')
    resetScores()
    TriggerClientEvent('moro_soccer:stopSoccer', -1)
    notifyPlayers(Config.gameEnds .. ' | Final score : '..finalScore, Config.ballCoords)
end)

RegisterNetEvent('moro_soccer:shareBall')
AddEventHandler('moro_soccer:shareBall', function(netId)
    TriggerClientEvent('moro_soccer:shareBall', -1, netId)
end)

RegisterNetEvent('moro_soccer:ballOutOfBounds')
AddEventHandler('moro_soccer:ballOutOfBounds', function()
    TriggerClientEvent('moro_soccer:ballOutOfBounds', -1)
end)

RegisterNetEvent('moro_soccer:soccerStarted')
AddEventHandler('moro_soccer:soccerStarted', function()
    local _source = source
    TriggerClientEvent('moro_soccer:soccerStarted', _source, soccerStarted)
    TriggerClientEvent('moro_soccer:setScores', _source, score)
end)

RegisterNetEvent('moro_soccer:goal')
AddEventHandler('moro_soccer:goal', function(goalIndex, ballCoords)
    score[goalIndex] = score[goalIndex] + 1
    TriggerClientEvent('moro_soccer:goal', -1)
    TriggerClientEvent('moro_soccer:setScores', -1, score)

    local scoreText = table.concat(score, ' - ')
    local message = Config.goalNotification..' Score '..scoreText
    notifyPlayers(message, ballCoords)
end)
