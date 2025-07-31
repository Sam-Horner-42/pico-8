
enemy={
    x = 64, --xpos
    y = -1, --ypos
    spd = 1, --speed
    state = "alive",
    w = 7,
    h = 7,
    explosion_timer = 0,
    health = 4,
    sprite = 4,
    hit_effect_timer = 0,
    is_hit = false,
    clr = 8,
    pickup_chance = 0,
    trailx = 0, 
    traily = 0,
    trail_rad = 4,
    trail_clr = 6,
    

    new=function(self,tbl)
        tbl=tbl or {}
        tbl.drift = tbl.drift or flr(rnd(2)) -- whether the asteroid drifts (0 or 1)
        tbl.drift_amount = tbl.drift_amount or flr(rnd(2)) -- how much the asteroids drift
        tbl.sprite = tbl.sprite or self.sprite
        setmetatable(tbl, {__index=self})
        return tbl
    end,
    
    
    update=function(self)
        self.y += self.spd -- only move if alive
        
        if self.drift == 0 then
            self.x += self.drift_amount
            if self.x > 128 then
                del(enemies, self) --delete enemies
            end
        elseif self.drift == 1 then
            self.x -= self.drift_amount
            if self.x < 0 then
                del(enemies, self) --delete enemies
            end
        end
        if self.y > 128 then
            del(enemies, self) --delete enemies
        end
        
        if self.clr > 6 then
            self.clr -= 1
        else 
            self.clr = 8 
        end
        if self.state == "alive" then
            
		elseif self.state == "hit" then
            if self.health <= 0 then 
                if self.explosion_timer == 0 then
                    self.explosion_timer = 15 
                end
                
                self.spd = -0.5
                self.drift = 3
                self.sprite = 5
                self.state = "exploded"
            elseif self.hit_effect_timer == 0 then
                self.hit_effect_timer = 15
                self.state = "alive"
            end
            
		elseif self.state == "exploded" then
            if self.explosion_timer == 0 then
                self.pickup_chance = flr(rnd(1000))
            
            self.spite = 6
                if self.pickup_chance == 1 then
                    add(pickups, pickup:new({
                        x = self.x,
                        y = self.y,
                        sprite_id = 13,
                        }))
                elseif self.pickup_chance <= 4 then
                    add(pickups, pickup:new({
                        x = self.x,
                        y = self.y,
                        sprite_id = 14,
                        }))
                elseif self.pickup_chance <= 10 then
                    add(pickups, pickup:new({
                        x = self.x,
                        y = self.y,
                        sprite_id = 15,
                        }))
                end
				del(enemies, self)   
			end
		end
        
        
        if self.explosion_timer > 0 then
            self.explosion_timer -= 1
        end
        if self.hit_effect_timer > 0 then
            self.hit_effect_timer -= 1
        else
            self.is_hit = false
        end
        
        if self.hit_effect_timer > 0 and self.hit_effect_timer < 8 then
            self.clr = 7
        else 
            self.clr = 8 
        end
        
    end,

    draw=function(self)
        if self.hit_effect_timer > 0 then
            circfill(self.x+3, self.y+3, 4, self.clr)
        else 
            spr(self.sprite, self.x, self.y) -- normal asteroid sprite
        end
    end,
}


