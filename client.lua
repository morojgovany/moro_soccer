local ball = nil
local spawnedProps = {}
local soccerStarted = false
local promptGroup = GetRandomIntInRange(0, 0xffffff)
local startGroup = GetRandomIntInRange(0, 0xffffff)
local stopPrompt = nil
local startPrompt = nil
local hitPrompt = nil
local lobedPrompt = nil
local blip = nil
local npc = nil
local score = {}
local goalEntities = {}

local function resetScores()
    score = {}
    for i = 1, #Config.goalEntities do
        score[i] = 0
    end
end

resetScores()

local function loadBlip()
    if Config.blip.enable then
        blip = BlipAddForCoords(1664425300, Config.blip.coords.x, Config.blip.coords.y, Config.blip.coords.z)
        SetBlipSprite(blip, Config.blip.sprite, true)
        SetBlipScale(blip, 1.0)
        Citizen.InvokeNative(0x662D364ABF16DE2F, blip, Config.blip.color)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.blip.name)
    end
end


local function loadPrompts()
    if hitPrompt then
        PromptDelete(hitPrompt)
    end
    local str = CreateVarString(10, 'LITERAL_STRING', Config.kickPrompt)
    hitPrompt = PromptRegisterBegin()
    PromptSetControlAction(hitPrompt, Config.kickPromptKey)
    PromptSetText(hitPrompt, str)
    PromptSetEnabled(hitPrompt, 1)
    PromptSetVisible(hitPrompt, 1)
    PromptSetStandardMode(hitPrompt, 1)
    PromptSetGroup(hitPrompt, promptGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, hitPrompt, true)
    PromptRegisterEnd(hitPrompt)

    if lobedPrompt then
        PromptDelete(lobedPrompt)
    end
    local str = CreateVarString(10, 'LITERAL_STRING', Config.lobedPrompt)
    lobedPrompt = PromptRegisterBegin()
    PromptSetControlAction(lobedPrompt, Config.lobedPromptKey)
    PromptSetText(lobedPrompt, str)
    PromptSetEnabled(lobedPrompt, 1)
    PromptSetVisible(lobedPrompt, 1)
    PromptSetStandardMode(lobedPrompt, 1)
    PromptSetGroup(lobedPrompt, promptGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, lobedPrompt, true)
    PromptRegisterEnd(lobedPrompt)

    if startPrompt then
        PromptDelete(startPrompt)
    end
    local str = CreateVarString(10, 'LITERAL_STRING', Config.startPrompt)
    startPrompt = PromptRegisterBegin()
    PromptSetControlAction(startPrompt, Config.startPromptKey)
    PromptSetText(startPrompt, str)
    PromptSetEnabled(startPrompt, 1)
    PromptSetVisible(startPrompt, 1)
    PromptSetStandardMode(startPrompt, 1)
    PromptSetGroup(startPrompt, startGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, startPrompt, true)
    PromptRegisterEnd(startPrompt)

    if stopPrompt then
        PromptDelete(stopPrompt)
    end
    local str = CreateVarString(10, 'LITERAL_STRING', Config.stopPrompt)
    stopPrompt = PromptRegisterBegin()
    PromptSetControlAction(stopPrompt, Config.stopPromptKey)
    PromptSetText(stopPrompt, str)
    PromptSetEnabled(stopPrompt, 0)
    PromptSetVisible(stopPrompt, 1)
    PromptSetStandardMode(stopPrompt, 1)
    PromptSetGroup(stopPrompt, startGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, stopPrompt, true)
    PromptRegisterEnd(stopPrompt)
end

local function loadModel(model)
    if IsModelInCdimage(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end
    end
    return model
end

local function spawnBall()
    loadModel(Config.ballModel)
    ball = CreateObjectNoOffset(Config.ballModel, Config.ballCoords, true, true, false)
    PlaceEntityOnGroundProperly(ball)
    SetEntityAsMissionEntity(ball, true, true)
    SetEntityVisible(ball, true)
    SetEntityCollision(ball, true, true)
    SetEntityInvincible(ball, true)
    NetworkRegisterEntityAsNetworked(ball)
    local netId = ObjToNet(ball)
    while not NetworkDoesNetworkIdExist(netId) do
        Wait(250)
        netId = ObjToNet(ball)
    end
    SetNetworkIdExistsOnAllMachines(netId, true)
    Wait(250)
    TriggerServerEvent('moro_soccer:shareBall', netId)
end

local function spawnProp(model, coords, rotation, collision)
    local modelHash = loadModel(model)
    local obj = CreateObjectNoOffset(modelHash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityRotation(obj, rotation.x, rotation.y, rotation.z, 2, true)
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, collision, true)
    SetEntityInvincible(obj, true)
    SetEntityVisible(obj, true)
    spawnedProps[#spawnedProps + 1] = obj
    return obj
end

local function spawnProps()
    for _, v in pairs(Config.props) do
        spawnProp(v.model, v.coords, v.rotation, v.collision)
    end
    if Config.useEntityGoal then
        for _, v in pairs(Config.goalEntities) do
            goalEntities[#goalEntities + 1] = spawnProp(v.model, v.coords, v.rotation, true)
        end
    end
end

local function spawnNpc()
    if npc then
        print('NPC already spawned')
        return
    end
    local model = loadModel(Config.npc.model)
    npc = CreatePed(model, Config.npc.coords.x, Config.npc.coords.y, Config.npc.coords.z, Config.npc.coords.w, false, false, false, false)
    SetRandomOutfitVariation(npc, true)
    PlaceEntityOnGroundProperly(npc, false)
    FreezeEntityPosition(npc, true)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityVisible(npc, true)
end

local function deleteNpc()
    if npc and DoesEntityExist(npc) then
        DeleteEntity(npc)
        npc = nil
    end
end

-- Play whistle sound at player's position
local function playWhistle(whistle)
    soundRef = whistle.soundRef or "NBD1_Sounds"
    local soundName = whistle.soundName or "POLICE_WHISTLE_SINGLE"
    local attempts = 1
    while soundRef ~= 0 and not Citizen.InvokeNative(0xD9130842D7226045, soundRef, 0) and attempts <= 300 do
        attempts = attempts + 1
        Wait(0)
    end
    if soundRef == 0 or Citizen.InvokeNative(0xD9130842D7226045, soundRef, 0) then
        Citizen.InvokeNative(0xCCE219C922737BFA, soundName, Config.ballCoords, soundRef, false, 0, false, 0) -- play on ball position
        Citizen.CreateThread(function()
            Wait(2000)
            Citizen.InvokeNative(0x531A78D6BF27014B, soundRef)
        end)
    end
end

Citizen.CreateThread(function()
    if IsLoadingScreenVisible() or IsScreenFadedOut() then
        repeat Wait(500) until not IsLoadingScreenVisible() and not IsScreenFadedOut()
    end
    if Config.blip.enable then
        loadBlip()
    end
    if Config.npc.enable then
        local npcCoords = vector3(Config.npc.coords.x, Config.npc.coords.y, Config.npc.coords.z)
        while true do
            local wait = 1000
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist = #(playerCoords - npcCoords)
            if dist < Config.npc.distance then
                wait = 0
                if not npc then
                    spawnNpc()
                end
            elseif npc then
                deleteNpc()
            end
            Wait(wait)
        end
    end
end)

local function hitBall(lobed)
    if not ball then return end
    local playerPed = PlayerPedId()
    local forwardVector = GetEntityForwardVector(playerPed)
    local velocity = (forwardVector * math.random(Config.minKickVelocity, Config.maxKickVelocity)) + 0.0
    RequestAnimDict(Config.kick.dict)
    while not HasAnimDictLoaded(Config.kick.dict) do
        Wait(10)
    end
    TaskPlayAnim(playerPed, Config.kick.dict, Config.kick.name, 5.0, 8.0, 1000, 2, 0, false, false, false)
    Wait(400)
    if lobed then
        velocity = vector3(velocity.x - 2.0, velocity.y - 2.0, (velocity.z - 2.0) + Config.lobedKickZAxis)
    end
    if not NetworkHasControlOfEntity(ball) then
        NetworkRequestControlOfEntity(ball)
        local startTime = GetGameTimer()
        while not NetworkHasControlOfEntity(ball) and (GetGameTimer() - startTime) < 1000 do
            NetworkRequestControlOfEntity(ball)
            Wait(10)
        end
    end
    if not NetworkHasControlOfEntity(ball) then return end
    SetEntityVelocity(ball, velocity.x, velocity.y, velocity.z)
end

Citizen.CreateThread(function()
    if IsLoadingScreenVisible() or IsScreenFadedOut() then
        repeat Wait(500) until not IsLoadingScreenVisible() and not IsScreenFadedOut()
    end
    Wait(math.random(500, 2000))
    TriggerServerEvent('moro_soccer:soccerStarted')
    loadPrompts()
    while true do
        local waitTime = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local dist = #(coords - Config.startCoords)
        if dist < 1.5 then
            if not IsPedDeadOrDying(playerPed)
                and not IsPedOnMount(playerPed)
                and not IsPedInCombat(playerPed)
                and not IsPedInMeleeCombat(playerPed) then
                waitTime = 0
                PromptSetActiveGroupThisFrame(startGroup, CreateVarString(10, 'LITERAL_STRING', Config.startPromptGroup))
                if Citizen.InvokeNative(0xC92AC953F0A982AE, startPrompt) then
                    TriggerServerEvent('moro_soccer:startSoccer')
                    Wait(1000)
                end
                if Citizen.InvokeNative(0xC92AC953F0A982AE, stopPrompt) then
                    TriggerServerEvent('moro_soccer:stopSoccer')
                    Wait(1000)
                end
            end
        end
        Wait(waitTime)
    end
end)

RegisterNetEvent('moro_soccer:startSoccer')
AddEventHandler('moro_soccer:startSoccer', function()
    soccerStarted = true
    PromptSetEnabled(stopPrompt, 1)
    PromptSetEnabled(startPrompt, 0)
    Citizen.CreateThread(function()
        spawnProps()
        local startTime = GetGameTimer()
        local timeoutMs = 2000
        playWhistle(Config.startWhristle)
        if not ball then
            repeat Wait(500) until ball or (GetGameTimer() - startTime) > timeoutMs
        end
        while soccerStarted and ball do
            local waitTime = 150
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local ballCoords = GetEntityCoords(ball)
            local distance = #(playerCoords - ballCoords)
            if Config.replaceBallIfOutOfBounds and NetworkHasControlOfEntity(ball) then
                if not Config.field:isPointInside(ballCoords) then
                    SetEntityCoords(ball, Config.ballCoords.x, Config.ballCoords.y, Config.ballCoords.z, false, false, false, false)
                    FreezeEntityPosition(ball, true)
                    SetEntityVelocity(ball, 0.0, 0.0, 0.0)
                    PlaceEntityOnGroundProperly(ball)
                    FreezeEntityPosition(ball, false)
                    TriggerServerEvent('moro_soccer:ballOutOfBounds')
                    Wait(100)
                end
            end
            if distance <= Config.hitDistance then
                if not IsPedDeadOrDying(playerPed)
                    and not IsPedOnMount(playerPed)
                    and not IsPedInCombat(playerPed)
                    and not IsPedInMeleeCombat(playerPed) then
                    waitTime = 0
                    PromptSetActiveGroupThisFrame(promptGroup, CreateVarString(10, 'LITERAL_STRING', Config.promptGroup))
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, hitPrompt) then
                        hitBall()
                        Wait(100)
                    end
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, lobedPrompt) then
                        hitBall(true)
                        Wait(100)
                    end
                end
            end
            if Config.useEntityGoal then
                for k, v in pairs(goalEntities) do
                    local ballCoords = GetEntityCoords(ball)
                    local goalCoords = GetEntityCoords(goalEntities[k])
                    if #(ballCoords - goalCoords) < 2.5 then
                        waitTime = 0
                    end
                    if Citizen.InvokeNative(0x9A2304A64C3C8423, goalEntities[k], ball) then
                        TriggerServerEvent('moro_soccer:goal', k, ballCoords)
                        SetEntityCoords(ball, Config.ballCoords.x, Config.ballCoords.y, Config.ballCoords.z, false, false, false, false)
                        FreezeEntityPosition(ball, true)
                        SetEntityVelocity(ball, 0.0, 0.0, 0.0)
                        PlaceEntityOnGroundProperly(ball)
                        FreezeEntityPosition(ball, false)
                        Wait(5000)
                    end
                end
            end
            Wait(waitTime)
        end
    end)
end)

RegisterNetEvent('moro_soccer:stopSoccer')
AddEventHandler('moro_soccer:stopSoccer', function()
    soccerStarted = false
    playWhistle(Config.stopWhistle)
    if DoesEntityExist(ball) then
        DeleteEntity(ball)
        ball = nil
    end
    if goalEntities then
        for k, v in pairs(goalEntities) do
            if DoesEntityExist(v) then
                DeleteEntity(v)
            end
        end
        goalEntities = {}
    end
    for k, v in pairs(spawnedProps) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    spawnedProps = {}
    resetScores()
    PromptSetEnabled(stopPrompt, 0)
    PromptSetEnabled(startPrompt, 1)
end)

RegisterNetEvent('moro_soccer:soccerStarted')
AddEventHandler('moro_soccer:soccerStarted', function(started)
    if started then
        TriggerEvent('moro_soccer:startSoccer')
        soccerStarted = true
    end
end)

RegisterNetEvent('moro_soccer:spawnBall')
AddEventHandler('moro_soccer:spawnBall', function()
    spawnBall()
end)

RegisterNetEvent('moro_soccer:ballOutOfBounds')
AddEventHandler('moro_soccer:ballOutOfBounds', function()
    playWhistle(Config.outOfBoundsWhistle)
end)

RegisterNetEvent('moro_soccer:goal')
AddEventHandler('moro_soccer:goal', function()
    playWhistle(Config.goalWhistle)
end)

RegisterNetEvent('moro_soccer:setScores')
AddEventHandler('moro_soccer:setScores', function(newScore)
    score = newScore
end)

RegisterNetEvent('moro_soccer:shareBall')
AddEventHandler('moro_soccer:shareBall', function(netId)
    if not ball then
        ball = NetToObj(netId)
        if not DoesEntityExist(ball) or GetEntityCoords(ball) == vector3(0.0, 0.0, 0.0) then
            ball = nil
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if DoesEntityExist(ball) then
            DeleteEntity(ball)
        end
        for k, v in pairs(spawnedProps) do
            if DoesEntityExist(v) then
                DeleteEntity(v)
            end
        end
        if hitPrompt then
            PromptDelete(hitPrompt)
            hitPrompt = nil
        end
        if blip then
            RemoveBlip(blip)
            blip = nil
        end
        if npc and DoesEntityExist(npc) then
            DeleteEntity(npc)
            npc = nil
        end
    end
end)
