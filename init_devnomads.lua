--Rename these paths to where you placed the repositories for FAF and nomads
--you need to use double slashes \\ in the path for it to work. look at the example paths first before overwriting
dev_path = 'G:\\GITS\\fa'
dev_pathnomads = 'G:\\GITS\\nomads'



-- this imports a path file that is written by Forged Alliance Forever right before it starts the game.
dofile(InitFileDir .. '\\..\\fa_path.lua')
path = {}
local function mount_dir(dir, mountpoint)
    table.insert(path, { dir = dir, mountpoint = mountpoint } )
end

local function clear_cache()
    local dir = SHGetFolderPath('LOCAL_APPDATA') .. 'Gas Powered Games\\Supreme Commander Forged Alliance\\cache\\'
    LOG('Clearing cached shader files in: ' .. dir)
    for _,file in io.dir(dir .. '**') do
        if string.find(file, 'mesh') then
            os.remove(dir .. file)
        end
    end
end

local function mount_contents(dir, mountpoint)
    LOG('checking ' .. dir)
    for _,entry in io.dir(dir .. '\\*') do
        if entry != '.' and entry != '..' then
            local mp = string.lower(entry)
            mp = string.gsub(mp, '[.]scd$', '')
            mp = string.gsub(mp, '[.]zip$', '')
            mount_dir(dir .. '\\' .. entry, mountpoint .. '/' .. mp)
        end
    end
end

function mount_mod_sounds(MODFOLDER)
    -- searching for mods inside the modfolder
    for _,mod in io.dir( MODFOLDER..'\\*.*') do
        -- do we have a true directory ?
        if mod != '.' and mod != '..' then
            -- searching for sounds inside mod folder
            for _,folder in io.dir(MODFOLDER..'\\'..mod..'\\*.*') do
                -- if we found a folder named sounds then mount it
                if folder == 'sounds' then
                    LOG('Found mod sounds in: '..mod)
                    mount_dir(MODFOLDER..'\\'..mod..'\\sounds', '/sounds')
                    break
                end
            end
        end
    end
end

-- Clear the shader
clear_cache()

-- This section mounts sounds from the mods directory to allow mods to add custom sounds to the game
mount_mod_sounds(SHGetFolderPath('PERSONAL') .. 'My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\mods')
mount_mod_sounds(InitFileDir .. '\\..\\user\\My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\mods')

-- these are the classic supcom directories. They don't work with accents or other foreign characters in usernames
mount_contents(SHGetFolderPath('PERSONAL') .. 'My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\mods', '/mods')
mount_contents(SHGetFolderPath('PERSONAL') .. 'My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\maps', '/maps')
-- these are the local FAF directories. The My Games ones are only there for people with usernames that don't work in the upper ones.
mount_contents(InitFileDir .. '\\..\\user\\My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\mods', '/mods')
mount_contents(InitFileDir .. '\\..\\user\\My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\maps', '/maps')
mount_dir(dev_pathnomads, '/')
mount_dir(dev_path, '/')
mount_dir(dev_pathnomads .. '\\movies', '/')
-- these are using the newly generated path from the dofile() statement at the beginning of this script
mount_dir(fa_path .. '\\gamedata\\*.scd', '/')
mount_dir(fa_path, '/')
hook = {
    '/schook',
    '/nomadhook',
    '/sounds',
}
protocols = {
    'http',
    'https',
    'mailto',
    'ventrilo',
    'teamspeak',
    'daap',
    'im',
}
