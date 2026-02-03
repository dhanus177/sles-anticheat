-- Known Cheat Engines, Hack Menus, and Mod Menus
CheatDatabase = {}

-- Process names (for client-side detection if possible)
CheatDatabase.Processes = {
    -- Cheat Engines
    "cheatengine",
    "cheatengine-x86_64",
    "artmoney",
    "gameguardian",
    
    -- Mod Menus
    "eulen",
    "redengine",
    "lynx",
    "modestmenu",
    "stand",
    "cherax",
    "kiddions",
    "2take1",
    
    -- Injectors
    "xenos",
    "extreme_injector",
    "processhacker",
    "x64dbg",
}

-- Window titles to detect
CheatDatabase.WindowTitles = {
    "Cheat Engine",
    "ArtMoney",
    "Process Hacker",
    "Eulen",
    "RedEngine",
    "Lynx Menu",
    "Modest Menu",
    "Stand",
    "x64dbg",
}

-- Known executor patterns
CheatDatabase.ExecutorPatterns = {
    "eulen.lua",
    "mod_menu",
    "cheat_menu",
    "executor",
}

-- Suspicious resource names
CheatDatabase.SuspiciousResources = {
    "eulen",
    "lynx",
    "redengine",
    "modestmenu",
    "stand",
    "cherax",
    "executor",
    "inject",
    "blum",
    "blumpanel",
    "blum-panel",
    "blum_panel",
    "blummenu",
    "xmenu",
    "x-menu",
    "dpanel",
    "d-panel",
    "cipher",
    "cipherpanel",
}
