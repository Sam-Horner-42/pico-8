projectile = {
    x = 0,
    y = 0,
    spd = -5,
    w = 2,
    h = 4,

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, {__index = self})
        return tbl
    end,

    update = function(self)
        self.y += self.spd
    end,

    draw = function(self)
        -- simple small bullet
	    rectfill(self.x, self.y+6, self.x, self.y, 8) -- red bullet, length 2
    end

}