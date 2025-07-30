projectile = {
    x = 0,
    y = 0,
    spd = -4,
    w = 8,
    h = 8,

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, {__index = self})
        return tbl
    end,

    update = function(self)
        self.y += self.spd
        if self.y > 128 then
            deli(projectiles, self)
        end
    end,

    draw = function(self)
        spr(20, self.x, self.y)
    end

}