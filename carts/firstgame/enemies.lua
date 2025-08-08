
enemy={
    x = 64, y = -1, -- position
    spd = 1, --speed
    
    w = 7, h = 7,

    -- state and visuals
    state = "alive", -- "alive" | "hit" | "exploded"
    explosion_timer = 0,
    health = 4,
    sprite = 4,
    hit_effect_timer = 0,
    clr = 8,
    pickup_chance = 0,
    
    new=function(self,tbl)
        tbl=tbl or {}
        tbl.drift = tbl.drift or flr(rnd(2)) -- whether the asteroid drifts (0 or 1)
        tbl.drift_amount = tbl.drift_amount or flr(rnd(1)) -- how much the asteroids drift
        tbl.sprite = tbl.sprite or self.sprite
        setmetatable(tbl, {__index=self})
        return tbl
    end,
    
    
    update=function(self)
        self.y += self.spd 
        
        if self.drift == 0 then
            self.x += self.drift_amount
            if self.x > 128 then del(enemies, self) end --delete enemies
        elseif self.drift == 1 then
            self.x -= self.drift_amount
            if self.x < 20 then del(enemies, self) end --delete enemies
        end
        if self.y > 128 then del(enemies, self) end --delete enemies
        
        if self.clr > 6 then
            self.clr -= 1
        else 
            self.clr = 8 
        end

        -- state machine
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
                self.hit_effect_timer = 10
                self.state = "alive"
            end
            
		elseif self.state == "exploded" then
            if self.explosion_timer == 0 then
                -- final frame: maybe drop a pickup and remove self
                local r = flr(rnd(100))
                self.sprite = 6
                if     r == 1  then add(pickups, pickup:new({x=self.x, y=self.y, sprite_id=13}))
                elseif r <= 4  then add(pickups, pickup:new({x=self.x, y=self.y, sprite_id=14}))
                elseif r <= 10 then add(pickups, pickup:new({x=self.x, y=self.y, sprite_id=15}))
                end
                del(enemies, self)
                return  
			end
		end
        
        self.explosion_timer = decrement_timer(self.explosion_timer)
        self.hit_effect_timer = decrement_timer(self.hit_effect_timer)
        if self.hit_effect_timer <= 0 then
            self.is_hit = false
        else
            if self.hit_effect_timer < 3 then
                self.clr = 7
            else 
                self.clr = 8 
            end
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


