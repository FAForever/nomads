name = "Hotbuild"
uid = "98785b7a-9e9e-4863-abb3-46aaf1caef80"
version = 10
description = "Zulans hot build mode (Nomads version)"
author = "Zulan"
url = "http://scst.myvowclan.de/hotbuild"
icon = "/mods/hotbuild/textures/mod_icon.dds"
selectable = false
enabled = false
exclusive = false
ui_only = true

requires = {
    '4f8b5ac3-346c-4d25-ac34-7b8ccc14eb0a', # GAZ UI mod, Nomads version
}
requiresNames = {
    ['4f8b5ac3-346c-4d25-ac34-7b8ccc14eb0a'] = "GAZ UI (Nomads version)",
}
conflicts = {
    'E0B71332-D055-11DC-8D93-9BEE55D89593',  # version 9
}
before = { }
after = {
  "4f8b5ac3-346c-4d25-ac34-7b8ccc14eb0a"
}
