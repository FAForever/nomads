-- This is kinda destructive. We're overriding the stock file with this one but hooking is not done yet so that may yet
-- be succesfull. Other than the localization loading stuff nothing is changed. This file now supports 3rd party
-- localization files.

local loc_table

-- ===========================================================================================
-- Modified the localization scripts to allow 3rd party localizations like the one for Nomads.
-- To use, put in the folder /loc a new lua file, it's name is not important but should not
-- conflict with other mods. This lua file should contain 1 line; for Nomads this is:
--
--         StringsDB = { 'nomads_strings', }
--
-- This tells the script below to look for a file called 'nomads_strings.lua' and use it's
-- contents as localization strings. The file 'nomads_strings.lua' can be in any of the language
-- subdirectories. There should always be such a file in the 'us' subdirectory of /loc (so
-- /lua/us/). This is the fallback directory in case no localization for the given language
-- exists. It is possible to specify multiple files by providing multiple values in the table.

local function MakeFileName( file )
    return file..'.lua'
end

local function MakeFilePath(la, file)
    return '/loc/' .. la .. '/'.. MakeFileName(file)
end

local function okLanguage(la)
    -- see if given language exists. We do this by checking for the default supcom database file which should always exist if
    -- it's a proper language.

    local file = 'strings_db'

    -- check if given language is good
    if la ~= '' and exists( MakeFilePath(la, file) ) then
        return la
    end

    -- if given language is not ok, check if we can use english instead
    if exists( MakeFilePath('us', file) ) then
        return 'us'
    end

    -- if still not ok find the first one that fits and use it
    local f = '*' .. MakeFileName( file )
    local dbfiles = DiskFindFiles('/loc', f)
    la = string.gsub(dbfiles[1], ".*/(.*)/.*", "%1")
    return la
end

local function loadLanguage(la)

    local stringFiles = { 'strings_db', }

    -- get me a good language
    local la = okLanguage(la)
    __language = la

    if HasLocalizedVO(la) then
        AudioSetLanguage(la)
    else
        AudioSetLanguage('us')
    end

    -- now load all available strings databases. These should be in /loc/*.lua. Filtering out any file not directly in /loc/
    local path = '/loc'
    local len = string.len( path ) + 2
    files = DiskFindFiles(path, '*.lua')
    for k, file in files do
        local substr = string.sub( file, len )    -- /loc/us/strings_db.lua  ->  us/strings_db.lua
        if not string.find( substr, '/') then     -- above example contains another / so skip it!
            local f = import(file)
            if f.StringsDB and type(f.StringsDB) == 'table' then
                for k, v in f.StringsDB do
                    if not table.find( stringFiles, v ) then
                        table.insert( stringFiles, v )
                    end
                end
            else
                WARN('Localization: No StringsDB variable found or it is not a table in file '..file)
            end
        end
    end

    local newdb = {}
    local db, path
    for k, file in stringFiles do
        db = {}
        path = MakeFilePath(la, file)
        if not path or not exists(path) then
            if la ~= 'US' then
                WARN('Localization: cant find strings database file '..repr(path)..' for language '..repr(la)..'. Trying US instead.')
                path = MakeFilePath('US', file)
            end
            if not path or not exists(path) then
                WARN('Localization: cant find strings database file '..repr(path)..' for language US')
            end
        end
        doscript( path, db)
        newdb = table.merged( newdb, db )
    end

    loc_table = newdb
end

-- Change the current language
function language(la)
    loadLanguage(la)
    SetPreference('options_overrides.language', __language)
end

loadLanguage(__language)

-- ===========================================================================================

-- Special tokens that can be included in a loc string via {g Player} etc. The
-- Player name gets replaced with the current selected player name.
LocGlobals = {
    PlayerName="Player",
    LBrace="{",
    RBrace="}",
    LT="<",
    GT=">"
}

-- Called from string.gsub in LocExpand() to expand a single {k v} element
local function LocSubFn(op, ident)
    if op=='i' then
        local s = loc_table[ident]
        if s then
            return LocExpand(s)
        else
            WARN('missing localization key for include: '..ident)
            return "{unknown key: "..ident.."}"
        end
    elseif op=='g' then
        local s = LocGlobals[ident]
        if iscallable(s) then
            s = s()
        end
        if s then
            return s
        else
            WARN('missing localization global: '..ident)
            return "{unknown global: "..ident.."}"
        end
    else
        WARN('unknown localization directive: '..op..':'..ident)
        return "{invalid directive: "..op.." "..ident.."}"
    end
end


-- Given some text from the loc DB, recursively apply formatting directives
function LocExpand(s)
    -- Look for braces {} in text
    return (string.gsub(s, "{(%w+) ([^{}]*)}", LocSubFn))
end


-- If s is a string with a localization tag, like "<LOC HW1234>Hello World",
-- return a localized version of it.
--
-- Note - we use [[foo]] string syntax here instead of "foo", so the localizing
-- script won't try to mess with *our* strings.
function LOC(s)
    if s == nil then
        return s
    end

    if string.sub(s,1,5) ~= [[<LOC ]] then
        -- This string doesn't have a <LOC key> tag
        return LocExpand(s)
    end

    local i = string.find(s,">")
    if not i then
        -- Missing the second half of <LOC> tag
        WARN(_TRACEBACK('String has malformed loc tag: ',s))
        return s
    end

    local key = string.sub(s,6,i-1)

    local r = loc_table[key]
    if not r then
        r = string.sub(s,i+1)
        if r=="" then
            r = key
        end
    end
    r = LocExpand(r)
    return r
end


-- Like string.format, but applies LOC() to all string args first.
function LOCF(...)
    for k,v in arg do
        if type(v)=='string' then
            arg[k] = LOC(v)
        end
    end
    return string.format(unpack(arg))
end


-- Call LOC() on all elements of a table
function LOC_ALL(t)
    r = {}
    for k,v in t do
        r[k] = LOC(v)
    end
    return r
end

