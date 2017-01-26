# nomads
This project is about bringing Nomads back as playable faction via featured mod and make a serious attempt to 
integrate them into the main game.

To get nomads working on your PC you need to do a few steps:

1) download the file init_devnomads.lua and place this file into your faf bin directory (C:/ProgramData/FAForever/bin)

2) change the first 2 lines to point to your faf and nomads github repos

3) change your nomads shortcut to run the init file, i.e. create a new shortcut with this target:

C:\ProgramData\FAForever\bin\ForgedAlliance.exe /init init_devnomads.lua /EnableDiskWatch /showlog /log C:\ProgramData\FAForever\logs\dev.log



if you encounter an error like this: 
WARNING: attempt to retrieve annotation from unknown technique NomadsUnit
WARNING: c:\work\rts\main\code\src\libs\gpggal\EffectD3D9.cpp(89) invalid effect technique requested: NomadsUnit

run the shader_cleaner.bat to fix it



# Map Editor
To run the Map Editor with nomads units you need to do the following steps:

1) Paste *nomads_mesh.fx* file into *effects* folder and rename it to *mesh.fx*

2) Pack *effects, env, textures, units* folders from this repository into *Z_nomads.scd* using Winrar or similar (needs to be set as *.zip* NOT *.rar*)

3) remove the mesh.fx file from the *effects* folder of the repository again

4) Paste *Z_nomads.scd* into Supcom *gamedata* folder `THQ\Gas Powered Games\Supreme Commander\gamedata`

5) Go to `%USERNAME%\AppData\Local\Gas Powered Games\SupremeCommander\cache` and delete the content of the folder
