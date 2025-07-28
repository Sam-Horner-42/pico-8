
enemy={
    x = 64, --xpos
    y = -1, --ypos
    spd = 1, --speed
    state = "alive",
    w = 7,
    h = 7,
    explosion_timer = 0,
    health = 2,
    sprite = 4,
    hit_effect_timer = 0,
    is_hit = false,
    clr = 8,
    pickup_chance = 0,
    

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
        elseif self.drift == 1 then
            self.x -= self.drift_amount
        end
        if self.state == "alive" then
            
		elseif self.state == "hit" then
            if self.health <= 0 then 
                if self.explosion_timer == 0 then
                    self.explosion_timer = 15 
                end
                popup_x = enemy.x
                popup_y = enemy.y - 8
                popup_timer = game_start_timer
                self.spd = -0.5
                self.drift = 3
                self.sprite = 5
                self.state = "exploded"
            elseif self.hit_effect_timer == 0 then
                self.hit_effect_timer = 20
                self.state = "alive"
            end
            if hit_sound_cooldown == 0 then
                sfx(1, 2)
                hit_sound_cooldown = 5
            end
		elseif self.state == "exploded" then
            self.pickup_chance = flr(rnd(200))
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
			if self.explosion_timer == 0 then
                
				del(enemies, self)   
			end
		end
        if self.y > 128 then
            del(enemies, self) --delete enemies
        end
        if self.explosion_timer > 0 then
            self.explosion_timer -= 1
        end
        if self.hit_effect_timer > 0 then
            self.hit_effect_timer -= 1
        else
            self.is_hit = false
        end
        if self.hit_effect_timer > 0 and self.hit_effect_timer < 7 then
            self.clr = 7
        end
        
    end,

    draw=function(self)
        spr(self.sprite, self.x, self.y) -- normal asteroid sprite
        if self.state == "hit" then
            outline_spr(self.sprite, self.x, self.y, 1, 1, false, false, self.clr)
        end
    end,
}


