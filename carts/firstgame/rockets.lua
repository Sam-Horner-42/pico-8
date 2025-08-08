rocket = {
    x = 0,
    y = 0,
    spd = -3,
    w = 5,
    h = 4,
    life = 30,
    state = "alive",
    exp_start=64,          -- first explosion sprite id
    exp_len=5,             -- number of explosion frames (5)
    exp_i=0,               -- current explosion frame index

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, {__index = self})
        return tbl
    end,
    destroy=function(self)
        if self.state=="alive" then
            self.state="exploded"
            self.exp_i=0
        end
    end,
    
    update = function(self, i)
        if self.state == "alive" then
            self.y += self.spd    
            if self.life > 0 then -- TODO fix explosion collisions with rockets
                self.life -= 1
            else
            -- auto explode when life runs out
            self:destroy()
        end
            return    
        end
       -- state: exploded → advance one sprite per frame
        self.exp_i+=1
        if self.exp_i>=self.exp_len then
            -- finished the 5 frames: remove the rocket
            deli(rockets, i)
            return
        end
    end,
      
    draw = function(self)
	    if self.state=="alive" and self.life>0 then
            spr(10,self.x,self.y)
        else
            -- show current explosion frame
            spr(self.exp_start + min(self.exp_i, self.exp_len-1), self.x, self.y)
        end
        
    end

}