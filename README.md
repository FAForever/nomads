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


hope for the best
