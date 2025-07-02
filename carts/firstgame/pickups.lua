pickup={
    x=64, --xpos
    y=-1, --ypos
    spd = 1 + flr(rnd(1)), --speed
    state = "alive",
    w = 8,
    h = 8,
    sprite_id = 9,
    circ_colour = 8,

    new=function(self,tbl)
        tbl=tbl or {}
        tbl.drift = tbl.drift or flr(rnd(1)) -- 0 or 1
        tbl.drift_amount = tbl.drift_amount or flr(rnd(1)) -- you can tweak this range
        tbl.sprite_id = tbl.sprite_id or self.sprite_id
        setmetatable(tbl, {__index=self})
        return tbl
    end,

    update=function(self)
        if self.state == "alive" then
			self.y += self.spd
            if self.drift == 0 then
                self.x += self.drift_amount
                self.y += self.drift_amount
            elseif self.drift == 1 then
                self.x -= self.drift_amount
                self.y -= self.drift_amount
            end
		elseif self.state == "hit" then
			del(gameplay.pickups, self)
		end
    end,

    draw = function(self)
        local sprite = self.sprite_id
		spr(sprite, self.x, self.y)
    end,
}