# nomads
This project is about bringing Nomads back as playable faction via featured mod and make a serious attempt to 
integrate them into the main game.

To get nomads working on your PC you need to do a few steps:

1) download the file init_devnomads.lua and place this file into your faf bin directory (C:/ProgramData/FAForever/bin)

2) change the first 2 lines to point to your faf and nomads github repos

3) change your nomads shortcut to run the init file, i.e. create a new shortcut with this target:

C:\ProgramData\FAForever\bin\ForgedAlliance.exe /init init_devnomads.lua /EnableDiskWatch /showlog /log C:\ProgramData\FAForever\logs\dev.log



if you encounter an error like this: 
WARNING: attempt to retrieve annotation from unknown technique NomadUnit
WARNING: c:\work\rts\main\code\src\libs\gpggal\EffectD3D9.cpp(89) invalid effect technique requested: NomadUnit

run the shader_cleaner.bat to fix it



#editor
To run the editor with nomads units you need to do the following steps:

1) go to your sup com installation (not FA) and navigate to the gamedata folder

2) rename the files effects.scd, env.scd, units.scd and textures.scd to the ending .zip

3) copy the content of the nomads directories from your githup repo into the respective archives

4) replace the mesh.fx file in effects.scd/ with the nomads_mesh.fx (rename that file to mesh.fx)

5) rename all .zip files back to .scd

6) go to USERNAME\AppData\Local\Gas Powered Games\SupremeCommander\cache and delete the content of the folder

hope for the best
