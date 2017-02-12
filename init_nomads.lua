#################################################################################################
## VARIABLES
#################################################################################################

# Edit these where needed.

# Where can the uncompressed nomads files be found? Specify full path, with drive letter. Escape each \ with another \ . So for
# each \ in the path there should be 2. Example: C:\\games\\Nomads mod\\files
local DevPath = ''

# Nomads datafile name + extension (in case we're not using DevPath)
local File = 'nomads.nmd'

#################################################################################################
## DO NOT EDIT
#################################################################################################

# Some functions
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
        if string.find(file, 'mesh') then
            os.remove(dir .. file)
        end
    end
end

########

# Start, do original datapath file
dofile(InitFileDir..'\\SupComDataPath.lua')
# Add our own hook to the list. Used to make our files overwrite existing files to ensure flawless operation.
table.insert(hook, '/nomadhook')
table.insert(hook, '/sounds')

# Clear the shader
clear_cache()

# Now add our files to the path table. This is a bit tricky cause we need our files to be first in the list or
# we'll get all kinds of issues (simplest check: is there a weird icon in the campaign manager window? If yes then
# there are issues).
local oldPath = path
path = {}
mount_dir(InitFileDir..'\\..\\gamedata\\'..File, '/')
mount_dir(InitFileDir..'\\..\\gamedata\\nomadsmovie','/')
for k, v in oldPath do
    table.insert(path, v)
end

# All done!
