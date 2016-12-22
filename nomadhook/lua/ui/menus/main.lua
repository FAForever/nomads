local AutoRotatingMovie = import('/lua/maui/movie.lua').AutoRotatingMovie

function CreateBackMovie(parent)
    local backMovie = AutoRotatingMovie(parent)

    local path = '/movies/'
    local Sequences = {
# TODO: replace FA stock with the a selection of movies based on last played faction. A setting should be available in the settings
# menu to change it.

        { path .. 'main_menu.sfd', },  # FA stock

#        { path .. 'FMV_SCX_Outro.sfd', },
#        { path .. 'FMV_SCX_Post_Outro.sfd', },
##        { path .. 'timeline.sfd', },
#        { path .. 'X02_Rhiza_DB01_04020.sfd', },
#        { path .. 'X04_Brackman_DB01_04024.sfd', },
#        { path .. 'X06_Seth-Iavow_M03_04500.sfd', },
#        { path .. 'X02_Princess_M02_04283.sfd', },
#        { path .. 'X03_HQ_M02_03283.sfd', },
#        { path .. 'X1T_Fletcher_TU04_05004.sfd', },
#        { path .. 'X05_Hex5_M01_03789.sfd', },
#        { path .. 'X03_Kael_M02_03313.sfd', },
#        { path .. 'X02_Mathea_M02_03159.sfd', },
#        { path .. 'X04_Dostya_M02_04014.sfd', },
#        { path .. 'X05_Amalia_M03_04055.sfd', },
#        { path .. 'X01_Graham_M02_04003.sfd', },
#        { path .. 'X05_Brackman_B01_04026.sfd', },    
    }

    for k, v in Sequences do
        backMovie:LoadSequence( v )
    end
    backMovie:Play()

    LayoutHelpers.AtCenterIn(backMovie, parent)
    backMovie.Height:Set(parent.Height)
    backMovie.Width:Set(function()
        local ratio = parent.Height() / 1024
        return 1824 * ratio
    end)
    return backMovie
end
