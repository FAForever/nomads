local Version = 'Nomads 115'

---@return PATCH
---@return string # game type
---@return string # commit hash
function GetVersionData()
    return Version, GameType, Commit
end