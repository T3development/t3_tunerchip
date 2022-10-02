fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 't3mpu5'
description 't3_tunerchip'
version '1.0.0'

ui_page 'html/index.html'

client_scripts {
    'config.lua',
	'client/main.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'config.lua',
	'server/main.lua',
}

files {
	'html/index.html',
    'html/script.js',
    'html/style.css',
    'html/images/*.png',
}