name = "Nomads"
version = 85
copyright = "brute51"
description = "Adds a new faction to the game"
author = "CookieNoob, Exotic_Retard, Brute51, original nomads team"
uid = "87635264-9r3e-e38s-5kr8-nomadsv00085"
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