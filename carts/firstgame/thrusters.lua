thruster_particle = {
    x = 0, 
    y = 0,
    dx = 0, 
    dy = 0,
    life = 10, -- how long it lives
    clr = 10,
    size = 0.5,

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, { __index = self })
        return tbl
    end,

    update = function(self)
        self.x += self.dx
        self.y += self.dy
        self.life -= 1
    end,

    draw = function(self)
        if self.life > 0 then
            circfill(self.x, self.y, self.size, self.clr)
        end
    end
}
