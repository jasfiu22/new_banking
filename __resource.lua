lua54 'yes'
client_script('client/client.lua')

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
}

-- Uncomment the desired version 
ui_page('client/html/UI.html') -- French UI
--ui_page('client/html/UI-en.html') -- English UI
--ui_page('client/html/UI-de.html') -- German UI

files {
	'client/html/*.*',
    'client/html/media/font/*.otf',
    'client/html/media/img/*.png',
}
