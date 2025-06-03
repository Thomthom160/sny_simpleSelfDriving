fx_version 'cerulean'
game 'gta5'

author 'SANDY#6078'
description 'Standalone simple self driving resource'
version '1.1.1'
lua54 'yes'

ui_page 'client/html/index.html'

shared_scripts { 
    '@ox_lib/init.lua',
}

files {
    'client/html/sounds/*.mp3',
    'client/html/js/*.js',
    'client/html/*.html'
}

client_scripts {
    'lang/*.json',
    'config.lua',
    'client/cl_fn_main.lua',
    'client/cl_main.lua'
}