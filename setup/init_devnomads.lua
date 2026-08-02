--Rename this path to where you placed the repositories for  nomads
dev_pathnomads = 'your-nomads-repository-location'

-- **Make sure you also have the file "init_local_development.lua" set up**

-- Start, do original init development file, which does multiple things:
-- - Adds the base game files to `path`.
-- - Adds the map/mod vault files to `path`.
-- - Clears the shader cache.
dofile(InitFileDir .. '\\init_local_development.lua')

-- Add our own hook to the list. Used to make our files overwrite existing files to ensure flawless operation.
table.insert(hook, '/nomadhook')
table.insert(hook, '/sounds')

-- Now add our files to the path table. This is a bit tricky cause we need our files to be first in the list or
-- we'll get all kinds of issues (simplest check: is there a weird icon in the campaign manager window? If yes then
-- there are issues).
table.insert(path, 1, {
    dir = dev_pathnomads,
    mountpoint = '/'
})
table.insert(path, 2, {
    dir = dev_pathnomads .. '\\movies',
    mountpoint = '/'
})

-- Inserting into the global path table directly breaks the original init file's `MountDirectory` function,
-- but as that function operates only locally in that file, and it is now inaccessible, this should be fine.
