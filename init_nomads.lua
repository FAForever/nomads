local function mount_dir(dir, mountpoint)
    table.insert(path, { dir = dir, mountpoint = mountpoint })
end
local function mount_contents(dir, mountpoint)
    LOG('checking '..dir)
    for _,entry in io.dir(dir..'\\*') do
        if entry != '.' and entry != '..' then
            local mp = string.lower(entry)
            mp = string.gsub(mp, '[.]scd$', '')
            mp = string.gsub(mp, '[.]zip$', '')
            mount_dir(dir..'\\'..entry, mountpoint..'/'..mp)
        end
    end
end

local function clear_cache()
    local dir = SHGetFolderPath('LOCAL_APPDATA') .. 'Gas Powered Games\\Supreme Commander Forged Alliance\\cache\\'
    LOG('Clearing cached shader files in: ' .. dir)
    for _,file in io.dir(dir .. '**') do
        if string.find(file, 'mesh') or string.find(file, 'particle') then
            os.remove(dir .. file)
        end
    end
end

-- Start, do original datapath file
dofile(InitFileDir..'\\SupComDataPath.lua')
-- Add our own hook to the list. Used to make our files overwrite existing files to ensure flawless operation.
table.insert(hook, '/nomadhook')
table.insert(hook, '/sounds')

-- Clear the shader
clear_cache()

-- Now add our files to the path table. This is a bit tricky cause we need our files to be first in the list or
-- we'll get all kinds of issues (simplest check: is there a weird icon in the campaign manager window? If yes then
-- there are issues).
local oldPath = path
path = {}
mount_dir(InitFileDir..'\\..\\movies', '/')
mount_dir(InitFileDir..'\\..\\gamedata\\units.nmd', '/')
mount_dir(InitFileDir..'\\..\\gamedata\\textures.nmd', '/')
mount_dir(InitFileDir..'\\..\\gamedata\\sounds.nmd', '/')
mount_dir(InitFileDir..'\\..\\gamedata\\effects.nmd', '/')
mount_dir(InitFileDir..'\\..\\gamedata\\env.nmd', '/')
mount_dir(InitFileDir..'\\..\\gamedata\\nomadhook.nmd', '/')
mount_dir(InitFileDir..'\\..\\gamedata\\lua.nmd', '/')
mount_dir(InitFileDir..'\\..\\gamedata\\projectiles.nmd', '/')
mount_dir(InitFileDir..'\\..\\gamedata\\loc.nmd', '/')
mount_dir(InitFileDir..'\\..\\gamedata\\meshes.nmd', '/')

--load preferences into the game as well, letting us have much more control over their contents. This also includes cache and similar.
mount_dir(SHGetFolderPath('LOCAL_APPDATA') .. 'Gas Powered Games\\Supreme Commander Forged Alliance', '/preferences')

for k, v in oldPath do
    table.insert(path, v)
end

-- All done!
