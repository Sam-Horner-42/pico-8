
enemy={
    x = 64, --xpos
    y = -1, --ypos
    spd = 3 + flr(rnd(1)), --speed
    state = "alive",
    w = 8,
    h = 8,
    explosion_timer = 5,
    health = 1,
    sprite_id = 4,
    

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
    end,

    draw=function(self)
        local sprite = self.sprite_id
        if self.state == "alive" then
			spr(sprite, self.x, self.y) -- normal asteroid sprite
		elseif self.state == "hit" then
			spr(sprite+1, self.x, self.y) -- partially exploded
		elseif self.state == "exploded" then
			spr(sprite+2, self.x, self.y) -- fully exploded
		end
    end,
}


