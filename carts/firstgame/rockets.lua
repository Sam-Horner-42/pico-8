rocket = {
    x = 0,
    y = 0,
    spd = -3,
    w = 5,
    h = 4,
    life = 30,
    state = "alive",
    spr = 10,

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, {__index = self})
        return tbl
    end,

    
    update = function(self)
        if self.state == "alive" then
            self.y += self.spd    
            if self.life > 0 then -- TODO fix explosion collisions with rockets
                self.life -= 1
            else
                explode(self.x, self.y)
                del(rockets, self)
            end 
        end
    end,
      
    draw = function(self)
        if self.state=="alive" then
            spr(self.spr,self.x,self.y)
        end
    end

}