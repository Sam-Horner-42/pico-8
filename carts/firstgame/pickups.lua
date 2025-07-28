pickup={
    x=64, --xpos
    y=-1, --ypos
    spd = 1, --speed
    state = "alive",
    w = 8,
    h = 8,
    sprite_id = 9,
    bx = 0,
    by = 0,
    count = 0, 

    new=function(self,tbl)
        tbl=tbl or {}
        tbl.drift = tbl.drift or flr(rnd(1)) -- 0 or 1
        tbl.drift_amount = tbl.drift_amount or flr(rnd(1)) -- you can tweak this range
        tbl.sprite_id = tbl.sprite_id or self.sprite_id

        setmetatable(tbl, {__index=self})
        return tbl
    end,

    update=function(self)
        local sprite = self.sprite_id
        local colour = self.circ_colour
        if self.state == "alive" then
			self.y += self.spd
            if is_within_radius(player.x, player.y, self.x, self.y, 50) then
                local acceleration = 0
                if player.y < self.y then
                    acceleration = 2
                end
                --TODO fix this
                local dx = player.x - (self.x)
                local dy = player.y - (self.y - acceleration)
                local dist = sqrt(dx^2 + dy^2)
                if dist > 0 then 
                    self.x += ((dx / dist) * self.spd) * 1.2
                    self.y += ((dy / dist) * self.spd) * 1.2
                    -- draw beam effect (sprite 31 used as example)
                    local steps = flr(dist) / 10
                    self.count = dist
                    for i = 1, steps do
                        self.bx = self.x + dx / i / 2
                        self.by = self.y + dy / i / 2
                        
                    end
                    
                end
                --TODO create link between player and items
            end
		elseif self.state == "hit" then
			del(pickups, self)
		end

        
    end,

    draw = function(self)
        local clr = 10
        if self.sprite_id >= 13 then clr = 12 end
		outline_spr(self.sprite_id, self.x, self.y, 1, 1, false, false, clr)
        spr(31, self.bx, self.by, 5)
    end,
}