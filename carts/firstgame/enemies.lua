
enemy={
    x = 64, --xpos
    y = -1, --ypos
    spd = 1, --speed
    state = "alive",
    w = 8,
    h = 8,
    explosion_timer = 5,
    health = 3,
    sprite_id = 4,
    hit_effect_timer=0,
    

    new=function(self,tbl)
        tbl=tbl or {}
        tbl.drift = tbl.drift or flr(rnd(2)) -- whether the asteroid drifts (0 or 1)
        tbl.drift_amount = tbl.drift_amount or flr(rnd(2)) -- how much the asteroids drift
        tbl.sprite_id = tbl.sprite_id or self.sprite_id
        setmetatable(tbl, {__index=self})
        return tbl
    end,
    
    
    update=function(self)
        if self.state == "alive" then
			self.y += self.spd
            if self.drift == 0 then
                self.x += self.drift_amount
            elseif self.drift == 1 then
                self.x -= self.drift_amount
            end

		elseif self.state == "hit" then
			self.explosion_timer -= 1
			if self.explosion_timer <= 2 then
				self.state = "exploded"
			end

		elseif self.state == "exploded" then
			self.explosion_timer -= 1
			if self.explosion_timer <= 0 then
				del(gameplay.enemies, self)   
			end
		end
        if self.hit_effect_timer > 0 then
            self.hit_effect_timer -= 1
        end
    end,

    draw=function(self)
        local sprite = self.sprite_id
        
        if self.state == "hit" then
            sprite += 1 -- partially exploded
        elseif self.state == "exploded" then
            sprite += 1
        end
        spr(sprite, self.x, self.y) -- normal asteroid sprite
       
        if is_within_radius(gameplay.player.x, gameplay.player.y, self.x, self.y, 40) and self.state == "alive" then
            local outline_clr = 8
            if self.hit_effect_timer > 0 then
                outline_clr = 7
            end
            outline_spr(sprite, self.x, self.y, 1, 1, false, false, outline_clr)
        end
    end,
}


