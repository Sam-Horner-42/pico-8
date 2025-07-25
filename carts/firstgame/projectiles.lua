projectile = {
    x = 0,
    y = 0,
    spd = -3,
    w = 8,
    h = 8,

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, {__index = self})
        return tbl
    end,

    update = function(self)
        self.y += self.spd
    end,

    draw = function(self)
	    --rectfill(self.x, self.y+6, self.x, self.y, 8) -- red bullet, length 2
        spr(20, self.x, self.y)
    end

}