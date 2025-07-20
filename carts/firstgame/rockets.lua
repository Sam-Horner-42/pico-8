rocket = {
    x = 0,
    y = 0,
    spd = -4,
    w = 2,
    h = 4,
    life = 20,
    state = "alive",

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, {__index = self})
        tbl.exps={}
        tbl.expclrs={5, 9, 10, 7}
        return tbl
    end,
    
    destroy = function(self)
        if self.state == "alive" then
            self.w = 20
            self.h = 20
            self.state = "hit"
            self.explosion_x = self.x
            self.explosion_y = self.y
            self:spawn_explosion(self.explosion_x, self.explosion_y)
            del(rocket, self)
        end
    end,
    
    update = function(self)
        if self.life > 0 and self.state == "alive" then
            add(thruster_particles, thruster_particle:new({
                x = self.x + 4,
                y = self.y + 7,
                dx = rnd(0.2) - 0.2,
                dy = rnd(0.5) + 0.4,
                life = 4,
                size = 2,
                smoke = false
            }))
            self.life -= 1
        elseif self.life <= 0 then
            self:destroy()
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
    spawn_explosion = function(self, x, y)
        for i=0,15 do 
            add(self.exps, {
                x=x,
                y=y,
                spdx = 1 - rnd(2),
                spdy= 2 + rnd(2),
                scale= 8 + rnd(5),
                l=3
            })
        end
    end,
    draw = function(self)
	    if self.life > 0 then
            spr(13, self.x, self.y)
        end
        pal()
        for p in all(self.exps) do
            
            circfill(p.x, p.y, p.scale, self.expclrs[p.c])
        end  
    end

}