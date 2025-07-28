thruster_particle = {
    x = 0, 
    y = 0,
    dx = 0, 
    dy = 0,
    life = 10, -- how long it lives
    clr = 12,
    size = 3,
    smoke = false,

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, { __index = self })
        return tbl
    end,

    update = function(self)
        if self.smoke == false then
            if self.size <= 4 and self.size >= 2 then
                self.size -= 1
            end
            if btn(1) and not btn(2) then -- right, prevents weird tail
                self.life -= 2
                self.dy += .4
            end 
            if btn(0) and not btn(2) then -- left, prevents weird tail
                self.life -= 2 
                self.dy += .4
            end 
            if btn(3) then self.life -= 1 end
        elseif self.smoke == true then
            if self.size <= 4 and self.size >= 1 and self.life < 2 then
                self.size -= 1
            end
            if self.life >= 4 then
                self.clr = 6
            else 
                self.clr = 7
            end
        end
        if self.life <= 0 then
            del(thruster_particles, self)
        end
        self.life -= 1
        
        self.x += self.dx
        if rnd(1) > 0.03 then
            self.y += self.dy
        end
    end,

    draw = function(self)
        if self.life > 0 then
            circfill(self.x, self.y, self.size, self.clr)
        end
    end
}
