rocket = {
    x = 0,
    y = 0,
    spd = -3,
    w = 2,
    h = 4,
    life = 20,

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, {__index = self})
        tbl.exps={}
        tbl.expclrs={5, 9, 10, 7}
        return tbl
    end,
    
    
    
    update = function(self)
        

        if self.life > 0 then
            self.life -= 1
            add(thruster_particles, thruster_particle:new({
                x = self.x + 4,
                y = self.y + 7,
                dx = rnd(0.2) - 0.2,
                dy = rnd(0.5) + 0.4,
                life = 4,
                size = 3,
                smoke = false
            }))
        elseif self.life == 0 then
           self.h = 20
           self.w = 20 
           for i=0,20 do 
                add(self.exps,{
                    x=self.x,
                    y=self.y,
                    spdx=2-rnd(4),
                    spdy=2-rnd(5),
                    scale=8+rnd(5),
                    l=3
                })
            end
            self.life -= 1
        end
        for p in all(self.exps) do
            p.x+=p.spdx
            p.y+=p.spdy
            p.scale-=.1
            p.l-=.1
            p.c=flr(p.l)
            if p.l <= 0 then del(self.exps,p) end
        end
        self.y += self.spd
        
    end,

    draw = function(self)
	    if self.life > 0 then
            spr(13, self.x, self.y)
        end
        
        for p in all(self.exps) do
            circfill(p.x, p.y, p.scale, self.expclrs[p.c])   
        end  
    end

}