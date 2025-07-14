thruster_particle = {
    x = 0, 
    y = 0,
    dx = 0, 
    dy = 0,
    life = 10, -- how long it lives
    clr = 12,
    size = 2,
    smoke = false,

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, { __index = self })
        return tbl
    end,

    update = function(self)
        if self.smoke == false then
            if self.life >= 6 then
                self.clr = 12
            else  
                self.clr = 7
            end
            
            if btn(1) and not btn(2) then self.life -= 1 end -- right, prevents weird tail
            if btn(0) and not btn(2) then self.life -= 1 end -- left, prevents weird tail
        elseif self.smoke == true then
            if self.life >= 4 then
                self.clr = 6
            else 
                self.clr = 7
            end
        end
        self.life -= 1
        
        if self.size <= 4 and self.size >= 2 then
            self.size -= 1
        end
        self.x += self.dx
        self.y += self.dy
        
        
        
       
    end,

    draw = function(self)
        if self.life > 0 then
            circfill(self.x, self.y, self.size, self.clr)
        end
    end
}
