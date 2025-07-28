pickup={
    x=64, --xpos
    y=-1, --ypos
    spd = 1, --speed
    state = "alive",
    w = 8,
    h = 8,
    sprite_id = 9,

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
                end
                --TODO create link between player and items
            end
		elseif self.state == "hit" then
			del(pickups, self)
		end

        
    end,

    draw = function(self)
		outline_spr(self.sprite_id, self.x, self.y, 1, 1, false, false, 12)
    end,
}