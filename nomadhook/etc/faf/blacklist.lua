-- A set of mod uids we don't approve of, and explanations for why we don't like them.

local INCOMPATIBLE = "<LOC uimod_0021>Incompatible with current FAF"
local UPGRADE = "<LOC uimod_0022>Please update to newest version"
local INTEGRATED = "<LOC uimod_0023>Integrated with FAF"
local BROKEN = "<LOC uimod_0024>Broken"
local OBSOLETE = "<LOC uimod_0025>Obsolete"
local HARMFUL = "<LOC uimod_0026>Considered harmful"

-- We add a couple of special nomads specific entries here:
local Nomads = "An old and outdated version of Nomads thats broken."
local IncompatibleWithNomads = "Incompatible with the Nomads mod, causing things to break."

Blacklist['50423624-1e83-4fc2-85b3-nomadsv00074'] = Nomads