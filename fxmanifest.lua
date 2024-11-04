fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

description 'mri_Qshops'
credits 'felps.j.j, mur4i, wasabirobby#5110'
version '2.0.1'
ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'bridge/framework.lua'
}

client_scripts {
    'bridge/**/client.lua',
    'client/*.lua'
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'bridge/**/server.lua',
    'server/*.lua'
}

files {
    'locales/*.json',
}

dependencies {
    "qbx_core",
    "ox_lib",
    'ox_inventory'
}
