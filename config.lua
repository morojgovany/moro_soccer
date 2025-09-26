Config = {}
Config.ballModel = `mp004_p_goatball_02a`
Config.ballCoords = vector3(-1337.89794921875, -1079.7015380859375, 74.6993408203125) -- spawn and replace coords
Config.startCoords = vector3(-1311.9139404296875, -1075.17333984375, 73.97453308105469) -- prompt coords

Config.blip = { -- blip on map
    enable = true,
    coords = Config.startCoords, -- prompt coords
    sprite = `blip_ball`, -- https://github.com/femga/rdr3_discoveries/tree/045036a6de49e58326db3ddf7e6d6a99d7f0e651/useful_info_from_rpfs/textures/blips_mp
    scale = 0.8,
    color = `BLIP_MODIFIER_MP_COLOR_6`, -- https://github.com/femga/rdr3_discoveries/tree/045036a6de49e58326db3ddf7e6d6a99d7f0e651/useful_info_from_rpfs/blip_modifiers
    name = "Soccer"
}
Config.npc = { -- npc on prompt start
    enable = true,
    model = `cs_sd_streetkid_01a`,
    coords = vector4(-1312.2708740234375, -1075.8756103515625, 74.00108337402344, -30.0),
    distance = 80.0,
}
Config.kick = { -- kick animation
    dict = 'mech_melee@blade@_male@_ambient@_healthy@intimidation@_streamed',
    name = 'att_haymaker_head_rightside_dist_near_v1',
}
Config.hitDistance = 1.2 -- min distance to hit ball

Config.props = { -- props to be spawned, feel free to add more
    {
        model = `mp001_s_mprockline_18m`,
        coords = vec3(-1334.180054,-1088.959961,74.250000),
        rotation = vec3(0.000000,-1.000000,180.000000),
        collision = false,
    },
    {
        model = `mp001_s_mprockcircle_10m`,
        coords = vec3(-1337.897949,-1079.701538,74.468315),
        rotation = vec3(0.000000,0.000000,-179.880569),
        collision = false,
    },
    {
        model = `mp001_s_mprockcircle01x`,
        coords = vec3(-1326.329590,-1079.796509,74.202545),
        rotation = vec3(0.000000,0.000000,-91.436020),
        collision = false,
    },
    {
        model = `mp001_s_mprockline_9m`,
        coords = vec3(-1346.760010,-1088.959961,74.589996),
        rotation = vec3(0.000000,-3.999996,178.999985),
        collision = false,
    },
    {
        model = `mp001_s_mprockline_9m`,
        coords = vec3(-1345.922729,-1070.051147,74.549950),
        rotation = vec3(0.000000,0.000000,-0.698789),
        collision = false,
    },
    {
        model = `mp001_s_mprockline_18m`,
        coords = vec3(-1350.338135,-1079.275269,74.699997),
        rotation = vec3(0.000000,2.000000,90.000000),
        collision = false,
    },
    {
        model = `mp001_s_mprockline_18m`,
        coords = vec3(-1324.336670,-1079.686157,74.129997),
        rotation = vec3(0.000000,0.000000,-91.250397),
        collision = false,
    },
    {
        model = `mp001_s_mprockline_18m`,
        coords = vec3(-1333.346313,-1070.205078,74.389999),
        rotation = vec3(0.000000,-1.000000,179.066452),
        collision = false,
    },
    {
        model = `mp001_s_mprockcircle01x`,
        coords = vec3(-1348.222168,-1079.598389,74.555054),
        rotation = vec3(0.000000,0.000000,86.265511),
        collision = false,
    },
}
-- Whistle soundsets
-- https://github.com/femga/rdr3_discoveries/blob/045036a6de49e58326db3ddf7e6d6a99d7f0e651/audio/soundsets/soundsets.lua#L10
Config.startWhristle = {
    soundRef = 'NBD1_Sounds',
    soundName = 'POLICE_WHISTLE_SINGLE',
}
Config.goalWhistle = {
    soundRef = 'GNG3_Sounds',
    soundName = 'POLICE_WHISTLE_MULTI',
}
Config.stopWhistle = {
    soundRef = 'GNG3_Sounds',
    soundName = 'POLICE_WHISTLE_MULTI',
}
Config.outOfBoundsWhistle = {
    soundRef = 'NBD1_Sounds',
    soundName = 'POLICE_WHISTLE_MULTI',
}

Config.replaceBallIfOutOfBounds = true -- replace ball if out of bounds / need field to be set if true
Config.field = PolyZone:Create({ -- field coords, must be set if replaceBallIfOutOfBounds is true
    vector2(-1350.4071044922, -1070.0439453125),
    vector2(-1324.1361083984, -1070.1440429688),
    vector2(-1324.456665039, -1088.9881591796),
    vector2(-1350.2575683594, -1088.9610595704)
}, {
    name = "Soccer",
})
-- ball physics
Config.minKickVelocity = 8.0
Config.maxKickVelocity = 12.0
Config.lobedKickZAxis = 10.0
-- translations
Config.promptGroup = "Soccer ball"
Config.kickPrompt = "Hit ball"
Config.lobedPrompt = "Lobe ball"
Config.startPrompt = "Start soccer"
Config.startPromptGroup = "Soccer field"
Config.stopPrompt = "Stop soccer"
Config.goalNotification = "Goal!"
Config.gameStarts = "Game is starting"
Config.gameEnds = "Game is over"
-- keybinds
Config.kickPromptKey = 0xCEFD9220 -- Default E
Config.lobedPromptKey = 0xE30CD707 -- Default R
Config.startPromptKey = 0x760A9C6F -- Default G
Config.stopPromptKey = 0xE30CD707 -- Default R
-- goal detection
Config.useEntityGoal = true -- need goalEntities to be set if true / if false you have to count points manually
Config.goalEntities = { -- to count goals auto
    [1] = {
        model = `mp007_p_fishnet_damage01x`,
        coords = vec3(-1350.339966,-1079.510010,74.729813),
        rotation = vec3(90.000000,-0.000005,87.000000),
    },
    [2] = {
        model = `mp007_p_fishnet_damage01x`,
        coords = vec3(-1324.300049,-1079.952759,74.132185),
        rotation = vec3(90.000000,-0.000005,-92.000000),
    },
}

Config.notificationDistance = 100.0 -- distance to notify players and spectators of score (from ball start coords)
RegisterNetEvent('moro_soccer:notify')
AddEventHandler('moro_soccer:notify', function(_source, message)
    -- replace with your notification system
    TriggerClientEvent('vorp:TipRight', _source, message, 4000) -- vorp default
end)
