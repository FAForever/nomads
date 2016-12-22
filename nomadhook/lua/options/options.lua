do


table.insert( options.sound.items,

            {
                title = "<LOC NomadsNewOptions0001>Unit selection sounds",
                key = 'unitsnd_selection',
                type = 'toggle',
                default = 'simple',
                custom = {
                    states = {
                        { text = "<LOC NomadsNewOptions0002>", key = 'none' },
                        { text = "<LOC NomadsNewOptions0003>", key = 'simple' },
                        { text = "<LOC NomadsNewOptions0004>", key = 'full' },
                    },
                },
            }
)


table.insert( options.sound.items,

            {
                title = "<LOC NomadsNewOptions0011>Unit command acknowledge sounds",
                key = 'unitsnd_acknowledge',
                type = 'toggle',
                default = 'none',
                custom = {
                    states = {
                        { text = "<LOC NomadsNewOptions0012>", key = 'none' },
                        { text = "<LOC NomadsNewOptions0013>", key = 'simple' },
                        { text = "<LOC NomadsNewOptions0014>", key = 'full' },
                    },
                },
            }
)


end
