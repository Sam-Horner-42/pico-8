rocket = {
    x = 0,
    y = 0,
    spd = -3,
    w = 2,
    h = 4,

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, {__index = self})
        return tbl
    end,

    update = function(self)
        self.y += self.spd
        add(thruster_particles, thruster_particle:new({
                x = self.x + 3,
                y = self.y + 7,
                dx = rnd(0.2) - 0.2,
                dy = rnd(0.5) + 0.4,
                life = 3,
                size = 2,
                smoke = false
            }))
    end,

    draw = function(self)
	    spr(13, self.x, self.y)
    end

}