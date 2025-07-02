laser_beam = {
    x = 0,
    y = 0,
    w = 2,
    h = 120, -- long vertical beam
    offset_x = 0,

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, {__index = self})
        return tbl
    end,

    update = function(self, player)
        self.x = player.x + self.offset_x
        self.y = (player.y+1) - self.h
    end,

    draw = function(self)
        rectfill(self.x, self.y, self.x, self.y + self.h, 8) -- bright color
    end
}
