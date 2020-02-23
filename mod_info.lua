name = "Nomads"
version = 90
copyright = "brute51"
description = "Adds the Nomads, a fully fledged fifth faction to the game. Required for playing the custom Nomads campaign."
author = "Armaster, Ninrai, Savi, StevenC21, Shadowlord1, Uveso, JJsAI, Exotic_Retard, Brute51, and many more"
uid = "42687514-4d8b-4ed3-9122-nomadsv00090"
url = ""
icon = ""
identifier = ""
selectable = false
exclusive = false
enabled = true
ui_only = false
requires = { }
requiresNames = { }
conflicts = { }
before = { }
after = { }
_faf_modname='Nomads'
mountpoints = {
    ['effects'] = '/effects',
    ['env'] = '/env',
    ['loc'] = '/loc',
    ['lua'] = '/lua',
    ['meshes'] = '/meshes',
    ['movies'] = '/movies',
    ['nomadhook'] = '/nomadhook',
    ['projectiles'] = '/projectiles',
    ['sounds'] = '/sounds',
    ['textures'] = '/textures',
    ['units'] = '/units',
}
hooks = {
    '/nomadhook',
    '/sounds',
}