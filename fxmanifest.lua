fx_version 'cerulean'
game 'gta5'

author 'SLES'
description 'Advanced Anti-Cheat for FiveM RP Server'
version '1.0.0'

shared_scripts {
    'config.lua'
}

server_scripts {
    'server/ban_manager.lua',
    'server/hwid_ban.lua',
    'server/player_stats.lua',
    'server/screenshot.lua',
    'server/framework_protection.lua',
    'server/backdoor_detection.lua',
    'server/cipher_panel_detection.lua',
    'server/detections.lua',
    'server/behavioral.lua',
    'server/admin_commands.lua',
    'server/admin_panel.lua',
    'server/txadmin_integration.lua',
    'server/main.lua'
}

client_scripts {
    'client/process_check.lua',
    'client/integrity_check.lua',
    'client/screen_check.lua',
    'client/enhanced_main.lua',
    'client/admin_tools.lua',
    'client/admin_panel.lua',
    'client/cipher_backdoor_check.lua',
    'client/download_prompt.lua',
    'client/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/logo.png'
}

shared_scripts {
    'shared/cheat_database.lua'
}
