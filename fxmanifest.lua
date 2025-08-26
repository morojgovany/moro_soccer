fx_version "adamant"
game 'rdr3'
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
lua54 'yes'
name "moro_soccer"
startup_message "moro_soccer loaded successfully!"
author "Morojgovany"
description "Soccer game for redm"

shared_scripts {
    '@PolyZone/client.lua',
    "config.lua",
}
client_script {
    'client.lua',
}
server_script {
    'server.lua',
}

dependencies {
    'PolyZone',
}
