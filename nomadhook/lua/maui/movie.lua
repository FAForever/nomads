AutoRotatingMovie = Class(Movie) {

    sequence = {},
    curSeq = -1,
    curSeqKey = -1,

    LoadSequence = function(self, seq, replace)
        # puts a new movie sequence in the sequence list. if replace is true then the old sequence list is deleted first
        if replace then
            self.sequence = {}
        end
        table.insert( self.sequence, seq )
    end,

    GetNextMovieFile = function(self)
        self.curSeqKey = self.curSeqKey + 1
        if not self.sequence[ self.curSeq ] or not self.sequence[ self.curSeq ][ self.curSeqKey ] then
            local oldKey = self.curSeq
            local i = 20
            while oldKey == self.curSeq and i > 0 do
                self.curSeq = Random( 1, table.getn( self.sequence ) )
                i = i - 1
            end
            self.curSeqKey = 1
        end
        return self.sequence[ self.curSeq ][ self.curSeqKey ]
    end,

    Play = function(self)
        local next = self:GetNextMovieFile()
        Movie.Set(self, next)
        Movie.Play(self)
    end,

    OnFinished = function(self)
        self:Play()
    end,

    OnDestroy = function(self)
        self.sequence = nil
        Movie.OnDestroy(self)
    end,
}
