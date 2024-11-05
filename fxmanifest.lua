fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'btc_fines'
author 'Betiucia'
version '1.0'

shared_scripts {
    '@jo_libs/init.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'langague.lua'
}


client_scripts {
    'client.lua',

}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

dependencies {
    'rsg-core',
    'jo_libs',
    'ox_lib',
}

ui_page "nui://jo_libs/nui/menu/index.html"

jo_libs {
    'notification',
    'menu',
    'callback',
}


lua54 'yes'
