fx_version 'cerulean'
game 'gta5'

author 'Thomthom160'
description 'Standalone simple self driving resource'
version '1.2.0'
lua54 'yes'

ui_page 'client/html/index.html'

shared_script '@ox_lib/init.lua'

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